// examples/chat-app/src/index.js
import { createApp } from '@cramp/core';

const app = createApp({
  apiKey: process.env.OPENAI_API_KEY,
  mountPoint: '#app'
});

// Chat component
app.component('ai-chat', `
  <div class="chat-container">
    <div class="messages" x-ref="messages">
      <template x-for="message in messages">
        <div class="message" x-class="message.role">
          <div class="avatar">{{ message.role === 'user' ? '👤' : '🤖' }}</div>
          <div class="content">{{ message.content }}</div>
        </div>
      </template>
    </div>
    
    <div class="input-area">
      <textarea 
        x-bind="prompt"
        placeholder="Ask anything..."
        x-on:keydown.enter.prevent="sendMessage"
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
    isProcessing: false
  },

  async sendMessage() {
    if (!this.state.prompt.trim()) return;

    const userMessage = {
      role: 'user',
      content: this.state.prompt
    };

    this.setState({
      messages: [...this.state.messages, userMessage],
      isProcessing: true,
      prompt: ''
    });

    try {
      const response = await this.app.ai.process(userMessage.content);

      const aiMessage = {
        role: 'assistant',
        content: response
      };

      this.setState({
        messages: [...this.state.messages, aiMessage]
      });

      // Scroll to bottom
      this.$refs.messages.scrollTop = this.$refs.messages.scrollHeight;
    } catch (error) {
      console.error('Chat error:', error);
      this.setState({
        messages: [...this.state.messages, {
          role: 'error',
          content: 'Sorry, something went wrong. Please try again.'
        }]
      });
    } finally {
      this.setState({ isProcessing: false });
    }
  }
});

// Styles
const styles = `
  .chat-container {
    display: flex;
    flex-direction: column;
    height: 100vh;
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
  }

  .messages {
    flex: 1;
    overflow-y: auto;
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  .message {
    display: flex;
    gap: 10px;
    padding: 10px;
    border-radius: 8px;
    animation: fadeIn 0.3s ease-out;
  }

  .message.user {
    background: #e3f2fd;
    margin-left: 20%;
  }

  .message.assistant {
    background: #f5f5f5;
    margin-right: 20%;
  }

  .message.error {
    background: #ffebee;
    color: #c62828;
    margin: 0 20%;
  }

  .avatar {
    font-size: 24px;
  }

  .input-area {
    display: flex;
    gap: 10px;
    padding: 20px;
    background: white;
    border-top: 1px solid #eee;
  }

  textarea {
    flex: 1;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
    resize: none;
    height: 60px;
  }

  button {
    padding: 0 20px;
    background: #2196f3;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: background 0.2s;
  }

  button:hover {
    background: #1976d2;
  }

  button:disabled {
    background: #bdbdbd;
    cursor: not-allowed;
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }
`;

// Add styles
const styleElement = document.createElement('style');
styleElement.textContent = styles;
document.head.appendChild(styleElement);

// Mount app
app.mount();