// Ambient global declaration for Deno runtime in Supabase Edge Functions
declare namespace Deno {
  function serve(handler: (req: Request) => Response | Promise<Response>): void;
  var env: {
    get(key: string): string | undefined;
    set(key: string, value: string): void;
    delete(key: string): void;
    toObject(): { [key: string]: string };
  };
}
