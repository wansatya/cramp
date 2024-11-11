#!/usr/bin/env node
const path = require('path');
const fs = require('fs-extra');
const chalk = require('chalk');
const ora = require('ora');
const { execSync } = require('child_process');
const prompts = require('prompts');

class CreateCramp {
  constructor() {
    this.templates = {
      minimal: 'Minimal starter (recommended for learning)',
      chat: 'Chat application',
      full: 'Full-featured application'
    };
  }

  async create(projectName) {
    console.log(chalk.cyan(`
🦀 CRAMP - Creative Rapid AI Modern Platform

Creating a new CRAMP project: ${chalk.green(projectName)}
    `));

    try {
      // Get project configuration
      const config = await this.promptConfig();

      // Create project
      await this.createProject(projectName, config);

      // Show success message
      this.showSuccessMessage(projectName);
    } catch (error) {
      console.error(chalk.red('\n❌ Error:'), error);
      process.exit(1);
    }
  }

  async promptConfig() {
    const questions = [
      {
        type: 'select',
        name: 'template',
        message: 'Select a template:',
        choices: Object.entries(this.templates).map(([value, title]) => ({
          title,
          value
        })),
        initial: 0
      },
      {
        type: 'confirm',
        name: 'typescript',
        message: 'Use TypeScript?',
        initial: false
      },
      {
        type: 'confirm',
        name: 'git',
        message: 'Initialize Git repository?',
        initial: true
      },
      {
        type: 'text',
        name: 'apiKey',
        message: 'OpenAI API Key (optional):',
        initial: ''
      }
    ];

    return await prompts(questions);
  }

  async createProject(projectName, config) {
    const spinner = ora('Creating project directory...').start();
    const projectPath = path.join(process.cwd(), projectName);

    try {
      // Create project directory
      await fs.mkdir(projectPath);
      spinner.succeed();

      // Copy template
      spinner.start('Copying template files...');
      await this.copyTemplate(projectPath, config.template);
      spinner.succeed();

      // Configure TypeScript if selected
      if (config.typescript) {
        spinner.start('Setting up TypeScript...');
        await this.setupTypeScript(projectPath);
        spinner.succeed();
      }

      // Create package.json
      spinner.start('Creating package.json...');
      await this.createPackageJson(projectPath, projectName, config);
      spinner.succeed();

      // Install dependencies
      spinner.start('Installing dependencies...');
      this.installDependencies(projectPath);
      spinner.succeed();

      // Initialize git if selected
      if (config.git) {
        spinner.start('Initializing Git repository...');
        await this.initGit(projectPath);
        spinner.succeed();
      }

      // Configure API key if provided
      if (config.apiKey) {
        spinner.start('Configuring API key...');
        await this.configureApiKey(projectPath, config.apiKey);
        spinner.succeed();
      }

    } catch (error) {
      spinner.fail();
      throw error;
    }
  }

  async copyTemplate(projectPath, template) {
    const templatePath = path.join(__dirname, 'templates', template);
    await fs.copy(templatePath, projectPath);

    // Rename any template-specific files
    const gitignorePath = path.join(projectPath, 'gitignore');
    if (await fs.pathExists(gitignorePath)) {
      await fs.move(gitignorePath, path.join(projectPath, '.gitignore'));
    }
  }

  async createPackageJson(projectPath, projectName, config) {
    const packageJson = {
      name: projectName,
      version: '0.1.0',
      private: true,
      scripts: {
        dev: 'cramp dev',
        build: 'cramp build',
        start: 'cramp start',
        test: 'cramp test'
      },
      dependencies: {
        '@cramp/core': '^1.0.0'
      },
      devDependencies: {
        '@cramp/cli': '^1.0.0'
      }
    };

    if (config.typescript) {
      packageJson.devDependencies = {
        ...packageJson.devDependencies,
        typescript: '^5.0.0',
        '@types/node': '^20.0.0'
      };
    }

    await fs.writeJson(path.join(projectPath, 'package.json'), packageJson, {
      spaces: 2
    });
  }

  async setupTypeScript(projectPath) {
    const tsConfig = {
      compilerOptions: {
        target: 'ES2020',
        lib: ['DOM', 'DOM.Iterable', 'ESNext'],
        module: 'ESNext',
        skipLibCheck: true,
        moduleResolution: 'bundler',
        allowImportingTsExtensions: true,
        resolveJsonModule: true,
        isolatedModules: true,
        noEmit: true,
        strict: true,
        noUnusedLocals: true,
        noUnusedParameters: true,
        noFallthroughCasesInSwitch: true
      },
      include: ['src'],
      references: [{ path: './tsconfig.node.json' }]
    };

    await fs.writeJson(path.join(projectPath, 'tsconfig.json'), tsConfig, {
      spaces: 2
    });

    // Rename .js files to .ts
    const files = await fs.readdir(path.join(projectPath, 'src'));
    for (const file of files) {
      if (file.endsWith('.js')) {
        const oldPath = path.join(projectPath, 'src', file);
        const newPath = path.join(projectPath, 'src', file.replace('.js', '.ts'));
        await fs.move(oldPath, newPath);
      }
    }
  }

  installDependencies(projectPath) {
    execSync('npm install', {
      cwd: projectPath,
      stdio: 'inherit'
    });
  }

  async initGit(projectPath) {
    execSync('git init', { cwd: projectPath });
    execSync('git add .', { cwd: projectPath });
    execSync('git commit -m "Initial commit"', {
      cwd: projectPath,
      stdio: 'ignore'
    });
  }

  async configureApiKey(projectPath, apiKey) {
    // Create .env file
    await fs.writeFile(
      path.join(projectPath, '.env'),
      `OPENAI_API_KEY=${apiKey}\n`
    );

    // Add to .gitignore if not already present
    const gitignorePath = path.join(projectPath, '.gitignore');
    const gitignore = await fs.readFile(gitignorePath, 'utf8');
    if (!gitignore.includes('.env')) {
      await fs.appendFile(gitignorePath, '\n.env\n');
    }
  }

  showSuccessMessage(projectName) {
    console.log(chalk.green(`
✨ Successfully created project ${chalk.blue(projectName)}!

Next steps:
  ${chalk.cyan('cd')} ${projectName}
  ${chalk.cyan('npm run dev')}

Start editing ${chalk.cyan('src/index.js')} to customize your application.

Need help? Check out the docs at ${chalk.blue('https://crampjs.dev')}

Happy cramping! 🦀
    `));
  }
}

// Run the create tool
const projectName = process.argv[2];

if (!projectName) {
  console.log(chalk.red('Please specify a project name:'));
  console.log(chalk.blue('  npx create-cramp my-app'));
  process.exit(1);
}

new CreateCramp().create(projectName);