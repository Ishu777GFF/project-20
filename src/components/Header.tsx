export function Header({ onHome, language, onLanguageChange }: { onHome: () => void; language?: "en" | "hi"; onLanguageChange?: (language: "en" | "hi") => void }) {
  return (
    <header className="flex items-center justify-between px-6 py-4">
      <button
        className="flex items-baseline gap-2 text-lg font-bold text-brand-900"
        onClick={onHome}
      >
        MediKiosk{" "}
        <small className="text-sm font-normal text-slate-500">AI intake</small>
      </button>
      <div className="flex items-center gap-3">
        {language && onLanguageChange && (
          <div className="flex rounded-lg border border-slate-200 bg-white p-1" aria-label="Choose language">
            <button className={`header-language ${language === "en" ? "header-language-active" : ""}`} onClick={() => onLanguageChange("en")}>EN</button>
            <button className={`header-language ${language === "hi" ? "header-language-active" : ""}`} onClick={() => onLanguageChange("hi")}>हिंदी</button>
          </div>
        )}
        <span className="badge badge-normal">SIH26047 · Prototype</span>
      </div>
    </header>
  );
}
