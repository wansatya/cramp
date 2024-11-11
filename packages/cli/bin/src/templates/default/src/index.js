// packages/cli/src/commands/create.js
const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const ora = require('ora');
const { execSync } = require('child_process');

async function createCommand(name, options) {
  const spinner = ora('Creating CRAMP project...').start();

  try {
    // Create project directory
    const projectPath = path.join(process.cwd(), name);
    await fs.mkdir(projectPath);

    // Copy template
    const templatePath = path.join(__dirname, '../templates', options.template);
    await fs.copy(templatePath, projectPath);

    // Customize package.json
    const packageJsonPath = path.join(projectPath, 'package.json');
    const packageJson = await fs.readJson(packageJsonPath);
    packageJson.name = name;
    await fs.writeJson(packageJsonPath, packageJson, { spaces: 2 });

    // Initialize git
    execSync('git init', { cwd: projectPath });

    // Install dependencies
    spinner.text = 'Installing dependencies...';
    execSync('npm install', { cwd: projectPath, stdio: 'ignore' });

    spinner.succeed(chalk.green(`
      🦀 Project created successfully!
      
      Next steps:
        cd ${name}
        npm run dev
    `));
  } catch (error) {
    spinner.fail(chalk.red('Failed to create project'));
    console.error(error);
    process.exit(1);
  }
}

module.exports = createCommand;