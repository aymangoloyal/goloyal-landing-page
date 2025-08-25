import type { Express } from "express";
import { createServer, type Server } from "http";
import { z } from "zod";
import { insertDemoRequestSchema } from "../shared/schema";
import { storage } from "./storage";

export async function registerRoutes(app: Express): Promise<Server> {
  // Demo request endpoint
  app.post("/api/demo-requests", async (req, res) => {
    try {
      const validatedData = insertDemoRequestSchema.parse(req.body);
      const demoRequest = await storage.createDemoRequest(validatedData);
      res.status(201).json({
        success: true,
        message: "Demo request submitted successfully",
        id: demoRequest.id
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          message: "Validation error",
          errors: error.errors
        });
      } else {
        console.error("Demo request error:", error);
        res.status(500).json({
          success: false,
          message: "Failed to submit demo request"
        });
      }
    }
  });

  // Get all demo requests (for potential admin interface)
  app.get("/api/demo-requests", async (req, res) => {
    try {
      const demoRequests = await storage.getAllDemoRequests();
      res.json({ success: true, data: demoRequests });
    } catch (error) {
      console.error("Get demo requests error:", error);
      res.status(500).json({
        success: false,
        message: "Failed to retrieve demo requests"
      });
    }
  });

  const httpServer = createServer(app);

  return httpServer;
}
