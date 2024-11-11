// packages/core/src/index.js
import { Router } from './router';
import { Component } from './component';
import { AI } from './ai';

class Cramp {
  constructor(config = {}) {
    this.config = {
      apiKey: config.apiKey,
      mountPoint: config.mountPoint || '#app',
      baseUrl: config.baseUrl || 'https://api.openai.com/v1',
      model: config.model || 'gpt-3.5-turbo',
      ...config
    };

    this.router = new Router(this);
    this.components = new Map();
    this.ai = new AI(this.config);
  }

  async mount() {
    const root = document.querySelector(this.config.mountPoint);
    if (!root) throw new Error(`Mount point ${this.config.mountPoint} not found`);

    // Add default styles
    this.addDefaultStyles();

    // Initialize router
    this.router.init();

    return this;
  }

  component(name, template, methods = {}) {
    const component = new Component(name, template, methods, this);
    this.components.set(name, component);
    return component;
  }

  addDefaultStyles() {
    const styles = document.createElement('style');
    styles.textContent = `
      [x-cloak] { display: none !important; }
      .cramp-loading { opacity: 0.7; }
      .cramp-error { color: #dc3545; }
    `;
    document.head.appendChild(styles);
  }
}

export function createApp(config) {
  return new Cramp(config);
}

export { Router, Component, AI };