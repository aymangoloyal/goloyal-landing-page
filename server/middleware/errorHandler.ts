import type { NextFunction, Request, Response } from 'express';
import { ZodError } from 'zod';
import { log } from '../vite';

export interface AppError extends Error {
    statusCode?: number;
    isOperational?: boolean;
}

export class CustomError extends Error implements AppError {
    public statusCode: number;
    public isOperational: boolean;

    constructor(message: string, statusCode: number = 500) {
        super(message);
        this.statusCode = statusCode;
        this.isOperational = true;

        Error.captureStackTrace(this, this.constructor);
    }
}

export const errorHandler = (
    err: AppError | ZodError | Error,
    req: Request,
    res: Response,
    _next: NextFunction
) => {
    let statusCode = 500;
    let message = 'Internal Server Error';
    let details: any = null;

    // Handle Zod validation errors
    if (err instanceof ZodError) {
        statusCode = 400;
        message = 'Validation Error';
        details = err.errors.map(error => ({
            field: error.path.join('.'),
            message: error.message,
            code: error.code
        }));
    }
    // Handle custom application errors
    else if (err instanceof CustomError) {
        statusCode = err.statusCode;
        message = err.message;
    }
    // Handle other known error types
    else if (err.name === 'CastError') {
        statusCode = 400;
        message = 'Invalid ID format';
    }
    else if (err.name === 'ValidationError') {
        statusCode = 400;
        message = 'Validation Error';
    }
    else if (err.name === 'JsonWebTokenError') {
        statusCode = 401;
        message = 'Invalid token';
    }
    else if (err.name === 'TokenExpiredError') {
        statusCode = 401;
        message = 'Token expired';
    }
    else if (err.message) {
        message = err.message;
    }

    // Log error details
    const errorLog = {
        timestamp: new Date().toISOString(),
        method: req.method,
        url: req.originalUrl,
        statusCode,
        message: err.message,
        stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
        userAgent: req.get('User-Agent'),
        ip: req.ip
    };

    if (statusCode >= 500) {
        log(`❌ Server Error: ${JSON.stringify(errorLog)}`);
    } else {
        log(`⚠️ Client Error: ${JSON.stringify(errorLog)}`);
    }

    // Send error response
    const response: any = {
        success: false,
        error: message,
        timestamp: new Date().toISOString(),
        path: req.originalUrl
    };

    if (details) {
        response.details = details;
    }

    if (process.env.NODE_ENV === 'development') {
        response.stack = err.stack;
    }

    res.status(statusCode).json(response);
};
