#!/bin/bash

# install.sh
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

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR || handle_error "Failed to create temporary directory"

# Download core files
echo "⬇️  Downloading CRAMP framework..."

# Core framework file
curl -s -o cramp.js "https://raw.githubusercontent.com/cramp/cramp/main/packages/core/dist/cramp.js" || handle_error "Failed to download framework"

# Create project structure
mkdir -p "$PROJECT_NAME"/{src,public}
cd "$PROJECT_NAME" || handle_error "Failed to create project directory"

# Create package.json
cat > package.json << EOL
{
  "name": "${PROJECT_NAME}",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "cramp dev",
    "build": "cramp build",
    "start": "cramp start"
  },
  "dependencies": {
    "@cramp/core": "^1.0.0"
  },
  "devDependencies": {
    "@cramp/cli": "^1.0.0"
  }
}
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

        // Define routes
        app.router
            .add('/', {
                template: '<hello-cramp></hello-cramp>'
            })
            .add('/about', {
                template: \`
                    <div>
                        <h2>About CRAMP</h2>
                        <p>A modern framework for AI applications.</p>
                    </div>
                \`
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

# Copy framework file
cp ../cramp.js public/

# Initialize git
git init
cat > .gitignore << EOL
node_modules
dist
.env
.DS_Store
EOL

# Install dependencies
echo "📦 Installing dependencies..."
npm install || handle_error "Failed to install dependencies"

# Cleanup
cd ..
rm -rf $TEMP_DIR

echo "
✨ CRAMP project created successfully!

To get started:
  cd ${PROJECT_NAME}
  npm run dev

Happy cramping! 🦀
"