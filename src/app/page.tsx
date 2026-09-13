"use client";

import { useEffect, useRef, useState } from "react";
import { Header } from "@/components/Header";
import { api } from "@/lib/api";
import { questions, type Question } from "@/lib/questions";
import type { CaseData } from "@/lib/router-output";
import { setDemoRole } from "@/lib/role";

type View = "home" | "login" | "patientLogin" | "patientRegister" | "patientDashboard" | "patientVisits" | "doctorDashboard" | "register" | "intake" | "upload" | "done" | "doctor" | "case";
type LoginRole = "PATIENT" | "DOCTOR";
type PatientAccount = {
  id: string; fullName: string; phone: string | null; dob: Date | null; gender: string | null; accessCode: string | null; abhaId: string;
  visits: { id: string; mode: "GENERAL" | "AYUSH"; status: "IN_PROGRESS" | "READY_FOR_REVIEW" | "REVIEWED"; priority: "NORMAL" | "URGENT"; startedAt: Date; summary: { status: string } | null; redFlags: { id: string }[] }[];
};

const CONSENTS = ["history_collection", "document_processing", "mock_abdm_sharing"] as const;

const copy = {
  en: {
    step: "Step 1 of 3", start: "Start your visit", language: "Language",
    pathway: "Consultation pathway", general: "General clinical intake", ayush: "AYUSH / Ayurveda intake",
    name: "Full name", nameHint: "e.g. Meera Sharma",
    consent: "I consent to history collection and document processing for this demo.",
    continue: "Continue →", urgent: "Load urgent demo", mock: "Mock",
    registrationNotice: "ABHA ID is generated only for this demonstration. AYUSH entries are physician-assessment fields, not automated determination.",
    adaptive: "Adaptive clinical question", ayushField: "AYUSH structured field",
    placeholder: "Type here or use the microphone…", speak: "🎙 Speak", save: "Save & continue →",
    voiceUnavailable: "Voice recognition is unavailable in this browser. Please type instead.",
    voiceCaptured: "Voice transcript captured — review before saving.",
    voiceFallback: "Demo voice transcript inserted. Live microphone recognition requires a supported browser with microphone permission.",
    listening: "Listening… speak now", voiceHint: "Tap Speak, then say your answer clearly.",
    useTyped: "Review the text, then save and continue.",
    landingEyebrow: "Patient case-taking software", landingTitle: "Every patient story, ready for clinical review.",
    landingDescription: "A multilingual kiosk for structured clinical intake, deterministic safety escalation, document extraction, and doctor verification.",
    patientSignIn: "Patient sign in →", newRegistration: "New patient registration", doctorPortal: "Doctor portal",
    safety: "Safety note: this prototype documents history and highlights rule-based escalation signals. It does not diagnose or recommend treatment."
  },
  hi: {
    step: "चरण 1 / 3", start: "अपनी विज़िट शुरू करें", language: "भाषा",
    pathway: "परामर्श का प्रकार", general: "सामान्य क्लिनिकल इंटेक", ayush: "आयुष / आयुर्वेद इंटेक",
    name: "पूरा नाम", nameHint: "उदा. मीरा शर्मा",
    consent: "मैं इस डेमो के लिए अपना इतिहास एकत्र करने और दस्तावेज़ संसाधित करने की सहमति देता/देती हूँ।",
    continue: "जारी रखें →", urgent: "आपातकालीन डेमो लोड करें", mock: "डेमो",
    registrationNotice: "ABHA ID केवल इस डेमो के लिए बनाया जाता है। AYUSH प्रविष्टियाँ चिकित्सक के मूल्यांकन के लिए हैं, स्वचालित निर्धारण के लिए नहीं।",
    adaptive: "अनुकूली क्लिनिकल प्रश्न", ayushField: "आयुष संरचित फ़ील्ड",
    placeholder: "यहाँ लिखें या माइक्रोफ़ोन इस्तेमाल करें…", speak: "🎙 बोलें", save: "सहेजें और जारी रखें →",
    voiceUnavailable: "इस ब्राउज़र में वॉइस रिकग्निशन उपलब्ध नहीं है। कृपया टाइप करें।",
    voiceCaptured: "आवाज़ का टेक्स्ट कैप्चर हो गया है — सहेजने से पहले जाँच लें।",
    voiceFallback: "डेमो वॉइस ट्रांसक्रिप्ट जोड़ दिया गया है। लाइव माइक्रोफ़ोन के लिए समर्थित ब्राउज़र और माइक्रोफ़ोन अनुमति चाहिए।",
    listening: "सुन रहे हैं… अब बोलें", voiceHint: "बोलें पर टैप करें, फिर अपना उत्तर स्पष्ट रूप से बोलें।",
    useTyped: "टेक्स्ट जाँचें, फिर सहेजें और जारी रखें।",
    landingEyebrow: "रोगी केस-टेकिंग सॉफ्टवेयर", landingTitle: "हर रोगी की कहानी, क्लिनिकल समीक्षा के लिए तैयार।",
    landingDescription: "संरचित क्लिनिकल इंटेक, नियम-आधारित सुरक्षा संकेत, दस्तावेज़ निष्कर्षण और चिकित्सक सत्यापन के लिए बहुभाषी कियोस्क।",
    patientSignIn: "रोगी साइन इन →", newRegistration: "नया रोगी पंजीकरण", doctorPortal: "डॉक्टर पोर्टल",
    safety: "सुरक्षा सूचना: यह प्रोटोटाइप इतिहास दर्ज करता है और नियम-आधारित संकेत दिखाता है। यह निदान या उपचार की सलाह नहीं देता।"
  }
} as const;

const portalCopy = {
  en: {
    home: "Home", myVisits: "My visits", directory: "Patient Directory", startVisit: "+ Start a new visit", newCase: "+ New case taking",
    patientPortal: "Patient portal", patientPreview: "Patient preview", healthVisit: "My health visit", patientWelcome: "Your patient profile and visit history are available below.",
    patientIntro: "Start a structured intake, track its review status, and prepare documents for your clinician.", recordedVisits: "Recorded visits", guided: "Guided intake", guidedTitle: "Tell us what brought you in.", startIntake: "Start case intake →",
    profile: "Patient profile", edit: "Edit details", cancel: "Cancel", save: "Save profile details", previous: "Previous reports & OCR", addReport: "Add report & process OCR", visitHistory: "My visit timeline",
    allVisits: "All patient visits stored for this account.", noVisits: "No visits have been recorded for this patient yet.", firstVisit: "Start your first visit →",
    doctorOverview: "Clinical Overview & Case Portal", doctorWelcome: "Clinical review workspace is ready.", clinicalQueue: "Clinical queue", recentCases: "Recent clinical cases", openQueue: "Open clinical queue →",
  },
  hi: {
    home: "होम", myVisits: "मेरी विज़िट", directory: "रोगी निर्देशिका", startVisit: "+ नई विज़िट शुरू करें", newCase: "+ नया केस-टेकिंग",
    patientPortal: "रोगी पोर्टल", patientPreview: "रोगी पूर्वावलोकन", healthVisit: "मेरी स्वास्थ्य विज़िट", patientWelcome: "आपकी रोगी प्रोफ़ाइल और विज़िट इतिहास नीचे उपलब्ध है।",
    patientIntro: "संरचित इंटेक शुरू करें, समीक्षा स्थिति ट्रैक करें और अपने चिकित्सक के लिए दस्तावेज़ तैयार करें।", recordedVisits: "दर्ज विज़िट", guided: "निर्देशित इंटेक", guidedTitle: "बताइए आपको किस बात की परेशानी है।", startIntake: "केस इंटेक शुरू करें →",
    profile: "रोगी प्रोफ़ाइल", edit: "विवरण संपादित करें", cancel: "रद्द करें", save: "प्रोफ़ाइल विवरण सहेजें", previous: "पिछली रिपोर्ट और OCR", addReport: "रिपोर्ट जोड़ें और OCR करें", visitHistory: "मेरी विज़िट समयरेखा",
    allVisits: "इस खाते के लिए सभी दर्ज रोगी विज़िट।", noVisits: "इस रोगी के लिए अभी तक कोई विज़िट दर्ज नहीं हुई है।", firstVisit: "अपनी पहली विज़िट शुरू करें →",
    doctorOverview: "क्लिनिकल ओवरव्यू और केस पोर्टल", doctorWelcome: "क्लिनिकल समीक्षा कार्यक्षेत्र तैयार है।", clinicalQueue: "क्लिनिकल कतार", recentCases: "हाल की क्लिनिकल केस", openQueue: "क्लिनिकल कतार खोलें →",
  },
} as const;

// Shared UI strings that appear across portal cards, review screens, notices and buttons.
// Patient-entered answers and clinical summaries are intentionally not translated.
const wholeSiteHindi: Record<string, string> = {
  "Patient portal": "रोगी पोर्टल", "Doctor portal": "डॉक्टर पोर्टल", "Doctor console": "डॉक्टर कंसोल", "Clinical workspace": "क्लिनिकल कार्यक्षेत्र", "Patient preview": "रोगी पूर्वावलोकन", "My health visit": "मेरी स्वास्थ्य विज़िट", "My visits": "मेरी विज़िट", "Home": "होम", "Patient Directory": "रोगी निर्देशिका",
  "Care starts with a clear story.": "देखभाल एक स्पष्ट कहानी से शुरू होती है।", "A secure-looking demonstration portal for structured case-taking and clinician review.": "संरचित केस-टेकिंग और चिकित्सक समीक्षा के लिए पोर्टल।", "Sign in to view your visit preview, start a new intake, and follow your case status.": "अपनी विज़िट देखें, नया इंटेक शुरू करें और अपने केस की स्थिति जानें।", "Use the access code given during registration.": "पंजीकरण के समय दिया गया एक्सेस कोड उपयोग करें।", "New here?": "नए हैं?", "Create a patient account": "रोगी खाता बनाएं", "Already registered?": "पहले से पंजीकृत हैं?", "Sign in": "साइन इन", "Use this access code whenever you return to the patient portal.": "रोगी पोर्टल पर लौटने पर इस एक्सेस कोड का उपयोग करें।", "Your personal access code will be generated after registration. Keep it safe for your next sign in.": "पंजीकरण के बाद आपका व्यक्तिगत एक्सेस कोड बनाया जाएगा। अगली बार साइन इन करने के लिए इसे सुरक्षित रखें।",
  "Welcome back.": "वापसी पर स्वागत है।", "Access your health visit": "अपनी स्वास्थ्य विज़िट देखें", "New patient registration": "नया रोगी पंजीकरण", "Create your patient access.": "अपना रोगी एक्सेस बनाएं।", "Register once, sign in anytime": "एक बार पंजीकरण करें, कभी भी साइन इन करें", "Create patient account": "रोगी खाता बनाएं", "Patient sign in": "रोगी साइन इन", "Sign in →": "साइन इन →", "Registration complete": "पंजीकरण पूर्ण", "Your access code is ready": "आपका एक्सेस कोड तैयार है", "Go to patient sign in →": "रोगी साइन इन पर जाएं →",
  "Full name": "पूरा नाम", "Date of birth": "जन्म तिथि", "Gender": "लिंग", "Mobile number": "मोबाइल नंबर", "Select": "चुनें", "Female": "महिला", "Male": "पुरुष", "Other": "अन्य", "Edit details": "विवरण संपादित करें", "Cancel": "रद्द करें", "Save profile details": "प्रोफ़ाइल विवरण सहेजें", "Patient profile": "रोगी प्रोफ़ाइल", "Recorded visits": "दर्ज विज़िट", "My visit timeline": "मेरी विज़िट समयरेखा",
  "Previous reports & OCR": "पिछली रिपोर्ट और OCR", "Add report & process OCR": "रिपोर्ट जोड़ें और OCR करें", "Choose File": "फ़ाइल चुनें", "Mock OCR": "मॉक OCR", "DEMO DATA": "डेमो डेटा", "Start case intake →": "केस इंटेक शुरू करें →", "Start your first visit →": "अपनी पहली विज़िट शुरू करें →", "+ Start a new visit": "+ नई विज़िट शुरू करें", "+ New case taking": "+ नया केस-टेकिंग",
  "Information saved during your registration.": "आपके पंजीकरण के दौरान सहेजी गई जानकारी।", "Add an old prescription or lab report to your patient record.": "अपने रोगी रिकॉर्ड में पुरानी पर्ची या लैब रिपोर्ट जोड़ें।", "The uploaded file is recorded by name; extraction is a labelled mock in this prototype.": "अपलोड की गई फ़ाइल नाम सहित दर्ज की जाती है; निष्कर्षण इस प्रोटोटाइप में एक लेबल किया गया मॉक है।", "Your recent intake activity and clinician review status.": "आपकी हाल की इंटेक गतिविधि और चिकित्सक समीक्षा स्थिति।", "Profile and consent ready": "प्रोफ़ाइल और सहमति तैयार", "Start case-taking when ready": "तैयार होने पर केस-टेकिंग शुरू करें", "Clinician review": "चिकित्सक समीक्षा",
  "Clinical Overview & Case Portal": "क्लिनिकल ओवरव्यू और केस पोर्टल", "Clinical queue": "क्लिनिकल कतार", "Needs review": "समीक्षा आवश्यक", "Recent clinical cases": "हाल की क्लिनिकल केस", "View all cases →": "सभी केस देखें →", "Open clinical queue →": "क्लिनिकल कतार खोलें →", "Standardized AYUSH case-taking": "मानकीकृत आयुष केस-टेकिंग", "Review a complete patient story.": "एक पूर्ण रोगी कहानी की समीक्षा करें।", "Total recorded cases": "कुल दर्ज केस",
  "Review structured patient stories and deterministic triage signals before clinician confirmation.": "चिकित्सक पुष्टि से पहले संरचित रोगी कहानियों और नियम-आधारित ट्रायेज संकेतों की समीक्षा करें।", "Latest patient registrations and consultations.": "नवीनतम रोगी पंजीकरण और परामर्श।", "No clinical cases recorded yet. Start a new case-taking session.": "अभी तक कोई क्लिनिकल केस दर्ज नहीं हुआ है। नया केस-टेकिंग सत्र शुरू करें।", "Select a patient to review structured answers, deterministic red-flag rationale, document extraction, FHIR export, and audit history.": "संरचित उत्तर, नियम-आधारित रेड-फ्लैग तर्क, दस्तावेज़ निष्कर्षण, FHIR एक्सपोर्ट और ऑडिट इतिहास देखने के लिए रोगी चुनें।",
  "Ready for clinician review": "चिकित्सक समीक्षा के लिए तैयार", "Your case is in the queue.": "आपका केस कतार में है।", "Open doctor console →": "डॉक्टर कंसोल खोलें →", "Add a previous report": "पिछली रिपोर्ट जोड़ें", "Process document": "दस्तावेज़ प्रोसेस करें", "Generate summary →": "सारांश बनाएं →", "Skip document and generate summary": "दस्तावेज़ छोड़ें और सारांश बनाएं", "Editable clinical summary": "संपादन योग्य क्लिनिकल सारांश", "Confirm clinical summary": "क्लिनिकल सारांश की पुष्टि करें", "Reject / return to intake": "अस्वीकार करें / इंटेक पर लौटें", "Structured history": "संरचित इतिहास", "Document extraction": "दस्तावेज़ निष्कर्षण", "Audit timeline": "ऑडिट समयरेखा", "FHIR export": "FHIR एक्सपोर्ट", "Triage escalation": "ट्रायेज एस्केलेशन", "← Queue": "← कतार",
  "Step 3 of 3": "चरण 3 / 3", "Patient access code": "रोगी एक्सेस कोड", "Display name": "प्रदर्शन नाम", "Staff access code": "स्टाफ एक्सेस कोड", "Continue to clinical workspace →": "क्लिनिकल कार्यक्षेत्र में जाएं →", "Continue →": "जारी रखें →", "Patient case-taking software": "रोगी केस-टेकिंग सॉफ्टवेयर",
};

/** The scripted urgent chest-pain demo answers, matching the 5-minute SIH demo script. */
const DEMO_ANSWERS: Record<string, { value: string; input: "VOICE" | "TOUCH" }> = {
  chief: { value: "Severe chest pain and tightness", input: "VOICE" },
  duration: { value: "1–3 days ago", input: "VOICE" },
  severity: { value: "Severe (7–10)", input: "VOICE" },
  breathlessness: { value: "Yes", input: "VOICE" },
  sweating: { value: "Yes", input: "VOICE" },
  history: { value: "Diabetes; Metformin 500 mg; no known allergies", input: "VOICE" },
};

export default function Home() {
  const [view, setView] = useState<View>("home");
  const [lang, setLang] = useState<"en" | "hi">("en");
  const [mode, setMode] = useState<"GENERAL" | "AYUSH">("GENERAL");
  const [visitId, setVisitId] = useState<string | null>(null);
  const [step, setStep] = useState(0);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [answerDraft, setAnswerDraft] = useState("");
  const [isListening, setIsListening] = useState(false);
  const [notice, setNotice] = useState("");
  const [active, setActive] = useState<CaseData | null>(null);
  const [summaryDraft, setSummaryDraft] = useState("");
  const [fhirJson, setFhirJson] = useState<string | null>(null);
  const [loginRole, setLoginRole] = useState<LoginRole>("PATIENT");
  const [displayName, setDisplayName] = useState("Ishant Avasthi");
  const [accountName, setAccountName] = useState("");
  const [accountPhone, setAccountPhone] = useState("");
  const [accountDob, setAccountDob] = useState("");
  const [accountGender, setAccountGender] = useState("");
  const [accessCode, setAccessCode] = useState("");
  const [assignedCode, setAssignedCode] = useState<string | null>(null);
  const [patientAccount, setPatientAccount] = useState<PatientAccount | null>(null);
  const [editingProfile, setEditingProfile] = useState(false);
  const [patientDocumentNotice, setPatientDocumentNotice] = useState("");
  const translatedTextNodes = useRef(new WeakMap<Text, string>());
  const translatedPlaceholders = useRef(new WeakMap<HTMLInputElement | HTMLTextAreaElement, string>());

  const q: Question | undefined = questions[mode][step];
  const total = questions[mode].length;
  const text = copy[lang];
  const portal = portalCopy[lang];

  useEffect(() => {
    const translate = (source: string) => wholeSiteHindi[source.replace(/\s+/g, " ").trim()];
    const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);
    const textNodes: Text[] = [];
    while (walker.nextNode()) textNodes.push(walker.currentNode as Text);
    for (const node of textNodes) {
      const parent = node.parentElement;
      if (!parent || ["SCRIPT", "STYLE", "TEXTAREA", "PRE"].includes(parent.tagName)) continue;
      const current = node.textContent ?? "";
      const original = translatedTextNodes.current.get(node);
      if (lang === "en") {
        if (original && current === translate(original)) node.textContent = original;
        continue;
      }
      if (!original) {
        const translated = translate(current);
        if (translated) {
          translatedTextNodes.current.set(node, current);
          node.textContent = translated;
        }
      }
    }
    for (const element of Array.from(document.querySelectorAll<HTMLInputElement | HTMLTextAreaElement>("input[placeholder], textarea[placeholder]"))) {
      const current = element.placeholder;
      const original = translatedPlaceholders.current.get(element);
      if (lang === "en") {
        if (original && current === translate(original)) element.placeholder = original;
        continue;
      }
      if (!original) {
        const translated = translate(current);
        if (translated) { translatedPlaceholders.current.set(element, current); element.placeholder = translated; }
      }
    }
  });

  const reset = () => {
    setDemoRole("PATIENT");
    setView("home");
    setVisitId(null);
    setStep(0);
    setAnswers({});
    setAnswerDraft("");
    setIsListening(false);
    setNotice("");
    setActive(null);
    setFhirJson(null);
    setPatientAccount(null);
  };

  const goDoctor = () => {
    setDemoRole("DOCTOR");
    setView("doctor");
  };

  const openLogin = (role: LoginRole) => {
    setLoginRole(role);
    setView(role === "PATIENT" ? "patientLogin" : "login");
  };

  const continueLogin = () => {
    setDemoRole(loginRole);
    setView(loginRole === "DOCTOR" ? "doctorDashboard" : "patientDashboard");
  };

  // ---------- tRPC ----------
  const utils = api.useUtils();
  const createVisit = api.createVisit.useMutation({
    onSuccess: async (data, vars) => {
      setVisitId(data.visitId);
      if (vars.demo) {
        // Scripted urgent demo: replay all answers as voice-captured, then jump to upload.
        for (const question of questions.GENERAL) {
          const demo = DEMO_ANSWERS[question.id];
          await saveAnswerRaw(question, demo.value, demo.input, data.visitId);
        }
        setStep(total);
        setView("upload");
      } else {
        setView("intake");
      }
    },
    onError: (e) => alert(e.message),
  });

  async function saveAnswerRaw(
    question: Question,
    value: string,
    inputMode: "TOUCH" | "TEXT" | "VOICE",
    id: string,
  ) {
    const result = await utils.client.saveAnswer.mutate({
      visitId: id,
      questionId: question.id,
      label: question.label,
      answer: value,
      inputMode,
    });
    setAnswers((prev) => ({ ...prev, [question.id]: value }));
    if (result.flags.length > 0) {
      setNotice(result.flags.map((f) => f.message).join(" "));
    }
  }

  const queueQuery = api.doctorQueue.useQuery(undefined, {
    enabled: view === "doctor" || view === "doctorDashboard",
    refetchOnMount: "always",
  });

  const openCase = async (id: string) => {
    const data = await utils.client.doctorCase.query({ visitId: id });
    setActive(data);
    setSummaryDraft(data.visit.summary?.summaryText ?? "");
    setFhirJson(null);
    setView("case");
  };

  const review = api.reviewSummary.useMutation({
    onSuccess: async (_data, vars) => {
      await utils.doctorCase.invalidate({ visitId: active?.visit.id });
      await utils.doctorQueue.invalidate();
      await openCase(active!.visit.id);
      alert(`Summary ${vars.status.toLowerCase()} and audited.`);
    },
    onError: (e) => alert(e.message),
  });

  const completeVisit = api.completeVisit.useMutation({
    onSuccess: () => {
      setView("done");
    },
    onError: (e) => alert(e.message),
  });

  const patientRegister = api.patientRegister.useMutation({
    onSuccess: (data) => {
      setAssignedCode(data.accessCode);
      setAccessCode(data.accessCode);
      setDisplayName(data.fullName);
    },
    onError: (error) => alert(error.message),
  });

  const patientLogin = api.patientLogin.useMutation({
    onSuccess: (data) => {
      setDemoRole("PATIENT");
      setDisplayName(data.fullName);
      setPatientAccount(data as PatientAccount);
      window.localStorage.setItem("medikiosk_patient_access_code", accessCode.toUpperCase());
      setView("patientDashboard");
    },
    onError: (error) => alert(error.message),
  });

  const patientUpdate = api.patientUpdate.useMutation({
    onSuccess: (data) => {
      setPatientAccount((current) => current ? { ...current, fullName: data.fullName, dob: data.dob, gender: data.gender, phone: data.phone } : current);
      setDisplayName(data.fullName);
      setEditingProfile(false);
      setPatientDocumentNotice("Your profile details have been saved.");
    },
    onError: (error) => alert(error.message),
  });

  const patientAddDocument = api.patientAddDocument.useMutation({
    onSuccess: (data) => {
      setPatientDocumentNotice(`Previous report added: ${data.document.filename}. MOCK OCR found ${data.document.entities.map((entity) => `${entity.name} ${entity.value} ${entity.unit}`).join("; ")}.`);
    },
    onError: (error) => alert(error.message),
  });

  // ---------- kiosk actions ----------
  const startVisit = (demo: boolean) => {
    setDemoRole("PATIENT");
    const nameEl = document.getElementById("name") as HTMLInputElement | null;
    const dobEl = document.getElementById("dob") as HTMLInputElement | null;
    const genderEl = document.getElementById("gender") as HTMLSelectElement | null;
    const phoneEl = document.getElementById("phone") as HTMLInputElement | null;
    const consentEl = document.getElementById("consent") as HTMLInputElement | null;
    const fullName = demo ? "Meera Sharma" : nameEl?.value?.trim() || patientAccount?.fullName || "";
    const dob = demo ? "1982-11-12" : dobEl?.value || patientAccount?.dob?.toISOString().slice(0, 10) || "";
    const gender = demo ? "Female" : genderEl?.value || patientAccount?.gender || "";
    const phone = demo ? "9876543210" : phoneEl?.value?.trim() || patientAccount?.phone || "";
    if (!demo && (!fullName || !dob || !gender || !phone || !consentEl?.checked)) {
      alert(lang === "hi" ? "कृपया सभी विवरण भरें और सहमति दें।" : "Please complete every detail and accept consent.");
      return;
    }
    createVisit.mutate({
      fullName,
      dob,
      gender,
      phone,
      language: lang,
      mode,
      patientId: patientAccount?.id,
      consents: [...CONSENTS],
      demo,
    });
  };

  const next = async (value: string, inputMode: "TOUCH" | "TEXT" | "VOICE") => {
    if (!q || !visitId || !value.trim()) return;
    await saveAnswerRaw(q, value, inputMode, visitId);
    setAnswerDraft("");
    setIsListening(false);
    if (step + 1 < total) setStep(step + 1);
    else setView("upload");
  };

  const speak = () => {
    if (isListening) return;
    let fallbackQueued = false;
    const insertDemoTranscript = () => {
      if (fallbackQueued) return;
      fallbackQueued = true;
      const english: Record<string, string> = {
        chief: "I have pain and discomfort.",
        history: "No known allergies."
      };
      const hindi: Record<string, string> = {
        chief: "मुझे दर्द और तकलीफ है।",
        history: "मुझे कोई ज्ञात एलर्जी नहीं है।"
      };
      setIsListening(true);
      setNotice(text.listening);
      window.setTimeout(() => {
        setAnswerDraft((lang === "hi" ? hindi : english)[q?.id ?? ""] ?? (lang === "hi" ? "कृपया अपनी समस्या बताएं।" : "Please describe your concern."));
        setIsListening(false);
        setNotice(`${text.voiceFallback} ${text.useTyped}`);
      }, 1100);
    };
    const R =
      (window as unknown as { SpeechRecognition?: new () => SpeechRecognitionLike; webkitSpeechRecognition?: new () => SpeechRecognitionLike })
        .SpeechRecognition ??
      (window as unknown as { webkitSpeechRecognition?: new () => SpeechRecognitionLike })
        .webkitSpeechRecognition;
    if (!R) {
      insertDemoTranscript();
      return;
    }
    const rec = new R();
    rec.lang = lang === "hi" ? "hi-IN" : "en-IN";
    rec.continuous = false;
    rec.interimResults = true;
    rec.onstart = () => {
      setIsListening(true);
      setNotice(text.listening);
    };
    rec.onresult = (e) => {
      const last = e.results[e.results.length - 1]?.[0]?.transcript ?? "";
      if (last) setAnswerDraft(last);
      if (e.results[e.results.length - 1]?.isFinal) {
        setIsListening(false);
        setNotice(`${text.voiceCaptured} ${text.useTyped}`);
      }
    };
    rec.onerror = () => insertDemoTranscript();
    rec.onend = () => {
      if (!fallbackQueued) setIsListening(false);
    };
    try {
      setIsListening(true);
      setNotice(text.listening);
      rec.start();
    } catch {
      insertDemoTranscript();
    }
  };

  const uploadDocument = api.uploadDocument.useMutation({
    onSuccess: (data) => {
      setNotice(
        `Mock OCR complete: ${data.entities
          .map((e) => `${e.name} ${e.value} ${e.unit}${e.abnormal ? " (abnormal)" : ""}`)
          .join("; ")}`,
      );
    },
    onError: (e) => alert(e.message),
  });

  const processFile = () => {
    const el = document.getElementById("file") as HTMLInputElement | null;
    const file = el?.files?.[0];
    if (!file || !visitId) {
      alert("Choose a file first.");
      return;
    }
    uploadDocument.mutate({ visitId, filename: file.name, size: file.size });
  };

  const showFhir = async () => {
    if (!active) return;
    const bundle = await utils.client.fhirExport.query({ visitId: active.visit.id });
    setFhirJson(JSON.stringify(bundle, null, 2));
  };

  // ---------- views ----------
  if (view === "home") {
    return (
      <main>
        <Header onHome={reset} language={lang} onLanguageChange={setLang} />
        <section className="card mx-auto mt-10 max-w-3xl">
          <p className="eyebrow">{text.landingEyebrow}</p>
          <h1 className="mt-2 text-3xl font-bold text-brand-900">
            {text.landingTitle}
          </h1>
          <p className="mt-3 text-slate-600">
            {text.landingDescription}
          </p>
          <div className="mt-6 flex flex-wrap gap-3">
            <button className="btn btn-primary" onClick={() => setView("patientLogin")}>
              {text.patientSignIn}
            </button>
            <button className="btn btn-secondary" onClick={() => { setAssignedCode(null); setView("patientRegister"); }}>
              {text.newRegistration}
            </button>
            <button className="btn btn-secondary" onClick={() => openLogin("DOCTOR")}>
              {text.doctorPortal}
            </button>
          </div>
          <aside className="notice mt-6 text-sm">
            {text.safety}
          </aside>
        </section>
      </main>
    );
  }

  if (view === "patientLogin") {
    return (
      <main className="login-shell">
        <Header onHome={reset} language={lang} onLanguageChange={setLang} />
        <section className="login-card mx-auto mt-7 max-w-4xl overflow-hidden">
          <div className="login-aside"><span className="portal-mark">✦</span><p className="eyebrow text-blue-100 mt-5">Patient portal</p><h1 className="mt-3 text-3xl font-bold text-white">Welcome back.</h1><p className="mt-4 text-sm leading-6 text-blue-100">Sign in to view your visit preview, start a new intake, and follow your case status.</p></div>
          <div className="p-7 sm:p-10"><p className="eyebrow">Patient sign in</p><h2 className="mt-2 text-3xl font-bold text-brand-900">Access your health visit</h2><p className="mt-2 text-slate-600">Use the access code given during registration.</p>
            <label className="eyebrow mt-7 block" htmlFor="accessCode">Patient access code</label><input id="accessCode" className="input mt-2 uppercase" value={accessCode} onChange={(e) => setAccessCode(e.target.value.toUpperCase())} placeholder="PT-ISHANT18" />
            <button className="btn btn-primary mt-7 w-full" disabled={patientLogin.isPending} onClick={() => patientLogin.mutate({ accessCode })}>Sign in →</button>
            <p className="mt-5 text-center text-sm text-slate-600">New here? <button className="font-semibold text-brand-600 underline" onClick={() => { setAssignedCode(null); setView("patientRegister"); }}>Create a patient account</button></p>
          </div>
        </section>
      </main>
    );
  }

  if (view === "patientRegister") {
    return (
      <main className="login-shell"><Header onHome={reset} language={lang} onLanguageChange={setLang} />
        <section className="login-card mx-auto mt-7 max-w-4xl overflow-hidden"><div className="login-aside"><span className="portal-mark">✦</span><p className="eyebrow text-blue-100 mt-5">New patient registration</p><h1 className="mt-3 text-3xl font-bold text-white">Create your patient access.</h1><p className="mt-4 text-sm leading-6 text-blue-100">Your personal access code will be generated after registration. Keep it safe for your next sign in.</p></div>
          <div className="p-7 sm:p-10">{assignedCode ? <><p className="eyebrow">Registration complete</p><h2 className="mt-2 text-3xl font-bold text-brand-900">Your access code is ready</h2><p className="mt-3 text-slate-600">Use this access code whenever you return to the patient portal.</p><div className="access-code mt-6">{assignedCode}</div><button className="btn btn-primary mt-7 w-full" onClick={() => setView("patientLogin")}>Go to patient sign in →</button></> : <><p className="eyebrow">Create patient account</p><h2 className="mt-2 text-3xl font-bold text-brand-900">Register once, sign in anytime</h2><label className="eyebrow mt-6 block" htmlFor="accountName">Full name</label><input id="accountName" className="input mt-2" value={accountName} onChange={(e) => setAccountName(e.target.value)} placeholder="Your full name" /><label className="eyebrow mt-5 block" htmlFor="accountDob">Date of birth</label><input id="accountDob" type="date" className="input mt-2" value={accountDob} onChange={(e) => setAccountDob(e.target.value)} max={new Date().toISOString().slice(0, 10)} /><label className="eyebrow mt-5 block" htmlFor="accountGender">Gender</label><select id="accountGender" className="input mt-2" value={accountGender} onChange={(e) => setAccountGender(e.target.value)}><option value="">Select</option><option>Female</option><option>Male</option><option>Other</option></select><label className="eyebrow mt-5 block" htmlFor="accountPhone">Mobile number</label><input id="accountPhone" className="input mt-2" inputMode="numeric" value={accountPhone} onChange={(e) => setAccountPhone(e.target.value)} placeholder="10-digit mobile number" /><button className="btn btn-primary mt-7 w-full" disabled={patientRegister.isPending} onClick={() => patientRegister.mutate({ fullName: accountName, phone: accountPhone, dob: accountDob, gender: accountGender, language: lang })}>Create patient account →</button><p className="mt-5 text-center text-sm text-slate-600">Already registered? <button className="font-semibold text-brand-600 underline" onClick={() => setView("patientLogin")}>Sign in</button></p></>}</div>
        </section>
      </main>
    );
  }

  if (view === "login") {
    return (
      <main className="login-shell">
        <Header onHome={reset} language={lang} onLanguageChange={setLang} />
        <section className="login-card mx-auto mt-7 max-w-4xl overflow-hidden">
          <div className="login-aside">
            <span className="portal-mark">✦</span>
              <p className="eyebrow text-blue-100">Clinical staff portal</p>
            <h1 className="mt-3 text-3xl font-bold text-white">Care starts with a clear story.</h1>
            <p className="mt-4 text-sm leading-6 text-blue-100">
              A secure-looking demonstration portal for structured case-taking and clinician review.
            </p>
            <div className="login-trust mt-7">
              <b>SIH26047 clinical workspace</b>
              <span>Structured history, review queue, and clinician confirmation tools.</span>
            </div>
          </div>
          <div className="p-7 sm:p-10">
            <p className="eyebrow">Doctor sign in</p>
            <h2 className="mt-2 text-3xl font-bold text-brand-900">Clinical workspace</h2>
            <p className="mt-2 text-slate-600">Enter your display name to access the review queue.</p>
            <label className="eyebrow mt-7 block" htmlFor="displayName">Display name</label>
            <input id="displayName" className="input mt-2" value={displayName} onChange={(e) => setDisplayName(e.target.value)} placeholder="Your name" />
            <label className="eyebrow mt-5 block" htmlFor="doctorAccess">Staff access code</label>
            <input id="doctorAccess" className="input mt-2" defaultValue="DR-26047" />
            <button className="btn btn-primary mt-7 w-full" onClick={() => { setLoginRole("DOCTOR"); continueLogin(); }}>Continue to clinical workspace →</button>
            <p className="mt-5 text-center text-sm text-slate-600">Patient account? <button className="font-semibold text-brand-600 underline" onClick={() => setView("patientLogin")}>Patient sign in</button></p>
          </div>
        </section>
      </main>
    );
  }

  if (view === "patientDashboard") {
    return (
      <main>
        <PortalHeader name={displayName} role="Patient" language={lang} onLanguageChange={setLang} onHome={reset} onPortalHome={() => setView("patientDashboard")} onVisits={() => setView("patientVisits")} onPrimary={() => setView("register")} primaryLabel={portal.startVisit} />
        <section className="portal-page mx-auto max-w-5xl">
          <div className="welcome-banner"><span>✓</span> {lang === "hi" ? "वापसी पर स्वागत है," : "Welcome back,"} {displayName || "patient"}. {portal.patientWelcome}</div>
          <p className="eyebrow mt-8">{portal.patientPreview}</p>
          <h1 className="mt-2 text-3xl font-bold text-brand-900">{portal.healthVisit}</h1>
          <p className="mt-2 text-slate-600">{portal.patientIntro}</p>
          <div className="mt-7 grid gap-5 md:grid-cols-[1.05fr_.95fr]">
            <section className="portal-stat card">
              <span className="portal-icon">◉</span><div><b className="text-4xl text-brand-900">{patientAccount?.visits.length ?? 0}</b><p className="eyebrow mt-1">{portal.recordedVisits}</p></div>
              <span className="badge badge-normal ml-auto">Ready to start</span>
            </section>
            <section className="case-cta">
              <p className="eyebrow text-blue-100">{portal.guided}</p><h2>{portal.guidedTitle}</h2>
              <p>{lang === "hi" ? "सामान्य या आयुष इंटेक चुनें, टेक्स्ट या आवाज़ में उत्तर दें और साझा जानकारी की समीक्षा करें।" : "Choose General or AYUSH intake, answer in text or voice, and review what is shared."}</p>
              <button className="btn bg-white text-brand-700" onClick={() => setView("register")}>{portal.startIntake}</button>
            </section>
          </div>
          {patientAccount && <>
            <section className="card mt-6"><div className="flex items-center justify-between gap-3"><div><h2 className="text-xl font-bold text-brand-900">{portal.profile}</h2><p className="mt-1 text-sm text-slate-500">{lang === "hi" ? "आपके पंजीकरण के दौरान सहेजी गई जानकारी।" : "Information saved during your registration."}</p></div><div className="flex items-center gap-3"><span className="access-inline">{patientAccount.accessCode}</span><button className="btn btn-secondary" onClick={() => setEditingProfile((value) => !value)}>{editingProfile ? portal.cancel : portal.edit}</button></div></div>
              {editingProfile ? <div className="mt-5 grid gap-4 sm:grid-cols-2"><div><label className="eyebrow">Full name</label><input id="editName" className="input mt-2" defaultValue={patientAccount.fullName} /></div><div><label className="eyebrow">Date of birth</label><input id="editDob" type="date" className="input mt-2" defaultValue={patientAccount.dob?.toISOString().slice(0, 10)} /></div><div><label className="eyebrow">Gender</label><select id="editGender" className="input mt-2" defaultValue={patientAccount.gender ?? ""}><option value="">Select</option><option>Female</option><option>Male</option><option>Other</option></select></div><div><label className="eyebrow">Mobile number</label><input id="editPhone" className="input mt-2" defaultValue={patientAccount.phone ?? ""} /></div><button className="btn btn-primary sm:col-span-2" disabled={patientUpdate.isPending} onClick={() => patientUpdate.mutate({ patientId: patientAccount.id, fullName: (document.getElementById("editName") as HTMLInputElement).value, dob: (document.getElementById("editDob") as HTMLInputElement).value, gender: (document.getElementById("editGender") as HTMLSelectElement).value, phone: (document.getElementById("editPhone") as HTMLInputElement).value })}>Save profile details</button></div> : <div className="mt-5 grid gap-4 sm:grid-cols-2 lg:grid-cols-4"><p><span className="eyebrow">Full name</span><br /><b>{patientAccount.fullName}</b></p><p><span className="eyebrow">Date of birth</span><br /><b>{patientAccount.dob?.toISOString().slice(0, 10) ?? "Not recorded"}</b></p><p><span className="eyebrow">Gender</span><br /><b>{patientAccount.gender ?? "Not recorded"}</b></p><p><span className="eyebrow">Mobile</span><br /><b>{patientAccount.phone ?? "Not recorded"}</b></p></div>}
            </section>
            <section className="card mt-6"><div className="flex flex-wrap items-center justify-between gap-3"><div><h2 className="text-xl font-bold text-brand-900">{portal.previous}</h2><p className="mt-1 text-sm text-slate-500">{lang === "hi" ? "अपने रोगी रिकॉर्ड में पुरानी पर्ची या लैब रिपोर्ट जोड़ें।" : "Add an old prescription or lab report to your patient record."}</p></div><span className="mock-tag">Mock OCR</span></div><div className="mt-5 flex flex-wrap gap-3"><input id="patientReport" className="input max-w-md" type="file" accept=".pdf,image/*" /><button className="btn btn-primary" disabled={patientAddDocument.isPending} onClick={() => { const file = (document.getElementById("patientReport") as HTMLInputElement).files?.[0]; if (!file) { setPatientDocumentNotice("Choose a previous report before processing it."); return; } patientAddDocument.mutate({ patientId: patientAccount.id, filename: file.name, size: file.size }); }}>{portal.addReport}</button></div><p className="mt-3 text-xs text-slate-500">{lang === "hi" ? "अपलोड की गई फ़ाइल नाम सहित दर्ज की जाती है; निष्कर्षण इस प्रोटोटाइप में एक लेबल किया गया मॉक है।" : "The uploaded file is recorded by name; extraction is a labelled mock in this prototype."}</p>{patientDocumentNotice && <aside className="notice mt-4 text-sm">{patientDocumentNotice}</aside>}</section>
          </>}
          <section className="card mt-6">
            <div className="flex flex-wrap items-center justify-between gap-3"><div><h2 className="text-xl font-bold text-brand-900">My visit timeline</h2><p className="mt-1 text-sm text-slate-500">Your recent intake activity and clinician review status.</p></div><span className="mock-tag">Demo data</span></div>
            <div className="timeline mt-6"><div><b>Profile and consent ready</b><span>Today - patient portal</span></div><div><b>Start case-taking when ready</b><span>General and AYUSH pathways available</span></div><div><b>Clinician review</b><span>Available after you submit a case summary</span></div></div>
          </section>
        </section>
      </main>
    );
  }

  if (view === "patientVisits") {
    const visits = patientAccount?.visits ?? [];
    return <main><PortalHeader name={displayName} role="Patient" language={lang} onLanguageChange={setLang} onHome={reset} onPortalHome={() => setView("patientDashboard")} onVisits={() => setView("patientVisits")} onPrimary={() => setView("register")} primaryLabel="+ Start a new visit" /><section className="portal-page mx-auto max-w-5xl"><p className="eyebrow">Patient portal</p><h1 className="mt-2 text-3xl font-bold text-brand-900">My visits</h1><p className="mt-2 text-slate-600">All patient visits stored for this account.</p><section className="card mt-7">{visits.length ? <div className="grid gap-3">{visits.map((visit) => <div key={visit.id} className="choice flex items-center justify-between"><span><b>{visit.mode === "AYUSH" ? "AYUSH intake" : "General clinical intake"}</b><small className="block text-slate-500">Started {new Date(visit.startedAt).toLocaleString()} · {visit.status.replaceAll("_", " ").toLowerCase()}</small></span><span className={`badge ${visit.priority === "URGENT" ? "badge-urgent" : "badge-normal"}`}>{visit.priority}</span></div>)}</div> : <div className="py-10 text-center"><p className="text-slate-500">No visits have been recorded for this patient yet.</p><button className="btn btn-primary mt-5" onClick={() => setView("register")}>Start your first visit →</button></div>}</section></section></main>;
  }

  if (view === "doctorDashboard") {
    const cases = queueQuery.data ?? [];
    return (
      <main>
        <PortalHeader name={displayName} role="Doctor" language={lang} onLanguageChange={setLang} onHome={reset} onPortalHome={() => setView("doctorDashboard")} onVisits={goDoctor} onPrimary={() => setView("register")} primaryLabel={portal.newCase} />
        <section className="portal-page mx-auto max-w-5xl">
          <div className="welcome-banner"><span>✓</span> {lang === "hi" ? "वापसी पर स्वागत है," : "Welcome back,"} Dr. {displayName || "clinician"}. {portal.doctorWelcome}</div>
          <p className="eyebrow mt-8">{portal.doctorOverview}</p>
          <h1 className="mt-2 text-3xl font-bold text-brand-900">{portal.doctorOverview}</h1>
          <p className="mt-2 text-slate-600">Review structured patient stories and deterministic triage signals before clinician confirmation.</p>
          <div className="mt-7 grid gap-5 md:grid-cols-2">
            <section className="portal-stat card"><span className="portal-icon">♧</span><div><b className="text-4xl text-brand-900">{cases.length}</b><p className="eyebrow mt-1">Total recorded cases</p></div></section>
            <section className="case-cta"><p className="eyebrow text-blue-100">{lang === "hi" ? "मानकीकृत आयुष केस-टेकिंग" : "Standardized AYUSH case-taking"}</p><h2>{lang === "hi" ? "एक पूर्ण रोगी कहानी की समीक्षा करें।" : "Review a complete patient story."}</h2><p>{lang === "hi" ? "संरचित शिकायतें, इतिहास, दशविध क्षेत्र, दस्तावेज़ इकाइयाँ और नियम-आधारित ट्रायेज तर्क।" : "Structured complaints, history, Dashavidha fields, document entities, and rule-based triage rationale."}</p><button className="btn bg-white text-brand-700" onClick={goDoctor}>{portal.openQueue}</button></section>
          </div>
          <section className="card mt-6"><div className="flex flex-wrap items-center justify-between gap-3"><div><h2 className="text-xl font-bold text-brand-900">{portal.recentCases}</h2><p className="mt-1 text-sm text-slate-500">{lang === "hi" ? "नवीनतम रोगी पंजीकरण और परामर्श।" : "Latest patient registrations and consultations."}</p></div><button className="btn btn-secondary" onClick={goDoctor}>{lang === "hi" ? "सभी केस देखें →" : "View all cases →"}</button></div>
            <div className="mt-5 grid gap-3">{cases.slice(0, 3).map((c) => <button key={c.id} className="choice flex items-center justify-between" onClick={() => openCase(c.id)}><span><b>{c.fullName}</b><small className="block text-slate-500">{c.status.replaceAll("_", " ").toLowerCase()}</small></span><span className={`badge ${c.priority === "URGENT" ? "badge-urgent" : "badge-normal"}`}>{c.priority}</span></button>)}{!cases.length && <p className="py-8 text-center text-slate-500">No clinical cases recorded yet. Start a new case-taking session.</p>}</div>
          </section>
        </section>
      </main>
    );
  }

  if (view === "register") {
    return (
      <main>
        <Header onHome={reset} language={lang} onLanguageChange={setLang} />
        <section className="card mx-auto mt-10 max-w-2xl">
          <p className="eyebrow">{text.step}</p>
          <h2 className="mt-1 text-2xl font-bold text-brand-900">{text.start}</h2>

          <label className="eyebrow mt-6 block">{text.pathway}</label>
          <select
            className="input mt-2"
            value={mode}
            onChange={(e) => setMode(e.target.value as "GENERAL" | "AYUSH")}
          >
            <option value="GENERAL">{text.general}</option>
            <option value="AYUSH">{text.ayush}</option>
          </select>

          <label className="eyebrow mt-6 block" htmlFor="name">
            {text.name}
          </label>
          <input id="name" className="input mt-2" placeholder={text.nameHint} />

          <div className="mt-6 grid gap-4 sm:grid-cols-2">
            <div>
              <label className="eyebrow block" htmlFor="dob">
                {lang === "hi" ? "जन्म तिथि" : "Date of birth"}
              </label>
              <input id="dob" className="input mt-2" type="date" max={new Date().toISOString().slice(0, 10)} />
            </div>
            <div>
              <label className="eyebrow block" htmlFor="gender">
                {lang === "hi" ? "लिंग" : "Gender"}
              </label>
              <select id="gender" className="input mt-2" defaultValue="">
                <option value="" disabled>{lang === "hi" ? "चुनें" : "Select"}</option>
                <option value="Female">{lang === "hi" ? "महिला" : "Female"}</option>
                <option value="Male">{lang === "hi" ? "पुरुष" : "Male"}</option>
                <option value="Other">{lang === "hi" ? "अन्य" : "Other"}</option>
              </select>
            </div>
          </div>

          <label className="eyebrow mt-6 block" htmlFor="phone">
            {lang === "hi" ? "मोबाइल नंबर" : "Mobile number"}
          </label>
          <input id="phone" className="input mt-2" type="tel" inputMode="numeric" placeholder={lang === "hi" ? "10 अंकों का मोबाइल नंबर" : "10-digit mobile number"} />

          <label className="mt-6 flex items-start gap-2 text-sm text-slate-700">
            <input id="consent" type="checkbox" className="mt-1" />
            <span>
              {text.consent}
            </span>
          </label>

          <div className="mt-6 flex flex-wrap gap-3">
            <button className="btn btn-primary" onClick={() => startVisit(false)} disabled={createVisit.isPending}>
              {text.continue}
            </button>
            <button className="btn btn-secondary" onClick={() => startVisit(true)} disabled={createVisit.isPending}>
              {text.urgent}
            </button>
          </div>

          <aside className="notice mt-6 text-sm">
            <span className="mock-tag">{text.mock}</span> {text.registrationNotice}
          </aside>
        </section>
      </main>
    );
  }

  if (view === "intake" && q) {
    return (
      <main>
        <Header onHome={reset} language={lang} onLanguageChange={setLang} />
        <section className="card mx-auto mt-10 max-w-2xl">
          <div className="flex gap-1">
            {questions[mode].map((_, i) => (
              <span
                key={i}
                className={`h-1.5 flex-1 rounded-full ${i <= step ? "bg-brand-500" : "bg-slate-200"}`}
              />
            ))}
          </div>
          <p className="eyebrow mt-4">
            {mode === "AYUSH" ? text.ayushField : text.adaptive} ·{" "}
            {step + 1}/{total}
          </p>
          <h2 className="mt-1 text-2xl font-bold text-brand-900">
            {lang === "hi" ? q.hi : q.label}
          </h2>

          {notice && <div className="alert mt-4 text-sm">{notice}</div>}

          {q.type === "choice" ? (
            <div className="mt-6 grid gap-3">
              {q.choices.map((c, index) => (
                <button key={c} className="choice" onClick={() => next(c, "TOUCH")}>
                  {lang === "hi" ? q.hiChoices?.[index] ?? c : c}
                </button>
              ))}
            </div>
          ) : (
            <>
              <textarea
                id="answer"
                className="input mt-6 min-h-28"
                placeholder={text.placeholder}
                value={answerDraft}
                onChange={(event) => setAnswerDraft(event.target.value)}
              />
              <div className={`voice-status mt-3 ${isListening ? "is-listening" : ""}`} aria-live="polite">
                <span className="voice-orb" aria-hidden="true"><i /><i /><i /></span>
                <span>{isListening ? text.listening : text.voiceHint}</span>
              </div>
              <div className="mt-4 flex flex-wrap gap-3">
                <button className={`btn ${isListening ? "btn-listening" : "btn-secondary"}`} onClick={speak} disabled={isListening}>
                  {isListening ? text.listening : text.speak}
                </button>
                <button
                  className="btn btn-primary"
                  onClick={() => {
                    next(answerDraft, "TEXT");
                  }}
                >
                  {text.save}
                </button>
              </div>
            </>
          )}
        </section>
      </main>
    );
  }

  if (view === "upload") {
    return (
      <main>
        <Header onHome={reset} language={lang} onLanguageChange={setLang} />
        <section className="card mx-auto mt-10 max-w-2xl">
          <p className="eyebrow">Step 3 of 3</p>
          <h2 className="mt-1 text-2xl font-bold text-brand-900">Add a previous report</h2>
          <p className="mt-2 text-slate-600">
            Upload a prescription or lab report.{" "}
            <span className="mock-tag">Mock OCR</span> — extraction is a labelled
            prototype mock, not a production pipeline.
          </p>
          <input id="file" type="file" className="input mt-4" />
          <div className="mt-4 flex flex-wrap gap-3">
            <button className="btn btn-primary" onClick={processFile} disabled={uploadDocument.isPending}>
              Process document
            </button>
            <button
              className="btn btn-secondary"
              onClick={() => visitId && completeVisit.mutate({ visitId })}
              disabled={completeVisit.isPending}
            >
              Generate summary →
            </button>
          </div>
          {notice && <aside className="notice mt-4 text-sm">{notice}</aside>}
          <button
            className="mt-4 text-sm text-brand-600 underline"
            onClick={() => visitId && completeVisit.mutate({ visitId })}
          >
            Skip document and generate summary
          </button>
        </section>
      </main>
    );
  }

  if (view === "done") {
    return (
      <main>
        <Header onHome={reset} language={lang} onLanguageChange={setLang} />
        <section className="card mx-auto mt-10 max-w-2xl">
          <p className="eyebrow">Ready for clinician review</p>
          <h2 className="mt-1 text-2xl font-bold text-brand-900">Your case is in the queue.</h2>
          <p className="mt-2 text-slate-600">
            The case summary is generated from structured answers and requires doctor
            confirmation before it is considered final.
          </p>
          <button className="btn btn-primary mt-6" onClick={goDoctor}>
            Open doctor console →
          </button>
        </section>
      </main>
    );
  }

  if (view === "doctor") {
    return (
      <main>
        <Header onHome={reset} language={lang} onLanguageChange={setLang} />
        <section className="mx-auto mt-4 max-w-6xl px-2">
          <div className="grid gap-6 md:grid-cols-[340px_1fr]">
            <aside className="card h-fit">
              <p className="eyebrow">Clinical queue</p>
              <h2 className="mt-1 text-xl font-bold text-brand-900">Needs review</h2>
              {queueQuery.isLoading && <p className="mt-4 text-sm text-slate-500">Loading…</p>}
              {queueQuery.isError && (
                <p className="alert mt-4 text-sm">
                  {queueQuery.error.message} — role check failed? Reload the kiosk flow first.
                </p>
              )}
              <div className="mt-4 grid gap-2">
                {(queueQuery.data ?? []).map((c) => (
                  <button
                    key={c.id}
                    className="choice flex items-center justify-between"
                    onClick={() => openCase(c.id)}
                  >
                    <span>
                      <b>{c.fullName}</b>
                      <br />
                      <small className="text-slate-500">
                        {c.status.replaceAll("_", " ").toLowerCase()}
                      </small>
                    </span>
                    <span className={`badge ${c.priority === "URGENT" ? "badge-urgent" : "badge-normal"}`}>
                      {c.priority}
                    </span>
                  </button>
                ))}
                {(queueQuery.data ?? []).length === 0 && !queueQuery.isLoading && (
                  <p className="text-sm text-slate-500">
                    Queue is empty — complete a kiosk visit first.
                  </p>
                )}
              </div>
            </aside>
            <section className="card">
              <p className="eyebrow">Doctor console</p>
              <h2 className="mt-1 text-xl font-bold text-brand-900">
                One record, one review workspace.
              </h2>
              <p className="mt-2 text-slate-600">
                Select a patient to review structured answers, deterministic red-flag
                rationale, document extraction, FHIR export, and audit history.
              </p>
              <aside className="notice mt-4 text-sm">
                All <span className="mock-tag">Mock</span> OCR, ABHA, and ABDM functions here
                are prototype mocks. Production use requires approved identity, consent,
                security, and clinical governance.
              </aside>
            </section>
          </div>
        </section>
      </main>
    );
  }

  if (view === "case" && active) {
    const v = active.visit;
    return (
      <main>
        <Header onHome={reset} language={lang} onLanguageChange={setLang} />
        <section className="mx-auto mt-2 max-w-6xl px-2">
          <button className="btn btn-secondary mb-4" onClick={goDoctor}>
            ← Queue
          </button>

          <div className="card flex flex-wrap items-start justify-between gap-4">
            <div>
              <p className="eyebrow">
                {v.mode} intake · {v.status.replaceAll("_", " ").toLowerCase()}
              </p>
              <h2 className="mt-1 flex items-center gap-3 text-2xl font-bold text-brand-900">
                {v.patient.fullName}
                <span className={`badge ${v.priority === "URGENT" ? "badge-urgent" : "badge-normal"}`}>
                  {v.priority}
                </span>
              </h2>
              <p className="mt-1 text-sm text-slate-600">
                {v.patient.gender} · DOB {v.patient.dob?.toISOString().slice(0, 10)} ·{" "}
                <span className="mock-tag">Mock</span> {v.patient.abhaId}
              </p>
            </div>
            <button className="btn btn-secondary" onClick={showFhir}>
              FHIR export (<span className="mock-tag">Mock ABDM</span>)
            </button>
          </div>

          {active.visit.redFlags.length > 0 && (
            <div className="alert mt-4">
              <b>Triage escalation</b>
              <br />
              {active.visit.redFlags.map((f) => f.message).join(" ")}
            </div>
          )}

          {fhirJson && (
            <div className="card mt-4">
              <p className="eyebrow">
                FHIR R4 bundle · <span className="mock-tag">Mock ABDM export</span>
              </p>
              <pre className="mt-2 max-h-96 overflow-auto rounded-lg bg-slate-900 p-4 text-xs text-slate-100">
                {fhirJson}
              </pre>
            </div>
          )}

          <div className="mt-4 grid gap-6 lg:grid-cols-2">
            <div className="card">
              <p className="eyebrow">Editable clinical summary</p>
              <textarea
                className="input mt-3 min-h-56"
                value={summaryDraft}
                onChange={(e) => setSummaryDraft(e.target.value)}
              />
              <div className="mt-4 flex flex-wrap gap-3">
                <button
                  className="btn btn-primary"
                  onClick={() =>
                    review.mutate({ visitId: v.id, summaryText: summaryDraft, status: "CONFIRMED" })
                  }
                  disabled={review.isPending}
                >
                  Confirm clinical summary
                </button>
                <button
                  className="btn btn-secondary"
                  onClick={() =>
                    review.mutate({ visitId: v.id, summaryText: summaryDraft, status: "REJECTED" })
                  }
                  disabled={review.isPending}
                >
                  Reject / return to intake
                </button>
              </div>
            </div>

            <div className="card">
              <p className="eyebrow">Structured history</p>
              <div className="mt-3 grid gap-3 text-sm">
                {active.visit.answers.map((a) => (
                  <p key={a.id}>
                    <b>{a.label}</b>
                    <br />
                    <span className="text-slate-700">
                      {a.answer} <small className="text-slate-400">· {a.inputMode}</small>
                    </span>
                  </p>
                ))}
                {active.visit.answers.length === 0 && (
                  <p className="text-slate-500">No answers recorded.</p>
                )}
              </div>
              <hr className="my-4 border-slate-200" />
              <p className="eyebrow">
                Document extraction · <span className="mock-tag">Mock</span>
              </p>
              <div className="mt-3 grid gap-2 text-sm">
                {active.visit.documents.flatMap((d) =>
                  d.entities.map((e) => (
                    <p key={e.id}>
                      <b>{e.name}</b>: {e.value} {e.unit} {e.abnormal ? "⚠️" : ""}
                    </p>
                  )),
                )}
                {active.visit.documents.length === 0 && (
                  <p className="text-slate-500">No documents uploaded.</p>
                )}
              </div>
            </div>
          </div>

          <div className="card mt-6">
            <p className="eyebrow">Audit timeline</p>
            <div className="mt-3 grid gap-2 text-sm">
              {active.audit.map((a) => (
                <p key={a.id} className="border-b border-slate-100 pb-2">
                  <b>{a.action.replaceAll("_", " ").toLowerCase()}</b>
                  <br />
                  <small className="text-slate-500">
                    {new Date(a.createdAt).toLocaleString()} · {a.actor}
                  </small>
                </p>
              ))}
            </div>
          </div>
        </section>
      </main>
    );
  }

  return null;
}

function PortalHeader({ name, role, language, onLanguageChange, onHome, onPortalHome, onVisits, onPrimary, primaryLabel }: { name: string; role: "Patient" | "Doctor"; language: "en" | "hi"; onLanguageChange: (language: "en" | "hi") => void; onHome: () => void; onPortalHome: () => void; onVisits: () => void; onPrimary: () => void; primaryLabel: string }) {
  const labels = portalCopy[language];
  return (
    <header className="portal-header">
      <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-4 px-5 py-4">
        <button className="flex items-center gap-3 text-left" onClick={onHome}>
          <span className="portal-mark">✦</span><span><b className="block text-lg text-white">MediKiosk</b><small className="text-blue-200">MINISTRY OF AYUSH · SIH26047</small></span>
        </button>
        <nav className="flex flex-wrap items-center gap-2 text-sm text-blue-100"><button className="portal-nav" onClick={onPortalHome}>⌂ {labels.home}</button><button className="portal-nav" onClick={onVisits}>◌ {role === "Doctor" ? labels.directory : labels.myVisits}</button><button className="btn portal-primary" onClick={onPrimary}>{primaryLabel}</button><div className="flex rounded-lg bg-white p-1"><button className={`header-language ${language === "en" ? "header-language-active" : ""}`} onClick={() => onLanguageChange("en")}>EN</button><button className={`header-language ${language === "hi" ? "header-language-active" : ""}`} onClick={() => onLanguageChange("hi")}>हिंदी</button></div><button className="rounded-full bg-white px-3 py-1 font-semibold text-brand-900" onClick={onHome}>{name || role}</button></nav>
      </div>
    </header>
  );
}

interface SpeechRecognitionLike {
  lang: string;
  continuous: boolean;
  interimResults: boolean;
  start: () => void;
  onstart: () => void;
  onend: () => void;
  onresult: (event: { results: ArrayLike<{ [index: number]: { transcript: string }; isFinal?: boolean }> }) => void;
  onerror: (event: unknown) => void;
}
