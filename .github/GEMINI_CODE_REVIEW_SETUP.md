# Gemini Code Review Setup Guide

This repository is configured to work with **Gemini Code Assist** for AI-powered code reviews on pull requests.

## Quick Setup

### Step 1: Install Gemini Code Assist

1. Go to [Gemini Code Assist GitHub Marketplace](https://github.com/marketplace/gemini-code-assist)
2. Click **"Set up a plan"** or **"Install"**
3. Choose your plan:
   - **Free tier**: Limited reviews per month (good for personal/small projects)
   - **Paid plans**: More reviews, faster responses
4. Select this repository (`bennewell35/swiftly`) or "All repositories"

### Step 2: Configure Repository Access

During installation, grant these permissions:
- ✅ Read access to pull requests
- ✅ Write access to comments
- ✅ Read access to code

### Step 3: Usage

Gemini Code Assist will **automatically review** new pull requests within ~5 minutes. You can also manually trigger reviews:

#### Manual Commands

Comment on a pull request:

```
/gemini review
```

Request a summary:

```
/gemini summary
```

Request focused reviews:

```
/gemini review security
/gemini review performance
/gemini review best_practices
```

## What Gemini Reviews

For this Swift/iOS project, Gemini Code Assist will review:

- ✅ **Swift code quality** - Syntax, patterns, best practices
- ✅ **SwiftUI patterns** - View structure, state management
- ✅ **Architecture** - MVVM patterns, separation of concerns
- ✅ **Error handling** - Proper error management
- ✅ **Performance** - Efficient code patterns
- ✅ **Security** - Safe coding practices
- ✅ **Testing** - Test coverage and quality
- ✅ **Documentation** - Code comments and documentation

## Configuration (Optional)

Create `.github/gemini-code-assist.yml` for custom configuration:

```yaml
reviews:
  # Enable/disable automatic reviews
  auto_review: true
  
  # Minimum lines changed to trigger review
  min_lines: 10
  
  # Focus areas for this Swift project
  focus:
    - swift_best_practices
    - swiftui_patterns
    - architecture
    - testing
    - security
  
  # Exclude file patterns
  exclude:
    - "*.generated.swift"
    - "Pods/**"
    - "DerivedData/**"
    - "*.xcodeproj/**"
    - "*.xcworkspace/**"
  
  # Language-specific settings
  languages:
    - swift
    - objective-c  # If you have any Objective-C code
```

## Examples

### Example Review Request

1. Create a pull request
2. Wait ~5 minutes for automatic review, OR
3. Comment `/gemini review` for immediate review

Gemini will:
- Add comments to specific lines
- Suggest improvements
- Flag potential issues
- Provide explanations

### Example Response

Gemini might comment:

> **Line 42**: Consider using `@MainActor` for UI-related code
> 
> **Line 67**: This could benefit from error handling
> 
> **Overall**: Good separation of concerns! Consider adding unit tests for this function.

## Benefits for Swift Development

- **Learning**: Get feedback on Swift/SwiftUI patterns
- **Quality**: Catch issues before code review
- **Consistency**: Enforce coding standards
- **Documentation**: Get suggestions for better comments
- **Best Practices**: Learn iOS development patterns

## Troubleshooting

### Reviews not appearing?

1. Check that Gemini Code Assist is installed on the repository
2. Verify permissions are granted
3. Try manual command: `/gemini review`
4. Check GitHub Actions logs (if using Actions integration)

### Want to disable auto-reviews?

Create `.github/gemini-code-assist.yml`:

```yaml
reviews:
  auto_review: false
```

Then use `/gemini review` manually when needed.

## Resources

- [Gemini Code Assist Documentation](https://developers.google.com/gemini-code-assist/docs/set-up-code-assist-github)
- [GitHub Marketplace](https://github.com/marketplace/gemini-code-assist)
- [Gemini API Documentation](https://ai.google.dev/docs)

## Current Status

✅ Repository is ready for Gemini Code Review
✅ Tests are set up (XCTest)
✅ CI/CD workflow is configured
✅ Code structure is organized for AI review

Just install the GitHub App and start getting AI-powered code reviews!

