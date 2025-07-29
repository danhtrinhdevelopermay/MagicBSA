import { sql } from "drizzle-orm";
import { pgTable, text, varchar, timestamp, json } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

export const imageJobs = pgTable("image_jobs", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  originalImageUrl: text("original_image_url").notNull(),
  processedImageUrl: text("processed_image_url"),
  operation: text("operation", { enum: ["remove_background", "remove_text", "cleanup", "remove_logo"] }).notNull(),
  status: text("status", { enum: ["pending", "processing", "completed", "failed"] }).notNull().default("pending"),
  errorMessage: text("error_message"),
  metadata: json("metadata"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertImageJobSchema = createInsertSchema(imageJobs).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

export type InsertImageJob = z.infer<typeof insertImageJobSchema>;
export type ImageJob = typeof imageJobs.$inferSelect;
