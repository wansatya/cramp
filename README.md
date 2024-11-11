# 🦀 CRAMP

Creative Rapid AI Modern Platform - A zero-dependency framework for building AI-powered web applications.

## Features

- 🚀 **Zero-dependency core** - Lightweight and fast
- ⚡ **Simple API** - Intuitive and easy to learn
- 🤖 **AI-first design** - Built for AI applications
- 📦 **Component system** - Reusable and composable
- 🛣️ **Built-in routing** - Simple and powerful
- 🔄 **State management** - Reactive and efficient
- 🛠️ **Developer tools** - CLI and development server

## Quick Start

```bash
# Create a new project
npx create-cramp my-app

# Navigate to project
cd my-app

# Start development server
npm run dev
```

## Examples

### Minimal Example
```javascript
import { createApp } from '@cramp/core';

const app = createApp({
  apiKey: 'your-api-key'
});

app.component('hello-ai', `
  <div>
    <button x-on:click="generate">Generate</button>
    <div>{{ result }}</div>
  </div>
`, {
  async generate() {
    const result = await this.app.ai.process('Hello, AI!');
    this.setState({ result });
  }
});

app.mount('#app');
```

### Chat Example
See `examples/chat-app` for a full chat application example.

### Full Featured Example
See `examples/full-featured` for a complete application with all features.

## Documentation

### Installation

```bash
# Using npx (recommended)
npx create-cramp my-app

# Using npm
npm init cramp my-app

# Global CLI
npm install -g @cramp/cli
cramp create my-app
```

### Development

```bash
# Start development server
npm run dev

# Build for production
npm run build

# Run tests
npm test
```

### Project Structure

```
my-app/
├── src/
│   ├── components/    # Application components
│   ├── routes/        # Route components
│   └── index.js       # Application entry
├── public/            # Static assets
└── package.json
```

### CLI Commands

```bash
# Create new project
cramp create my-app

# Generate component
cramp component MyComponent

# Generate route
cramp route /path

# Start development
cramp dev

# Build for production
cramp build
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Package Structure

```
cramp/
├── packages/
│   ├── core/           # Framework core
│   ├── cli/            # Command line interface
│   └── create-cramp/   # Project creation tool
├── examples/           # Example applications
└── scripts/            # Build and development scripts
```

## License

MIT © CRAMP Team

## Development

```bash
# Clone repository
git clone https://github.com/wansatya/cramp.git

# Install dependencies
npm install

# Start development
npm run dev

# Build all packages
npm run build
```

## Repository Structure

```
cramp/
├── README.md
├── package.json
├── packages/
│   ├── core/                 # Core CRAMP framework
│   │   ├── package.json
│   │   ├── src/
│   │   │   ├── index.js     # Main framework entry
│   │   │   ├── router.js    # Routing system
│   │   │   ├── component.js # Component system
│   │   │   └── ai.js       # AI integration
│   │   └── dist/           # Built files
│   │
│   ├── cli/                # CLI tool
│   │   ├── package.json
│   │   ├── bin/
│   │   │   └── cramp.js    # CLI entry point
│   │   └── src/
│   │       ├── commands/   # CLI commands
│   │       └── templates/  # Project templates
│   │
│   └── create-cramp/       # Project creation tool
│       ├── package.json
│       └── index.js
│
├── examples/               # Example projects
│   ├── minimal/
│   ├── chat-app/
│   └── full-featured/
│
└── scripts/               # Build and development scripts
    ├── build.js
    └── dev.js
```