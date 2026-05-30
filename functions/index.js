const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

initializeApp();

const OPENROUTER_API_KEY = defineSecret("OPENROUTER_API_KEY");
const OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions";
const OPENROUTER_MODEL =
  process.env.OPENROUTER_MODEL || "google/gemini-2.5-flash-lite";
const OPENROUTER_HTTP_REFERER =
  process.env.OPENROUTER_HTTP_REFERER || "https://microwins.app";
const OPENROUTER_X_TITLE = process.env.OPENROUTER_X_TITLE || "MicroWins";

function extractBearerToken(req) {
  const authHeader = req.headers.authorization || "";
  if (!authHeader.startsWith("Bearer ")) {
    return null;
  }
  return authHeader.slice(7).trim();
}

async function verifyUser(req) {
  const token = extractBearerToken(req);
  if (!token) {
    return null;
  }
  try {
    return await getAuth().verifyIdToken(token);
  } catch (error) {
    logger.warn("Invalid Firebase ID token", { error: String(error) });
    return null;
  }
}

function buildPrompt(goal) {
  return `
You are a habit formation expert. User goal: "${goal}"

Generate 3 micro-routines (2-5 minutes each) that are:
1. Specific and actionable
2. Doable anywhere without equipment
3. Progressive in difficulty

Return ONLY valid JSON array with this structure:
[
  {
    "name": "string (max 50 chars)",
    "duration": 2,
    "steps": ["step 1", "step 2"],
    "category": "Health",
    "difficulty": "Beginner",
    "icon": "✅"
  }
]
Valid categories: Health, Productivity, Wellness, Learning, Fitness
`.trim();
}

function parseAiContent(rawContent) {
  const normalized = String(rawContent || "")
    .replaceAll("```json", "")
    .replaceAll("```", "")
    .trim();

  const parsed = JSON.parse(normalized);
  if (!Array.isArray(parsed)) {
    throw new Error("AI output is not an array");
  }

  return parsed.slice(0, 3).map((item) => {
    const name = String(item?.name || "").trim();
    if (!name) {
      throw new Error("Habit without name");
    }

    const durationValue = item?.duration;
    const duration =
      typeof durationValue === "number"
        ? durationValue
        : Number.parseInt(String(durationValue || "2"), 10);

    return {
      name: name.slice(0, 50),
      duration: Number.isFinite(duration) && duration > 0 ? duration : 2,
      category: String(item?.category || "Wellness"),
      icon: String(item?.icon || "✅"),
    };
  });
}

async function generateHabitsViaOpenRouter(goal, apiKey) {
  const response = await fetch(OPENROUTER_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      "HTTP-Referer": OPENROUTER_HTTP_REFERER,
      "X-Title": OPENROUTER_X_TITLE,
    },
    body: JSON.stringify({
      model: OPENROUTER_MODEL,
      messages: [{ role: "user", content: buildPrompt(goal) }],
    }),
  });

  if (!response.ok) {
    const upstreamText = await response.text();
    logger.error("OpenRouter upstream error", {
      status: response.status,
      body: upstreamText.slice(0, 500),
    });
    throw new Error("Upstream AI request failed");
  }

  const data = await response.json();
  const content = data?.choices?.[0]?.message?.content;
  if (!content) {
    throw new Error("AI response missing content");
  }

  return parseAiContent(content);
}

exports.api = onRequest(
  {
    region: "europe-west1",
    cors: true,
    secrets: [OPENROUTER_API_KEY],
    timeoutSeconds: 60,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const user = await verifyUser(req);
    if (!user) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    const goal = String(req.body?.goal || "").trim();
    if (!goal || goal.length < 3 || goal.length > 300) {
      res.status(400).json({ error: "Invalid goal" });
      return;
    }

    try {
      const habits = await generateHabitsViaOpenRouter(
        goal,
        OPENROUTER_API_KEY.value(),
      );
      res.status(200).json({ habits });
    } catch (error) {
      logger.error("AI habits generation failed", {
        uid: user.uid,
        error: String(error),
      });
      res.status(502).json({ error: "AI service unavailable" });
    }
  },
);
