# GoLoyal Landing Page

A modern, responsive landing page for GoLoyal built with React, TypeScript, and Vite.

## Features

- 🚀 Modern React with TypeScript
- 🎨 Beautiful UI with Tailwind CSS
- 📱 Fully responsive design
- ⚡ Fast development with Vite
- 🐳 Docker ready for deployment

## Quick Start

### Development

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start development server:**
   ```bash
   npm run dev
   ```

3. **Open your browser:**
   Navigate to `http://localhost:5173`

### Production Build

```bash
npm run build
```

## Deployment

### Azure Container Apps (Recommended)

Deploy to Azure with a single command:

```bash
cd deployment
./deploy.sh
```

This will:
- Create Azure resources
- Build and push Docker image
- Deploy to Azure Container Apps
- Provide you with the application URL

For detailed deployment instructions, see [deployment/README.md](deployment/README.md).

### Manual Docker Deployment

1. **Build the Docker image:**
   ```bash
   docker build -t goloyal-landing-page .
   ```

2. **Run the container:**
   ```bash
   docker run -p 5000:5000 goloyal-landing-page
   ```

## Project Structure

```
├── client/                 # Frontend React application
├── server/                 # Backend server
├── shared/                 # Shared types and schemas
├── deployment/             # Deployment scripts and documentation
├── Dockerfile             # Docker configuration
└── package.json           # Project dependencies
```

## Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint
- `npm run type-check` - Run TypeScript type checking

## Technologies Used

- **Frontend**: React 18, TypeScript, Vite
- **Styling**: Tailwind CSS, shadcn/ui
- **Backend**: Node.js, Express
- **Database**: PostgreSQL (with Drizzle ORM)
- **Deployment**: Docker, Azure Container Apps

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.
