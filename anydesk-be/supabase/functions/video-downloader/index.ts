export {};

// Konfigurasi CORS agar Flutter bisa melakukan request tanpa diblokir
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Parsing body request dari client (Flutter/Postman)
    const { platform, url: targetUrl } = await req.json()

    if (!platform || !targetUrl) {
      return new Response(
        JSON.stringify({ error: "Parameter 'platform' dan 'url' wajib diisi." }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    let apiUrl = "";

    // Penentuan endpoint RapidAPI berdasarkan platform
    switch (platform.toLowerCase()) {
      case "tiktok":
        apiUrl = "https://social-media-video-downloader.p.rapidapi.com/tiktok/v3/post/details";
        break;
      case "instagram":
        apiUrl = "https://social-media-video-downloader.p.rapidapi.com/instagram/v3/media/post/details";
        break;
      case "youtube":
        apiUrl = "https://social-media-video-downloader.p.rapidapi.com/youtube/v3/info";
        break;
      default:
        return new Response(
          JSON.stringify({ error: `Platform '${platform}' tidak didukung.` }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
        )
    }

    // Membentuk URL final, khusus Instagram kita gunakan 'shortcode', selainnya 'url'
    let finalUrl = "";
    if (platform.toLowerCase() === "instagram") {
      // Parse shortcode dari link Instagram (misal: https://www.instagram.com/p/DRUFUhkiadH/ -> DRUFUhkiadH)
      const match = targetUrl.match(/\/(?:p|reel|tv)\/([a-zA-Z0-9_-]+)/);
      const shortcode = match ? match[1] : targetUrl;
      finalUrl = `${apiUrl}?shortcode=${shortcode}`;
    } else {
      finalUrl = `${apiUrl}?url=${encodeURIComponent(targetUrl)}`;
    }

    // Mengambil API Key dari file .env.local dan menghapus spasi/enter (\r) yang tersembunyi
    const apiKey = (Deno.env.get("RAPIDAPI_KEY") ?? "").trim();

    // Eksekusi HTTP GET ke server RapidAPI
    const response = await fetch(finalUrl, {
      method: "GET",
      headers: {
        "x-rapidapi-key": apiKey,
        "x-rapidapi-host": "social-media-video-downloader.p.rapidapi.com"
      }
    });

    const responseText = await response.text();
    let data;
    try {
      data = JSON.parse(responseText);
    } catch (parseError) {
      return new Response(
        JSON.stringify({ error: `Gagal memparsing JSON dari API. Respons mentah: ${responseText.substring(0, 100)}` }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
      )
    }

    // DEBUG: log structure to see thumbnail field names
    console.log('=== API RESPONSE KEYS:', JSON.stringify(Object.keys(data)));
    if (data.metadata) {
      console.log('=== METADATA:', JSON.stringify(data.metadata));
    }
    if (data.contents) {
      const firstNode = Array.isArray(data.contents) ? data.contents[0] : data.contents;
      console.log('=== FIRST CONTENT NODE KEYS:', JSON.stringify(Object.keys(firstNode || {})));
      console.log('=== FIRST CONTENT NODE:', JSON.stringify(firstNode).substring(0, 500));
    }

    // Mengembalikan response RapidAPI ke client
    return new Response(
      JSON.stringify(data),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Internal server error"
    return new Response(
      JSON.stringify({ error: message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
