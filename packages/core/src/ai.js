// packages/core/src/ai.js
export class AI {
  constructor(config) {
    this.config = config;
    this.queue = [];
    this.processing = false;
  }

  async process(prompt, options = {}) {
    try {
      const response = await fetch(`${this.config.baseUrl}/chat/completions`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.config.apiKey}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          model: this.config.model,
          messages: [{ role: 'user', content: prompt }],
          ...options
        })
      });

      if (!response.ok) {
        throw new Error('AI request failed');
      }

      const data = await response.json();
      return data.choices[0].message.content;
    } catch (error) {
      throw new Error(`AI Processing Error: ${error.message}`);
    }
  }

  async processStream(prompt, options = {}, onChunk) {
    try {
      const response = await fetch(`${this.config.baseUrl}/chat/completions`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.config.apiKey}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          model: this.config.model,
          messages: [{ role: 'user', content: prompt }],
          stream: true,
          ...options
        })
      });

      if (!response.ok) throw new Error('AI request failed');

      const reader = response.body.getReader();
      const decoder = new TextDecoder();

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value);
        const lines = chunk.split('\n').filter(line => line.trim() !== '');

        for (const line of lines) {
          if (line.includes('[DONE]')) return;

          try {
            const json = JSON.parse(line.replace('data: ', ''));
            const content = json.choices[0].delta.content;
            if (content) onChunk(content);
          } catch (e) {
            console.warn('Failed to parse chunk:', e);
          }
        }
      }
    } catch (error) {
      throw new Error(`AI Streaming Error: ${error.message}`);
    }
  }

  // Rate limiting and queueing
  async enqueue(prompt, options = {}) {
    return new Promise((resolve, reject) => {
      this.queue.push({ prompt, options, resolve, reject });
      this.processQueue();
    });
  }

  async processQueue() {
    if (this.processing || this.queue.length === 0) return;

    this.processing = true;
    const { prompt, options, resolve, reject } = this.queue.shift();

    try {
      const result = await this.process(prompt, options);
      resolve(result);
    } catch (error) {
      reject(error);
    } finally {
      this.processing = false;
      this.processQueue();
    }
  }
}