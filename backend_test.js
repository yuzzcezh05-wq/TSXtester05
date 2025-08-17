const fs = require('fs').promises;
const path = require('path');
const { spawn } = require('child_process');

// Enhanced Project Runner for testing
class TestableEnhancedProjectRunner {
  constructor() {
    this.mainWindow = { webContents: { send: () => {} } };
    this.runningProjects = new Map();
    this.fileWatchers = new Map();
  }

  async findTsxFiles(dirPath, maxDepth = 2, currentDepth = 0) {
    if (currentDepth >= maxDepth) return [];
    
    try {
      const items = await fs.readdir(dirPath, { withFileTypes: true });
      let tsxFiles = [];

      for (const item of items) {
        if (item.name.startsWith('.') || item.name === 'node_modules') continue;
        
        const fullPath = path.join(dirPath, item.name);
        
        if (item.isDirectory()) {
          const subFiles = await this.findTsxFiles(fullPath, maxDepth, currentDepth + 1);
          tsxFiles = tsxFiles.concat(subFiles);
        } else if (item.name.endsWith('.tsx') || item.name.endsWith('.ts')) {
          tsxFiles.push(fullPath);
        }
      }

      return tsxFiles;
    } catch (error) {
      return [];
    }
  }

  async hasTypeScriptConfig(dirPath) {
    try {
      const configFiles = ['tsconfig.json', 'tsconfig.js', 'typescript.json'];
      for (const config of configFiles) {
        const configPath = path.join(dirPath, config);
        if (await fs.access(configPath).then(() => true).catch(() => false)) {
          return true;
        }
      }
      return false;
    } catch {
      return false;
    }
  }

  async detectTsxProject(projectPath, dependencies, tsxFiles) {
    let type = 'tsx-react';
    let framework = 'React + TypeScript';
    let buildTool = '';
    let autoScripts = {};

    if (dependencies.next) {
      type = 'nextjs-ts';
      framework = 'Next.js + TypeScript';
      buildTool = 'Next.js';
    } else if (dependencies['react-scripts']) {
      type = 'cra-ts';
      framework = 'Create React App + TypeScript';
      buildTool = 'Create React App';
    } else if (dependencies.vite) {
      type = 'vite-react-ts';
      framework = 'Vite + React + TypeScript';
      buildTool = 'Vite';
    } else {
      const hasAppTsx = tsxFiles.some(file => file.includes('App.tsx'));
      const hasIndexTsx = tsxFiles.some(file => file.includes('index.tsx'));
      
      if (hasAppTsx || hasIndexTsx) {
        type = 'vite-react-ts';
        framework = 'Vite + React + TypeScript';
        buildTool = 'Vite';
        
        autoScripts = {
          dev: 'vite',
          build: 'vite build',
          start: 'vite',
          preview: 'vite preview'
        };
      }
    }

    return { type, framework, buildTool, autoScripts };
  }

  async generateTsxPackageJson(projectPath, tsxFiles) {
    const projectName = path.basename(projectPath).toLowerCase().replace(/[^a-z0-9-]/g, '-');
    
    const packageJson = {
      name: projectName,
      version: "1.0.0",
      type: "module",
      scripts: {
        dev: "vite",
        build: "vite build",
        start: "vite",
        preview: "vite preview"
      },
      dependencies: {
        react: "^18.2.0",
        "react-dom": "^18.2.0"
      },
      devDependencies: {
        "@types/react": "^18.2.0",
        "@types/react-dom": "^18.2.0",
        "@vitejs/plugin-react": "^4.0.0",
        typescript: "^5.0.0",
        vite: "^4.4.0"
      }
    };

    const viteConfig = `import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true
  }
})`;

    try {
      await fs.writeFile(path.join(projectPath, 'vite.config.ts'), viteConfig);
    } catch (error) {
      console.log('Could not write vite.config.ts:', error.message);
    }

    return packageJson;
  }

  async checkReactImports(tsxFiles) {
    for (const file of tsxFiles.slice(0, 3)) {
      try {
        const content = await fs.readFile(file, 'utf8');
        if (content.includes('import React') || content.includes('from "react"') || content.includes('from \'react\'')) {
          return true;
        }
      } catch {
        continue;
      }
    }
    return false;
  }

  async detectProject(projectPath) {
    try {
      const packageJsonPath = path.join(projectPath, 'package.json');
      const hasPackageJson = await fs.access(packageJsonPath).then(() => true).catch(() => false);
      
      const tsxFiles = await this.findTsxFiles(projectPath);
      const hasTypeScript = await this.hasTypeScriptConfig(projectPath);
      
      if (!hasPackageJson && tsxFiles.length === 0) {
        return { type: 'unknown', hasPackageJson: false };
      }

      let packageJson = {};
      if (hasPackageJson) {
        packageJson = JSON.parse(await fs.readFile(packageJsonPath, 'utf8'));
      }

      const dependencies = { ...packageJson.dependencies, ...packageJson.devDependencies };
      
      let projectType = 'unknown';
      let framework = '';
      let buildTool = '';
      let autoScripts = {};

      if (tsxFiles.length > 0 || dependencies.typescript || hasTypeScript) {
        const tsxProjectInfo = await this.detectTsxProject(projectPath, dependencies, tsxFiles);
        projectType = tsxProjectInfo.type;
        framework = tsxProjectInfo.framework;
        buildTool = tsxProjectInfo.buildTool;
        autoScripts = tsxProjectInfo.autoScripts;
      } else {
        if (dependencies.react) {
          framework = 'React';
          if (dependencies.next) {
            projectType = 'nextjs';
            framework = 'Next.js';
          } else if (dependencies['react-scripts']) {
            projectType = 'cra';
            framework = 'Create React App';
          } else {
            projectType = 'react';
          }
        }
      }

      if (dependencies.vite) buildTool = 'Vite';
      else if (dependencies.webpack) buildTool = 'Webpack';

      if (!hasPackageJson && tsxFiles.length > 0) {
        packageJson = await this.generateTsxPackageJson(projectPath, tsxFiles);
        autoScripts = packageJson.scripts;
      }

      return {
        type: projectType,
        framework,
        buildTool,
        hasPackageJson,
        packageJson,
        scripts: { ...packageJson.scripts, ...autoScripts },
        name: packageJson.name || path.basename(projectPath),
        tsxFiles,
        hasTypeScript,
        isAutoGenerated: !hasPackageJson && tsxFiles.length > 0
      };
    } catch (error) {
      return { type: 'error', error: error.message };
    }
  }
}

// Test Suite
class TSXDetectionTestSuite {
  constructor() {
    this.runner = new TestableEnhancedProjectRunner();
    this.testResults = [];
    this.testFolders = [];
  }

  async setupTestEnvironment() {
    console.log('🔧 Setting up test environment...');
    
    // Create test directories
    const testDirs = [
      '/tmp/test-tsx-only',
      '/tmp/test-tsx-existing', 
      '/tmp/test-mixed',
      '/tmp/test-nested',
      '/tmp/test-nested/src',
      '/tmp/test-nested/components'
    ];

    for (const dir of testDirs) {
      try {
        await fs.mkdir(dir, { recursive: true });
        this.testFolders.push(dir);
      } catch (error) {
        console.error(`Failed to create ${dir}:`, error.message);
      }
    }

    // Create test files
    await this.createTestFiles();
    console.log('✅ Test environment setup complete');
  }

  async createTestFiles() {
    // TSX-only folder
    const tsxOnlyFiles = {
      'App.tsx': `import React, { useState } from 'react';

function App() {
  const [count, setCount] = useState(0);
  return (
    <div>
      <h1>TSX Only Project</h1>
      <button onClick={() => setCount(count + 1)}>Count: {count}</button>
    </div>
  );
}

export default App;`,
      'index.tsx': `import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root')!);
root.render(<App />);`
    };

    for (const [filename, content] of Object.entries(tsxOnlyFiles)) {
      await fs.writeFile(path.join('/tmp/test-tsx-only', filename), content);
    }

    // TSX with existing package.json
    const existingPackageJson = {
      name: 'existing-tsx-project',
      version: '1.0.0',
      dependencies: {
        react: '^18.0.0',
        'react-dom': '^18.0.0'
      },
      devDependencies: {
        typescript: '^5.0.0',
        vite: '^4.0.0'
      }
    };

    await fs.writeFile(
      path.join('/tmp/test-tsx-existing', 'package.json'),
      JSON.stringify(existingPackageJson, null, 2)
    );
    await fs.writeFile(
      path.join('/tmp/test-tsx-existing', 'Component.tsx'),
      `import React from 'react';
export const Component = () => <div>Existing TSX Project</div>;`
    );

    // Mixed project
    await fs.writeFile(
      path.join('/tmp/test-mixed', 'script.js'),
      'console.log("JavaScript file");'
    );
    await fs.writeFile(
      path.join('/tmp/test-mixed', 'Component.jsx'),
      'import React from "react"; export default () => <div>JSX</div>;'
    );
    await fs.writeFile(
      path.join('/tmp/test-mixed', 'TypedComponent.tsx'),
      'import React from "react"; export const TypedComponent: React.FC = () => <div>TSX</div>;'
    );

    // Nested structure
    await fs.writeFile(
      path.join('/tmp/test-nested/src', 'main.tsx'),
      'import React from "react"; import ReactDOM from "react-dom/client";'
    );
    await fs.writeFile(
      path.join('/tmp/test-nested/components', 'Button.tsx'),
      'import React from "react"; export const Button = () => <button>Click me</button>;'
    );
  }

  async runTest(testName, testFunction) {
    console.log(`\n🧪 Running test: ${testName}`);
    try {
      const result = await testFunction();
      console.log(`✅ ${testName}: PASSED`);
      this.testResults.push({ name: testName, status: 'PASSED', result });
      return result;
    } catch (error) {
      console.log(`❌ ${testName}: FAILED - ${error.message}`);
      this.testResults.push({ name: testName, status: 'FAILED', error: error.message });
      throw error;
    }
  }

  async testFindTsxFiles() {
    return await this.runTest('TSX File Detection Engine', async () => {
      // Test TSX-only folder
      const tsxOnlyFiles = await this.runner.findTsxFiles('/tmp/test-tsx-only');
      if (tsxOnlyFiles.length !== 2) {
        throw new Error(`Expected 2 TSX files, found ${tsxOnlyFiles.length}`);
      }

      // Test nested structure with depth limit
      const nestedFiles = await this.runner.findTsxFiles('/tmp/test-nested', 2);
      if (nestedFiles.length !== 2) {
        throw new Error(`Expected 2 nested TSX files, found ${nestedFiles.length}`);
      }

      // Test mixed folder
      const mixedFiles = await this.runner.findTsxFiles('/tmp/test-mixed');
      if (mixedFiles.length !== 1) {
        throw new Error(`Expected 1 TSX file in mixed folder, found ${mixedFiles.length}`);
      }

      return {
        tsxOnlyCount: tsxOnlyFiles.length,
        nestedCount: nestedFiles.length,
        mixedCount: mixedFiles.length
      };
    });
  }

  async testProjectDetection() {
    return await this.runTest('Enhanced Project Detection with TSX Support', async () => {
      // Test TSX-only folder (should auto-generate)
      const tsxOnlyDetection = await this.runner.detectProject('/tmp/test-tsx-only');
      if (!tsxOnlyDetection.isAutoGenerated) {
        throw new Error('TSX-only folder should be marked as auto-generated');
      }
      if (tsxOnlyDetection.type !== 'vite-react-ts') {
        throw new Error(`Expected vite-react-ts, got ${tsxOnlyDetection.type}`);
      }

      // Test existing project
      const existingDetection = await this.runner.detectProject('/tmp/test-tsx-existing');
      if (existingDetection.isAutoGenerated) {
        throw new Error('Existing project should not be marked as auto-generated');
      }
      if (!existingDetection.hasPackageJson) {
        throw new Error('Should detect existing package.json');
      }

      // Test mixed project
      const mixedDetection = await this.runner.detectProject('/tmp/test-mixed');
      if (mixedDetection.tsxFiles.length !== 1) {
        throw new Error('Should detect 1 TSX file in mixed project');
      }

      return {
        tsxOnly: tsxOnlyDetection,
        existing: existingDetection,
        mixed: mixedDetection
      };
    });
  }

  async testPackageJsonGeneration() {
    return await this.runTest('Auto-Package.json Generation for TSX Projects', async () => {
      const tsxFiles = await this.runner.findTsxFiles('/tmp/test-tsx-only');
      const packageJson = await this.runner.generateTsxPackageJson('/tmp/test-tsx-only', tsxFiles);

      // Verify package.json structure
      if (!packageJson.dependencies.react) {
        throw new Error('Generated package.json should include React dependency');
      }
      if (!packageJson.devDependencies.typescript) {
        throw new Error('Generated package.json should include TypeScript dev dependency');
      }
      if (!packageJson.devDependencies.vite) {
        throw new Error('Generated package.json should include Vite dev dependency');
      }
      if (packageJson.scripts.dev !== 'vite') {
        throw new Error('Generated package.json should have correct dev script');
      }

      // Check if vite.config.ts was created
      const viteConfigExists = await fs.access(path.join('/tmp/test-tsx-only', 'vite.config.ts'))
        .then(() => true).catch(() => false);
      if (!viteConfigExists) {
        throw new Error('vite.config.ts should be auto-created');
      }

      return {
        packageJson,
        viteConfigCreated: viteConfigExists
      };
    });
  }

  async cleanup() {
    console.log('\n🧹 Cleaning up test environment...');
    for (const folder of this.testFolders) {
      try {
        await fs.rm(folder, { recursive: true, force: true });
      } catch (error) {
        console.log(`Warning: Could not clean up ${folder}`);
      }
    }
    console.log('✅ Cleanup complete');
  }

  async runAllTests() {
    console.log('🚀 Starting TSX Detection Test Suite...\n');
    
    try {
      await this.setupTestEnvironment();
      
      // Run all tests
      await this.testFindTsxFiles();
      await this.testProjectDetection();
      await this.testPackageJsonGeneration();
      
      // Print summary
      console.log('\n📊 Test Results Summary:');
      console.log('========================');
      
      const passed = this.testResults.filter(t => t.status === 'PASSED').length;
      const failed = this.testResults.filter(t => t.status === 'FAILED').length;
      
      console.log(`✅ Passed: ${passed}`);
      console.log(`❌ Failed: ${failed}`);
      console.log(`📈 Success Rate: ${((passed / this.testResults.length) * 100).toFixed(1)}%`);
      
      if (failed > 0) {
        console.log('\n❌ Failed Tests:');
        this.testResults.filter(t => t.status === 'FAILED').forEach(test => {
          console.log(`  - ${test.name}: ${test.error}`);
        });
      }
      
      return {
        totalTests: this.testResults.length,
        passed,
        failed,
        successRate: (passed / this.testResults.length) * 100,
        results: this.testResults
      };
      
    } finally {
      await this.cleanup();
    }
  }
}

// Run the tests
async function runBackendTests() {
  const testSuite = new TSXDetectionTestSuite();
  return await testSuite.runAllTests();
}

// Export for use
if (require.main === module) {
  runBackendTests().then(results => {
    console.log('\n🎯 Final Test Results:', results);
    process.exit(results.failed > 0 ? 1 : 0);
  }).catch(error => {
    console.error('💥 Test suite failed:', error);
    process.exit(1);
  });
}

module.exports = { runBackendTests, TSXDetectionTestSuite };