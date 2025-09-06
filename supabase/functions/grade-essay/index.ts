// supabase/functions/grade-essay/index.ts
// Deno Edge Function: penilai esai berbasis rubrik (provider: Gemini)
//
// ENV WAJIB:
//   GEMINI_API_KEY = AIza... (Google AI Studio / Google Cloud Generative Language)
//
// CATATAN:
//  - Jika di config.toml: [functions.grade-essay].verify_jwt = true,
//    saat testing lokal sertakan header Authorization: Bearer <access_token>.
//  - Untuk lokal cepat, bisa set verify_jwt = false sementara.

type RubricItem = { name: string; weight?: number; criteria: string };
type EvalRequest = {
  problem: string;
  answer: string;
  rubric: RubricItem[];
  lang?: "id" | "en";
};

// Helper respons JSON + CORS
function json(body: unknown, init: ResponseInit = {}, cors = true): Response {
  const headers = new Headers(init.headers || {});
  headers.set("Content-Type", "application/json");
  if (cors) {
    headers.set("Access-Control-Allow-Origin", "*");
    headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    headers.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  }
  return new Response(JSON.stringify(body), { ...init, headers });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return json({}, { status: 204 }); // preflight

  try {
    if (req.method !== "POST") return json({ error: "Use POST" }, { status: 405 });

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) return json({ error: "Missing GEMINI_API_KEY" }, { status: 500 });

    const body = (await req.json()) as EvalRequest | null;
    if (!body) return json({ error: "Missing JSON body" }, { status: 400 });

    const { problem, answer, rubric, lang = "id" } = body;
    if (!problem?.trim()) return json({ error: "Missing 'problem'" }, { status: 400 });
    if (!answer?.trim()) return json({ error: "Missing 'answer'" }, { status: 400 });
    if (!Array.isArray(rubric) || rubric.length === 0) {
      return json({ error: "Missing 'rubric' (array)" }, { status: 400 });
    }

    const rubricText = rubric
      .map((r, i) => `${i + 1}. ${r.name}${r.weight ? ` (weight ${r.weight})` : ""}: ${r.criteria}`)
      .join("\n");

    const system = (lang === "id")
      ? "Anda tutor matematika SMP. Nilai jawaban berdasarkan rubrik secara adil. Beri umpan balik ringkas, spesifik, dan membangun."
      : "You are a middle school math tutor. Score using the rubric fairly. Provide concise, specific, constructive feedback.";

    // Prompt untuk memaksa JSON valid
    const userPrompt = [
      lang === "id" ? "SOAL:" : "PROBLEM:",
      problem,
      "",
      lang === "id" ? "RUBRIK (0/1 per butir, urut):" : "RUBRIC (0/1 per item, in order):",
      rubricText,
      "",
      lang === "id" ? "JAWABAN SISWA:" : "STUDENT ANSWER:",
      answer,
      "",
      (lang === "id")
        ? "TUGAS: Pikir langkah demi langkah. Skor tiap butir 0 atau 1 (urutan sama). Ringkas feedback. KELUARKAN **JSON VALID** SAJA:\n{ \"scores\": [0|1, ...], \"feedback\": \"...\" }"
        : "TASK: Think step-by-step. Score each rubric item 0 or 1 (same order). Summarize feedback. OUTPUT **VALID JSON ONLY**:\n{ \"scores\": [0|1, ...], \"feedback\": \"...\" }",
    ].join("\n");

    // Endpoint Gemini (Generative Language API v1beta)
    const endpoint =
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${encodeURIComponent(apiKey)}`;

    const payload = {
      // generationConfig bantu jaga determinisme & dorong JSON-only
      generationConfig: {
        temperature: 0,
        // Jika akunmu sudah pakai "Responses API" terbaru, properti bisa "response_mime_type".
        // Di v1beta generateContent standar, kita tetap pakai prompt yang memaksa JSON.
      },
      contents: [
        {
          role: "user",
          parts: [
            { text: `${system}\n\n${userPrompt}` }
          ]
        }
      ],
      // (opsional) safetySettings bisa ditambahkan kalau perlu
    };

    const resp = await fetch(endpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    if (!resp.ok) {
      const text = await resp.text();
      return json({ error: "Gemini error", detail: text }, { status: 502 });
    }

    const data = await resp.json();

    // Format umum: data.candidates[0].content.parts[0].text
    const text: string | undefined =
      data?.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!text) return json({ error: "Empty response from model" }, { status: 500 });

    let parsed: { scores?: unknown; feedback?: unknown } = {};
    try {
      // Model mengembalikan string JSON (atau kadang dibungkus ```json ... ```),
      // jadi bersihkan fence kalau ada:
      const clean = text.trim().replace(/^```json\s*|\s*```$/g, "");
      parsed = JSON.parse(clean);
    } catch {
      return json({ error: "Model returned non-JSON", raw: text }, { status: 500 });
    }

    if (!Array.isArray(parsed.scores) || typeof parsed.feedback !== "string") {
      return json({ error: "Invalid structure", raw: parsed }, { status: 500 });
    }

    // Normalisasi panjang scores = panjang rubric
    const scores = rubric.map((_, i) => Number(parsed.scores?.[i] ? 1 : 0));
    const feedback = parsed.feedback;

    return json({ scores, feedback }, { status: 200 });
  } catch (err) {
    return json({ error: "Server error", detail: String(err) }, { status: 500 });
  }
});
