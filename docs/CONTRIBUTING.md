# Contributing to GoLoyal

Thank you for your interest in contributing to GoLoyal! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Code Style](#code-style)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct. Please read it before contributing.

## Getting Started

1. **Fork the repository**
2. **Clone your fork**
   ```bash
   git clone https://github.com/your-username/goloyal-landing-page.git
   cd goloyal-landing-page
   ```
3. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- Node.js 18+
- npm or yarn
- Git
- Docker (optional)

### Installation

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start development server**
   ```bash
   npm run dev
   ```

### Available Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm run start` | Start production server |
| `npm run lint` | Run ESLint |
| `npm run format` | Format code with Prettier |
| `npm run type-check` | Run TypeScript type checking |
| `npm run test` | Run tests |
| `npm run test:watch` | Run tests in watch mode |
| `npm run test:coverage` | Run tests with coverage |

## Code Style

### TypeScript

- Use TypeScript for all new code
- Prefer `const` over `let` and `var`
- Use explicit return types for functions
- Avoid `any` type - use proper types or `unknown`
- Use interfaces for object shapes
- Use enums for constants

### React

- Use functional components with hooks
- Use TypeScript for props
- Follow React best practices
- Use proper naming conventions
- Keep components small and focused

### File Naming

- Use kebab-case for file names
- Use PascalCase for component names
- Use camelCase for variables and functions
- Use UPPER_SNAKE_CASE for constants

### Code Organization

```
client/src/
├── components/     # Reusable UI components
├── pages/         # Page components
├── hooks/         # Custom React hooks
├── lib/           # Utility functions
└── types/         # TypeScript type definitions
```

## Testing

### Writing Tests

- Write tests for all new features
- Use descriptive test names
- Test both success and error cases
- Mock external dependencies
- Use proper assertions

### Test Structure

```typescript
describe('ComponentName', () => {
  it('should render correctly', () => {
    // Test implementation
  });

  it('should handle user interactions', () => {
    // Test implementation
  });

  it('should handle errors gracefully', () => {
    // Test implementation
  });
});
```

### Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

## Pull Request Process

1. **Ensure your code follows the style guidelines**
   ```bash
   npm run lint
   npm run format
   npm run type-check
   ```

2. **Write or update tests**
   ```bash
   npm test
   ```

3. **Update documentation**
   - Update README.md if needed
   - Add JSDoc comments for new functions
   - Update API documentation

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Use the provided template
   - Describe your changes clearly
   - Link related issues
   - Request reviews from maintainers

### Commit Message Format

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Build or tool changes

Examples:
```
feat(auth): add user authentication
fix(api): resolve database connection issue
docs(readme): update installation instructions
```

## Issue Reporting

### Before Creating an Issue

1. Check existing issues
2. Search for similar problems
3. Try to reproduce the issue
4. Gather relevant information

### Issue Template

When creating an issue, please include:

- **Description**: Clear description of the problem
- **Steps to reproduce**: Detailed steps to reproduce the issue
- **Expected behavior**: What you expected to happen
- **Actual behavior**: What actually happened
- **Environment**: OS, browser, Node.js version
- **Screenshots**: If applicable
- **Additional context**: Any other relevant information

### Bug Reports

- Be specific and detailed
- Include error messages
- Provide reproduction steps
- Mention your environment

### Feature Requests

- Explain the problem you're solving
- Describe the proposed solution
- Consider alternatives
- Provide use cases

## Review Process

1. **Automated Checks**
   - CI/CD pipeline runs tests
   - Code quality checks
   - Security scans

2. **Code Review**
   - Maintainers review the code
   - Address feedback and suggestions
   - Make necessary changes

3. **Approval**
   - At least one maintainer approval required
   - All checks must pass
   - Documentation updated

## Getting Help

- **Documentation**: Check the README and docs
- **Issues**: Search existing issues
- **Discussions**: Use GitHub Discussions
- **Discord**: Join our community server

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to GoLoyal! 🚀
