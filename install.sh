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

# Validate project name
if [ -z "$PROJECT_NAME" ]; then
    handle_error "Project name is required"
fi

if [ -d "$PROJECT_NAME" ]; then
    handle_error "Directory $PROJECT_NAME already exists"
fi

echo "📦 Creating project: $PROJECT_NAME"

# Create project directory
mkdir -p "$PROJECT_NAME"/{src,public} || handle_error "Failed to create project structure"
cd "$PROJECT_NAME" || handle_error "Failed to enter project directory"

# Create package.json with build script
cat > package.json << EOL
{
  "name": "${PROJECT_NAME}",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "node server.js",
    "build": "node build.js",
    "start": "node server.js --prod"
  },
  "dependencies": {
    "express": "^4.18.2",
    "ws": "^8.14.2"
  },
  "devDependencies": {
    "esbuild": "^0.19.5"
  }
}
EOL

# Create development server
cat > server.js << EOL
const express = require('express');
const path = require('path');
const { createServer } = require('http');
const { WebSocketServer } = require('ws');

const app = express();
const server = createServer(app);
const wss = new WebSocketServer({ server });
const port = process.env.PORT || 3000;

// Live reload
wss.on('connection', (ws) => {
    console.log('Client connected to live reload');
    ws.on('close', () => console.log('Client disconnected'));
});

// Serve static files
app.use(express.static('public'));
app.use(express.static('src'));

// SPA fallback
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'src/index.html'));
});

server.listen(port, () => {
    console.log(\`
🦀 CRAMP development server running at http://localhost:\${port}
    \`);
});

// Watch for file changes
const fs = require('fs');
fs.watch('src', { recursive: true }, (eventType, filename) => {
    wss.clients.forEach((client) => {
        client.send('reload');
    });
});
EOL

# Create build script
cat > build.js << EOL
const esbuild = require('esbuild');
const fs = require('fs');
const path = require('path');

async function build() {
    try {
        // Ensure dist directory exists
        if (!fs.existsSync('dist')) {
            fs.mkdirSync('dist');
        }

        // Copy static files
        fs.copyFileSync('src/index.html', 'dist/index.html');
        fs.copyFileSync('public/cramp.js', 'dist/cramp.js');

        console.log('✨ Build complete! Files are in the dist/ directory');
    } catch (error) {
        console.error('Build failed:', error);
        process.exit(1);
    }
}

build();
EOL

# Create index.html with live reload
cat > src/index.html << EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CRAMP App</title>
    <script src="/cramp.js"></script>
</head>
<body>
    <div id="app">
        <hello-cramp></hello-cramp>
    </div>

    <script>
        // Live reload script
        const ws = new WebSocket('ws://' + window.location.host);
        ws.onmessage = () => window.location.reload();
    </script>

    <script>
        // Initialize CRAMP
        document.addEventListener('DOMContentLoaded', () => {
            const app = cramp.create({
                mountPoint: '#app'
            });

            // Define components
            app.component('hello-cramp', \`
                <div class="hello">
                    <h1 class="greeting"></h1>
                    <button class="btn">Click me!</button>
                </div>
            \`, {
                state: {
                    greeting: 'Hello CRAMP! 🦀',
                    buttonText: 'Click me!'
                },
                
                connectedCallback() {
                    this.render();
                    this.querySelector('.btn').addEventListener('click', () => this.updateGreeting());
                },

                updateGreeting() {
                    this.setState({
                        greeting: 'CRAMP is awesome! ⚡️'
                    });
                },

                render() {
                    this.querySelector('.greeting').textContent = this.state.greeting;
                    this.querySelector('.btn').textContent = this.state.buttonText;
                }
            });

            // Mount the app
            app.mount();
        });
    </script>

    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }
        
        #app {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .hello {
            text-align: center;
            padding: 20px;
        }
        
        .btn {
            padding: 10px 20px;
            background: #FF4F4F;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            transition: transform 0.2s;
        }
        
        .btn:hover {
            transform: translateY(-2px);
        }
    </style>
</body>
</html>
EOL

# Create the framework core file with improved component system
cat > public/cramp.js << EOL
// CRAMP Framework Core
(function(global) {
    class CrampComponent extends HTMLElement {
        constructor() {
            super();
            this._state = {};
        }

        get state() {
            return this._state;
        }

        set state(newState) {
            this._state = { ...this._state, newState };
        }

        setState(newState) {
            this._state = { ...this._state, ...newState };
            this.render();
        }
    }

    class Cramp {
        constructor(config = {}) {
            this.config = {
                mountPoint: config.mountPoint || '#app',
                ...config
            };
            this.components = new Map();
        }

        component(name, template, methods = {}) {
            class CustomComponent extends CrampComponent {
                constructor() {
                    super();
                    this._state = methods.state || {};
                    Object.assign(this, methods);
                    this.template = template;
                }

                connectedCallback() {
                    if (methods.connectedCallback) {
                        methods.connectedCallback.call(this);
                    } else {
                        this.render();
                    }
                }

                render() {
                    if (methods.render) {
                        methods.render.call(this);
                    } else {
                        this.innerHTML = this.processTemplate();
                    }
                }

                processTemplate() {
                    let html = this.template;
                    for (const [key, value] of Object.entries(this.state)) {
                        html = html.replace(
                            new RegExp(\`{{\\\s*\${key}\\\s*}}\`, 'g'),
                            value
                        );
                    }
                    return html;
                }
            }

            if (!customElements.get(\`\${name}\`)) {
                customElements.define(\`\${name}\`, CustomComponent);
            }
        }

        mount() {
            const root = document.querySelector(this.config.mountPoint);
            if (!root) throw new Error(\`Mount point \${this.config.mountPoint} not found\`);
        }
    }

    global.cramp = {
        create: (config) => new Cramp(config)
    };
})(typeof window !== 'undefined' ? window : global);
EOL

# Create .gitignore
cat > .gitignore << EOL
node_modules
dist
.env
.DS_Store
EOL

# Initialize git
git init

# Install dependencies
echo "📦 Installing dependencies..."
npm install || handle_error "Failed to install dependencies"

echo "
✨ CRAMP project created successfully!

To get started:
  cd ${PROJECT_NAME}
  npm run dev     # Start development server

Your app will be available at http://localhost:3000

To build for production:
  npm run build   # Files will be in the dist/ directory

Happy cramping! 🦀
"