// scripts/build.js
const esbuild = require('esbuild');
const { copyFile, mkdir, writeFile, readFile } = require('fs/promises');
const { existsSync } = require('fs');
const path = require('path');

class CrampBuilder {
  constructor() {
    this.distPath = path.join(process.cwd(), 'dist');
    this.srcPath = path.join(process.cwd(), 'src');
    this.platformConfigs = new Map([
      ['vercel', this.generateVercelConfig],
      ['render', this.generateRenderConfig],
      ['nginx', this.generateNginxConfig]
    ]);
  }

  async build() {
    console.log('🦀 Building CRAMP application...');

    try {
      // Ensure dist directory exists
      await mkdir(this.distPath, { recursive: true });

      // Build the application
      await this.buildApp();

      // Generate platform-specific configs
      await this.generatePlatformConfigs();

      console.log('✨ Build complete! Your app is ready for deployment.');
      this.showDeploymentInstructions();
    } catch (error) {
      console.error('❌ Build failed:', error);
      process.exit(1);
    }
  }

  async buildApp() {
    // Read cramp.config.js if it exists
    const config = await this.loadConfig();

    // Bundle the application
    await esbuild.build({
      entryPoints: ['src/index.js'],
      bundle: true,
      minify: true,
      sourcemap: true,
      outdir: 'dist',
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
        'process.env.NODE_ENV': '"production"',
        ...config.env
      },
      metafile: true
    });

    // Copy and process HTML template
    await this.processHtmlTemplate();

    // Copy static assets
    await this.copyStaticAssets();
  }

  async loadConfig() {
    const configPath = path.join(process.cwd(), 'cramp.config.js');
    if (existsSync(configPath)) {
      return require(configPath);
    }
    return { env: {} };
  }

  async processHtmlTemplate() {
    const template = await readFile(path.join(this.srcPath, 'index.html'), 'utf-8');

    // Process template with production optimizations
    const processedTemplate = template
      // Add cache busting
      .replace(/\.js"/g, '.js?v=' + Date.now() + '"')
      // Add meta tags
      .replace('</head>',
        `  <meta name="description" content="Built with CRAMP Framework">
           <link rel="preconnect" href="https://api.openai.com">
           </head>`
      )
      // Add loading state
      .replace('<div id="app">',
        `<div id="app">
           <div id="cramp-loader" style="text-align:center;padding:20px;">
             🦀 Loading...
           </div>`
      );

    await writeFile(path.join(this.distPath, 'index.html'), processedTemplate);
  }

  async copyStaticAssets() {
    const staticDir = path.join(this.srcPath, 'static');
    if (existsSync(staticDir)) {
      await this.copyDir(staticDir, path.join(this.distPath, 'static'));
    }
  }

  async generatePlatformConfigs() {
    for (const [platform, generator] of this.platformConfigs) {
      await generator.call(this);
    }
  }

  async generateVercelConfig() {
    const vercelConfig = {
      version: 2,
      builds: [
        {
          src: 'dist/**',
          use: '@vercel/static'
        }
      ],
      routes: [
        {
          src: '/api/(.*)',
          dest: '/api/$1'
        },
        {
          src: '/(.*)',
          dest: '/index.html'
        }
      ]
    };

    await writeFile(
      path.join(process.cwd(), 'vercel.json'),
      JSON.stringify(vercelConfig, null, 2)
    );
  }

  async generateRenderConfig() {
    const renderConfig = {
      buildCommand: 'npm run build',
      publishPath: 'dist',
      routes: [
        { type: 'rewrite', source: '/api/(.*)', destination: '/api/$1' },
        { type: 'rewrite', source: '/(.*)', destination: '/index.html' }
      ],
      headers: [
        {
          source: '/**',
          headers: [
            {
              key: 'Cache-Control',
              value: 'public, max-age=0, must-revalidate'
            }
          ]
        }
      ]
    };

    await writeFile(
      path.join(process.cwd(), 'render.yaml'),
      JSON.stringify(renderConfig, null, 2)
    );
  }

  async generateNginxConfig() {
    const nginxConfig = `
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    # GZIP compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
    gzip_min_length 1000;

    # Cache static assets
    location /static {
        expires 1y;
        add_header Cache-Control "public, no-transform";
    }

    # API proxying
    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }
}
`;

    await writeFile(
      path.join(this.distPath, 'nginx.conf'),
      nginxConfig
    );
  }

  showDeploymentInstructions() {
    console.log(`
📦 Deployment Instructions:

1. Vercel:
   vercel deploy

2. Render:
   git push render main

3. Nginx:
   - Copy dist/ to /usr/share/nginx/html
   - Copy dist/nginx.conf to /etc/nginx/conf.d/default.conf
   - Restart nginx

Your build is in the dist/ directory and ready for deployment!
    `);
  }
}

// Run the builder
new CrampBuilder().build();