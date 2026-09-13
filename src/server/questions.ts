export type QuestionType = "text" | "choice";

export interface Question {
  id: string;
  label: string;
  hi: string;
  type: QuestionType;
  choices: string[];
  hiChoices?: string[];
}

/** Shared question bank for both intake modes; identical content to the Python prototype. */
export const questions: Record<"GENERAL" | "AYUSH", Question[]> = {
  GENERAL: [
    {
      id: "chief",
      label: "What is troubling you today?",
      hi: "आज आपको किस बात की परेशानी है?",
      type: "text",
      choices: [],
    },
    {
      id: "duration",
      label: "When did this start?",
      hi: "यह कब शुरू हुआ?",
      type: "choice",
      choices: ["Today", "1–3 days ago", "4–7 days ago", "More than a week ago"],
      hiChoices: ["आज", "1–3 दिन पहले", "4–7 दिन पहले", "एक सप्ताह से अधिक"],
    },
    {
      id: "severity",
      label: "How severe is it?",
      hi: "समस्या कितनी गंभीर है?",
      type: "choice",
      choices: ["Mild (1–3)", "Moderate (4–6)", "Severe (7–10)"],
      hiChoices: ["हल्का (1–3)", "मध्यम (4–6)", "गंभीर (7–10)"],
    },
    {
      id: "breathlessness",
      label: "Are you having difficulty breathing?",
      hi: "क्या आपको सांस लेने में तकलीफ है?",
      type: "choice",
      choices: ["No", "Yes"],
      hiChoices: ["नहीं", "हाँ"],
    },
    {
      id: "sweating",
      label: "Any cold sweating, fainting, or dizziness?",
      hi: "क्या ठंडा पसीना, बेहोशी या चक्कर आए हैं?",
      type: "choice",
      choices: ["No", "Yes"],
      hiChoices: ["नहीं", "हाँ"],
    },
    {
      id: "history",
      label: "Any known illness, medicines, or allergies?",
      hi: "कोई पुरानी बीमारी, दवा या एलर्जी?",
      type: "text",
      choices: [],
    },
  ],
  AYUSH: [
    {
      id: "chief",
      label: "What is troubling you today?",
      hi: "आज आपको किस बात की परेशानी है?",
      type: "text",
      choices: [],
    },
    {
      id: "duration",
      label: "When did this start?",
      hi: "यह कब शुरू हुआ?",
      type: "choice",
      choices: ["Today", "1–3 days ago", "4–7 days ago", "More than a week ago"],
      hiChoices: ["आज", "1–3 दिन पहले", "4–7 दिन पहले", "एक सप्ताह से अधिक"],
    },
    {
      id: "prakriti",
      label: "Prakriti (self-described constitution)",
      hi: "प्रकृति (आपके अनुसार)",
      type: "choice",
      choices: ["Vata", "Pitta", "Kapha", "Mixed / not sure"],
      hiChoices: ["वात", "पित्त", "कफ", "मिश्रित / निश्चित नहीं"],
    },
    {
      id: "vikriti",
      label: "Vikriti / current imbalance",
      hi: "विकृति / वर्तमान असंतुलन",
      type: "text",
      choices: [],
    },
    {
      id: "ahara_shakti",
      label: "Ahara Shakti (appetite/digestion)",
      hi: "आहार शक्ति (भूख/पाचन)",
      type: "choice",
      choices: ["Good", "Variable", "Low"],
      hiChoices: ["अच्छा", "बदलता रहता है", "कम"],
    },
    {
      id: "vyayama_shakti",
      label: "Vyayama Shakti (exercise tolerance)",
      hi: "व्यायाम शक्ति",
      type: "choice",
      choices: ["Good", "Limited", "Very limited"],
      hiChoices: ["अच्छी", "सीमित", "बहुत सीमित"],
    },
    {
      id: "history",
      label: "Diet, sleep, medicines, or allergies?",
      hi: "आहार, नींद, दवा या एलर्जी?",
      type: "text",
      choices: [],
    },
  ],
};
