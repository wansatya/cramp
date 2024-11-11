// packages/core/src/router.js
export class Router {
  constructor() {
    this.routes = new Map();
    this.currentComponent = null;

    // Handle browser navigation
    window.addEventListener('popstate', () => this.handleRoute());

    // Handle link clicks
    document.addEventListener('click', (e) => {
      const link = e.target.closest('[data-link]');
      if (link) {
        e.preventDefault();
        this.navigate(link.getAttribute('href'));
      }
    });
  }

  addRoute(path, component) {
    this.routes.set(path, component);
    return this;
  }

  async navigate(path) {
    window.history.pushState({}, '', path);
    await this.handleRoute();
  }

  async handleRoute() {
    const path = window.location.pathname;
    const Component = this.routes.get(path) || this.routes.get('*');

    if (Component) {
      const root = document.querySelector('main');
      if (root) {
        const componentName = `cramp-page-${path.replace(/\//g, '-') || 'home'}`;
        const app = cramp.create();
        app.component(componentName, Component);
        root.innerHTML = `<${componentName}></${componentName}>`;
      }
    }
  }

  init() {
    this.handleRoute();
  }
}

// Create Link component
export const Link = {
  template: `
      <a 
          href="{{ to }}" 
          data-link 
          class="{{ class }}"
          onclick="this.getRootNode().host.handleClick(event)"
      >
          <slot></slot>
      </a>
  `,

  state: {
    to: '/',
    class: ''
  },

  handleClick(event) {
    event.preventDefault();
    this.navigate(this.state.to);
  },

  navigate(to) {
    window.dispatchEvent(new CustomEvent('cramp:navigate', {
      detail: { to }
    }));
  }
};

// Create single router instance
export const router = new Router();