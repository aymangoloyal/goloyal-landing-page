import type { NextFunction, Request, Response } from 'express';
import { log } from '../vite';

export const requestLogger = (req: Request, res: Response, next: NextFunction) => {
    const start = Date.now();
    const { method, originalUrl, ip } = req;

    // Capture response data
    let responseBody: any = null;
    const originalSend = res.send;
    const originalJson = res.json;

    res.send = function (body: any) {
        responseBody = body;
        return originalSend.call(this, body);
    };

    res.json = function (body: any) {
        responseBody = body;
        return originalJson.call(this, body);
    };

    // Log when response finishes
    res.on('finish', () => {
        const duration = Date.now() - start;
        const { statusCode } = res;

        // Only log API requests
        if (originalUrl.startsWith('/api')) {
            const logData = {
                method,
                url: originalUrl,
                statusCode,
                duration: `${duration}ms`,
                ip,
                userAgent: req.get('User-Agent')?.substring(0, 100),
                timestamp: new Date().toISOString()
            };

            // Truncate response body for logging
            if (responseBody && typeof responseBody === 'object') {
                const truncatedResponse = JSON.stringify(responseBody).substring(0, 200);
                if (truncatedResponse.length === 200) {
                    logData['response'] = truncatedResponse + '...';
                } else {
                    logData['response'] = truncatedResponse;
                }
            }

            // Color code based on status
            const statusColor = statusCode >= 500 ? '🔴' :
                statusCode >= 400 ? '🟡' :
                    statusCode >= 300 ? '🔵' : '🟢';

            log(`${statusColor} ${method} ${originalUrl} ${statusCode} (${duration}ms)`);

            // Log detailed info for errors or slow requests
            if (statusCode >= 400 || duration > 1000) {
                log(`📋 Request Details: ${JSON.stringify(logData)}`);
            }
        }
    });

    next();
};
