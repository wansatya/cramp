// examples/minimal/src/index.js
import { createApp } from '@cramp/core';

const app = createApp({
  mountPoint: '#app'
});

app.component('hello-world', `
  <div>
    <h1>{{ greeting }}</h1>
    <button x-on:click="updateGreeting">Change Greeting</button>
  </div>
`, {
  state: {
    greeting: 'Hello CRAMP!'
  },

  updateGreeting() {
    this.setState({
      greeting: 'CRAMP is awesome!'
    });
  }
});

app.router
  .add('/', {
    template: '<hello-world></hello-world>'
  });

app.mount();