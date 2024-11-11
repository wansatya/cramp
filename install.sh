#!/bin/bash

echo "
🦀 Installing CRAMP - Creative Rapid AI Modern Platform...
"

# Function to handle errors
handle_error() {
    echo "❌ Error: $1"
    exit 1
}

# Check requirements
command -v node >/dev/null 2>&1 || handle_error "Node.js is required but not installed."
command -v npm >/dev/null 2>&1 || handle_error "npm is required but not installed."

# Get project name from argument or prompt
PROJECT_NAME=$1
if [ -z "$PROJECT_NAME" ]; then
    echo "Enter project name:"
    read PROJECT_NAME
fi

# Create project structure
mkdir -p "$PROJECT_NAME"/{src/{components,pages,styles},public} || handle_error "Failed to create project structure"
cd "$PROJECT_NAME" || handle_error "Failed to enter project directory"

# Create package.json
cat > package.json << 'EOL'
{
  "name": "cramp-app",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "node server.js",
    "build": "node build.js",
    "start": "node server.js --prod"
  },
  "dependencies": {
    "express": "^4.18.2",
    "ws": "^8.14.2",
    "chokidar": "^3.5.3"
  },
  "devDependencies": {
    "esbuild": "^0.19.5"
  }
}
EOL

# Create index.html
cat > src/index.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CRAMP App</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="/styles/main.css">
    <script>
        // Configure Tailwind
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        cramp: {
                            50: '#fff1f1',
                            100: '#ffdfdf',
                            200: '#ffc5c5',
                            300: '#ff9d9d',
                            400: '#ff6464',
                            500: '#ff4f4f',
                            600: '#ed1515',
                            700: '#c80d0d',
                            800: '#a50f0f',
                            900: '#881414',
                            950: '#4b0404',
                        }
                    }
                }
            }
        };
    </script>
</head>
<body>
    <div id="root"></div>
    <script type="module" src="/index.js"></script>
</body>
</html>
EOL

# Create index.js (entry point)
cat > src/index.js << 'EOL'
import { cramp } from '/cramp.js';
import App from './App.js';

// Create main app instance
const app = cramp.create({
    mountPoint: '#root'
});

// Register the main App component
app.component('cramp-app', App);

// Mount when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    const root = document.querySelector('#root');
    root.innerHTML = '<cramp-app></cramp-app>';
    app.mount();
});
EOL

# Create App.js (main component)
cat > src/App.js << 'EOL'
import { cramp } from '/cramp.js';
import Header from './components/Header.js';
import Home from './pages/Home.js';

export default {
    template: `
        <div class="min-h-screen bg-gray-50">
            <cramp-header></cramp-header>
            <main>
                <cramp-home></cramp-home>
            </main>
        </div>
    `,
    
    async connectedCallback() {
        // Create a new instance for registering components
        const app = cramp.create();
        app.component('cramp-header', Header);
        app.component('cramp-home', Home);
    }
};
EOL

# Create Header component
cat > src/components/Header.js << 'EOL'
export default {
    template: `
        <header class="bg-white shadow">
            <nav class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
                <div class="flex h-16 justify-between items-center">
                    <div class="flex items-center">
                        <span class="text-2xl font-bold text-cramp-500">🦀 CRAMP</span>
                    </div>
                    <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
                        <a href="/" class="text-gray-900 hover:text-cramp-500 px-3 py-2 text-sm font-medium">Home</a>
                        <a href="/about" class="text-gray-900 hover:text-cramp-500 px-3 py-2 text-sm font-medium">About</a>
                        <a href="/docs" class="text-gray-900 hover:text-cramp-500 px-3 py-2 text-sm font-medium">Docs</a>
                    </div>
                </div>
            </nav>
        </header>
    `
};
EOL

# Create Home page component
cat > src/pages/Home.js << 'EOL'
export default {
    template: `
        <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-12">
            <div class="text-center">
                <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
                    Welcome to CRAMP
                </h1>
                <p class="mt-6 text-lg leading-8 text-gray-600">
                    Start building your AI-powered app
                </p>
                <div class="mt-10 flex items-center justify-center gap-x-6">
                    <button 
                        onclick="this.getRootNode().host.handleClick()"
                        class="rounded-md bg-cramp-500 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-cramp-600"
                    >
                        Get Started
                    </button>
                </div>
            </div>
        </div>
    `,

    state: {
        count: 0
    },

    handleClick() {
        this.setState({
            count: this.state.count + 1
        });
        console.log('Button clicked!', this.state.count);
    }
};
EOL

# Create main CSS file
cat > src/styles/main.css << 'EOL'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
    --cramp-50: #fff1f1;
    --cramp-100: #ffdfdf;
    --cramp-200: #ffc5c5;
    --cramp-300: #ff9d9d;
    --cramp-400: #ff6464;
    --cramp-500: #ff4f4f;
    --cramp-600: #ed1515;
    --cramp-700: #c80d0d;
    --cramp-800: #a50f0f;
    --cramp-900: #881414;
    --cramp-950: #4b0404;
}

.text-cramp-500 {
    color: var(--cramp-500);
}

.bg-cramp-500 {
    background-color: var(--cramp-500);
}

.hover\:bg-cramp-600:hover {
    background-color: var(--cramp-600);
}
EOL

# Create the framework core file
cat > public/cramp.js << 'EOL'
// CRAMP Framework Core
class CrampComponent extends HTMLElement {
    constructor() {
        super();
        this._state = {};
    }

    setState(newState) {
        this._state = { ...this._state, ...newState };
        this.render();
    }

    get state() {
        return this._state;
    }
}

class Cramp {
    constructor(config = {}) {
        this.config = {
            mountPoint: config.mountPoint || '#root',
            ...config
        };
        this.components = new Map();
    }

    component(name, options = {}) {
        if (this.components.has(name)) {
            return this.components.get(name);
        }

        const { template, state = {}, ...methods } = options;

        class CustomComponent extends CrampComponent {
            constructor() {
                super();
                this._state = state;
                Object.assign(this, methods);
            }

            connectedCallback() {
                if (methods.connectedCallback) {
                    methods.connectedCallback.call(this);
                }
                this.render();
            }

            render() {
                if (methods.render) {
                    methods.render.call(this);
                } else {
                    this.innerHTML = this.processTemplate();
                }
            }

            processTemplate() {
                let html = template;
                for (const [key, value] of Object.entries(this.state)) {
                    html = html.replace(
                        new RegExp(`{{\\s*${key}\\s*}}`, 'g'),
                        value
                    );
                }
                return html;
            }
        }

        if (!customElements.get(name)) {
            customElements.define(name, CustomComponent);
        }

        this.components.set(name, CustomComponent);
        return CustomComponent;
    }

    mount() {
        const root = document.querySelector(this.config.mountPoint);
        if (!root) throw new Error(`Mount point ${this.config.mountPoint} not found`);
    }
}

// Export as ES module
export const cramp = {
    create: (config) => new Cramp(config)
};

// Also expose to window for legacy support
window.cramp = cramp;
EOL

# Create development server
cat > server.js << 'EOL'
const express = require('express');
const path = require('path');
const { createServer } = require('http');
const { WebSocketServer } = require('ws');
const chokidar = require('chokidar');

const app = express();
const server = createServer(app);
const wss = new WebSocketServer({ server });
const port = process.env.PORT || 3000;

// Live reload
wss.on('connection', (ws) => {
    console.log('📱 Client connected to live reload');
    ws.on('close', () => console.log('📱 Client disconnected'));
});

// Serve static files
app.use(express.static('public'));
app.use(express.static('src'));

// SPA fallback
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'src/index.html'));
});

// Start server
server.listen(port, () => {
    console.log(`
🦀 CRAMP development server running at http://localhost:${port}
📝 Edit files in src/ to see live changes
    `);
});

// Watch for file changes
const watcher = chokidar.watch('src', {
    ignored: /^\.|[\/\\]\./,
    persistent: true
});

watcher
    .on('change', path => {
        console.log(`📝 File ${path} has been changed`);
        wss.clients.forEach((client) => {
            client.send('reload');
        });
    })
    .on('error', error => console.error(`❌ Watcher error: ${error}`));
EOL

# Create .gitignore
cat > .gitignore << 'EOL'
node_modules
dist
.env
.DS_Store
EOL

# Initialize git and install dependencies
git init
npm install || handle_error "Failed to install dependencies"

echo "
✨ CRAMP project created successfully!

Project structure:
  src/
    ├── components/    # Reusable components
    ├── pages/         # Page components
    ├── styles/        # CSS styles
    ├── index.js       # Entry point
    └── App.js         # Main component
  public/
    └── cramp.js       # Framework core

To get started:
  cd ${PROJECT_NAME}
  npm run dev          # Start development server

Your app will be available at http://localhost:3000

Happy cramping! 🦀
"