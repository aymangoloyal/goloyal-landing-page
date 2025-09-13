# Architecture Documentation

This document provides a comprehensive overview of the GoLoyal system architecture, including the technology stack, component relationships, and design decisions.

## System Overview

GoLoyal is a modern web application built with a React frontend and Express.js backend, designed to provide digital loyalty programs and digital coupons with Apple Wallet and Google Wallet integration.

## Architecture Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   Database      │
│   (React)       │◄──►│   (Express.js)  │◄──►│   (PostgreSQL)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Vite Dev      │    │   Middleware    │    │   Drizzle ORM   │
│   Server        │    │   (Security,    │    │   (Type-safe    │
│   (HMR)         │    │    Logging)     │    │    Queries)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Technology Stack

### Frontend
- **React 18**: UI framework with hooks
- **TypeScript**: Type safety and better developer experience
- **Vite**: Fast build tool and development server
- **Tailwind CSS**: Utility-first CSS framework
- **Radix UI**: Accessible component primitives
- **React Hook Form**: Form handling with validation
- **Zod**: Schema validation
- **TanStack Query**: Data fetching and caching
- **Wouter**: Lightweight routing

### Backend
- **Express.js**: Node.js web framework
- **TypeScript**: Type safety
- **Drizzle ORM**: Type-safe database queries
- **PostgreSQL**: Primary database
- **Passport.js**: Authentication (future)
- **Helmet**: Security headers
- **CORS**: Cross-origin resource sharing
- **Compression**: Response compression

### Infrastructure
- **Terraform**: Infrastructure as Code
- **Azure Container Apps**: Container orchestration
- **Azure PostgreSQL**: Managed database
- **Azure Container Registry**: Container image storage
- **Application Insights**: Monitoring and logging

## Component Architecture

### Frontend Components

```
client/src/
├── components/          # Reusable UI components
│   ├── ui/             # Radix UI components
│   └── ...             # Custom components
├── pages/              # Page components
│   ├── home.tsx        # Landing page
│   └── not-found.tsx   # 404 page
├── hooks/              # Custom React hooks
│   ├── use-mobile.tsx  # Mobile detection
│   └── use-toast.ts    # Toast notifications
├── lib/                # Utility functions
│   ├── queryClient.ts  # API client configuration
│   └── utils.ts        # General utilities
└── index.css           # Global styles
```

### Backend Components

```
server/
├── index.ts            # Application entry point
├── routes.ts           # API route definitions
├── storage.ts          # Data layer abstraction
├── vite.ts             # Vite integration
└── middleware/         # Express middleware
    ├── errorHandler.ts # Error handling
    └── requestLogger.ts # Request logging
```

### Shared Components

```
shared/
└── schema.ts           # Database schemas and validation
```

## Data Flow

### 1. User Interaction Flow

```
User Action → React Component → API Request → Express Route → Database → Response → UI Update
```

### 2. Demo Request Flow

```
1. User fills form → React Hook Form validation
2. Form submission → API request to /api/demo-requests
3. Express route → Zod validation → Storage layer
4. Database insert → Success response → Toast notification
```

### 3. Error Handling Flow

```
Error occurs → Error handler middleware → Logging → Structured response → UI error display
```

## Security Architecture

### Security Layers

1. **Network Security**
   - HTTPS enforcement
   - CORS configuration
   - Rate limiting

2. **Application Security**
   - Input validation (Zod)
   - SQL injection prevention (Drizzle ORM)
   - XSS protection (Helmet)
   - CSRF protection (future)

3. **Infrastructure Security**
   - Private network for database
   - Container security
   - Secrets management (Azure Key Vault)

### Authentication & Authorization

Currently using session-based authentication with plans for:
- JWT tokens
- OAuth integration
- Role-based access control

## Database Design

### Schema Overview

```sql
-- Users table (future)
CREATE TABLE users (
  id VARCHAR PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL
);

-- Demo requests table
CREATE TABLE demo_requests (
  id VARCHAR PRIMARY KEY DEFAULT gen_random_uuid(),
  business_name TEXT NOT NULL,
  contact_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL
);
```

### Database Relationships

- **One-to-Many**: Users → Demo Requests (future)
- **Many-to-Many**: Users → Loyalty Programs (future)

## API Design

### RESTful Endpoints

- `GET /health` - Health check
- `GET /api/version` - API version info
- `GET /api/docs` - API documentation
- `POST /api/demo-requests` - Submit demo request
- `GET /api/demo-requests` - List demo requests
- `GET /api/demo-requests/:id` - Get specific demo request

### Response Format

All API responses follow a consistent format:
```json
{
  "success": boolean,
  "data": object | null,
  "message": string | null,
  "timestamp": string
}
```

## Deployment Architecture

### Development Environment

```
┌─────────────────┐    ┌─────────────────┐
│   Vite Dev      │    │   Express.js    │
│   Server        │◄──►│   Server        │
│   (Port 5173)   │    │   (Port 5000)   │
└─────────────────┘    └─────────────────┘
```

### Production Environment

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Azure CDN     │    │   Azure         │    │   Azure         │
│   (Static       │◄──►│   Container     │◄──►│   PostgreSQL    │
│    Assets)      │    │   Apps          │    │   Database      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Performance Considerations

### Frontend Performance

- **Code Splitting**: Route-based code splitting
- **Lazy Loading**: Component lazy loading
- **Caching**: TanStack Query caching
- **Bundle Optimization**: Vite build optimization

### Backend Performance

- **Database Indexing**: Proper database indexes
- **Connection Pooling**: Database connection management
- **Caching**: Response caching (future)
- **Compression**: Response compression

### Infrastructure Performance

- **Auto-scaling**: Azure Container Apps scaling
- **CDN**: Static asset delivery
- **Load Balancing**: Azure load balancer

## Monitoring & Observability

### Application Monitoring

- **Application Insights**: Performance monitoring
- **Custom Logging**: Structured logging
- **Health Checks**: Application health monitoring
- **Error Tracking**: Error monitoring and alerting

### Infrastructure Monitoring

- **Azure Monitor**: Infrastructure metrics
- **Container Insights**: Container performance
- **Database Monitoring**: PostgreSQL performance

## Scalability Considerations

### Horizontal Scaling

- **Stateless Design**: No server-side state
- **Container Orchestration**: Azure Container Apps
- **Database Scaling**: Azure PostgreSQL scaling

### Vertical Scaling

- **Resource Limits**: CPU and memory limits
- **Database Resources**: PostgreSQL resource allocation

## Future Architecture Plans

### Phase 1: Authentication & User Management
- JWT-based authentication
- User registration and login
- Role-based access control

### Phase 2: Loyalty Program Features
- Digital loyalty cards
- Point system
- Reward management

### Phase 3: Wallet Integration
- Apple Wallet integration
- Google Wallet integration
- Push notifications

### Phase 4: Advanced Features
- Analytics dashboard
- Email marketing integration
- Mobile app development

## Development Workflow

### Local Development

1. **Clone repository**
2. **Install dependencies**: `npm install`
3. **Set up environment**: Copy `.env.example` to `.env`
4. **Start database**: PostgreSQL or Neon
5. **Run migrations**: `npm run db:push`
6. **Start development server**: `npm run dev`

### Deployment Pipeline

1. **Code commit** → GitHub
2. **Automated testing** → GitHub Actions
3. **Build application** → Docker image
4. **Deploy to Azure** → Terraform
5. **Health checks** → Application monitoring

## Best Practices

### Code Organization

- **Separation of Concerns**: Clear separation between layers
- **Type Safety**: TypeScript throughout the stack
- **Consistent Naming**: Follow established conventions
- **Documentation**: Comprehensive code documentation

### Security

- **Input Validation**: Validate all inputs
- **Error Handling**: Secure error responses
- **Authentication**: Proper authentication flows
- **Authorization**: Role-based access control

### Performance

- **Caching**: Implement appropriate caching
- **Optimization**: Regular performance reviews
- **Monitoring**: Continuous performance monitoring
- **Testing**: Performance testing

---

**Need help?** Check our [Troubleshooting Guide](./troubleshooting.md) or open an issue on GitHub.
