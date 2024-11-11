// packages/core/src/router.js
export class Router {
  constructor(app) {
    this.app = app;
    this.routes = new Map();
    this.currentRoute = null;

    // Handle browser navigation
    window.addEventListener('popstate', () => this.handleRoute());
    this.setupClickHandler();
  }

  setupClickHandler() {
    document.addEventListener('click', (e) => {
      const link = e.target.closest('[route]');
      if (link) {
        e.preventDefault();
        this.navigate(link.getAttribute('href'));
      }
    });
  }

  add(path, component) {
    this.routes.set(path, component);
    return this;
  }

  async navigate(path) {
    window.history.pushState({}, '', path);
    await this.handleRoute();
  }

  async handleRoute() {
    const path = window.location.pathname;
    const component = this.routes.get(path) || this.routes.get('*');

    if (component) {
      const root = document.querySelector(this.app.config.mountPoint);
      root.innerHTML = '';

      const instance = typeof component === 'function'
        ? new component()
        : component;

      root.appendChild(await instance.render());
      this.currentRoute = instance;
    }
  }

  init() {
    this.handleRoute();
  }
}