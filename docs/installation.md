# Installation Guide

This guide will help you install and set up GoLoyal on your local machine for development.

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

- **Node.js** (version 18 or higher)
  ```bash
  # Check your Node.js version
  node --version
  ```
  
- **npm** (comes with Node.js)
  ```bash
  # Check your npm version
  npm --version
  ```

- **Git**
  ```bash
  # Check your Git version
  git --version
  ```

### Optional Software

- **Docker** (for containerized development)
  ```bash
  # Check your Docker version
  docker --version
  ```

- **Azure CLI** (for deployment)
  ```bash
  # Check your Azure CLI version
  az --version
  ```

## Installation Steps

### 1. Clone the Repository

```bash
# Clone the repository
git clone https://github.com/your-org/goloyal-landing-page.git

# Navigate to the project directory
cd goloyal-landing-page
```

### 2. Install Dependencies

```bash
# Install all dependencies
npm install
```

This will install all required packages for both frontend and backend.

### 3. Environment Configuration

```bash
# Copy the example environment file
cp .env.example .env

# Edit the environment file with your configuration
nano .env  # or use your preferred editor
```

### 4. Database Setup

#### Option A: Local PostgreSQL (Recommended for Development)

1. **Install PostgreSQL**
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install postgresql postgresql-contrib
   
   # macOS (using Homebrew)
   brew install postgresql
   brew services start postgresql
   
   # Windows
   # Download from https://www.postgresql.org/download/windows/
   ```

2. **Create Database**
   ```bash
   # Connect to PostgreSQL
   sudo -u postgres psql
   
   # Create database and user
   CREATE DATABASE goloyal;
   CREATE USER goloyal_user WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE goloyal TO goloyal_user;
   \q
   ```

3. **Update Environment Variables**
   ```env
   DATABASE_URL=postgresql://goloyal_user:your_password@localhost:5432/goloyal
   ```

#### Option B: Neon Database (Cloud PostgreSQL)

1. **Sign up at [Neon](https://neon.tech)**
2. **Create a new project**
3. **Get your connection string**
4. **Update your .env file**
   ```env
   DATABASE_URL=postgresql://user:password@host:port/database?sslmode=require
   ```

### 5. Database Migration

```bash
# Push the database schema
npm run db:push
```

### 6. Start Development Server

```bash
# Start the development server
npm run dev
```

The application will be available at `http://localhost:5000`

## Verification

### 1. Check Application Health

Visit the health check endpoint:
```bash
curl http://localhost:5000/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "environment": "development",
  "version": "1.0.0"
}
```

### 2. Test API Endpoints

```bash
# Test API version endpoint
curl http://localhost:5000/api/version

# Test API documentation endpoint
curl http://localhost:5000/api/docs
```

### 3. Verify Frontend

Open your browser and navigate to `http://localhost:5000` to see the landing page.

## Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Check what's using port 5000
lsof -i :5000

# Kill the process or change the port in .env
PORT=5001 npm run dev
```

#### Database Connection Issues
```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Start PostgreSQL if needed
sudo systemctl start postgresql
```

#### Node Modules Issues
```bash
# Clear npm cache
npm cache clean --force

# Remove node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

#### Permission Issues
```bash
# Fix npm permissions
sudo chown -R $USER:$GROUP ~/.npm
sudo chown -R $USER:$GROUP ~/.config
```

### Getting Help

If you encounter issues:

1. **Check the logs** in your terminal
2. **Verify your environment variables**
3. **Ensure all prerequisites are installed**
4. **Check the [Troubleshooting Guide](./troubleshooting.md)**
5. **Open an issue** on GitHub

## Next Steps

After successful installation:

1. **Read the [Quick Start Guide](./quick-start.md)** to learn the basics
2. **Explore the [API Documentation](./api.md)** to understand the backend
3. **Check the [Contributing Guidelines](./CONTRIBUTING.md)** if you want to contribute
4. **Review the [Architecture Documentation](./architecture.md)** to understand the system design

## Development Tools

### Recommended VS Code Extensions

- **TypeScript and JavaScript Language Features**
- **ESLint**
- **Prettier**
- **Tailwind CSS IntelliSense**
- **GitLens**
- **Docker**

### VS Code Settings

Create `.vscode/settings.json` in your project:

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.preferences.importModuleSpecifier": "relative"
}
```

---

**Need help?** Check our [Troubleshooting Guide](./troubleshooting.md) or open an issue on GitHub.
