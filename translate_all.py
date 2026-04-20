import datetime
import re

input_path = "career_data_exports/GeminiPro_SeriousUpdate_20260419_234615.html"

with open(input_path, 'r', encoding='utf-8') as f:
    html = f.read()

# Expanded TRANSLATIONS with all countries
translations_js = """
const TRANSLATIONS = {
  US: {
    title: "Job Automation Compatibility List",
    live: "Live Tracking",
    target: "Target Occupation",
    region: "Select Region — LTV & Risk Age by Country",
    level: "Career Level — Click to compare salary & insights",
    ltvSection: "Job Lifetime Value Analysis",
    careerLtv: "Career LTV",
    humanSafe: "Human-Safe LTV",
    atRisk: "At-Risk LTV",
    autoIdx: "Automation Index",
    peakRisk: "Peak Risk Age",
    valueDist: "Career Value Distribution",
    safeLegend: "Human-Safe — physical judgment, creativity, subjective taste",
    riskLegend: "At-Risk — existing or emerging AI / robotics coverage",
    carEq: "Career LTV Equals",
    carSub: "Based on $28,000/unit reference price · 🟢 Safe · 🔴 At-Risk",
    incomeCurve: "Annual Income Curve — Full Career",
    incomeNote: "Colored dots mark level transitions",
    promoTitle: "Typical Promotion Timeline — Years in Role",
    insightsTitle: "Career Profile Insights",
    hazardTitle: "Occupational Hazards",
    langTitle: "Language Requirements",
    heatmapTitle: "City Income Heatmap",
    costIdx: "Cost Index",
    economicsTitle: "Career Economics and Fit",
    accessTitle: "Access Points",
    notesTitle: "School, Retirement, and Pivot Notes",
    resumeTitle: "Job Application Tracker (User Uploads)",
    recTitle: "Career Recommendations (Refine craft to unlock tiers)",
    studyTitle: "Academic & Networking Strategy",
    elderlyTitle: "Elderly Care Strategy (养老)",
    privateTitle: "Private School Capacity (私校)",
    loginMsg: "Login to see professional network recommendations",
    hallTitle: "Hall of Fame (Top Earners)",
    statusPlayable: "Playable",
    statusInGame: "In-Game",
    statusIntro: "Intro",
    statusNothing: "Nothing"
  },
  CN: {
    title: "职业自动化协同与生存指南",
    live: "实时追踪",
    target: "目标职业",
    region: "选择地区 — 各国 LTV 与风险年龄",
    level: "职业等级 — 点击对比薪资与见解",
    ltvSection: "职业生涯总价值分析 (LTV)",
    careerLtv: "生涯总价值",
    humanSafe: "人类核心价值",
    atRisk: "技术协同价值",
    autoIdx: "自动化指数",
    peakRisk: "风险峰值年龄",
    valueDist: "职业价值分布",
    safeLegend: "人类安全 — 物理判断、创意、主观味觉",
    riskLegend: "风险区域 — 现有或新兴 AI/机器人覆盖",
    carEq: "职业生涯价值等同于",
    carSub: "基于 $28,000/台 参考价 · 🟢 安全 · 🔴 风险",
    incomeCurve: "年收入曲线 — 完整职业生涯",
    incomeNote: "彩色圆点标记职级转换",
    promoTitle: "典型晋升时间表 — 岗位年限",
    insightsTitle: "职业生涯深度洞察",
    hazardTitle: "职业危害预警",
    langTitle: "语言与全球化要求",
    heatmapTitle: "城市收入热力图",
    costIdx: "生活成本指数",
    economicsTitle: "职业经济学与适配度",
    accessTitle: "职业切入点",
    notesTitle: "学校、退休与转型笔记",
    resumeTitle: "投递记录 (用户上传)",
    recTitle: "职业推荐 (磨炼技能将解锁更高阶岗位)",
    studyTitle: "学术成长与人脉建设方案",
    elderlyTitle: "养老与家庭责任 (养老问题)",
    privateTitle: "教育与私校能力 (私校问题)",
    loginMsg: "请登录以查看为您推荐的职业发展人脉",
    hallTitle: "职业殿堂 (高收入名人)",
    statusPlayable: "已就绪",
    statusInGame: "进行中",
    statusIntro: "初步引入",
    statusNothing: "无影响"
  },
  JP: {
    title: "職業自動化互換性リスト",
    live: "ライブトラッキング",
    target: "対象職種",
    region: "地域選択 — 国別LTVとリスク年齢",
    level: "キャリアレベル — 給与と洞察を比較",
    ltvSection: "生涯キャリア価値分析",
    careerLtv: "生涯LTV",
    humanSafe: "ヒューマンコア価値",
    atRisk: "技術支援価値",
    autoIdx: "自動化指数",
    peakRisk: "リスクピーク年齢",
    valueDist: "キャリア価値分布",
    safeLegend: "ヒューマンセーフ — 判断、創造性、味覚",
    riskLegend: "リスクあり — AI/ロボットの対象範囲",
    carEq: "生涯価値の換算",
    carSub: "$28,000/台の参考価格に基づく · 🟢 安全 · 🔴 リスク",
    incomeCurve: "年収曲線 — キャリア全体",
    incomeNote: "色の付いた点は職級の切り替わり",
    promoTitle: "標準的な昇進スケジュール",
    insightsTitle: "キャリア洞察",
    hazardTitle: "職業上の危険",
    langTitle: "言語要件",
    heatmapTitle: "都市別収入ヒートマップ",
    costIdx: "コスト指数",
    economicsTitle: "キャリア経済学",
    accessTitle: "アクセスポイント",
    notesTitle: "学校、退職、転換ノート",
    resumeTitle: "応募履歴 (ユーザーアップロード)",
    recTitle: "キャリア推奨 (スキルアップで上位職を解放)",
    studyTitle: "学術・ネットワーキング戦略",
    elderlyTitle: "老後と介護 (养老问题)",
    privateTitle: "私立学校の教育能力 (私校问题)",
    loginMsg: "ログインして人脈を確認",
    hallTitle: "栄誉の殿堂 (トップ層)",
    statusPlayable: "実用化",
    statusInGame: "導入中",
    statusIntro: "導入開始",
    statusNothing: "影響なし"
  },
  DE: {
    title: "Berufsautomatisierungs-Kompatibilitätsliste",
    live: "Live-Verfolgung",
    target: "Zielberuf",
    region: "Region auswählen — LTV & Risikoralter nach Land",
    level: "Karrierestufe — Gehalt & Insights vergleichen",
    ltvSection: "Analyse des Karrierewerts",
    careerLtv: "Karriere-LTV",
    humanSafe: "Menschlicher Kernwert",
    atRisk: "KI-gestützter Wert",
    autoIdx: "Automatisierungsindex",
    peakRisk: "Risikoalter-Gipfel",
    valueDist: "Verteilung des Karrierewerts",
    safeLegend: "Sicher — Urteilsvermögen, Kreativität, Geschmack",
    riskLegend: "Gefährdet — Bestehende oder künftige KI/Robotik",
    carEq: "Karriere-LTV entspricht",
    carSub: "Basierend auf $28.000/Einheit Referenzpreis · 🟢 Sicher · 🔴 Risiko",
    incomeCurve: "Einkommenskurve — Volle Karriere",
    incomeNote: "Farbige Punkte markieren Übergänge",
    promoTitle: "Typischer Beförderungszeitplan",
    insightsTitle: "Karriereprofil-Insights",
    hazardTitle: "Berufsgefahren",
    langTitle: "Sprachanforderungen",
    heatmapTitle: "Stadt-Einkommens-Heatmap",
    costIdx: "Kostenindex",
    economicsTitle: "Karriereökonomie",
    accessTitle: "Zugangspunkte",
    notesTitle: "Schul-, Ruhestands- und Pivot-Notizen",
    resumeTitle: "Bewerbungstracker",
    recTitle: "Karriereempfehlungen",
    studyTitle: "Akademische & Netzwerkstrategie",
    elderlyTitle: "Altersvorsorge & Pflege (养老问题)",
    privateTitle: "Privatschul-Kapazität (私校问题)",
    loginMsg: "Anmelden für Netzwerk-Empfehlungen",
    hallTitle: "Hall of Fame (Spitzenverdiener)",
    statusPlayable: "Anwendbar",
    statusInGame: "Im Einsatz",
    statusIntro: "Einführung",
    statusNothing: "Keine"
  },
  TW: {
    title: "職業自動化協同與生存指南",
    live: "實時追蹤",
    target: "目標職業",
    region: "選擇地區 — 各國 LTV 與風險年齡",
    level: "職業等級 — 點擊對比薪資與見解",
    ltvSection: "職業生涯總價值分析 (LTV)",
    careerLtv: "生涯總價值",
    humanSafe: "人類核心價值",
    atRisk: "技術協同價值",
    autoIdx: "自動化指數",
    peakRisk: "風險峰值年齡",
    valueDist: "職業價值分布",
    safeLegend: "人類安全 — 物理判斷、創意、主觀味覺",
    riskLegend: "風險區域 — 現有或新興 AI/機器人覆蓋",
    carEq: "職業生涯價值等同於",
    carSub: "基於 $28,000/台 參考價 · 🟢 安全 · 🔴 風險",
    incomeCurve: "年收入曲線 — 完整職業生涯",
    incomeNote: "彩色圓點標記職級轉換",
    promoTitle: "典型晉升時間表 — 崗位年限",
    insightsTitle: "職業生涯深度洞察",
    hazardTitle: "職業危害預警",
    langTitle: "語言與全球化要求",
    heatmapTitle: "城市收入熱力圖",
    costIdx: "生活成本指數",
    economicsTitle: "職業經濟學與適配度",
    accessTitle: "職業切入點",
    notesTitle: "學校、退休與轉型筆記",
    resumeTitle: "投遞記錄 (用戶上傳)",
    recTitle: "職業推薦 (磨鍊技能將解鎖更高階崗位)",
    studyTitle: "學術成長與人脈建設方案",
    elderlyTitle: "養老與家庭責任 (養老問題)",
    privateTitle: "教育與私校能力 (私校問題)",
    loginMsg: "請登錄以查看為您推薦的職業發展人脈",
    hallTitle: "職業殿堂 (高收入名人)",
    statusPlayable: "已就緒",
    statusInGame: "進行中",
    statusIntro: "初步引入",
    statusNothing: "無影響"
  }
};

const HALL_OF_FAME = {
  US: [
    { name: "Gordon Ramsay", worth: "$220M", title: "Global Brand CEO & Michelin Star Chef" },
    { name: "Wolfgang Puck", worth: "$120M", title: "Catering Empire & Fine Dining Pioneer" },
    { name: "Thomas Keller", worth: "$50M", title: "Napa Valley Legend · French Laundry" }
  ],
  CN: [
    { name: "大董 (Dong Zhenxiang)", worth: "¥800M+", title: "意境菜创始人 · 集团董事长" },
    { name: "屈浩 (Qu Hao)", worth: "Est. ¥100M", title: "鲁菜大师 · 屈浩烹饪学校校长" },
    { name: "陈晓卿 (Chen Xiaoqing)", worth: "Media Icon", title: "《舌尖上的中国》总导演 · 美食家" }
  ],
  JP: [
    { name: "小野二郎 (Jiro Ono)", worth: "Priceless", title: "寿司之神 · 職人精神の象徴" },
    { name: "成澤由浩 (Yoshihiro Narisawa)", worth: "Est. $15M", title: "里山料理開拓者 · 革新のシェフ" },
    { name: "脇屋友詞 (Yuji Wakiya)", worth: "Est. $10M", title: "アイアンシェフ · Wakiyaグループ代表" }
  ],
  UK: [
    { name: "Jamie Oliver", worth: "$200M", title: "Media Mogul & Food Campaigner" },
    { name: "Heston Blumenthal", worth: "$50M", title: "Scientific Gastronomy Master" },
    { name: "Marco Pierre White", worth: "Rockstar Chef", title: "First British 3-Star Michelin Chef" }
  ],
  AU: [
    { name: "Curtis Stone", worth: "$25M", title: "Global TV Chef & Maude Owner" },
    { name: "Kylie Kwong", worth: "Iconic", title: "Sustainable Food Pioneer & TV Star" },
    { name: "Shannon Bennett", worth: "$40M", title: "Vue de Monde Founder" }
  ],
  DE: [
    { name: "Tim Mälzer", worth: "€20M", title: "TV-Koch & 'Bullerei' Gastronom" },
    { name: "Kevin Fehling", worth: "3-Stars", title: "Modern Gastronomy · 'The Table'" },
    { name: "Christian Bau", worth: "Victus", title: "Victor's Fine Dining Master" }
  ],
  SG: [
    { name: "Justin Quek", worth: "Legend", title: "French-Asian Fusion Pioneer" },
    { name: "Janice Wong", worth: "S$15M", title: "Asia's Best Pastry Chef · 2am:dessertbar" },
    { name: "Jason Tan", worth: "Star", title: "Gastro-Botanica · Restaurant Euphoria" }
  ],
  TW: [
    { name: "江振誠 (André Chiang)", worth: "$20M+", title: "國際名廚 · RAW 創辦人" },
    { name: "陳嵐舒 (Lanshu Chen)", worth: "Elite", title: "亞洲最佳女廚師 · 樂沐創辦人" },
    { name: "阿基師 (A-Ji-Shi)", worth: "Household Name", title: "台灣名廚 · 國宴主廚" }
  ]
};

function applyLocalization(country) {
  const t = TRANSLATIONS[country] || TRANSLATIONS.US;
  const fame = HALL_OF_FAME[country] || HALL_OF_FAME.US;

  // Title & Header
  const title = document.querySelector('.page-title');
  if(title) title.innerHTML = t.title.replace(' ', '<br>');
  const live = document.querySelector('.header-tag');
  if(live) live.innerHTML = '<span class="live-dot"></span> ' + t.live;
  const target = document.querySelector('.page-subtitle');
  if(target) target.innerHTML = t.target + ': <span>CHEF / COOK (ID: OCC-2026-C)</span>';

  // Section Labels
  const regionLabel = document.querySelector('.country-label');
  if(regionLabel) regionLabel.textContent = t.region;
  const levelLabel = document.querySelector('.level-section .section-label');
  if(levelLabel) levelLabel.textContent = t.level;
  const ltvLabel = document.querySelector('.ltv-section .section-label');
  if(ltvLabel) ltvLabel.textContent = t.ltvSection;
  
  // KPI Labels
  const kpiTotal = document.querySelector('.ltv-card.c-total .ltv-lbl');
  if(kpiTotal) kpiTotal.textContent = t.careerLtv;
  const kpiSafe = document.querySelector('.ltv-card.c-safe .ltv-lbl');
  if(kpiSafe) kpiSafe.textContent = t.humanSafe;
  const kpiRisk = document.querySelector('.ltv-card.c-risk .ltv-lbl');
  if(kpiRisk) kpiRisk.textContent = t.atRisk;
  const kpiIdx = document.querySelector('.ltv-card.c-idx .ltv-lbl');
  if(kpiIdx) kpiIdx.textContent = t.autoIdx;
  const kpiAge = document.querySelector('.ltv-card.c-age .ltv-lbl');
  if(kpiAge) kpiAge.textContent = t.peakRisk;

  // Legends & Viz
  const carEq = document.querySelector('.car-viz-eq');
  if(carEq) carEq.textContent = t.carEq;
  const carSub = document.querySelector('.car-viz-sub');
  if(carSub) carSub.textContent = t.carSub;
  const incomeTitle = document.querySelector('.income-chart-title');
  if(incomeTitle) incomeTitle.textContent = t.incomeCurve;
  const incomeNote = document.querySelector('.income-chart-note');
  if(incomeNote) incomeNote.textContent = t.incomeNote;
  const promoTitle = document.querySelector('.promo-section .section-label');
  if(promoTitle) promoTitle.textContent = t.promoTitle;
  const insightsLabel = document.querySelector('.insights-grid').previousElementSibling;
  if(insightsLabel) insightsLabel.textContent = t.insightsTitle;
  const hazardLabel = document.querySelector('.hazards-section .section-label');
  if(hazardLabel) hazardLabel.textContent = t.hazardTitle;
  const langLabel = document.querySelector('.lang-section .section-label');
  if(langLabel) langLabel.textContent = t.langTitle + ' — ' + (COUNTRY_NAMES[country]||country);
  const heatmapLabel = document.querySelector('.heatmap-header .section-label');
  if(heatmapLabel) heatmapLabel.textContent = t.heatmapTitle + ' — ' + (COUNTRY_NAMES[country]||country);

  // Extended sections
  const ecoLabel = document.querySelector('.extended-section:nth-of-type(1) .section-label');
  if(ecoLabel) ecoLabel.textContent = t.economicsTitle;
  const accessLabel = document.querySelector('.extended-section:nth-of-type(2) .section-label');
  if(accessLabel) accessLabel.textContent = t.accessTitle;
  const notesLabel = document.querySelector('.extended-section:nth-of-type(3) .section-label');
  if(notesLabel) notesLabel.textContent = t.notesTitle;
  const resumeLabel = document.querySelector('.extended-section:nth-of-type(4) .section-label');
  if(resumeLabel) resumeLabel.textContent = t.resumeTitle;
  const recLabel = document.querySelector('.extended-section:nth-of-type(5) .section-label');
  if(recLabel) recLabel.textContent = t.recTitle;
  const studyLabel = document.querySelector('.extended-section:nth-of-type(6) .section-label');
  if(studyLabel) studyLabel.textContent = t.studyTitle;

  // Hall of Fame
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
        <div class="note-title">Networking Opportunities</div>
        <div class="note-value" style="font-size:12px; color:var(--text-faint)">Locked Content</div>
        <div class="note-meta">${t.loginMsg}</div>
      </div>
      <div class="note-card" style="grid-column: span 2">
        <div class="note-title">${t.hallTitle}</div>
        <div style="margin-top:10px">${fameHtml}</div>
      </div>
    `;
  }
}
"""

# Replace the previous translations and localization logic
pattern = r'// ── LOCALIZATION SYSTEM ──────────────────────────────────────────.*?applyLocalization\(code\);'
html = re.sub(pattern, translations_js + '\nfunction applyLocalization(country) { ... }', html, flags=re.DOTALL)

# Re-insert the function body carefully since re.sub with function code can be tricky
html = html.replace('function applyLocalization(country) { ... }', translations_js.split('function applyLocalization(country) {')[1].replace('}', '', 1).strip() if 'function applyLocalization(country) {' in translations_js else translations_js)

# Actually, let's just do a clean replacement of the whole JS block starting from translations
js_start = html.find('// ── LOCALIZATION SYSTEM')
js_end = html.find('renderCountryFull(code,animate=true){')
if js_start != -1 and js_end != -1:
    html = html[:js_start] + translations_js + '\n' + html[js_end:]

# Update currentLevel logic to ensure it doesn't break
html = html.replace('renderCountryFull(code,animate=true){', 'renderCountryFull(code,animate=true){\n  applyLocalization(code);')

# Save to new file
now = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
output_file = f"career_data_exports/GeminiPro_GlobalTranslation_{now}.html"

with open(output_file, 'w', encoding='utf-8') as f:
    f.write(html)

print(output_file)
