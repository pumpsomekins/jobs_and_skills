import datetime
import re

# Source file as requested
input_path = "career_data_exports/GeminiPro_20260419_220242.html"

with open(input_path, 'r', encoding='utf-8') as f:
    html = f.read()

# --- 1. CSS & Header Layout for MBTI ---
# Add some CSS for the MBTI input and handle the layout
css_update = """
/* MBTI Header Input */
.mbti-personalize { display: flex; flex-direction: column; align-items: flex-end; gap: 4px; }
.mbti-personalize label { font-size: 9px; font-weight: 700; color: var(--text-faint); text-transform: uppercase; letter-spacing: .08em; }
.mbti-input { background: var(--surface); border: 1px solid var(--border-hi); border-radius: 4px; padding: 4px 10px; font-size: 11px; color: var(--accent); width: 80px; text-align: center; outline: none; transition: border-color .2s; }
.mbti-input:focus { border-color: var(--accent); }
"""
html = html.replace('</style>', css_update + '\n</style>')

# Inject MBTI input into header-right
mbti_header_html = """
    <div class="header-right">
      <div class="mbti-personalize">
        <label>Personalize Layout</label>
        <input type="text" class="mbti-input" placeholder="Your MBTI" id="mbtiOverride">
      </div>
      <button class="btn-subscribe" id="openModal">
"""
html = html.replace('<div class="header-right">\n      <button class="btn-subscribe" id="openModal">', mbti_header_html)

# --- 2. Structural Content Updates (Cards & Labels) ---

# Replace Startup Preparation with Finding Sifu in ACCESS_LINKS logic
html = html.replace("{title:'Startup Preparation',desc:'Cloud kitchen, private dining, meal prep, consulting, SOP packaging'}", 
                    "{title:'Finding Sifu (拜师)',desc:'Master-apprentice links for traditional lineage training and expert mentorship. [External: Global Sifu Network](https://example.com/sifu)'}")

# --- 3. JavaScript Logic Update (The serious part) ---

# Define Translations and update rendering
js_logic = """
// ── LOCALIZATION SYSTEM ──────────────────────────────────────────
const TRANSLATIONS = {
  US: {
    title: "Job Automation Compatibility List",
    ltvLabel: "Career Lifetime Value",
    safeLabel: "Human-Safe LTV",
    riskLabel: "At-Risk LTV",
    hazardTitle: "Occupational Hazards",
    insightsTitle: "Career Profile Insights",
    langTitle: "Language Requirements",
    heatmapTitle: "City Income Heatmap",
    recTitle: "Career Recommendations (Refine craft to unlock tiers)",
    studyTitle: "Academic & Networking Strategy",
    loginMsg: "Login to see professional network recommendations",
    elderlyTitle: "Elderly Care Strategy (养老)",
    elderlyMeta: "Caring for parents and self depends on reaching Head Chef tier by age 35.",
    privateTitle: "Private School Capacity (私校)",
    privateMeta: "Elite schooling for heirs requires Executive tier or multi-outlet ownership.",
    resumeTitle: "My Applied Resumes (Self-Apply)"
  },
  CN: {
    title: "职业自动化协同与生存指南",
    ltvLabel: "职业生涯总价值 (LTV)",
    safeLabel: "人类核心价值",
    riskLabel: "技术协同价值",
    hazardTitle: "职业危害预警",
    insightsTitle: "职业生涯深度洞察",
    langTitle: "语言与全球化要求",
    heatmapTitle: "城市收入与成本热力图",
    recTitle: "职业推荐 (磨炼技能将解锁更高阶岗位)",
    studyTitle: "学术成长与人脉建设方案",
    loginMsg: "请登录以查看为您推荐的职业发展人脉",
    elderlyTitle: "养老与家庭责任 (养老问题)",
    elderlyMeta: "给父母和自己养老的能力取决于能否在35岁前晋升至主厨级别。",
    privateTitle: "教育与私校能力 (私校问题)",
    privateMeta: "负担子女私立学校教育通常需要行政总厨或多店主收入水平。",
    resumeTitle: "我的投递记录 (仅展示已投递简历)"
  },
  JP: {
    title: "職業自動化互換性リスト",
    ltvLabel: "生涯賃金価値 (LTV)",
    safeLabel: "ヒューマンコア価値",
    riskLabel: "技術支援価値",
    hazardTitle: "職業上の危険",
    insightsTitle: "キャリア洞察",
    langTitle: "言語要件",
    heatmapTitle: "都市別収入ヒートマップ",
    recTitle: "キャリア推奨 (スキルを磨くと上位職が解放されます)",
    studyTitle: "学術およびネットワーキング戦略",
    loginMsg: "ログインして人脈の推奨事項を確認する",
    elderlyTitle: "老後と介護 (养老问题)",
    elderlyMeta: "親と自分の老後は35歳までにヘッドシェフになれるか次第です。",
    privateTitle: "私立学校の教育能力 (私校问题)",
    privateMeta: "子供を私立学校に通わせるには、エグゼクティブシェフの収入が必要です。",
    resumeTitle: "応募済み履歴書 (自己応募)"
  }
  // ... other countries default to US for this demo
};

// ── HALL OF FAME DATA (Country Specific) ──────────────────────────
const HALL_OF_FAME = {
  US: [
    { name: "Gordon Ramsay", worth: "$220M", title: "Global Brand CEO & Michelin Star Chef" },
    { name: "Wolfgang Puck", worth: "$120M", title: "Catering Empire & Fine Dining Pioneer" }
  ],
  CN: [
    { name: "大董 (Dong Zhenxiang)", worth: "¥800M+", title: "意境菜创始人 · 集团董事长" },
    { name: "江振诚 (André Chiang)", worth: "Est. $20M", title: "国际名厨 · 饮食文化先行者" }
  ],
  JP: [
    { name: "小野二郎 (Jiro Ono)", worth: "Priceless", title: "寿司之神 · 職人精神の象徴" },
    { name: "成澤由浩 (Yoshihiro Narisawa)", worth: "Est. $15M", title: "里山料理開拓者 · 革新のシェフ" }
  ],
  UK: [
    { name: "Jamie Oliver", worth: "$200M", title: "Media Mogul & Campaigner" },
    { name: "Heston Blumenthal", worth: "$50M", title: "Gastronomy Scientist" }
  ]
};

function applyLocalization(country) {
  const t = TRANSLATIONS[country] || TRANSLATIONS.US;
  const fame = HALL_OF_FAME[country] || HALL_OF_FAME.US;

  // Text content updates
  const safeTitle = document.querySelector('.page-title');
  if(safeTitle) safeTitle.innerHTML = t.title.replace(' ', '<br>');
  
  const ltvLabel = document.querySelector('.ltv-card.c-total .ltv-lbl');
  if(ltvLabel) ltvLabel.textContent = t.ltvLabel;

  const hazardLabel = document.querySelector('.hazards-section .section-label');
  if(hazardLabel) hazardLabel.textContent = t.hazardTitle;

  const recLabel = document.querySelector('.extended-section:nth-of-type(1) .section-label');
  if(recLabel) recLabel.textContent = t.recTitle;

  const resumeLabel = document.querySelector('.extended-section:nth-of-type(2) .section-label');
  if(resumeLabel) resumeLabel.textContent = t.resumeTitle;

  // Update Hall of Fame card with rich data
  const networkGrid = document.getElementById('networkGrid');
  if(networkGrid) {
    const fameHtml = fame.map(p => `
      <div style="margin-bottom:8px; padding-bottom:8px; border-bottom:1px solid var(--border)">
        <div style="font-weight:800; color:#fff">${p.name} (${p.worth})</div>
        <div style="font-size:10px; color:var(--accent)">${p.title}</div>
      </div>
    `).join('');

    networkGrid.innerHTML = `
      <div class="note-card">
        <div class="note-title">${t.elderlyTitle}</div>
        <div class="note-value" style="font-size:14px">Tier Dependent</div>
        <div class="note-meta">${t.elderlyMeta}</div>
      </div>
      <div class="note-card">
        <div class="note-title">${t.privateTitle}</div>
        <div class="note-value" style="font-size:14px">Financial Capacity</div>
        <div class="note-meta">${t.privateMeta}</div>
      </div>
      <div class="note-card">
        <div class="note-title">People to Network With</div>
        <div class="note-value" style="font-size:12px; color:var(--text-faint)">Locked Content</div>
        <div class="note-meta">${t.loginMsg}</div>
      </div>
      <div class="note-card" style="grid-column: span 2">
        <div class="note-title">Hall of Fame (Top Earners)</div>
        <div style="margin-top:10px">${fameHtml}</div>
      </div>
    `;
  }
}
"""

# Inject new logic into renderCountryFull
html = html.replace('function renderCountryFull(code,animate=true){', js_logic + '\nfunction renderCountryFull(code,animate=true){\n  applyLocalization(code);')

# --- 4. Final Cleanup ---
# Remove the MBTI card from the grid as it's now in the header
html = re.sub(r'<div class="note-card">\s*<div class="note-title">MBTI Recommendation</div>.*?</div>\s*</div>', '', html, flags=re.DOTALL)

# Handle resume tracker visibility
html = html.replace('<div class="note-value" style="font-size:14px">Interview Scheduled</div>', 
                    '<div class="note-value" style="font-size:14px">Interview Scheduled</div><div style="font-size:9px; color:var(--accent); margin-top:4px">● Application Live</div>')

# Write output
now = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
output_file = f"career_data_exports/GeminiPro_SeriousUpdate_{now}.html"

with open(output_file, 'w', encoding='utf-8') as f:
    f.write(html)

print(f"DONE: {output_file}")
