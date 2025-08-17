const fs = require('fs').promises;
const path = require('path');

// Test IPC handlers functionality
class IPCHandlerTestSuite {
  constructor() {
    this.testResults = [];
    this.testFolders = [];
  }

  async setupTestEnvironment() {
    console.log('🔧 Setting up IPC handler test environment...');
    
    // Create test directories for IPC testing
    const testDirs = [
      '/tmp/ipc-test-tsx-only',
      '/tmp/ipc-test-existing',
      '/tmp/ipc-test-mixed',
      '/tmp/ipc-test-nested',
      '/tmp/ipc-test-nested/src'
    ];

    for (const dir of testDirs) {
      try {
        await fs.mkdir(dir, { recursive: true });
        this.testFolders.push(dir);
      } catch (error) {
        console.error(`Failed to create ${dir}:`, error.message);
      }
    }

    await this.createIPCTestFiles();
    console.log('✅ IPC test environment setup complete');
  }

  async createIPCTestFiles() {
    // Create TSX-only project
    await fs.writeFile(
      path.join('/tmp/ipc-test-tsx-only', 'App.tsx'),
      `import React from 'react';
export default function App() {
  return <div>TSX App</div>;
}`
    );

    await fs.writeFile(
      path.join('/tmp/ipc-test-tsx-only', 'main.tsx'),
      `import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
ReactDOM.createRoot(document.getElementById('root')!).render(<App />);`
    );

    // Create existing project with package.json
    const existingPackage = {
      name: 'existing-project',
      version: '1.0.0',
      dependencies: {
        react: '^18.0.0',
        'react-dom': '^18.0.0'
      },
      devDependencies: {
        typescript: '^5.0.0',
        '@vitejs/plugin-react': '^4.0.0',
        vite: '^4.0.0'
      },
      scripts: {
        dev: 'vite',
        build: 'vite build'
      }
    };

    await fs.writeFile(
      path.join('/tmp/ipc-test-existing', 'package.json'),
      JSON.stringify(existingPackage, null, 2)
    );

    await fs.writeFile(
      path.join('/tmp/ipc-test-existing', 'Component.tsx'),
      `import React from 'react';
export const Component = () => <div>Existing Component</div>;`
    );

    // Create mixed project
    await fs.writeFile(
      path.join('/tmp/ipc-test-mixed', 'index.js'),
      'console.log("Regular JS file");'
    );

    await fs.writeFile(
      path.join('/tmp/ipc-test-mixed', 'Component.tsx'),
      `import React from 'react';
export const MixedComponent: React.FC = () => <div>Mixed TSX</div>;`
    );

    // Create nested project
    await fs.writeFile(
      path.join('/tmp/ipc-test-nested/src', 'App.tsx'),
      `import React from 'react';
export default function NestedApp() {
  return <div>Nested TSX App</div>;
}`
    );
  }

  async runTest(testName, testFunction) {
    console.log(`\n🧪 Running IPC test: ${testName}`);
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

  // Simulate the detect-project IPC handler
  async simulateDetectProject(projectPath) {
    const packageJsonPath = path.join(projectPath, 'package.json');
    const hasPackageJson = await fs.access(packageJsonPath).then(() => true).catch(() => false);
    
    // Simulate findTsxFiles
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

    // Enhanced TSX/TypeScript detection
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

    // Detect build tool
    if (dependencies.vite) buildTool = 'Vite';
    else if (dependencies.webpack) buildTool = 'Webpack';

    // Auto-generate package.json if TSX files found but no package.json
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
  }

  // Simulate the setup-project IPC handler
  async simulateSetupProject(projectPath) {
    try {
      const detection = await this.simulateDetectProject(projectPath);
      
      if (detection.isAutoGenerated) {
        // Write the auto-generated package.json
        const packageJsonPath = path.join(projectPath, 'package.json');
        await fs.writeFile(packageJsonPath, JSON.stringify(detection.packageJson, null, 2));
        
        return { success: true, message: 'TSX project auto-configured!' };
      }
      
      return { success: true, message: 'Project already configured' };
    } catch (error) {
      return { success: false, error: error.message };
    }
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

    // Check for existing build tools and frameworks first
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
      // Auto-detect based on TSX file structure only if no existing framework
      const hasAppTsx = tsxFiles.some(file => file.includes('App.tsx'));
      const hasIndexTsx = tsxFiles.some(file => file.includes('index.tsx') || file.includes('main.tsx'));
      
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

  async testDetectProjectIPC() {
    return await this.runTest('Detect-Project IPC Handler', async () => {
      // Test TSX-only folder
      const tsxOnlyResult = await this.simulateDetectProject('/tmp/ipc-test-tsx-only');
      if (!tsxOnlyResult.isAutoGenerated) {
        throw new Error('TSX-only project should be marked as auto-generated');
      }
      if (tsxOnlyResult.type !== 'vite-react-ts') {
        throw new Error(`Expected vite-react-ts, got ${tsxOnlyResult.type}`);
      }
      if (tsxOnlyResult.tsxFiles.length !== 2) {
        throw new Error(`Expected 2 TSX files, found ${tsxOnlyResult.tsxFiles.length}`);
      }

      // Test existing project
      const existingResult = await this.simulateDetectProject('/tmp/ipc-test-existing');
      if (existingResult.isAutoGenerated) {
        throw new Error('Existing project should not be auto-generated');
      }
      if (!existingResult.hasPackageJson) {
        throw new Error('Should detect existing package.json');
      }
      if (existingResult.framework !== 'Vite + React + TypeScript') {
        throw new Error(`Expected 'Vite + React + TypeScript', got ${existingResult.framework}`);
      }

      // Test mixed project
      const mixedResult = await this.simulateDetectProject('/tmp/ipc-test-mixed');
      if (mixedResult.tsxFiles.length !== 1) {
        throw new Error(`Expected 1 TSX file in mixed project, found ${mixedResult.tsxFiles.length}`);
      }
      if (!mixedResult.isAutoGenerated) {
        throw new Error('Mixed project with TSX should be auto-generated');
      }

      return {
        tsxOnly: tsxOnlyResult,
        existing: existingResult,
        mixed: mixedResult
      };
    });
  }

  async testSetupProjectIPC() {
    return await this.runTest('Setup-Project IPC Handler', async () => {
      // Test auto-setup for TSX-only project
      const setupResult = await this.simulateSetupProject('/tmp/ipc-test-tsx-only');
      if (!setupResult.success) {
        throw new Error(`Setup failed: ${setupResult.error}`);
      }
      if (setupResult.message !== 'TSX project auto-configured!') {
        throw new Error(`Expected auto-configuration message, got: ${setupResult.message}`);
      }

      // Verify package.json was created
      const packageJsonPath = path.join('/tmp/ipc-test-tsx-only', 'package.json');
      const packageJsonExists = await fs.access(packageJsonPath).then(() => true).catch(() => false);
      if (!packageJsonExists) {
        throw new Error('package.json should be created during setup');
      }

      const packageJson = JSON.parse(await fs.readFile(packageJsonPath, 'utf8'));
      if (!packageJson.dependencies.react) {
        throw new Error('Generated package.json should include React');
      }
      if (!packageJson.devDependencies.vite) {
        throw new Error('Generated package.json should include Vite');
      }

      // Test setup for existing project
      const existingSetupResult = await this.simulateSetupProject('/tmp/ipc-test-existing');
      if (!existingSetupResult.success) {
        throw new Error(`Existing project setup failed: ${existingSetupResult.error}`);
      }
      if (existingSetupResult.message !== 'Project already configured') {
        throw new Error(`Expected 'already configured' message, got: ${existingSetupResult.message}`);
      }

      return {
        tsxOnlySetup: setupResult,
        existingSetup: existingSetupResult,
        packageJsonCreated: packageJsonExists
      };
    });
  }

  async testFrameworkDetection() {
    return await this.runTest('Framework Detection Logic', async () => {
      // Test Next.js detection
      const nextjsPackage = {
        dependencies: { react: '^18.0.0', next: '^13.0.0' },
        devDependencies: { typescript: '^5.0.0' }
      };
      const nextjsResult = await this.detectTsxProject('/tmp/test', nextjsPackage, ['/tmp/test/page.tsx']);
      if (nextjsResult.type !== 'nextjs-ts') {
        throw new Error(`Expected nextjs-ts, got ${nextjsResult.type}`);
      }

      // Test CRA detection
      const craPackage = {
        dependencies: { react: '^18.0.0', 'react-scripts': '^5.0.0' },
        devDependencies: { typescript: '^5.0.0' }
      };
      const craResult = await this.detectTsxProject('/tmp/test', craPackage, ['/tmp/test/App.tsx']);
      if (craResult.type !== 'cra-ts') {
        throw new Error(`Expected cra-ts, got ${craResult.type}`);
      }

      // Test Vite detection
      const vitePackage = {
        dependencies: { react: '^18.0.0' },
        devDependencies: { vite: '^4.0.0', typescript: '^5.0.0' }
      };
      const viteResult = await this.detectTsxProject('/tmp/test', vitePackage, ['/tmp/test/main.tsx']);
      if (viteResult.type !== 'vite-react-ts') {
        throw new Error(`Expected vite-react-ts, got ${viteResult.type}`);
      }

      return {
        nextjs: nextjsResult,
        cra: craResult,
        vite: viteResult
      };
    });
  }

  async cleanup() {
    console.log('\n🧹 Cleaning up IPC test environment...');
    for (const folder of this.testFolders) {
      try {
        await fs.rm(folder, { recursive: true, force: true });
      } catch (error) {
        console.log(`Warning: Could not clean up ${folder}`);
      }
    }
    console.log('✅ IPC cleanup complete');
  }

  async runAllTests() {
    console.log('🚀 Starting IPC Handler Test Suite...\n');
    
    try {
      await this.setupTestEnvironment();
      
      // Run all IPC tests
      await this.testDetectProjectIPC();
      await this.testSetupProjectIPC();
      await this.testFrameworkDetection();
      
      // Print summary
      console.log('\n📊 IPC Test Results Summary:');
      console.log('=============================');
      
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

// Run the IPC tests
async function runIPCTests() {
  const testSuite = new IPCHandlerTestSuite();
  return await testSuite.runAllTests();
}

// Export for use
if (require.main === module) {
  runIPCTests().then(results => {
    console.log('\n🎯 Final IPC Test Results:', results);
    process.exit(results.failed > 0 ? 1 : 0);
  }).catch(error => {
    console.error('💥 IPC test suite failed:', error);
    process.exit(1);
  });
}

module.exports = { runIPCTests, IPCHandlerTestSuite };