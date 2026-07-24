import { corsHeaders } from "../_shared/utils/cors.ts";
import { buildSuccessResponse, buildErrorResponse } from "../_shared/utils/response.ts";
import { RapidApiClient } from "../_shared/services/rapidapi_client.ts";
import { ApiError } from "../_shared/exceptions/api_error.ts";

Deno.serve(async (req: Request) => {
  // 1. Tangani CORS preflight request
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 2. Pastikan method POST
    if (req.method !== "POST") {
      throw new ApiError(405, "Method Not Allowed. Use POST.");
    }

    // 3. Parsing body
    const body = await req.json().catch(() => null);
    if (!body || !body.url) {
      throw new ApiError(400, "Field 'url' is required in the JSON body.");
    }

    // 4. Ekstrak data via Service Layer
    const apiClient = new RapidApiClient();
    const result = await apiClient.extractMedia(body.url);

    // 5. Kembalikan Response Sukses
    return buildSuccessResponse(result);

  } catch (error: unknown) {
    // 6. Tangkap Error
    return buildErrorResponse(error);
  }
});
