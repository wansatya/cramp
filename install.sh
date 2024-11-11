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

# Create package.json with updated dependencies
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
    "ws": "^8.14.2",
    "chokidar": "^3.5.3"
  },
  "devDependencies": {
    "esbuild": "^0.19.5"
  }
}
EOL

# Create development server with chokidar
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

// Watch for file changes using chokidar
const watcher = chokidar.watch('src', {
    ignored: /^\.|[\/\\]\./,  // Ignore dotfiles
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

# Create build script
cat > build.js << EOL
const esbuild = require('esbuild');
const fs = require('fs');
const path = require('path');

async function build() {
    console.log('🔨 Building CRAMP application...');

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
        console.error('❌ Build failed:', error);
        process.exit(1);
    }
}

build();
EOL

# Create index.html with live reload
cat > src/index.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CRAMP App</title>
    <script src="/cramp.js"></script>
    <style>
        body {
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
    </style>
</head>
<body>
    <div id="app"></div>

    <script>
        // Initialize CRAMP
        document.addEventListener('DOMContentLoaded', () => {
            const app = cramp.create({
                mountPoint: '#app'
            });
            
            // Mount the app
            app.mount();
        });
    </script>
</body>
</html>
EOL

# Create the framework core file
cat > public/cramp.js << 'EOL'
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
            
            // Automatically define hello-world component
            this.component('hello-world', {
                template: '<h1>Hello, World! 🦀</h1>',
                styles: `
                    h1 { 
                        font-family: system-ui, -apple-system, sans-serif;
                        color: #FF4F4F;
                        text-align: center;
                        padding: 20px;
                        margin: 0;
                        font-size: 2.5rem;
                    }
                `
            });
        }

        component(name, options = {}) {
            const { template, styles, methods = {} } = options;

            class CustomComponent extends CrampComponent {
                constructor() {
                    super();
                    this._state = methods.state || {};
                    Object.assign(this, methods);
                }

                connectedCallback() {
                    // Add styles if provided
                    if (styles) {
                        const styleSheet = new CSSStyleSheet();
                        styleSheet.replaceSync(styles);
                        this.adoptedStyleSheets = [styleSheet];
                    }

                    this.render();
                    if (methods.connectedCallback) {
                        methods.connectedCallback.call(this);
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

            // Define the custom element
            if (!customElements.get(name)) {
                customElements.define(name, CustomComponent);
            }

            return CustomComponent;
        }

        mount() {
            const root = document.querySelector(this.config.mountPoint);
            if (!root) throw new Error(`Mount point ${this.config.mountPoint} not found`);
            
            // Automatically add hello-world component if root is empty
            if (!root.children.length) {
                const helloWorld = document.createElement('hello-world');
                root.appendChild(helloWorld);
            }
        }
    }

    // Export to global scope
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