# Overview

This is a full-stack web application built with React/TypeScript frontend and Express.js backend. GoLoyal is a SaaS platform that helps local businesses launch loyalty programs and digital coupons that integrate with Apple Wallet and Google Wallet. The application features a modern landing page with demo request functionality, comprehensive UI components from shadcn/ui, and full deployment infrastructure for Google Cloud Platform.

# Recent Changes

**August 22, 2025**: Added comprehensive deployment infrastructure for Google Cloud Platform
- Created multi-stage Dockerfile for containerized deployment
- Implemented GitHub Actions workflow with automated CI/CD pipeline
- Built Terraform infrastructure as code for GCP resources (Cloud Run, Cloud SQL, VPC)
- Configured production-ready security and networking
- Added deployment documentation and setup guides

**August 23, 2025**: Added multi-cloud deployment support with Azure integration
- Created Azure infrastructure templates using Bicep for Container Apps and PostgreSQL
- Built comprehensive multi-cloud GitHub Actions workflow supporting Azure and GCP
- Added automated setup scripts for both cloud providers
- Implemented environment-specific deployments (dev, staging, prod)
- Created detailed multi-cloud deployment documentation with cost comparisons
- Added manual workflow dispatch for flexible deployment targeting

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## Frontend Architecture
- **Framework**: React 18 with TypeScript using Vite as the build tool
- **Routing**: Wouter for lightweight client-side routing
- **State Management**: TanStack Query (React Query) for server state management
- **UI Library**: shadcn/ui components built on Radix UI primitives
- **Styling**: Tailwind CSS with CSS custom properties for theming
- **Form Handling**: React Hook Form with Zod validation
- **Development**: Hot module replacement and error overlay for development experience

## Backend Architecture  
- **Framework**: Express.js with TypeScript
- **Database ORM**: Drizzle ORM with PostgreSQL dialect
- **API Design**: RESTful API with JSON responses
- **Error Handling**: Centralized error handling middleware
- **Logging**: Custom request/response logging with duration tracking
- **Session Management**: PostgreSQL session store (connect-pg-simple)

## Database Design
- **Users Table**: Basic user authentication with username/password
- **Demo Requests Table**: Business contact information for demo scheduling
- **Schema Validation**: Drizzle-Zod integration for runtime type safety
- **Migrations**: Drizzle Kit for database schema management

## Development Environment
- **Build System**: Vite for frontend, esbuild for backend production builds
- **Type Safety**: Strict TypeScript configuration with path aliases
- **Code Quality**: ESM modules throughout the application
- **Development Server**: Vite dev server with proxy configuration for API calls

## Storage Layer
- **Primary Storage**: PostgreSQL database via Neon serverless
- **Fallback Storage**: In-memory storage implementation for development
- **Connection Management**: Environment-based database URL configuration
- **Data Validation**: Zod schemas for all database operations

# External Dependencies

## Database Services
- **Neon Database**: Serverless PostgreSQL hosting (@neondatabase/serverless)
- **PostgreSQL**: Primary database with UUID generation and timestamp support

## UI and Styling
- **Radix UI**: Comprehensive set of accessible component primitives
- **Tailwind CSS**: Utility-first CSS framework with custom design tokens
- **Lucide React**: Icon library for consistent iconography
- **Google Fonts**: Inter font family for typography

## Development Tools
- **Replit Integration**: Vite plugin for runtime error modal and cartographer
- **PostCSS**: CSS processing with Tailwind CSS and Autoprefixer
- **TypeScript**: Static type checking with strict configuration

## Form and Validation
- **React Hook Form**: Form state management with TypeScript support
- **Zod**: Runtime type validation and schema definition
- **Hookform Resolvers**: Integration between React Hook Form and Zod

## Build and Deployment
- **Vite**: Frontend build tool with React plugin
- **ESBuild**: Backend bundling for production
- **TSX**: TypeScript execution for development server