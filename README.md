# 🦀 CRAMP

Creative Rapid AI Modern Platform - A zero-dependency framework for building AI-powered web applications.

## Quick Start

```bash
curl -sSL https://raw.githubusercontent.com/wansatya/cramp/master/install.sh | bash -s cramp-ai
```
```bash
cd cramp-ai
```
```bash
npm run dev
```

Your app will be running at `http://localhost:3000` 🚀

## Features

- 🚀 **Zero-dependency core** - Lightweight and fast
- ⚡ **Simple API** - React-like component system
- 🤖 **AI-first design** - Built for AI applications
- 📦 **Modern stack** - ES Modules + Tailwind CSS
- 🔄 **Hot reload** - See changes instantly
- 🛠️ **Developer friendly** - Clear project structure

## Project Structure

```
cramp-ai/
├── src/
│   ├── components/    # Reusable components
│   ├── pages/         # Page components
│   ├── styles/        # CSS styles
│   ├── index.js       # Entry point
│   └── App.js         # Main component
├── public/
│   └── cramp.js       # Framework core
└── package.json
```

## Creating Components

```javascript
// src/components/MyComponent.js
export default {
    template: `
        <div class="my-component">
            <h1>{{ title }}</h1>
            <button onclick="this.getRootNode().host.handleClick()">
                Click me
            </button>
        </div>
    `,

    state: {
        title: 'Hello CRAMP!'
    },

    handleClick() {
        this.setState({
            title: 'CRAMP is awesome!'
        });
    }
};
```

## Using Components

```javascript
// src/App.js
import { cramp } from '/cramp.js';
import MyComponent from './components/MyComponent.js';

export default {
    template: `
        <div class="app">
            <cramp-my-component></cramp-my-component>
        </div>
    `,
    
    async connectedCallback() {
        const app = cramp.create();
        app.component('cramp-my-component', MyComponent);
    }
};
```

## Available Scripts

```bash
# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

## Customization

### Tailwind CSS

The framework comes with Tailwind CSS pre-configured. You can customize the theme in your HTML:

```html
<script>
tailwind.config = {
    theme: {
        extend: {
            colors: {
                cramp: {
                    500: '#ff4f4f',
                    // ... other shades
                }
            }
        }
    }
};
</script>
```

### Components

Components follow a simple pattern with template, state, and methods:

```javascript
export default {
    // Template with state bindings
    template: `<div>{{ message }}</div>`,

    // Component state
    state: {
        message: 'Hello!'
    },

    // Lifecycle method
    connectedCallback() {
        console.log('Component mounted');
    },

    // Custom methods
    handleEvent() {
        this.setState({ message: 'Updated!' });
    }
};
```

## Development

1. Clone the repository:
```bash
curl -sSL https://raw.githubusercontent.com/wansatya/cramp/master/install.sh | bash -s cramp-ai
```

2. Install dependencies:
```bash
cd cramp-ai
npm install
```

3. Start development server:
```bash
npm run dev
```

## Production

Build your app for production:

```bash
npm run build
```

The built files will be in the `dist/` directory.

## Examples

Check out these examples:

1. Basic Component:
```javascript
// components/Counter.js
export default {
    template: `
        <div class="counter">
            <h2>Count: {{ count }}</h2>
            <button onclick="this.getRootNode().host.increment()">
                Increment
            </button>
        </div>
    `,
    
    state: {
        count: 0
    },
    
    increment() {
        this.setState({
            count: this.state.count + 1
        });
    }
};
```

2. AI Integration:
```javascript
// components/AiChat.js
export default {
    template: `
        <div class="ai-chat">
            <div class="messages">{{ response }}</div>
            <input 
                type="text" 
                onkeyup="this.getRootNode().host.handleInput(event)"
            >
        </div>
    `,
    
    state: {
        response: ''
    },
    
    async handleInput(event) {
        if (event.key === 'Enter') {
            const response = await fetch('/api/ai', {
                method: 'POST',
                body: JSON.stringify({
                    prompt: event.target.value
                })
            });
            const data = await response.json();
            this.setState({ response: data.text });
        }
    }
};
```

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing`
5. Submit a pull request

## License

[MIT © Wansatya Campus](LICENSE)

## Support

- Documentation: [crampjs.readthedocs.io](https://crampjs.readthedocs.io)
- GitHub: [wansatya/cramp](https://github.com/wansatya/cramp)
- Issues: [GitHub Issues](https://github.com/wansatya/cramp/issues)