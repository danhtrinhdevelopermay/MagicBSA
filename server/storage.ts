import { type ImageJob, type InsertImageJob } from "@shared/schema";
import { randomUUID } from "crypto";

export interface IStorage {
  createImageJob(job: InsertImageJob): Promise<ImageJob>;
  getImageJob(id: string): Promise<ImageJob | undefined>;
  updateImageJob(id: string, updates: Partial<ImageJob>): Promise<ImageJob | undefined>;
  getAllImageJobs(): Promise<ImageJob[]>;
}

export class MemStorage implements IStorage {
  private imageJobs: Map<string, ImageJob>;

  constructor() {
    this.imageJobs = new Map();
  }

  async createImageJob(insertJob: InsertImageJob): Promise<ImageJob> {
    const id = randomUUID();
    const now = new Date();
    const job: ImageJob = { 
      id, 
      originalImageUrl: insertJob.originalImageUrl,
      processedImageUrl: insertJob.processedImageUrl || null,
      operation: insertJob.operation,
      status: insertJob.status || "pending",
      errorMessage: insertJob.errorMessage || null,
      metadata: insertJob.metadata || null,
      createdAt: now,
      updatedAt: now
    };
    this.imageJobs.set(id, job);
    return job;
  }

  async getImageJob(id: string): Promise<ImageJob | undefined> {
    return this.imageJobs.get(id);
  }

  async updateImageJob(id: string, updates: Partial<ImageJob>): Promise<ImageJob | undefined> {
    const existingJob = this.imageJobs.get(id);
    if (!existingJob) return undefined;
    
    const updatedJob: ImageJob = {
      ...existingJob,
      ...updates,
      updatedAt: new Date()
    };
    
    this.imageJobs.set(id, updatedJob);
    return updatedJob;
  }

  async getAllImageJobs(): Promise<ImageJob[]> {
    return Array.from(this.imageJobs.values()).sort(
      (a, b) => b.createdAt.getTime() - a.createdAt.getTime()
    );
  }
}

export const storage = new MemStorage();
