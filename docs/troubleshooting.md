# Troubleshooting Guide

This guide helps you resolve common issues when working with GoLoyal.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Development Issues](#development-issues)
- [Database Issues](#database-issues)
- [Deployment Issues](#deployment-issues)
- [Performance Issues](#performance-issues)
- [Getting Help](#getting-help)

## Installation Issues

### Node.js Version Issues

**Problem**: "Node.js version not supported" or similar errors.

**Solution**:
```bash
# Check your Node.js version
node --version

# If below 18, update Node.js
# Using nvm (recommended)
nvm install 18
nvm use 18

# Or download from https://nodejs.org/
```

### npm Install Fails

**Problem**: `npm install` fails with various errors.

**Solutions**:
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# If using yarn
rm -rf node_modules yarn.lock
yarn install

# Check for network issues
npm config get registry
npm config set registry https://registry.npmjs.org/
```

### Permission Issues

**Problem**: Permission denied errors during installation.

**Solutions**:
```bash
# Fix npm permissions
sudo chown -R $USER:$GROUP ~/.npm
sudo chown -R $USER:$GROUP ~/.config

# Or use nvm to avoid permission issues
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18
```

## Development Issues

### Port Already in Use

**Problem**: "Port 5000 is already in use" error.

**Solutions**:
```bash
# Find what's using the port
lsof -i :5000

# Kill the process
kill -9 <PID>

# Or use a different port
PORT=5001 npm run dev
```

### Vite Dev Server Issues

**Problem**: Vite dev server not working properly.

**Solutions**:
```bash
# Clear Vite cache
rm -rf node_modules/.vite

# Restart the dev server
npm run dev

# Check for TypeScript errors
npm run type-check
```

### TypeScript Errors

**Problem**: TypeScript compilation errors.

**Solutions**:
```bash
# Check for type errors
npm run type-check

# Fix auto-fixable issues
npm run lint -- --fix

# Update TypeScript if needed
npm update typescript
```

### ESLint/Prettier Issues

**Problem**: Code formatting or linting errors.

**Solutions**:
```bash
# Fix auto-fixable issues
npm run lint -- --fix

# Format code
npm run format

# Check specific files
npx eslint client/src/App.tsx
npx prettier --check client/src/App.tsx
```

## Database Issues

### Database Connection Failed

**Problem**: "Database connection failed" error.

**Solutions**:
```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Start PostgreSQL
sudo systemctl start postgresql

# Check connection string in .env
cat .env | grep DATABASE_URL

# Test connection manually
psql $DATABASE_URL
```

### Migration Issues

**Problem**: Database migrations fail.

**Solutions**:
```bash
# Reset database (WARNING: This will delete all data)
npm run db:push -- --force

# Check schema
npx drizzle-kit introspect

# Generate new migration
npx drizzle-kit generate
```

### Neon Database Issues

**Problem**: Issues with Neon cloud database.

**Solutions**:
1. **Check Neon dashboard** for connection status
2. **Verify connection string** format
3. **Check IP allowlist** if configured
4. **Test connection** using Neon's SQL editor

## Deployment Issues

### Docker Build Fails

**Problem**: Docker build fails with various errors.

**Solutions**:
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker build --no-cache -t goloyal-app .

# Check Dockerfile syntax
docker build --dry-run .
```

### Azure Deployment Issues

**Problem**: Terraform deployment fails.

**Solutions**:
```bash
# Check Azure CLI login
az account show

# Login to Azure
az login

# Check Terraform state
cd terraform
terraform plan

# Destroy and recreate if needed
terraform destroy
terraform apply
```

### Container App Issues

**Problem**: Azure Container App not working.

**Solutions**:
```bash
# Check container app status
az containerapp show --name goloyal-prod-app --resource-group goloyal-prod-rg

# View logs
az containerapp logs show --name goloyal-prod-app --resource-group goloyal-prod-rg

# Check environment variables
az containerapp show --name goloyal-prod-app --resource-group goloyal-prod-rg --query "properties.template.containers[0].env"
```

## Performance Issues

### Slow Development Server

**Problem**: Development server is slow.

**Solutions**:
```bash
# Check system resources
htop

# Increase Node.js memory limit
NODE_OPTIONS="--max-old-space-size=4096" npm run dev

# Use production build for testing
npm run build
npm run start
```

### Large Bundle Size

**Problem**: Production bundle is too large.

**Solutions**:
```bash
# Analyze bundle
npm run build
npx vite-bundle-analyzer dist/public/assets

# Check for duplicate dependencies
npm ls

# Optimize imports
# Use dynamic imports for large libraries
```

### Database Performance

**Problem**: Database queries are slow.

**Solutions**:
```bash
# Check database indexes
psql $DATABASE_URL -c "\d+ demo_requests"

# Analyze query performance
EXPLAIN ANALYZE SELECT * FROM demo_requests;

# Add indexes if needed
CREATE INDEX idx_demo_requests_created_at ON demo_requests(created_at);
```

## Common Error Messages

### "Module not found"

**Solution**:
```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Check import paths
# Ensure correct relative paths
```

### "Cannot find module 'typescript'"

**Solution**:
```bash
# Install TypeScript globally
npm install -g typescript

# Or install locally
npm install --save-dev typescript
```

### "EADDRINUSE"

**Solution**:
```bash
# Find and kill process using port
lsof -i :5000
kill -9 <PID>

# Or use different port
PORT=5001 npm run dev
```

### "ENOENT: no such file or directory"

**Solution**:
```bash
# Check file paths
ls -la

# Ensure files exist
# Check case sensitivity (important on Linux)
```

## Debugging Tips

### Enable Debug Logging

```bash
# Enable debug logging
DEBUG=* npm run dev

# Or set in .env
DEBUG=express:*,app:*
```

### Check Environment Variables

```bash
# Print environment variables
env | grep -E "(NODE_ENV|PORT|DATABASE)"

# Check .env file
cat .env
```

### Network Debugging

```bash
# Check network connectivity
curl -v http://localhost:5000/health

# Check DNS resolution
nslookup yourdomain.com

# Check SSL certificate
openssl s_client -connect yourdomain.com:443
```

## Getting Help

### Before Asking for Help

1. **Check this troubleshooting guide**
2. **Search existing issues** on GitHub
3. **Check the logs** for error messages
4. **Verify your environment** matches requirements
5. **Try the solutions** listed above

### When Asking for Help

Include the following information:

- **Error message** (full text)
- **Steps to reproduce** the issue
- **Environment details**:
  - OS and version
  - Node.js version
  - npm version
  - Database type and version
- **Relevant logs** or stack traces
- **What you've already tried**

### Where to Get Help

- **GitHub Issues**: [Create an issue](https://github.com/your-org/goloyal-landing-page/issues)
- **GitHub Discussions**: [Start a discussion](https://github.com/your-org/goloyal-landing-page/discussions)
- **Documentation**: Check our [Documentation Hub](./README.md)

### Useful Commands

```bash
# System information
node --version
npm --version
docker --version
terraform --version

# Project status
npm run type-check
npm run lint
npm test

# Database status
psql $DATABASE_URL -c "SELECT version();"

# Application status
curl http://localhost:5000/health
```

---

**Still having issues?** Open a [GitHub issue](https://github.com/your-org/goloyal-landing-page/issues) with detailed information about your problem.
