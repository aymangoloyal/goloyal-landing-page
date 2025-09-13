# API Documentation

This document provides comprehensive documentation for the GoLoyal API endpoints.

## Base URL

- **Development**: `http://localhost:5000`
- **Production**: `https://yourdomain.com`

## Authentication

Currently, the API uses session-based authentication. All endpoints that require authentication will return a 401 status code if not authenticated.

## Response Format

All API responses follow a consistent format:

### Success Response
```json
{
  "success": true,
  "data": {},
  "message": "Optional message",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message",
  "details": {},
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/endpoint"
}
```

## Rate Limiting

API endpoints are rate-limited to 100 requests per 15-minute window per IP address. When rate limited, you'll receive a 429 status code.

## Endpoints

### Health Check

#### GET /health

Check the health status of the application.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "environment": "development",
  "version": "1.0.0"
}
```

---

### API Information

#### GET /api/version

Get API version information.

**Response:**
```json
{
  "success": true,
  "data": {
    "version": "1.0.0",
    "environment": "development",
    "timestamp": "2024-01-01T00:00:00.000Z"
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### GET /api/docs

Get API documentation.

**Response:**
```json
{
  "success": true,
  "data": {
    "endpoints": [
      {
        "method": "POST",
        "path": "/api/demo-requests",
        "description": "Submit a demo request",
        "parameters": {
          "body": {
            "businessName": "string (required)",
            "contactName": "string (required)",
            "email": "string (required, valid email)",
            "phone": "string (optional)"
          }
        }
      }
    ]
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

### Demo Requests

#### POST /api/demo-requests

Submit a new demo request.

**Request Body:**
```json
{
  "businessName": "Acme Corp",
  "contactName": "John Doe",
  "email": "john@acme.com",
  "phone": "+1234567890"
}
```

**Validation Rules:**
- `businessName`: Required, non-empty string
- `contactName`: Required, non-empty string
- `email`: Required, valid email format
- `phone`: Optional, string

**Success Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid-string"
  },
  "message": "Demo request submitted successfully",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

**Error Response (400):**
```json
{
  "success": false,
  "error": "Validation Error",
  "details": [
    {
      "field": "email",
      "message": "Please enter a valid email address",
      "code": "invalid_string"
    }
  ],
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/demo-requests"
}
```

#### GET /api/demo-requests

Get all demo requests (paginated).

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)

**Example Request:**
```
GET /api/demo-requests?page=1&limit=5
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "requests": [
      {
        "id": "uuid-string",
        "businessName": "Acme Corp",
        "contactName": "John Doe",
        "email": "john@acme.com",
        "phone": "+1234567890",
        "createdAt": "2024-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 25,
      "totalPages": 3
    }
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### GET /api/demo-requests/:id

Get a specific demo request by ID.

**Path Parameters:**
- `id`: Demo request UUID

**Example Request:**
```
GET /api/demo-requests/123e4567-e89b-12d3-a456-426614174000
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "businessName": "Acme Corp",
    "contactName": "John Doe",
    "email": "john@acme.com",
    "phone": "+1234567890",
    "createdAt": "2024-01-01T00:00:00.000Z"
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

**Error Response (404):**
```json
{
  "success": false,
  "error": "Demo request not found",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/demo-requests/123e4567-e89b-12d3-a456-426614174000"
}
```

---

## Error Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request - Validation error |
| 401 | Unauthorized - Authentication required |
| 404 | Not Found - Resource not found |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error - Server error |

## Validation Errors

When validation fails, the response includes detailed error information:

```json
{
  "success": false,
  "error": "Validation Error",
  "details": [
    {
      "field": "email",
      "message": "Please enter a valid email address",
      "code": "invalid_string"
    },
    {
      "field": "businessName",
      "message": "Business name is required",
      "code": "invalid_string"
    }
  ],
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/endpoint"
}
```

## Testing the API

### Using curl

```bash
# Health check
curl http://localhost:5000/health

# Submit demo request
curl -X POST http://localhost:5000/api/demo-requests \
  -H "Content-Type: application/json" \
  -d '{
    "businessName": "Test Corp",
    "contactName": "Test User",
    "email": "test@example.com",
    "phone": "+1234567890"
  }'

# Get demo requests
curl http://localhost:5000/api/demo-requests

# Get specific demo request
curl http://localhost:5000/api/demo-requests/request-id
```

### Using Postman

1. Import the following collection:
```json
{
  "info": {
    "name": "GoLoyal API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "url": "http://localhost:5000/health"
      }
    },
    {
      "name": "Submit Demo Request",
      "request": {
        "method": "POST",
        "url": "http://localhost:5000/api/demo-requests",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"businessName\": \"Test Corp\",\n  \"contactName\": \"Test User\",\n  \"email\": \"test@example.com\",\n  \"phone\": \"+1234567890\"\n}"
        }
      }
    }
  ]
}
```

## SDK Examples

### JavaScript/TypeScript

```typescript
class GoLoyalAPI {
  private baseURL: string;

  constructor(baseURL: string = 'http://localhost:5000') {
    this.baseURL = baseURL;
  }

  async submitDemoRequest(data: {
    businessName: string;
    contactName: string;
    email: string;
    phone?: string;
  }) {
    const response = await fetch(`${this.baseURL}/api/demo-requests`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });

    return response.json();
  }

  async getDemoRequests(page: number = 1, limit: number = 10) {
    const response = await fetch(
      `${this.baseURL}/api/demo-requests?page=${page}&limit=${limit}`
    );
    return response.json();
  }

  async getDemoRequest(id: string) {
    const response = await fetch(`${this.baseURL}/api/demo-requests/${id}`);
    return response.json();
  }
}

// Usage
const api = new GoLoyalAPI();

// Submit demo request
const result = await api.submitDemoRequest({
  businessName: 'Acme Corp',
  contactName: 'John Doe',
  email: 'john@acme.com',
  phone: '+1234567890',
});

console.log(result);
```

## Rate Limiting Headers

When rate limiting is active, the following headers are included in responses:

- `X-RateLimit-Limit`: Maximum requests per window
- `X-RateLimit-Remaining`: Remaining requests in current window
- `X-RateLimit-Reset`: Time when the rate limit resets (Unix timestamp)

---

**Need help?** Check our [Troubleshooting Guide](./troubleshooting.md) or open an issue on GitHub.
