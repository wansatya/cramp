// scripts/dev.js
const esbuild = require('esbuild');
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');
const path = require('path');

class CrampDevServer {
  constructor() {
    this.app = express();
    this.port = process.env.PORT || 3000;
  }

  async start() {
    console.log('🦀 Starting CRAMP development server...');

    // Setup middleware
    this.setupMiddleware();

    // Start esbuild in watch mode
    await this.startBuildWatch();

    // Start the server
    this.app.listen(this.port, () => {
      console.log(`
🚀 Development server running at http://localhost:${this.port}
📝 Edit files in src/ to see live changes
🔄 Hot reload enabled
      `);
    });
  }

  setupMiddleware() {
    this.app.use(cors());
    this.app.use(express.json());

    // Serve static files from dist
    this.app.use(express.static('dist'));

    // API proxy
    this.app.use('/api', createProxyMiddleware({
      target: process.env.API_URL || 'http://localhost:3001',
      changeOrigin: true,
      pathRewrite: { '^/api': '' }
    }));

    // SPA fallback
    this.app.get('*', (req, res) => {
      res.sendFile(path.join(process.cwd(), 'dist', 'index.html'));
    });
  }

  async startBuildWatch() {
    const ctx = await esbuild.context({
      entryPoints: ['src/index.js'],
      bundle: true,
      outdir: 'dist',
      sourcemap: true,
      format: 'esm',
      splitting: true,
      target: ['es2020'],
      loader: {
        '.js': 'jsx',
        '.css': 'css',
        '.svg': 'dataurl',
        '.png': 'dataurl',
        '.jpg': 'dataurl',
        '.gif': 'dataurl'
      },
      define: {
        'process.env.NODE_ENV': '"development"'
      },
      plugins: [{
        name: 'reload-plugin',
        setup(build) {
          build.onEnd(() => {
            console.log('🔄 Build updated');
          });
        }
      }]
    });

    await ctx.watch();
  }
}

// Run the development server
new CrampDevServer().start();