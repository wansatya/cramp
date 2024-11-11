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

# Create project directory directly (no temp dir needed)
mkdir -p "$PROJECT_NAME"/{src,public} || handle_error "Failed to create project structure"
cd "$PROJECT_NAME" || handle_error "Failed to enter project directory"

# Create package.json first
cat > package.json << EOL
{
  "name": "${PROJECT_NAME}",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "node server.js",
    "build": "cramp build",
    "start": "node server.js --prod"
  },
  "dependencies": {
    "express": "^4.18.2",
    "ws": "^8.14.2"
  }
}
EOL

# Create development server
cat > server.js << EOL
const express = require('express');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

// Serve static files
app.use(express.static('public'));
app.use(express.static('src'));

// SPA fallback
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'src/index.html'));
});

app.listen(port, () => {
    console.log(\`
🦀 CRAMP development server running at http://localhost:\${port}
    \`);
});
EOL

# Create index.html
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
        <!-- CRAMP will mount here -->
    </div>

    <script>
        const app = cramp.create({
            mountPoint: '#app'
        });

        // Define components
        app.component('hello-cramp', \`
            <div class="hello">
                <h1>{{ greeting }}</h1>
                <button x-on:click="updateGreeting">
                    {{ buttonText }}
                </button>
            </div>
        \`, {
            state: {
                greeting: 'Hello CRAMP! 🦀',
                buttonText: 'Click me!'
            },
            
            updateGreeting() {
                this.setState({
                    greeting: 'CRAMP is awesome! ⚡️'
                });
            }
        });

        // Mount the app
        app.mount();
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
        
        button {
            padding: 10px 20px;
            background: #FF4F4F;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            transition: transform 0.2s;
        }
        
        button:hover {
            transform: translateY(-2px);
        }
    </style>
</body>
</html>
EOL

# Create the framework core file
cat > public/cramp.js << EOL
// CRAMP Framework Core
(function(global) {
    class Cramp {
        constructor(config = {}) {
            this.config = {
                mountPoint: config.mountPoint || '#app',
                ...config
            };
            this.state = {};
            this.components = new Map();
        }

        component(name, template, methods = {}) {
            this.components.set(name, { template, methods });
            
            // Register custom element
            customElements.define(\`cramp-\${name}\`, class extends HTMLElement {
                connectedCallback() {
                    this.innerHTML = template;
                    Object.assign(this, methods);
                    this.state = methods.state || {};
                    this.setupEvents();
                }

                setState(newState) {
                    this.state = { ...this.state, ...newState };
                    this.render();
                }

                setupEvents() {
                    this.querySelectorAll('[x-on\\\\:click]').forEach(el => {
                        const method = el.getAttribute('x-on:click');
                        el.addEventListener('click', () => this[method]());
                    });
                }

                render() {
                    let html = template;
                    for (const [key, value] of Object.entries(this.state)) {
                        html = html.replace(new RegExp(\`{{\\\s*\${key}\\\s*}}\`, 'g'), value);
                    }
                    this.innerHTML = html;
                    this.setupEvents();
                }
            });
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
  npm install     # Install dependencies
  npm run dev     # Start development server

Your app will be available at http://localhost:3000

Happy cramping! 🦀
"