// supabase/functions/grade-essay/index.ts
// Edge Function — penilaian esai matematika (Gemini, JSON-only output)

type GradeRequest = {
  problem_text: string;
  student_answer: string;
  rubric?: { criteria: string[] };
};

type GradeJSON = {
  explanation: string;
  scores: number[]; // 0/1 per kriteria
  total: number;
};

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
const MODEL = "gemini-1.5-flash";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return new Response("Use POST", { status: 405, headers: CORS });

  try {
    if (!GEMINI_API_KEY) throw new Error("Missing GEMINI_API_KEY");

    const body = (await req.json()) as GradeRequest;
    const criteria = body.rubric?.criteria ?? [
      "Rumus benar",
      "Substitusi benar",
      "Perhitungan benar",
    ];

    const prompt = `
Anda adalah guru matematika SMP. Nilailah jawaban siswa berdasarkan rubrik.

Soal:
${body.problem_text}

Jawaban siswa:
${body.student_answer}

Rubrik (urut sesuai nomor):
${criteria.map((c, i) => `${i + 1}. ${c}`).join("\n")}

Kembalikan **JSON VALID SAJA** persis dengan skema:
{"explanation":"(string singkat)","scores":[0 atau 1,...],"total":(jumlah 0/1)}

Jangan sertakan teks lain, tidak ada catatan, tidak ada code fence.
`;

    // Panggil REST Gemini (tanpa library, paling kompatibel di Edge Runtime)
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GEMINI_API_KEY}`;
    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ role: "user", parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0.2,
            // Minta langsung JSON (membantu Gemini agar tidak mengirim teks bebas)
            responseMimeType: "application/json"
          },
        }),
      }
    );
    if (!res.ok) throw new Error(`Gemini error: ${await res.text()}`);

    const data = await res.json();
    const text: string =
      data?.candidates?.[0]?.content?.parts?.map((p: any) => p?.text ?? "").join("") ?? "";

    // Ambil blok JSON dari teks model (kalau dibungkus embel2)
        let parsed: { explanation: string; scores: number[]; total: number };
    try {
      parsed = repairJson(text);
    } catch (e) {
      // fallback terakhir: bungkus minimal agar tidak crash, biar kamu bisa lihat apa isi text
      return new Response(JSON.stringify({ raw: text, error: String(e) }), {
        status: 500,
        headers: { "Content-Type": "application/json", ...CORS },
      });
    }

    if (!Array.isArray(parsed.scores)) throw new Error("Bad model output");
    return new Response(JSON.stringify(parsed), {
      headers: { "Content-Type": "application/json", ...CORS },
    });
  } catch (e: any) {
    const msg = typeof e?.message === "string" ? e.message : String(e);
    return new Response(JSON.stringify({ error: msg }), {
      status: 500,
      headers: { "Content-Type": "application/json", ...CORS },
    });
  }
});

function repairJson(text: string) {
  // ambil blok { ... } jika ada teks lain
  let s = (text.match(/\{[\s\S]*\}/)?.[0] ?? text).trim();

  // normalisasi kutip pintar -> ASCII
  s = s.replace(/[\u201C\u201D]/g, '"').replace(/[\u2018\u2019]/g, "'");

  // hapus koma gantung sebelum ] atau }
  s = s.replace(/,\s*(\]|\})/g, "$1");

  // kadang model pakai true/false/undefined tidak valid → (jarang) bisa ditangani manual jika perlu
  return JSON.parse(s);
}

