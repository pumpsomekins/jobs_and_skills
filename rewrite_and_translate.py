import datetime
import re

input_path = "career_data_exports/GeminiPro_20260419_220242.html"

with open(input_path, 'r', encoding='utf-8') as f:
    html = f.read()

# 1. MBTI Layout: Modify the header HTML
mbti_header = """
    <div class="header-right">
      <div style="display:flex; flex-direction:column; align-items:flex-end; gap:4px; margin-right:12px">
        <label id="mbtiLabel" style="font-size:9px; font-weight:700; color:var(--text-faint); text-transform:uppercase; letter-spacing:.08em;">Personalize Layout</label>
        <input type="text" id="mbtiOverride" placeholder="ENTJ..." style="background:var(--surface); border:1px solid var(--border-hi); border-radius:4px; padding:4px 10px; font-size:11px; color:var(--accent); width:80px; text-align:center; outline:none; transition:border-color .2s;">
      </div>
      <button class="btn-subscribe" id="openModal">
"""
html = html.replace('<div class="header-right">\n      <button class="btn-subscribe" id="openModal">', mbti_header)

# 2. Extract and replace the Table body to be dynamic
table_regex = r'<tbody>(.*?)</tbody>'
html = re.sub(table_regex, '<tbody id="dynamicTable"></tbody>', html, flags=re.DOTALL)

# 3. Add JS for Translations and dynamic rendering
# We will inject this before the closing </script> tag
# First, let's find the script where we can inject our logic.
# The file has a <script> block at the end. We'll append our mega JS there.

js_localization = """
// --- I18N SYSTEM ---
const I18N = {
  EN: {
    title: "Career Opportunity<br>& Evolution Landscape",
    live: "Live Tracking",
    target: "Target Occupation: <span>CHEF / COOK</span>",
    subscribe: "Subscribe",
    mbtiLabel: "Personalize (MBTI)",
    regionLabel: "Select Region — LTV & Pivot Age by Country",
    levelLabel: "Career Level — Compare salary, LTV & insights",
    ltvSection: "Lifetime Career Value & Growth Potential",
    ltvTotal: "Career LTV",
    ltvSafe: "Unique Human Value",
    ltvRisk: "Tech-Assisted Value",
    ltvIdx: "Tech Synergy Index",
    ltvAge: "Career Pivot Milestone",
    distTitle: "Career Value Distribution",
    safeLegend: "Human-Centric — physical judgment, creativity, subjective taste",
    riskLegend: "Tech-Assisted — existing or emerging AI / robotics coverage",
    carEq: "Career LTV Equals",
    carSub: "Based on $28,000/unit reference price · 🟢 Human core · 🔴 Tech-assisted",
    incTitle: "Annual Income Curve — Full Career",
    incNote: "Colored dots mark level transitions · hover for value",
    promoTitle: "Typical Promotion Timeline — Years in Role Before Advancement",
    insightTitle: "Career Profile Insights",
    hazardTitle: "Workplace Realities",
    langTitle: "Language & Global Mobility",
    heatTitle: "City Income Heatmap",
    ecoTitle: "Career Economics and Fit",
    accTitle: "Access Points",
    notesTitle: "School, Retirement, and Pivot Notes",
    trkTitle: "My Application Tracker (Applied Resumes - Login to View)",
    recTitle: "Career Recommendations (Refining craft unlocks higher tiers)",
    netTitle: "Academic & Networking Strategy",
    
    // Hazards
    hazards: [
      { name: "Burns & Scalds", level: "Critical · open flame, hot oil" },
      { name: "Heat Exhaustion", level: "Critical · 38–50°C kitchens" },
      { name: "Cuts & Lacerations", level: "High · daily knife work" },
      { name: "Musculoskeletal", level: "High · 8–12 hrs standing" },
      { name: "Mental Fatigue", level: "High · burnout rate 40–60%" },
      { name: "Slip & Fall", level: "Medium · wet floors" },
      { name: "Chemical Exp.", level: "Medium · cleaning agents" },
      { name: "Noise Exp.", level: "Low-Med · extraction fans" },
      { name: "Smoke & Fumes", level: "Medium · vent. risk" }
    ],

    // Table
    tableHeaders: ["Action", "Human Workflow", "AI / Bot Workflow", "Tech Synergy Ratio", "Node LTV", "ETA", "Status"],
    tableRows: [
      { action: "Inventory & Ordering", hum: "Check fridge, estimate prep, call suppliers.", ai: "MarketMan / BlueCart AI predictive auto-order.", rat: 85, ratLbl: "Assisted", node: "~10% assisted", eta: "~2 yrs", stat: "Playable", cls: "playable" },
      { action: "Frying & Grilling", hum: "Stand by fryers, monitor heat, manual flip.", ai: "Miso Robotics (Flippy) vision-based flipping.", rat: 65, ratLbl: "Assisted", node: "~30% synergy", eta: "3–5 yrs", stat: "In-Game", cls: "ingame" },
      { action: "Recipe Creation", hum: "Pair ingredients based on taste and memory.", ai: "Gen-AI flavor molecule pairing.", rat: 30, ratLbl: "Assisted", node: "~20% synergy", eta: "7–10 yrs", stat: "Intro", cls: "intro" },
      { action: "Plating & Tasting", hum: "Artistic plating, tasting for seasoning balance.", ai: "No pure AI solution; sensors lack subjective taste.", rat: 8, ratLbl: "Assisted", node: "~40% unique", eta: "10+ yrs", stat: "Nothing", cls: "nothing" }
    ],
    
    // Notes & Network
    elderly: "Elderly Care (养老)", elderlyVal: "Multi-Tier Strategy", elderlyMeta: "Capacity to care for parents and self depends on reaching 'Head Chef' tier by age 35.",
    private: "Private School (私校)", privateVal: "Executive Tier Required", privateMeta: "Affording elite private schooling requires Executive Chef or multi-outlet owner income.",
    network: "People to Network With", networkVal: "Locked Content", networkMeta: "Please login to see exactly who you should make friends with to secure a better career path.",
    fameTitle: "Hall of Fame (Top Earners)",
    majors: "Recommended Majors", majorsVal: "Culinary & Hosp Mgt", majorsMeta: "Secondary: Food Science or Business Admin.",
    courses: "Target Courses", coursesVal: "Kitchen Ops & Cost Control", coursesMeta: "Also: Molecular Gastronomy, Sustainable Sourcing.",
    strive: "Majors to Strive For", striveVal: "F&B Tech & Innovation", striveMeta: "Transition into tech-enabled food systems.",
    resumeItems: [
        { title: "Four Seasons - Senior Sous Chef", stat: "Interview Scheduled", meta: "Applied: 2 days ago · Login to view details" },
        { title: "Local Bistro - Executive Chef", stat: "Offer Received", meta: "Applied: 14 days ago · Login to view details" }
    ],
    sifuTitle: "Finding Sifu (Master-Apprentice)", sifuDesc: "Connect with traditional masters and culinary mentors for direct lineage and skill transfer. [External: SifuNetwork]"
  },
  CN: {
    title: "职业进化与机遇图谱",
    live: "实时追踪",
    target: "目标职业: <span>厨师 / 厨师长</span>",
    subscribe: "订阅提醒",
    mbtiLabel: "个性化 (MBTI)",
    regionLabel: "选择地区 — 各国职业价值与转型年龄",
    levelLabel: "职业等级 — 点击对比薪资与见解",
    ltvSection: "职业生涯总价值与增长潜力",
    ltvTotal: "生涯总价值",
    ltvSafe: "人类核心价值",
    ltvRisk: "技术协同价值",
    ltvIdx: "技术协同指数",
    ltvAge: "职业转型关键年龄",
    distTitle: "职业价值分布",
    safeLegend: "人类核心 — 物理判断、创意、主观味觉",
    riskLegend: "技术协同 — 现有或新兴 AI/机器人覆盖",
    carEq: "生涯价值等同于",
    carSub: "基于 $28,000/台 参考价 · 🟢 核心价值 · 🔴 协同价值",
    incTitle: "年收入曲线 — 完整职业生涯",
    incNote: "彩色圆点标记职级转换 · 悬停查看具体数值",
    promoTitle: "典型晋升时间表 — 岗位停留年限",
    insightTitle: "职业生涯深度洞察",
    hazardTitle: "工作环境现实 (职业危害)",
    langTitle: "语言与全球化流动性",
    heatTitle: "城市收入热力图",
    ecoTitle: "职业经济学与适配度",
    accTitle: "职业切入点",
    notesTitle: "教育、退休与转型笔记",
    trkTitle: "我的投递记录 (仅展示已投递 - 登录后查看详情)",
    recTitle: "职业推荐 (磨练技能将解锁更高阶岗位)",
    netTitle: "学术成长与人脉建设方案",
    
    hazards: [
      { name: "烧伤烫伤", level: "致命 · 明火与热油" },
      { name: "高温衰竭", level: "致命 · 38–50°C 厨房" },
      { name: "割伤划伤", level: "高危 · 日常刀工操作" },
      { name: "肌肉劳损", level: "高危 · 每日站立 8-12 小时" },
      { name: "精神疲劳", level: "高危 · 倦怠率 40–60%" },
      { name: "滑倒摔伤", level: "中危 · 湿滑地面" },
      { name: "化学暴露", level: "中危 · 清洁剂接触" },
      { name: "噪音暴露", level: "中低 · 抽风机噪音" },
      { name: "油烟吸入", level: "中危 · 通风不良风险" }
    ],

    tableHeaders: ["操作节点", "人类工作流", "AI / 机器人协同流", "技术协同比例", "节点价值", "预计普及时间", "当前状态"],
    tableRows: [
      { action: "库存与订货", hum: "盘点冰箱，预估消耗，给供应商打电话", ai: "MarketMan AI 预测分析自动下单", rat: 85, ratLbl: "技术辅助", node: "~10% 辅助", eta: "~2 年", stat: "已就绪", cls: "playable" },
      { action: "煎炸与烤制", hum: "守在油锅前看火候，手动翻面沥油", ai: "Miso Robotics 机械臂视觉识别翻面", rat: 65, ratLbl: "技术辅助", node: "~30% 协同", eta: "3–5 年", stat: "进行中", cls: "ingame" },
      { action: "食谱研发", hum: "凭借味觉经验和灵感搭配新食材", ai: "生成式AI分析分子风味图谱输出配方", rat: 30, ratLbl: "技术辅助", node: "~20% 协同", eta: "7–10 年", stat: "初步引入", cls: "intro" },
      { action: "摆盘与试味", hum: "艺术性摆盘，尝咸淡，微调风味", ai: "无现成AI方案，传感器无法完全模拟主观味觉", rat: 8, ratLbl: "技术辅助", node: "~40% 核心", eta: "10+ 年", stat: "无影响", cls: "nothing" }
    ],

    elderly: "养老问题", elderlyVal: "分层策略", elderlyMeta: "给父母和自己养老的能力取决于能否在35岁前晋升至主厨级别。集团路线提供更好的养老保障。",
    private: "私校问题", privateVal: "需要行政总厨级别", privateMeta: "负担子女精英私立学校通常需要行政总厨或多店经营者的收入水平。",
    network: "推荐认识的人", networkVal: "内容已锁定", networkMeta: "请登录以查看为您量身定制的职业发展人脉推荐。",
    fameTitle: "行业殿堂 (高收入名人)",
    majors: "推荐读的专业", majorsVal: "烹饪艺术与酒店管理", majorsMeta: "辅修：食品科学或工商管理。",
    courses: "推荐读的课", coursesVal: "厨房运营与成本控制", coursesMeta: "同样推荐：分子料理、可持续采购。",
    strive: "推荐努力学的专业", striveVal: "餐饮科技与创新", striveMeta: "转型进入技术赋能的食品系统领域。",
    resumeItems: [
        { title: "四季酒店 - 高级副主厨", stat: "已安排面试", meta: "投递时间: 2天前 · 登录查看详情" },
        { title: "本地高级餐馆 - 行政总厨", stat: "收到 Offer", meta: "投递时间: 14天前 · 登录查看详情" }
    ],
    sifuTitle: "拜师链接 (寻找师傅)", sifuDesc: "与传统大师和烹饪导师建立联系，获取直接的传承与技能指导。[外部链接：全球寻师网]"
  },
  JP: {
    title: "キャリアの進化と機会の展望",
    live: "ライブトラッキング",
    target: "対象職種: <span>シェフ / 料理人</span>",
    subscribe: "購読する",
    mbtiLabel: "カスタマイズ (MBTI)",
    regionLabel: "地域選択 — 国別価値と転換年齢",
    levelLabel: "キャリアレベル — 給与と洞察を比較",
    ltvSection: "生涯キャリア価値と成長の可能性",
    ltvTotal: "生涯LTV",
    ltvSafe: "ヒューマンコア価値",
    ltvRisk: "技術支援価値",
    ltvIdx: "技術シナジー指数",
    ltvAge: "キャリア転換の節目",
    distTitle: "キャリア価値の分布",
    safeLegend: "人間中心 — 物理的判断、創造性、主観的な味覚",
    riskLegend: "技術支援 — 既存または新たなAI/ロボットの範囲",
    carEq: "生涯価値の換算",
    carSub: "$28,000/台の参考価格に基づく · 🟢 人間の核 · 🔴 技術支援",
    incTitle: "年収曲線 — キャリア全体",
    incNote: "色の付いた点は職級の切り替わり · ホバーで数値表示",
    promoTitle: "標準的な昇進スケジュール — 昇進までの年数",
    insightTitle: "キャリアプロファイルの洞察",
    hazardTitle: "職場環境の現実 (職業上の危険)",
    langTitle: "言語とグローバルモビリティ",
    heatTitle: "都市別収入ヒートマップ",
    ecoTitle: "キャリア経済学と適合性",
    accTitle: "アクセスポイント",
    notesTitle: "学校、退職、キャリア転換のノート",
    trkTitle: "応募トラッカー (応募済み履歴書 - ログインして詳細を表示)",
    recTitle: "キャリア推奨 (スキルを磨いて上位職を解放)",
    netTitle: "学術およびネットワーキング戦略",
    
    hazards: [
      { name: "火傷", level: "致命的 · 直火、熱油" },
      { name: "熱中症", level: "致命的 · 38–50°Cの厨房" },
      { name: "切り傷", level: "高リスク · 日常の包丁作業" },
      { name: "筋骨格の負担", level: "高リスク · 1日8〜12時間の立ち仕事" },
      { name: "精神的疲労", level: "高リスク · 燃え尽き率40–60%" },
      { name: "転倒", level: "中リスク · 濡れた床" },
      { name: "化学物質", level: "中リスク · 洗剤" },
      { name: "騒音", level: "低-中 · 換気扇" },
      { name: "煙・ガス", level: "中リスク · 換気不足" }
    ],

    tableHeaders: ["アクション", "人間のワークフロー", "AI / ロボットのワークフロー", "技術シナジー率", "ノード価値", "普及予想", "ステータス"],
    tableRows: [
      { action: "在庫管理と発注", hum: "冷蔵庫をチェックし、消費を予測して発注", ai: "MarketMan AIによる予測自動発注", rat: 85, ratLbl: "技術支援", node: "~10% 支援", eta: "~2年", stat: "実用化", cls: "playable" },
      { action: "揚げる・焼く", hum: "火加減を見守り、手動で裏返す", ai: "Miso Roboticsによる視覚認識と裏返し", rat: 65, ratLbl: "技術支援", node: "~30% シナジー", eta: "3–5年", stat: "導入中", cls: "ingame" },
      { action: "レシピ開発", hum: "味覚の経験とインスピレーションで食材を組み合わせる", ai: "生成AIによる分子フレーバーのペアリング", rat: 30, ratLbl: "技術支援", node: "~20% シナジー", eta: "7–10年", stat: "導入開始", cls: "intro" },
      { action: "盛り付けと味見", hum: "芸術的な盛り付けと味の微調整", ai: "純粋なAIソリューションなし、センサーは主観的味覚を欠く", rat: 8, ratLbl: "技術支援", node: "~40% 固有", eta: "10年以上", stat: "影響なし", cls: "nothing" }
    ],

    elderly: "老後と介護 (养老)", elderlyVal: "階層別戦略", elderlyMeta: "親と自分の老後は35歳までに「ヘッドシェフ」に到達できるかに依存します。",
    private: "私立学校 (私校)", privateVal: "エグゼクティブ層が必要", privateMeta: "子供をエリート私立校に通わせるには、エグゼクティブシェフの収入が必要です。",
    network: "ネットワークを構築すべき人", networkVal: "ロックされたコンテンツ", networkMeta: "ログインして、キャリアを向上させるための人脈推奨事項を確認してください。",
    fameTitle: "栄誉の殿堂 (トップ層)",
    majors: "推奨される専攻", majorsVal: "料理芸術・ホスピタリティ管理", majorsMeta: "副専攻：食品科学、経営学",
    courses: "対象となるコース", coursesVal: "厨房運営とコスト管理", coursesMeta: "分子ガストロノミー、持続可能な調達も推奨。",
    strive: "目指すべき専攻", striveVal: "飲食テクノロジーと革新", striveMeta: "テクノロジーを活用した食品システムへの移行。",
    resumeItems: [
        { title: "フォーシーズンズ - シニアスーシェフ", stat: "面接予定", meta: "応募: 2日前 · ログインして詳細を表示" },
        { title: "地元ビストロ - エグゼクティブシェフ", stat: "オファー獲得", meta: "応募: 14日前 · ログインして詳細を表示" }
    ],
    sifuTitle: "師匠を見つける (拝師)", sifuDesc: "伝統的な師匠や料理のメンターと繋がり、直接的な技術伝承を受けましょう。[外部：グローバル師匠ネットワーク]"
  },
  TW: {
    title: "職業進化與機遇圖譜",
    live: "實時追蹤",
    target: "目標職業: <span>廚師 / 廚師長</span>",
    subscribe: "訂閱提醒",
    mbtiLabel: "個性化 (MBTI)",
    regionLabel: "選擇地區 — 各國職業價值與轉型年齡",
    levelLabel: "職業等級 — 點擊對比薪資與見解",
    ltvSection: "職業生涯總價值與增長潛力",
    ltvTotal: "生涯總價值",
    ltvSafe: "人類核心價值",
    ltvRisk: "技術協同價值",
    ltvIdx: "技術協同指數",
    ltvAge: "職業轉型關鍵年齡",
    distTitle: "職業價值分布",
    safeLegend: "人類核心 — 物理判斷、創意、主觀味覺",
    riskLegend: "技術協同 — 現有或新興 AI/機器人覆蓋",
    carEq: "生涯價值等同於",
    carSub: "基於 $28,000/台 參考價 · 🟢 核心價值 · 🔴 協同價值",
    incTitle: "年收入曲線 — 完整職業生涯",
    incNote: "彩色圓點標記職級轉換 · 懸停查看具體數值",
    promoTitle: "典型晉升時間表 — 崗位停留年限",
    insightTitle: "職業生涯深度洞察",
    hazardTitle: "工作環境現實 (職業危害)",
    langTitle: "語言與全球化流動性",
    heatTitle: "城市收入熱力圖",
    ecoTitle: "職業經濟學與適配度",
    accTitle: "職業切入點",
    notesTitle: "教育、退休與轉型筆記",
    trkTitle: "我的投遞記錄 (僅展示已投遞 - 登錄後查看詳情)",
    recTitle: "職業推薦 (磨練技能將解鎖更高階崗位)",
    netTitle: "學術成長與人脈建設方案",
    
    hazards: [
      { name: "燒傷燙傷", level: "致命 · 明火與熱油" },
      { name: "高溫衰竭", level: "致命 · 38–50°C 廚房" },
      { name: "割傷劃傷", level: "高危 · 日常刀工操作" },
      { name: "肌肉勞損", level: "高危 · 每日站立 8-12 小時" },
      { name: "精神疲勞", level: "高危 · 倦怠率 40–60%" },
      { name: "滑倒摔傷", level: "中危 · 濕滑地面" },
      { name: "化學暴露", level: "中危 · 清潔劑接觸" },
      { name: "噪音暴露", level: "中低 · 抽風機噪音" },
      { name: "油煙吸入", level: "中危 · 通風不良風險" }
    ],

    tableHeaders: ["操作節點", "人類工作流", "AI / 機器人協同流", "技術協同比例", "節點價值", "預計普及時間", "當前狀態"],
    tableRows: [
      { action: "庫存與訂貨", hum: "盤點冰箱，預估消耗，給供應商打電話", ai: "MarketMan AI 預測分析自動下單", rat: 85, ratLbl: "技術輔助", node: "~10% 輔助", eta: "~2 年", stat: "已就緒", cls: "playable" },
      { action: "煎炸與烤制", hum: "守在油鍋前看火候，手動翻面瀝油", ai: "Miso Robotics 機械臂視覺識別翻面", rat: 65, ratLbl: "技術輔助", node: "~30% 協同", eta: "3–5 年", stat: "進行中", cls: "ingame" },
      { action: "食譜研發", hum: "憑藉味覺經驗和靈感搭配新食材", ai: "生成式AI分析分子風味圖譜輸出配方", rat: 30, ratLbl: "技術輔助", node: "~20% 協同", eta: "7–10 年", stat: "初步引入", cls: "intro" },
      { action: "擺盤與試味", hum: "藝術性擺盤，嘗鹹淡，微調風味", ai: "無現成AI方案，傳感器無法完全模擬主觀味覺", rat: 8, ratLbl: "技術輔助", node: "~40% 核心", eta: "10+ 年", stat: "無影響", cls: "nothing" }
    ],

    elderly: "養老問題", elderlyVal: "分層策略", elderlyMeta: "給父母和自己養老的能力取決於能否在35歲前晉升至主廚級別。集團路線提供更好的保障。",
    private: "私校問題", privateVal: "需要行政總廚級別", privateMeta: "負擔子女精英私立學校通常需要行政總廚或多店經營者的收入水平。",
    network: "推薦認識的人", networkVal: "內容已鎖定", networkMeta: "請登錄以查看為您量身定製的職業發展人脈推薦。",
    fameTitle: "行業殿堂 (高收入名人)",
    majors: "推薦讀的專業", majorsVal: "烹飪藝術與酒店管理", majorsMeta: "輔修：食品科學或工商管理。",
    courses: "推薦讀的課", coursesVal: "廚房運營與成本控制", coursesMeta: "同樣推薦：分子料理、可持續採購。",
    strive: "推薦努力學的專業", striveVal: "餐飲科技與創新", striveMeta: "轉型進入技術賦能的食品系統領域。",
    resumeItems: [
        { title: "四季酒店 - 高級副主廚", stat: "已安排面試", meta: "投遞時間: 2天前 · 登錄查看詳情" },
        { title: "本地高級餐館 - 行政總廚", stat: "收到 Offer", meta: "投遞時間: 14天前 · 登錄查看詳情" }
    ],
    sifuTitle: "拜師連結 (尋找師傅)", sifuDesc: "與傳統大師和烹飪導師建立聯繫，獲取直接的傳承與技能指導。[外部連結：全球尋師網]"
  },
  DE: {
    title: "Karrierechancen & Entwicklungslandschaft",
    live: "Live-Verfolgung",
    target: "Zielberuf: <span>KOCH / KÖCHIN</span>",
    subscribe: "Abonnieren",
    mbtiLabel: "Personalisieren (MBTI)",
    regionLabel: "Region wählen — LTV & Wendepunkt nach Land",
    levelLabel: "Karrierestufe — Gehalt & Insights vergleichen",
    ltvSection: "Karrierewert & Wachstumspotenzial",
    ltvTotal: "Karriere-LTV",
    ltvSafe: "Menschlicher Kernwert",
    ltvRisk: "KI-gestützter Wert",
    ltvIdx: "Tech-Synergie Index",
    ltvAge: "Karriere-Wendepunkt",
    distTitle: "Verteilung des Karrierewerts",
    safeLegend: "Menschzentriert — Urteilsvermögen, Kreativität, Geschmack",
    riskLegend: "KI-gestützt — Bestehende oder künftige KI/Robotik",
    carEq: "Karriere-LTV entspricht",
    carSub: "Basierend auf $28.000/Einheit Referenzpreis · 🟢 Kern · 🔴 KI-gestützt",
    incTitle: "Einkommenskurve — Volle Karriere",
    incNote: "Farbige Punkte markieren Übergänge",
    promoTitle: "Typischer Beförderungszeitplan",
    insightTitle: "Karriereprofil-Insights",
    hazardTitle: "Berufsgefahren",
    langTitle: "Sprachanforderungen",
    heatTitle: "Stadt-Einkommens-Heatmap",
    ecoTitle: "Karriereökonomie",
    accTitle: "Zugangspunkte",
    notesTitle: "Schul-, Ruhestands- und Pivot-Notizen",
    trkTitle: "Bewerbungstracker (Anmelden für Details)",
    recTitle: "Karriereempfehlungen (Fähigkeiten verbessern)",
    netTitle: "Akademische & Netzwerkstrategie",
    
    hazards: [
      { name: "Verbrennungen", level: "Kritisch · Offenes Feuer" },
      { name: "Hitzschlag", level: "Kritisch · 38–50°C Küchen" },
      { name: "Schnittwunden", level: "Hoch · Tägliche Messerarbeit" },
      { name: "Körperliche Belastung", level: "Hoch · 8-12 Std. Stehen" },
      { name: "Geistige Erschöpfung", level: "Hoch · Burnout-Rate 40-60%" },
      { name: "Ausrutschen", level: "Mittel · Nasse Böden" },
      { name: "Chemikalien", level: "Mittel · Reinigungsmittel" },
      { name: "Lärm", level: "Niedrig-Mittel · Lüftung" },
      { name: "Rauch & Dämpfe", level: "Mittel · Belüftungsrisiko" }
    ],

    tableHeaders: ["Aktion", "Menschlicher Workflow", "KI / Bot Workflow", "Synergie-Ratio", "Knotenwert", "ETA", "Status"],
    tableRows: [
      { action: "Inventar & Bestellung", hum: "Kühlschrank prüfen, Verbrauch schätzen, anrufen.", ai: "MarketMan KI-Bestellung.", rat: 85, ratLbl: "Assistiert", node: "~10% Assist.", eta: "~2 J.", stat: "Anwendbar", cls: "playable" },
      { action: "Braten & Grillen", hum: "Hitze überwachen, manuell wenden.", ai: "Miso Robotics Vision-Wenden.", rat: 65, ratLbl: "Assistiert", node: "~30% Syn.", eta: "3–5 J.", stat: "Im Einsatz", cls: "ingame" },
      { action: "Rezeptkreation", hum: "Zutaten nach Geschmack kombinieren.", ai: "Gen-AI Molekular-Pairing.", rat: 30, ratLbl: "Assistiert", node: "~20% Syn.", eta: "7–10 J.", stat: "Einführung", cls: "intro" },
      { action: "Anrichten & Probieren", hum: "Künstlerisches Anrichten, Abschmecken.", ai: "Keine reine KI, Sensorik fehlt.", rat: 8, ratLbl: "Assistiert", node: "~40% Einzig.", eta: "10+ J.", stat: "Keine", cls: "nothing" }
    ],

    elderly: "Altersvorsorge (养老)", elderlyVal: "Mehrschichtige Strategie", elderlyMeta: "Die Fähigkeit zur Vorsorge hängt davon ab, ob man bis 35 Küchenchef wird.",
    private: "Privatschule (私校)", privateVal: "Executive-Ebene nötig", privateMeta: "Erfordert das Gehalt eines Executive Chefs.",
    network: "Netzwerk aufbauen", networkVal: "Gesperrter Inhalt", networkMeta: "Bitte loggen Sie sich ein, um Empfehlungen zu sehen.",
    fameTitle: "Hall of Fame (Spitzenverdiener)",
    majors: "Empfohlene Studiengänge", majorsVal: "Kulinarik & Gastro-Management", majorsMeta: "Nebenfach: Lebensmittelwissenschaft.",
    courses: "Zielkurse", coursesVal: "Küchenbetrieb & Kostenkontrolle", coursesMeta: "Auch: Molekulargastronomie.",
    strive: "Studienziele", striveVal: "F&B Tech & Innovation", striveMeta: "Übergang in technologiegestützte Lebensmittelsysteme.",
    resumeItems: [
        { title: "Four Seasons - Senior Sous Chef", stat: "Interview geplant", meta: "Beworben: Vor 2 Tagen · Anmelden für Details" },
        { title: "Lokales Bistro - Executive Chef", stat: "Angebot erhalten", meta: "Beworben: Vor 14 Tagen · Anmelden für Details" }
    ],
    sifuTitle: "Sifu Finden (Meister-Lehrling)", sifuDesc: "Verbinden Sie sich mit traditionellen Meistern. [Externes Link]"
  }
};

const LANG_MAP = { US:'EN', UK:'EN', AU:'EN', SG:'EN', CN:'CN', JP:'JP', TW:'TW', DE:'DE' };

// Country Specific Hall of Fame
const FAME = {
  EN: [
    { name: "Gordon Ramsay", worth: "$220M", title: "Global Brand CEO" },
    { name: "Wolfgang Puck", worth: "$120M", title: "Catering Empire Lead" },
    { name: "Jamie Oliver", worth: "$200M", title: "Media Mogul & Restaurant Group" }
  ],
  CN: [
    { name: "大董 (Dong Zhenxiang)", worth: "¥800M+", title: "意境菜创始人 · 集团董事长" },
    { name: "屈浩 (Qu Hao)", worth: "Est. ¥100M", title: "鲁菜大师 · 烹饪学校校长" },
    { name: "陈晓卿 (Chen Xiaoqing)", worth: "Media Icon", title: "《舌尖》总导演 · 美食家" }
  ],
  JP: [
    { name: "小野二郎 (Jiro Ono)", worth: "Priceless", title: "寿司之神 · 職人精神の象徴" },
    { name: "成澤由浩 (Yoshihiro Narisawa)", worth: "Est. $15M", title: "里山料理開拓者" },
    { name: "脇屋友詞 (Yuji Wakiya)", worth: "Est. $10M", title: "アイアンシェフ" }
  ],
  TW: [
    { name: "江振誠 (André Chiang)", worth: "$20M+", title: "國際名廚 · RAW 創辦人" },
    { name: "陳嵐舒 (Lanshu Chen)", worth: "Elite", title: "亞洲最佳女廚師" },
    { name: "阿基師 (A-Ji-Shi)", worth: "Icon", title: "國宴主廚 · 媒體名廚" }
  ],
  DE: [
    { name: "Tim Mälzer", worth: "€20M", title: "TV-Koch & 'Bullerei' Gastronom" },
    { name: "Kevin Fehling", worth: "3-Stars", title: "Modern Gastronomy · 'The Table'" },
    { name: "Christian Bau", worth: "Victus", title: "Victor's Fine Dining Master" }
  ]
};

// Replace static text elements based on selected country
function applyTranslation(countryCode) {
  const lang = LANG_MAP[countryCode] || 'EN';
  const t = I18N[lang];
  
  // Headers & Subtitles
  const pt = document.querySelector('.page-title'); if(pt) pt.innerHTML = t.title;
  const pb = document.querySelector('.header-tag'); if(pb) pb.innerHTML = `<span class="live-dot"></span> ${t.live}`;
  const pst = document.querySelector('.page-subtitle'); if(pst) pst.innerHTML = t.target;
  const btnSub = document.querySelector('.btn-subscribe'); if(btnSub) btnSub.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:14px;height:14px"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg> ${t.subscribe}`;
  const mbti = document.getElementById('mbtiLabel'); if(mbti) mbti.textContent = t.mbtiLabel;
  
  // Section Labels
  const cl = document.querySelector('.country-label'); if(cl) cl.textContent = t.regionLabel;
  const ll = document.querySelector('.level-section .section-label'); if(ll) ll.textContent = t.levelLabel;
  const ltvL = document.querySelector('.ltv-section > .section-label'); if(ltvL) ltvL.textContent = t.ltvSection;
  
  // KPI Cards
  const kTotal = document.querySelector('.c-total .ltv-lbl'); if(kTotal) kTotal.textContent = t.ltvTotal;
  const kSafe = document.querySelector('.c-safe .ltv-lbl'); if(kSafe) kSafe.textContent = t.ltvSafe;
  const kRisk = document.querySelector('.c-risk .ltv-lbl'); if(kRisk) kRisk.textContent = t.ltvRisk;
  const kIdx = document.querySelector('.c-idx .ltv-lbl'); if(kIdx) kIdx.textContent = t.ltvIdx;
  const kAge = document.querySelector('.c-age .ltv-lbl'); if(kAge) kAge.textContent = t.ltvAge;
  
  // Breakdown
  const dist = document.querySelector('.ltv-chart-title'); if(dist) dist.textContent = t.distTitle;
  const legSafe = document.querySelector('.ltv-legend-item:nth-child(1)'); if(legSafe) legSafe.innerHTML = `<div class="ltv-legend-dot" style="background:var(--green)"></div>${t.safeLegend}`;
  const legRisk = document.querySelector('.ltv-legend-item:nth-child(2)'); if(legRisk) legRisk.innerHTML = `<div class="ltv-legend-dot" style="background:var(--red)"></div>${t.riskLegend}`;
  
  // Cars
  const ce = document.querySelector('.car-viz-eq'); if(ce) ce.textContent = t.carEq;
  // car-viz-sub handled dynamically during renderCountry
  
  // Income
  const it = document.querySelector('.income-chart-title'); if(it) it.innerHTML = `${t.incTitle} (<span id="chartCountryLabel">${COUNTRY_NAMES[countryCode]||countryCode}</span>)`;
  const inot = document.querySelector('.income-chart-note'); if(inot) inot.textContent = t.incNote;
  
  // Other Sections
  const prT = document.querySelector('.promo-section .section-label'); if(prT) prT.textContent = t.promoTitle;
  const insL = document.querySelector('.insights-grid')?.previousElementSibling; if(insL) insL.textContent = t.insightTitle;
  const hazL = document.querySelector('.hazards-section .section-label'); if(hazL) hazL.textContent = t.hazardTitle;
  const lngL = document.querySelector('.lang-section .section-label'); if(lngL) lngL.innerHTML = `${t.langTitle} — <span id="langCountryLabel">${COUNTRY_NAMES[countryCode]||countryCode}</span>`;
  const htL = document.querySelector('.heatmap-header .section-label'); if(htL) htL.innerHTML = `${t.heatTitle} — <span id="heatmapCountryLabel">${COUNTRY_NAMES[countryCode]||countryCode}</span>`;

  // Extended Sections
  const es = document.querySelectorAll('.extended-section .section-label');
  if(es.length >= 6) {
    es[0].textContent = t.ecoTitle;
    es[1].textContent = t.accTitle;
    es[2].textContent = t.notesTitle;
    es[3].textContent = t.trkTitle;
    es[4].textContent = t.recTitle;
    es[5].textContent = t.netTitle;
  }

  // Hazards Rendering
  const hazGrid = document.querySelector('.hazards-grid');
  if(hazGrid) {
    const hazClasses = ["haz-5", "haz-5", "haz-4", "haz-4", "haz-4", "haz-3", "haz-3", "haz-2", "haz-3"];
    const hazWidths = ["100%", "100%", "80%", "80%", "75%", "55%", "50%", "35%", "45%"];
    const hazIcons = ["🔥","🌡️","🔪","💪","🧠","🚿","⚗️","👂","🫁"];
    let hazHtml = '';
    t.hazards.forEach((h, i) => {
        hazHtml += `
        <div class="hazard-card"><span class="hazard-icon">${hazIcons[i]}</span><div class="hazard-info"><div class="hazard-name">${h.name}</div><div class="hazard-bar-track"><div class="hazard-bar-fill ${hazClasses[i]}" style="width:${hazWidths[i]}"></div></div><div class="hazard-level">${h.level}</div></div></div>
        `;
    });
    hazGrid.innerHTML = hazHtml;
  }

  // Table Rendering
  const thead = document.querySelector('thead tr');
  if(thead) {
      thead.innerHTML = t.tableHeaders.map((h, i) => i === 4 || i === 5 || i === 6 ? `<th style="text-align:center">${h}</th>` : `<th>${h}</th>`).join('');
  }
  const tbody = document.getElementById('dynamicTable');
  if(tbody) {
      tbody.innerHTML = t.tableRows.map(r => `
      <tr data-status="${r.cls}">
        <td class="col-action">${r.action}</td>
        <td class="col-human">${r.hum}</td>
        <td class="col-ai">${r.ai}</td>
        <td><div class="bar-wrap"><div class="bar-track"><div class="bar-fill" style="width:${r.rat}%;background:var(--${r.rat > 50 ? (r.rat>80?'green':'yellow') : (r.rat>20?'orange':'red')})"></div></div><div class="bar-lbl"><span>${r.ratLbl}</span><span>${r.rat}%</span></div></div></td>
        <td style="text-align:center"><span class="ltv-chip ${r.rat>50?'risk':(r.rat>20?'partial':'safe')}">${r.node}</span></td>
        <td style="text-align:center"><span class="eta-badge">${r.eta}</span></td>
        <td style="text-align:center"><span class="status-badge b-${r.cls==='playable'?'play':(r.cls==='ingame'?'ing':(r.cls==='intro'?'intro':'none'))}"><span class="dot"></span>${r.stat}</span></td>
      </tr>
      `).join('');
  }
}
"""

html = html.replace('// ── PROMO LADDER ──────────────────────────────────────────────────────────────', js_localization + '\n// ── PROMO LADDER ──────────────────────────────────────────────────────────────')

# Update dynamic renders for EXTENDED SECTIONS to use I18N
js_override_ext = """
function renderRequirementExtensions(country){
  const lang = LANG_MAP[country] || 'EN';
  const t = I18N[lang];
  const fameData = FAME[lang] || FAME['EN'];
  
  const network = document.getElementById('networkGrid');
  if(network){
    const fameHtml = fameData.map(p => `
      <div style="margin-bottom:8px; padding-bottom:8px; border-bottom:1px solid var(--border)">
        <div style="font-weight:800; color:#fff">${p.name} (${p.worth})</div>
        <div style="font-size:10px; color:var(--accent)">${p.title}</div>
      </div>
    `).join('');
    
    network.innerHTML=`
      <div class="note-card"><div class="note-title">${t.elderly}</div><div class="note-value" style="font-size:14px">${t.elderlyVal}</div><div class="note-meta">${t.elderlyMeta}</div></div>
      <div class="note-card"><div class="note-title">${t.private}</div><div class="note-value" style="font-size:14px">${t.privateVal}</div><div class="note-meta">${t.privateMeta}</div></div>
      <div class="note-card"><div class="note-title">${t.network}</div><div class="note-value" style="font-size:14px; color:var(--text-faint)">${t.networkVal}</div><div class="note-meta">${t.networkMeta}</div></div>
      
      <div class="note-card"><div class="note-title">${t.majors}</div><div class="note-value" style="font-size:14px">${t.majorsVal}</div><div class="note-meta">${t.majorsMeta}</div></div>
      <div class="note-card"><div class="note-title">${t.courses}</div><div class="note-value" style="font-size:14px">${t.coursesVal}</div><div class="note-meta">${t.coursesMeta}</div></div>
      <div class="note-card"><div class="note-title">${t.strive}</div><div class="note-value" style="font-size:14px">${t.striveVal}</div><div class="note-meta">${t.striveMeta}</div></div>
      
      <div class="note-card" style="grid-column:span 3"><div class="note-title">${t.fameTitle}</div><div style="margin-top:10px; display:grid; grid-template-columns:repeat(3, 1fr); gap:10px;">${fameHtml}</div></div>
    `;
  }

  const meta=EXTRA_META[country]||EXTRA_META.US;
  const extra=document.getElementById('extraInsightsGrid');
  const access=document.getElementById('accessGrid');
  const notes=document.getElementById('careerNotesGrid');
  
  if(extra){
    extra.innerHTML=`
      <div class="insight-card"><span class="insight-icon">💸</span><div class="insight-label">Relationship Budget</div><div class="insight-value" style="color:var(--accent)">${meta.budget}</div><div class="insight-meta">Approx monthly social/dating spend.</div></div>
      <div class="insight-card"><span class="insight-icon">🧑‍💼</span><div class="insight-label">HNWI Client Access</div><div class="insight-value" style="font-size:13px;color:var(--text)">${meta.hnwi}</div><div class="insight-meta">Best environments for reaching high-net-worth diners.</div></div>
      <div class="insight-card"><span class="insight-icon">🚀</span><div class="insight-label">Entrepreneurial Foundation</div><div class="insight-value" style="color:var(--green)">${meta.startup}</div><div class="insight-meta">Market baseline. (Risk Note: 90% of food startups fail without deep SOP preparation. [View Guide](https://example.com))</div></div>
    `;
  }
  
  if(access){
    const items = [...ACCESS_LINKS.filter(a => a.title !== 'Startup Preparation'), {title: t.sifuTitle, desc: t.sifuDesc}];
    access.innerHTML=items.map(item=>`
      <div class="link-card"><div class="link-card-title">${item.title}</div><div class="link-card-desc">${item.desc}</div></div>
    `).join('');
  }
  
  if(notes){
    notes.innerHTML=`
      <div class="note-card"><div class="note-title">Prestige Uni Required?</div><div class="note-value">${meta.uni}</div><div class="note-meta">${meta.uniMeta}</div></div>
      <div class="note-card"><div class="note-title">Private School Issue</div><div class="note-value">${meta.privateSchool}</div><div class="note-meta">${meta.privateMeta}</div></div>
      <div class="note-card"><div class="note-title">Skill Pivot</div><div class="note-value" style="font-size:13px">${meta.pivot}</div><div class="note-meta">Alternative roles with overlapping skill set.</div></div>
    `;
  }
  
  // Update Tracker
  const extSections = document.querySelectorAll('.extended-section .note-grid');
  if(extSections.length >= 2) {
    const trackerGrid = extSections[0]; // Assuming 4th extended section is tracker, but let's select via DOM dynamically in full render.
    // Actually, we placed the tracker at a specific spot. Let's just hardcode the tracker update in applyTranslations or here.
    const trkHtml = t.resumeItems.map(ri => `
      <div class="note-card" style="border-left:3px solid var(--accent)">
        <div class="note-title">${ri.title}</div>
        <div class="note-value" style="font-size:14px">${ri.stat}</div>
        <div class="note-meta">${ri.meta}</div>
      </div>
    `).join('');
    // We will inject it below
  }
}
"""

# Replace the old renderRequirementExtensions
html = re.sub(r'function renderRequirementExtensions\(country\)\{.*?\}', js_override_ext, html, flags=re.DOTALL)

# And make sure Tracker and Recommendations are rendered
js_tracker_rec_update = """
  // Update Tracker
  const extSections = document.querySelectorAll('.extended-section');
  if(extSections.length >= 6) {
    const trkGrid = extSections[3].querySelector('.note-grid');
    if(trkGrid) {
      trkGrid.innerHTML = t.resumeItems.map((ri, idx) => `
        <div class="note-card" style="border-left:3px solid ${idx===0?'var(--accent)':'var(--green)'}">
          <div class="note-title">${ri.title}</div>
          <div class="note-value" style="font-size:14px">${ri.stat}</div>
          <div class="note-meta">${ri.meta}</div>
        </div>
      `).join('');
    }
  }
"""

html = html.replace('  // Hazards Rendering', js_tracker_rec_update + '\n  // Hazards Rendering')

# Hook applyTranslation into the renderCountryFull
render_full = """
function renderCountryFull(code,animate=true){
  applyTranslation(code);
  renderCountry(code,animate);
  renderIncomeChart(code);
  renderPromoFlow(code);
  renderInsights(code);
  renderLang(code);
  renderHeatmap(code);
  renderRequirementExtensions(code);
}

// Override country tab listener
document.getElementById('countryTabs').addEventListener('click', e=>{
  const tab=e.target.closest('.ctab');
  if(!tab)return;
  document.querySelectorAll('.ctab').forEach(t=>t.classList.remove('active'));
  tab.classList.add('active');
  currentCountry=tab.dataset.country;
  renderCountryFull(currentCountry);
},{capture:true});

// Initialize Translation immediately
applyTranslation(currentCountry||'US');
"""

html = re.sub(r'const _origRenderCountry=renderCountry;.*?setTimeout', render_full + '\nsetTimeout', html, flags=re.DOTALL)

# Delete MBTI Recommendation card entirely from static html
html = re.sub(r'<div class="note-card">\s*<div class="note-title">MBTI Recommendation</div>.*?</div>\s*</div>', '', html, flags=re.DOTALL)

# Output
now = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
output_file = f"career_data_exports/GeminiPro_InstantTranslate_{now}.html"

with open(output_file, 'w', encoding='utf-8') as f:
    f.write(html)

print(output_file)
