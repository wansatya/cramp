#!/usr/bin/env node

const { program } = require('commander');
const createCommand = require('../src/commands/create');
const componentCommand = require('../src/commands/component');
const routeCommand = require('../src/commands/route');
const buildCommand = require('../src/commands/build');
const devCommand = require('../src/commands/dev');

program
  .name('cramp')
  .description('CRAMP - Creative Rapid AI Modern Platform')
  .version('1.0.0');

program
  .command('create <name>')
  .description('Create a new CRAMP project')
  .option('-t, --template <template>', 'template to use', 'default')
  .action(createCommand);

program
  .command('component <name>')
  .description('Generate a new component')
  .option('-d, --dir <directory>', 'component directory', 'src/components')
  .action(componentCommand);

program
  .command('route <path>')
  .description('Generate a new route')
  .option('-d, --dir <directory>', 'routes directory', 'src/routes')
  .action(routeCommand);

program
  .command('build')
  .description('Build for production')
  .option('-t, --target <target>', 'deployment target', 'static')
  .action(buildCommand);

program
  .command('dev')
  .description('Start development server')
  .option('-p, --port <port>', 'port to use', '3000')
  .action(devCommand);

program.parse();