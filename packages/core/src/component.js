// packages/core/src/component.js
export class Component {
  constructor(name, template, methods = {}, app) {
    this.name = name;
    this.template = template;
    this.methods = methods;
    this.app = app;
    this.state = {};
    this.refs = new Map();

    this.setupComponent();
  }

  setupComponent() {
    // Create custom element
    if (!customElements.get(`cramp-${this.name}`)) {
      customElements.define(`cramp-${this.name}`, class extends HTMLElement {
        connectedCallback() {
          this.component = new Component(
            this.getAttribute('name'),
            this.innerHTML,
            {},
            this.app
          );
          this.component.mount(this);
        }
      });
    }

    // Bind methods
    Object.entries(this.methods).forEach(([key, method]) => {
      this[key] = method.bind(this);
    });
  }

  setState(newState) {
    this.state = { ...this.state, ...newState };
    this.update();
  }

  async mount(element) {
    this.element = element;
    await this.render();
    this.setupEventListeners();
  }

  setupEventListeners() {
    this.element.querySelectorAll('[x-on]').forEach(el => {
      const [event, method] = el.getAttribute('x-on').split(':');
      el.addEventListener(event, (e) => this[method](e));
    });
  }

  async render() {
    if (!this.template) return;

    const html = await this.processTemplate();
    if (this.element) {
      this.element.innerHTML = html;
    }
    return this.createElementFromHTML(html);
  }

  async processTemplate() {
    let html = this.template;

    // Process state bindings
    html = html.replace(/\{\{(.*?)\}\}/g, (_, key) => {
      const value = key.trim().split('.').reduce((obj, k) => obj[k], this.state);
      return value ?? '';
    });

    return html;
  }

  createElementFromHTML(html) {
    const div = document.createElement('div');
    div.innerHTML = html.trim();
    return div.firstChild;
  }

  async update() {
    await this.render();
    this.setupEventListeners();
  }

  $(selector) {
    return this.element.querySelector(selector);
  }

  $$(selector) {
    return this.element.querySelectorAll(selector);
  }
}