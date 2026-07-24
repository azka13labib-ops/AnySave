import { corsHeaders } from "./cors.ts";
import { ApiError } from "../exceptions/api_error.ts";

export const buildSuccessResponse = (data: unknown, statusCode = 200): Response => {
  return new Response(JSON.stringify({ success: true, data }), {
    status: statusCode,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
};

export const buildErrorResponse = (error: unknown): Response => {
  if (error instanceof ApiError) {
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      status: error.statusCode,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const message = error instanceof Error ? error.message : "Internal Server Error";
  return new Response(JSON.stringify({ success: false, error: message }), {
    status: 500,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
};
