import type { Express } from "express";
import express from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { insertImageJobSchema } from "@shared/schema";
import multer from "multer";
import path from "path";
import { randomUUID } from "crypto";
import fs from "fs/promises";

// Configure multer for file uploads
const upload = multer({
  dest: 'uploads/',
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req: any, file: any, cb: any) => {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPG, PNG, and WEBP are allowed.'));
    }
  }
});

async function processWithClipdrop(imageBuffer: Buffer, operation: string, maskBuffer?: Buffer): Promise<Buffer> {
  const CLIPDROP_API_KEY = process.env.CLIPDROP_API_KEY || process.env.VITE_CLIPDROP_API_KEY || "";
  
  if (!CLIPDROP_API_KEY) {
    throw new Error("Clipdrop API key not found in environment variables");
  }

  // Map operations to API endpoints
  const apiEndpoints = {
    "remove_background": "https://clipdrop-api.co/remove-background/v1",
    "remove_text": "https://clipdrop-api.co/remove-text/v1", 
    "cleanup": "https://clipdrop-api.co/cleanup/v1",
    "remove_logo": "https://clipdrop-api.co/remove-text/v1" // Logo removal uses same endpoint as text removal
  };

  const apiUrl = apiEndpoints[operation as keyof typeof apiEndpoints];
  if (!apiUrl) {
    throw new Error(`Unsupported operation: ${operation}`);
  }

  const formData = new FormData();
  formData.append("image_file", new Blob([imageBuffer]), "image.png");
  
  // For cleanup operation, mask is required
  if (operation === "cleanup" && maskBuffer) {
    formData.append("mask_file", new Blob([maskBuffer]), "mask.png");
  }

  const response = await fetch(apiUrl, {
    method: "POST",
    headers: {
      "x-api-key": CLIPDROP_API_KEY,
    },
    body: formData,
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Clipdrop API error: ${response.status} - ${errorText}`);
  }

  return Buffer.from(await response.arrayBuffer());
}

export async function registerRoutes(app: Express): Promise<Server> {
  // Create uploads directory if it doesn't exist
  try {
    await fs.mkdir('uploads', { recursive: true });
    await fs.mkdir('processed', { recursive: true });
  } catch (error) {
    // Directory might already exist
  }

  // Upload image and create job
  app.post("/api/jobs", upload.single('image'), async (req: any, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ message: "No image file provided" });
      }

      const { operation } = req.body;
      
      const validOperations = ["remove_background", "remove_text", "cleanup", "remove_logo"];
      if (!operation || !validOperations.includes(operation)) {
        return res.status(400).json({ message: "Invalid operation. Supported operations: " + validOperations.join(", ") });
      }

      // Move uploaded file to permanent location
      const imageId = randomUUID();
      const fileExtension = path.extname(req.file.originalname);
      const permanentPath = `uploads/${imageId}${fileExtension}`;
      
      await fs.rename(req.file.path, permanentPath);

      // Create job record
      const job = await storage.createImageJob({
        originalImageUrl: `/${permanentPath}`,
        operation: operation as "remove_background" | "remove_text" | "cleanup" | "remove_logo",
        status: "pending",
        processedImageUrl: null,
        errorMessage: null,
        metadata: {
          originalName: req.file.originalname,
          fileSize: req.file.size,
          mimeType: req.file.mimetype
        }
      });

      res.json(job);
    } catch (error) {
      console.error("Upload error:", error);
      res.status(500).json({ message: "Failed to upload image" });
    }
  });

  // Process image job
  app.post("/api/jobs/:id/process", async (req, res) => {
    try {
      const { id } = req.params;
      const job = await storage.getImageJob(id);

      if (!job) {
        return res.status(404).json({ message: "Job not found" });
      }

      if (job.status !== "pending") {
        return res.status(400).json({ message: "Job is not in pending state" });
      }

      // Update job status to processing
      await storage.updateImageJob(id, { status: "processing" });

      // Read the original image
      const originalPath = job.originalImageUrl.substring(1); // Remove leading slash
      const imageBuffer = await fs.readFile(originalPath);

      try {
        // Process with Clipdrop API
        const processedBuffer = await processWithClipdrop(imageBuffer, job.operation);

        // Save processed image
        const processedPath = `processed/${id}.png`;
        await fs.writeFile(processedPath, processedBuffer);

        // Update job with success
        const updatedJob = await storage.updateImageJob(id, {
          status: "completed",
          processedImageUrl: `/${processedPath}`
        });

        res.json(updatedJob);
      } catch (processError) {
        console.error("Processing error:", processError);
        
        // Update job with error
        const updatedJob = await storage.updateImageJob(id, {
          status: "failed",
          errorMessage: processError instanceof Error ? processError.message : "Unknown processing error"
        });

        res.status(500).json(updatedJob);
      }
    } catch (error) {
      console.error("Process job error:", error);
      res.status(500).json({ message: "Failed to process job" });
    }
  });

  // Get job status
  app.get("/api/jobs/:id", async (req, res) => {
    try {
      const { id } = req.params;
      const job = await storage.getImageJob(id);

      if (!job) {
        return res.status(404).json({ message: "Job not found" });
      }

      res.json(job);
    } catch (error) {
      console.error("Get job error:", error);
      res.status(500).json({ message: "Failed to get job" });
    }
  });

  // Get all jobs (for history)
  app.get("/api/jobs", async (req, res) => {
    try {
      const jobs = await storage.getAllImageJobs();
      res.json(jobs);
    } catch (error) {
      console.error("Get jobs error:", error);
      res.status(500).json({ message: "Failed to get jobs" });
    }
  });

  // Serve uploaded and processed images
  app.use('/uploads', express.static('uploads'));
  app.use('/processed', express.static('processed'));

  const httpServer = createServer(app);
  return httpServer;
}
