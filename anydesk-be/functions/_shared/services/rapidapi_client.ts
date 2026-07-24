import { ExtractedMedia, RapidApiResponse } from "../models/types.ts";
import { ApiError } from "../exceptions/api_error.ts";

export class RapidApiClient {
  private readonly apiKey: string;
  private readonly host = "social-media-video-downloader.p.rapidapi.com";
  private readonly baseUrl = `https://${this.host}/smvd/get/all`;

  constructor() {
    const key = Deno.env.get("RAPIDAPI_KEY");
    if (!key) {
      throw new ApiError(500, "RAPIDAPI_KEY is missing from environment variables");
    }
    this.apiKey = key;
  }

  async extractMedia(url: string): Promise<ExtractedMedia> {
    try {
      const response = await fetch(`${this.baseUrl}?url=${encodeURIComponent(url)}`, {
        method: "GET",
        headers: {
          "X-RapidAPI-Key": this.apiKey,
          "X-RapidAPI-Host": this.host,
        },
      });

      if (!response.ok) {
        throw new ApiError(response.status, `RapidAPI Error: ${response.statusText}`);
      }

      const data = (await response.json()) as RapidApiResponse;

      if (!data.success) {
        throw new ApiError(400, data.message || "Failed to extract media from the provided URL.");
      }

      return this.mapToExtractedMedia(url, data);
    } catch (error) {
      if (error instanceof ApiError) throw error;
      throw new ApiError(500, error instanceof Error ? error.message : "Unknown error during extraction");
    }
  }

  private mapToExtractedMedia(originalUrl: string, data: RapidApiResponse): ExtractedMedia {
    const platform = this.detectPlatform(originalUrl);
    
    return {
      platform,
      title: data.title || "Video Download",
      thumbnail: data.picture || "",
      medias: (data.links || []).map(link => ({
        quality: link.quality || "normal",
        url: link.link,
        extension: link.type || "mp4",
      })),
    };
  }

  private detectPlatform(url: string): ExtractedMedia['platform'] {
    const lowerUrl = url.toLowerCase();
    if (lowerUrl.includes('tiktok.com')) return 'tiktok';
    if (lowerUrl.includes('instagram.com')) return 'instagram';
    if (lowerUrl.includes('youtube.com') || lowerUrl.includes('youtu.be')) return 'youtube';
    return 'unknown';
  }
}
