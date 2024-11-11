// examples/full-featured/src/index.js
import { createApp } from '@cramp/core';

const app = createApp({
  apiKey: process.env.OPENAI_API_KEY,
  mountPoint: '#app'
});

// Components
app.component('nav-bar', `
  <nav class="nav-bar">
    <div class="brand">🦀 CRAMP</div>
    <div class="links">
      <a href="/" route>Home</a>
      <a href="/chat" route>Chat</a>
      <a href="/image" route>Image</a>
      <a href="/settings" route>Settings</a>
    </div>
    <div class="user" x-if="user">
      <img :src="user.avatar" alt="avatar">
      <span>{{ user.name }}</span>
    </div>
  </nav>
`);

app.component('ai-chat', `
  <div class="ai-chat">
    <div class="messages" x-ref="messages">
      <template x-for="message in messages">
        <div class="message" x-class="message.role">
          <div class="avatar">{{ message.role === 'user' ? '👤' : '🤖' }}</div>
          <div class="content">
            <div class="text">{{ message.content }}</div>
            <div class="time">{{ formatTime(message.timestamp) }}</div>
          </div>
        </div>
      </template>
    </div>
    
    <div class="input-area">
      <div class="tools">
        <button x-on:click="clearChat">Clear</button>
        <button x-on:click="toggleMode">{{ mode }}</button>
      </div>
      <textarea 
        x-bind="prompt"
        placeholder="Ask anything..."
        x-on:keydown.enter.prevent="sendMessage"
        x-on:keydown.meta.enter="sendMessage"
      ></textarea>
      <button 
        x-on:click="sendMessage"
        x-bind:disabled="isProcessing"
      >
        {{ isProcessing ? 'Thinking...' : 'Send' }}
      </button>
    </div>
  </div>
`, {
  state: {
    messages: [],
    prompt: '',
    isProcessing: false,
    mode: 'chat' // chat or stream
  },

  async sendMessage() {
    if (!this.state.prompt.trim()) return;

    const message = {
      role: 'user',
      content: this.state.prompt,
      timestamp: Date.now()
    };

    this.setState({
      messages: [...this.state.messages, message],
      isProcessing: true,
      prompt: ''
    });

    try {
      if (this.state.mode === 'stream') {
        await this.streamResponse(message.content);
      } else {
        await this.chatResponse(message.content);
      }
    } catch (error) {
      console.error('Chat error:', error);
      this.addErrorMessage();
    } finally {
      this.setState({ isProcessing: false });
    }
  },

  async chatResponse(prompt) {
    const response = await this.app.ai.process(prompt);
    this.addAIMessage(response);
  },

  async streamResponse(prompt) {
    let content = '';
    const messageId = Date.now();

    // Add initial AI message
    this.setState({
      messages: [...this.state.messages, {
        id: messageId,
        role: 'assistant',
        content: '',
        timestamp: Date.now()
      }]
    });

    await this.app.ai.processStream(prompt, {}, (chunk) => {
      content += chunk;

      // Update the streaming message
      this.setState({
        messages: this.state.messages.map(m =>
          m.id === messageId
            ? { ...m, content }
            : m
        )
      });
    });
  },

  addAIMessage(content) {
    this.setState({
      messages: [...this.state.messages, {
        role: 'assistant',
        content,
        timestamp: Date.now()
      }]
    });
    this.scrollToBottom();
  },

  addErrorMessage() {
    this.setState({
      messages: [...this.state.messages, {
        role: 'error',
        content: 'Sorry, something went wrong. Please try again.',
        timestamp: Date.now()
      }]
    });
  },

  clearChat() {
    this.setState({ messages: [] });
  },

  toggleMode() {
    this.setState({
      mode: this.state.mode === 'chat' ? 'stream' : 'chat'
    });
  },

  scrollToBottom() {
    this.$refs.messages.scrollTop = this.$refs.messages.scrollHeight;
  },

  formatTime(timestamp) {
    return new Date(timestamp).toLocaleTimeString();
  }
});

// Routes
app.router
  .add('/', {
    template: `
      <div class="home">
        <nav-bar></nav-bar>
        <div class="hero">
          <h1>Welcome to CRAMP</h1>
          <p>The Creative Rapid AI Modern Platform</p>
        </div>
        <div class="features">
          <div class="feature">
            <h3>🚀 Fast</h3>
            <p>Built for speed and efficiency</p>
          </div>
          <div class="feature">
            <h3>🤖 AI-First</h3>
            <p>Integrated AI capabilities</p>
          </div>
          <div class="feature">
            <h3>📦 Simple</h3>
            <p>Easy to learn and use</p>
          </div>
        </div>
      </div>
    `
  })
  .add('/chat', {
    template: `
      <div class="chat-page">
        <nav-bar></nav-bar>
        <ai-chat></ai-chat>
      </div>
    `
  })
  .add('/settings', {
    template: `
      <div class="settings">
        <nav-bar></nav-bar>
        <h2>Settings</h2>
        <div class="settings-form">
          <label>
            API Key
            <input type="password" x-bind="apiKey">
          </label>
          <label>
            Model
            <select x-bind="model">
              <option value="gpt-3.5-turbo">GPT-3.5 Turbo</option>
              <option value="gpt-4">GPT-4</option>
            </select>
          </label>
          <button x-on:click="saveSettings">Save</button>
        </div>
      </div>
    `
  });

// Mount app
app.mount();