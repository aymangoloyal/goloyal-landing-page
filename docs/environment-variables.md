# Environment Variables

This document describes all environment variables used in the GoLoyal application.

## Quick Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `NODE_ENV` | No | `development` | Application environment |
| `PORT` | No | `5000` | Server port |
| `HOST` | No | `0.0.0.0` | Server host |
| `DATABASE_URL` | Yes | - | Database connection string |
| `VITE_API_BASE_URL` | No | - | Frontend API base URL |
| `SESSION_SECRET` | No | - | Session encryption secret |
| `JWT_SECRET` | No | - | JWT token secret |

## Application Configuration

### NODE_ENV
**Type**: `string`  
**Required**: No  
**Default**: `development`  
**Values**: `development`, `staging`, `production`

Sets the application environment. Affects logging, error handling, and feature flags.

```env
NODE_ENV=production
```

### PORT
**Type**: `number`  
**Required**: No  
**Default**: `5000`

The port on which the server will listen.

```env
PORT=5000
```

### HOST
**Type**: `string`  
**Required**: No  
**Default**: `0.0.0.0`

The host address on which the server will bind.

```env
HOST=0.0.0.0
```

## Database Configuration

### DATABASE_URL
**Type**: `string`  
**Required**: Yes  
**Format**: `postgresql://username:password@host:port/database?sslmode=require`

PostgreSQL connection string. Used by Drizzle ORM to connect to the database.

```env
# Local PostgreSQL
DATABASE_URL=postgresql://goloyal_user:password@localhost:5432/goloyal

# Neon Database
DATABASE_URL=postgresql://user:password@host:port/database?sslmode=require

# Azure PostgreSQL
DATABASE_URL=postgresql://goloyal_admin:password@server.postgres.database.azure.com:5432/goloyal?sslmode=require
```

## Frontend Configuration

### VITE_API_BASE_URL
**Type**: `string`  
**Required**: No  
**Default**: Empty string

Base URL for API requests from the frontend. If not set, relative URLs are used.

```env
# Development
VITE_API_BASE_URL=http://localhost:5000

# Production
VITE_API_BASE_URL=https://api.yourdomain.com
```

## Security Configuration

### SESSION_SECRET
**Type**: `string`  
**Required**: No  
**Default**: Random string

Secret key for encrypting session data. Should be a strong, random string in production.

```env
SESSION_SECRET=your-super-secret-session-key-here
```

### JWT_SECRET
**Type**: `string`  
**Required**: No  
**Default**: Random string

Secret key for signing JWT tokens. Should be a strong, random string in production.

```env
JWT_SECRET=your-super-secret-jwt-key-here
```

## Email Configuration (Future)

### SMTP_HOST
**Type**: `string`  
**Required**: No  
**Default**: `smtp.gmail.com`

SMTP server hostname for sending emails.

```env
SMTP_HOST=smtp.gmail.com
```

### SMTP_PORT
**Type**: `number`  
**Required**: No  
**Default**: `587`

SMTP server port.

```env
SMTP_PORT=587
```

### SMTP_USER
**Type**: `string`  
**Required**: No

SMTP username/email address.

```env
SMTP_USER=your-email@gmail.com
```

### SMTP_PASS
**Type**: `string`  
**Required**: No

SMTP password or app password.

```env
SMTP_PASS=your-app-password
```

## Monitoring Configuration

### ENABLE_LOGGING
**Type**: `boolean`  
**Required**: No  
**Default**: `true`

Enable or disable application logging.

```env
ENABLE_LOGGING=true
```

### LOG_LEVEL
**Type**: `string`  
**Required**: No  
**Default**: `info`  
**Values**: `error`, `warn`, `info`, `debug`

Logging level for application logs.

```env
LOG_LEVEL=debug
```

## Feature Flags

### ENABLE_ANALYTICS
**Type**: `boolean`  
**Required**: No  
**Default**: `false`

Enable analytics tracking.

```env
ENABLE_ANALYTICS=true
```

### ENABLE_NOTIFICATIONS
**Type**: `boolean`  
**Required**: No  
**Default**: `true`

Enable push notifications.

```env
ENABLE_NOTIFICATIONS=true
```

## Azure Configuration (Deployment)

### AZURE_SUBSCRIPTION_ID
**Type**: `string`  
**Required**: No

Azure subscription ID for deployment.

```env
AZURE_SUBSCRIPTION_ID=your-subscription-id
```

### AZURE_TENANT_ID
**Type**: `string`  
**Required**: No

Azure tenant ID for authentication.

```env
AZURE_TENANT_ID=your-tenant-id
```

### AZURE_CLIENT_ID
**Type**: `string`  
**Required**: No

Azure client ID for service principal.

```env
AZURE_CLIENT_ID=your-client-id
```

### AZURE_CLIENT_SECRET
**Type**: `string`  
**Required**: No

Azure client secret for service principal.

```env
AZURE_CLIENT_SECRET=your-client-secret
```

## Environment-Specific Configurations

### Development Environment

```env
NODE_ENV=development
PORT=5000
HOST=0.0.0.0
DATABASE_URL=postgresql://goloyal_user:password@localhost:5432/goloyal
VITE_API_BASE_URL=http://localhost:5000
ENABLE_LOGGING=true
LOG_LEVEL=debug
ENABLE_ANALYTICS=false
ENABLE_NOTIFICATIONS=true
```

### Staging Environment

```env
NODE_ENV=staging
PORT=5000
HOST=0.0.0.0
DATABASE_URL=postgresql://user:password@staging-host:5432/goloyal?sslmode=require
VITE_API_BASE_URL=https://staging-api.yourdomain.com
SESSION_SECRET=staging-session-secret
JWT_SECRET=staging-jwt-secret
ENABLE_LOGGING=true
LOG_LEVEL=info
ENABLE_ANALYTICS=true
ENABLE_NOTIFICATIONS=true
```

### Production Environment

```env
NODE_ENV=production
PORT=5000
HOST=0.0.0.0
DATABASE_URL=postgresql://goloyal_admin:password@prod-server.postgres.database.azure.com:5432/goloyal?sslmode=require
VITE_API_BASE_URL=https://api.yourdomain.com
SESSION_SECRET=production-super-secret-session-key
JWT_SECRET=production-super-secret-jwt-key
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=noreply@yourdomain.com
SMTP_PASS=your-app-password
ENABLE_LOGGING=true
LOG_LEVEL=warn
ENABLE_ANALYTICS=true
ENABLE_NOTIFICATIONS=true
```

## Security Best Practices

### 1. Use Strong Secrets
Generate strong, random secrets for production:

```bash
# Generate session secret
openssl rand -base64 32

# Generate JWT secret
openssl rand -base64 32
```

### 2. Environment-Specific Files
Use different `.env` files for different environments:

- `.env.development`
- `.env.staging`
- `.env.production`

### 3. Never Commit Secrets
Ensure `.env` files are in `.gitignore`:

```gitignore
.env
.env.local
.env.*.local
```

### 4. Use Azure Key Vault (Production)
Store sensitive values in Azure Key Vault:

```env
# Reference Key Vault secrets
DATABASE_URL=@Microsoft.KeyVault(SecretUri=https://your-vault.vault.azure.net/secrets/database-url/)
SESSION_SECRET=@Microsoft.KeyVault(SecretUri=https://your-vault.vault.azure.net/secrets/session-secret/)
```

## Validation

The application validates environment variables on startup. Missing required variables will cause the application to fail to start.

### Required Variables Check

```typescript
// Example validation
const requiredVars = ['DATABASE_URL'];
for (const varName of requiredVars) {
  if (!process.env[varName]) {
    throw new Error(`Missing required environment variable: ${varName}`);
  }
}
```

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check `DATABASE_URL` format
   - Verify database is running
   - Check network connectivity

2. **Port Already in Use**
   - Change `PORT` value
   - Kill process using the port

3. **Frontend API Calls Fail**
   - Check `VITE_API_BASE_URL` value
   - Verify CORS configuration
   - Check network connectivity

### Debug Environment Variables

```bash
# Print all environment variables
env

# Print specific variables
echo $NODE_ENV
echo $DATABASE_URL

# Check .env file
cat .env
```

---

**Need help?** Check our [Troubleshooting Guide](./troubleshooting.md) or open an issue on GitHub.
