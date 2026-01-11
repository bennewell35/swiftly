# Jest Testing & Gemini Code Review Setup Guide

## Important Note

**Jest is for JavaScript/TypeScript projects**, not Swift/iOS. 

- **For Swift/iOS projects**: Use **XCTest** (built into Xcode)
- **For JavaScript/TypeScript projects**: Use **Jest**

This guide covers both Jest setup (for JS/TS) and Gemini Code Review setup (works for any language).

---

## Part 1: Setting Up Jest (JavaScript/TypeScript Projects)

### 1. Install Jest

```bash
npm install --save-dev jest
```

Or with TypeScript support:

```bash
npm install --save-dev jest @types/jest ts-jest typescript
```

### 2. Configure Jest

**Option A: Basic setup (package.json)**

Add to your `package.json`:

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  },
  "jest": {
    "testEnvironment": "node",
    "coveragePathIgnorePatterns": [
      "/node_modules/"
    ]
  }
}
```

**Option B: TypeScript setup (jest.config.js)**

Create `jest.config.js`:

```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
};
```

### 3. Write Tests

Create test files with `.test.js`, `.spec.js`, `.test.ts`, or `.spec.ts`:

```javascript
// sum.js
function sum(a, b) {
  return a + b;
}
module.exports = sum;

// sum.test.js
const sum = require('./sum');

describe('sum function', () => {
  test('adds 1 + 2 to equal 3', () => {
    expect(sum(1, 2)).toBe(3);
  });

  test('handles negative numbers', () => {
    expect(sum(-1, -2)).toBe(-3);
  });
});
```

### 4. Run Tests

```bash
# Run all tests
npm test

# Watch mode (re-runs on file changes)
npm run test:watch

# With coverage report
npm run test:coverage
```

### 5. GitHub Actions Integration

Create `.github/workflows/test.yml`:

```yaml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18.x, 20.x]

    steps:
    - uses: actions/checkout@v4

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Run tests
      run: npm test

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      if: matrix.node-version == '20.x'
      with:
        files: ./coverage/lcov.info
```

---

## Part 2: Gemini Code Review Assistant Setup (GitHub)

Gemini Code Assist provides AI-powered code reviews directly in GitHub pull requests.

### Step 1: Install Gemini Code Assist

1. Go to [Gemini Code Assist GitHub Marketplace](https://github.com/marketplace/gemini-code-assist)
2. Click **"Set up a plan"** or **"Install"**
3. Choose your plan:
   - **Free tier**: Limited reviews per month
   - **Paid plans**: More reviews, faster responses

### Step 2: Configure Repository Access

1. During installation, select repositories:
   - **All repositories** (recommended for personal accounts)
   - **Only select repositories** (recommended for organizations)
2. Grant necessary permissions:
   - Read access to pull requests
   - Write access to comments
   - Read access to code

### Step 3: Usage

#### Automatic Reviews

Gemini Code Assist **automatically reviews** new pull requests within ~5 minutes:
- Analyzes code changes
- Adds comments with suggestions
- Provides security insights
- Suggests improvements

#### Manual Invocation

Comment on a pull request to request reviews:

```
/gemini review
```

Request a summary:

```
/gemini summary
```

Request a focused review:

```
/gemini review security
/gemini review performance
```

### Step 4: Configuration (Optional)

Create `.github/gemini-code-assist.yml`:

```yaml
# Configuration for Gemini Code Assist
reviews:
  # Enable/disable automatic reviews
  auto_review: true
  
  # Minimum lines changed to trigger review
  min_lines: 10
  
  # Focus areas
  focus:
    - security
    - performance
    - best_practices
  
  # Exclude file patterns
  exclude:
    - "*.min.js"
    - "dist/**"
    - "node_modules/**"
  
  # Language-specific settings
  languages:
    - javascript
    - typescript
    - python
    - swift  # Yes, it works for Swift too!
```

### Step 5: GitHub Actions Integration (Alternative)

If you want more control, you can use Gemini API directly in GitHub Actions:

Create `.github/workflows/gemini-review.yml`:

```yaml
name: Gemini Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
    
    - name: Run Gemini Review
      uses: actions/github-script@v7
      env:
        GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
      with:
        script: |
          // This is a simplified example
          // You'll need to implement the actual Gemini API call
          const diff = await github.rest.pulls.get({
            owner: context.repo.owner,
            repo: context.repo.repo,
            pull_number: context.issue.number,
          });
          
          // Call Gemini API and post review comments
          // See Gemini API docs for implementation
```

**Note**: The official GitHub App is easier than manual API integration.

---

## Part 3: For Swift/iOS Projects (This Repository)

Since this is a **Swift project**, here's what you should use instead:

### Swift Testing: XCTest

Tests are already set up in the `SwiftExperiment` directory. See:

- `SwiftExperiment/Tests/NoteTests.swift` - Example test file
- `SwiftExperiment/.github/workflows/ios-ci.yml` - CI/CD with tests

**Run tests:**
```bash
# In Xcode: Cmd + U
# Or command line:
xcodebuild test \
  -project DailyReadiness.xcodeproj \
  -scheme DailyReadiness \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Gemini Code Review for Swift

Gemini Code Assist **works with Swift code too!** Just install the GitHub App as described above. It will:
- Review Swift code
- Suggest improvements
- Check for common Swift patterns
- Review SwiftUI code

---

## Quick Setup Checklist

### For JavaScript/TypeScript Project:
- [ ] Install Jest: `npm install --save-dev jest`
- [ ] Configure `package.json` or `jest.config.js`
- [ ] Write test files (`*.test.js` or `*.test.ts`)
- [ ] Add test script: `npm test`
- [ ] (Optional) Set up GitHub Actions for CI

### For Gemini Code Review:
- [ ] Install Gemini Code Assist from GitHub Marketplace
- [ ] Select repositories to enable
- [ ] Test with a pull request (auto-review should trigger)
- [ ] (Optional) Create `.github/gemini-code-assist.yml` config
- [ ] Use `/gemini review` for manual reviews

---

## Resources

- **Jest Documentation**: https://jestjs.io/
- **Gemini Code Assist**: https://github.com/marketplace/gemini-code-assist
- **Gemini Code Assist Docs**: https://developers.google.com/gemini-code-assist/docs/set-up-code-assist-github
- **Swift Testing (XCTest)**: https://developer.apple.com/documentation/xctest

---

## Example: Complete Jest + Gemini Setup

Here's a minimal working example:

**package.json:**
```json
{
  "name": "my-project",
  "version": "1.0.0",
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch"
  },
  "devDependencies": {
    "jest": "^29.7.0"
  }
}
```

**math.js:**
```javascript
function add(a, b) {
  return a + b;
}

module.exports = { add };
```

**math.test.js:**
```javascript
const { add } = require('./math');

test('adds 1 + 2 to equal 3', () => {
  expect(add(1, 2)).toBe(3);
});
```

Run: `npm test`

Then install Gemini Code Assist from GitHub Marketplace, and it will automatically review your pull requests!

