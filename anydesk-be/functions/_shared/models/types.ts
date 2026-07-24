export interface MediaOption {
  quality: string;
  url: string;
  extension: string;
}

export interface ExtractedMedia {
  platform: 'tiktok' | 'instagram' | 'youtube' | 'unknown';
  title: string;
  thumbnail: string;
  medias: MediaOption[];
}

export interface RapidApiResponse {
  success: boolean;
  src_url?: string;
  title?: string;
  picture?: string;
  links?: {
    link: string;
    type: string;
    quality: string;
    render?: string;
  }[];
  message?: string;
}
