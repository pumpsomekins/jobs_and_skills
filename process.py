import re
import datetime

with open('SkillsNJobs_FullRequirements.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update formatting function to use local currency symbol
content = content.replace(
    "function fmt(n){ return '$' + n.toLocaleString('en-US'); }",
    "function fmt(n, c='US'){ const sym = COUNTRIES[c].symbol || '$'; return sym + n.toLocaleString('en-US'); }"
)

content = content.replace(
    "function fmtK(n){ return n >= 1000000 ? '$'+(n/1000000).toFixed(2)+'M' : fmt(n); }",
    "function fmtK(n, c='US'){ const sym = COUNTRIES[c].symbol || '$'; return n >= 1000000 ? sym+(n/1000000).toFixed(2)+'M' : fmt(n, c); }"
)

# 2. Add currency symbols to COUNTRIES
country_replacements = {
    "annualUSD:56000": "symbol:'$', annualUSD:56000, annualLocal:56000",
    "annualUSD:44000": "symbol:'£', annualUSD:44000, annualLocal:35000",
    "annualUSD:42000": "symbol:'A$', annualUSD:42000, annualLocal:65000",
    "annualUSD:41000": "symbol:'€', annualUSD:41000, annualLocal:38000",
    "annualUSD:28000": "symbol:'¥', annualUSD:28000, annualLocal:4200000",
    "annualUSD:31000": "symbol:'S$', annualUSD:31000, annualLocal:42000",
    "annualUSD:15000": "symbol:'NT$', annualUSD:15000, annualLocal:480000",
    "annualUSD:12000": "symbol:'¥', annualUSD:12000, annualLocal:86000"
}
for old, new in country_replacements.items():
    content = content.replace(old, new)

# Update calcLTV to calculate local LTV
content = content.replace(
    "const ltv = c.annualUSD * c.career;",
    "const ltv = c.annualUSD * c.career; const ltvLocal = c.annualLocal * c.career; const safeLocal = Math.round(ltvLocal * (1 - c.automationIdx/100)); const riskLocal = ltvLocal - safeLocal;"
)
# Make sure safe and risk still use USD for car calculations, but we pass local versions for display
# Wait, let's just change calcLTV completely to use local currency for display, and keep USD for car math.
old_calcltv = """function calcLTV(c){
  const ltv = c.annualUSD * c.career;
  const safe = Math.round(ltv * (1 - c.automationIdx/100));
  const risk = ltv - safe;
  const carCount = Math.round(ltv / c.carPriceUSD);
  const safeCarCount = Math.round(safe / c.carPriceUSD);
  const riskCarCount = carCount - safeCarCount;
  const safeYears = c.riskAge - c.startAge;
  const totalWorkYears = 55 - c.startAge;
  return { ltv, safe, risk, carCount, safeCarCount, riskCarCount, safeYears, totalWorkYears };
}"""
new_calcltv = """function calcLTV(c){
  const ltvUSD = c.annualUSD * c.career;
  const safeUSD = Math.round(ltvUSD * (1 - c.automationIdx/100));
  const ltv = c.annualLocal * c.career;
  const safe = Math.round(ltv * (1 - c.automationIdx/100));
  const risk = ltv - safe;
  const carCount = Math.round(ltvUSD / c.carPriceUSD);
  const safeCarCount = Math.round(safeUSD / c.carPriceUSD);
  const riskCarCount = carCount - safeCarCount;
  const safeYears = c.riskAge - c.startAge;
  const totalWorkYears = 55 - c.startAge;
  return { ltv, safe, risk, carCount, safeCarCount, riskCarCount, safeYears, totalWorkYears, ltvUSD, safeUSD };
}"""
content = content.replace(old_calcltv, new_calcltv)

# Update renderCountry to use local currency format
content = content.replace("animNum(document.getElementById('kpi-ltv'), prevLTV, d.ltv, '$', '');",
                          "animNum(document.getElementById('kpi-ltv'), prevLTV, d.ltv, c.symbol, '');")
content = content.replace("animNum(document.getElementById('kpi-safe'), 0, d.safe, '$', '');",
                          "animNum(document.getElementById('kpi-safe'), 0, d.safe, c.symbol, '');")
content = content.replace("animNum(document.getElementById('kpi-risk'), 0, d.risk, '$', '');",
                          "animNum(document.getElementById('kpi-risk'), 0, d.risk, c.symbol, '');")

content = content.replace("segSafe.textContent = `${fmt(d.safe)} Safe (${safePct}%)`;",
                          "segSafe.textContent = `${fmt(d.safe, code)} Safe (${safePct}%)`;")
content = content.replace("segRisk.textContent = `${fmt(d.risk)} At Risk (${riskPct}%)`;",
                          "segRisk.textContent = `${fmt(d.risk, code)} At Risk (${riskPct}%)`;")

content = content.replace("document.getElementById('car-safe-label').textContent = `${d.safeCarCount} cars = Human-Safe LTV (${fmt(d.safe)})`;",
                          "document.getElementById('car-safe-label').textContent = `${d.safeCarCount} cars = Human-Safe LTV (${fmt(d.safe, code)})`;")
content = content.replace("document.getElementById('car-risk-label').textContent = `${d.riskCarCount} cars = At-Risk LTV (${fmt(d.risk)})`;",
                          "document.getElementById('car-risk-label').textContent = `${d.riskCarCount} cars = At-Risk LTV (${fmt(d.risk, code)})`;")

# 3. Add new HTML sections before the Filters + Table
new_html = """
  <!-- ── Resume Tracker ── -->
  <div class="extended-section">
    <div class="section-label">Job Application Tracker (User Uploads)</div>
    <div class="note-grid">
      <div class="note-card" style="border-left:3px solid var(--accent)">
        <div class="note-title">Four Seasons - Senior Sous Chef</div>
        <div class="note-value" style="font-size:14px">Interview Scheduled</div>
        <div class="note-meta">Applied: 2 days ago · Match: 92%</div>
      </div>
      <div class="note-card" style="border-left:3px solid var(--green)">
        <div class="note-title">Local Bistro - Executive Chef</div>
        <div class="note-value" style="font-size:14px">Offer Received</div>
        <div class="note-meta">Applied: 14 days ago · Match: 88%</div>
      </div>
      <div class="note-card" style="border-left:3px solid var(--yellow)">
        <div class="note-title">Ritz-Carlton - Chef de Partie</div>
        <div class="note-value" style="font-size:14px">Under Review</div>
        <div class="note-meta">Applied: 5 days ago · Match: 85%</div>
      </div>
    </div>
  </div>

  <!-- ── Career Recommendations ── -->
  <div class="extended-section">
    <div class="section-label">Career Recommendations (Based on Skill Set)</div>
    <div class="note-grid">
      <div class="note-card">
        <div class="note-title">Food Technologist (R&D)</div>
        <div class="note-value" style="font-size:14px; color:var(--accent)">88% Match</div>
        <div class="note-meta">Focus on sensory evaluation, recipe scaling, and food chemistry. High growth, lower physical strain.</div>
      </div>
      <div class="note-card">
        <div class="note-title">Event Operations Manager</div>
        <div class="note-value" style="font-size:14px; color:var(--green)">82% Match</div>
        <div class="note-meta">Leverages high-pressure coordination, vendor management, and timing logistics.</div>
      </div>
      <div class="note-card">
        <div class="note-title">F&B Procurement Specialist</div>
        <div class="note-value" style="font-size:14px; color:var(--yellow)">79% Match</div>
        <div class="note-meta">Utilizes knowledge of ingredient quality, yield management, and supplier networks.</div>
      </div>
    </div>
  </div>

  <!-- ── Study & Network Recommendations ── -->
  <div class="extended-section">
    <div class="section-label">Academic & Networking Strategy</div>
    <div class="note-grid" id="networkGrid">
      <!-- Will be populated by JS -->
    </div>
  </div>
"""

content = content.replace('<!-- Filters + Table -->', new_html + '\n  <!-- Filters + Table -->')

# 4. Add JS for the new Study & Network section
new_js = """
function renderRequirementExtensions(country){
"""

new_js_logic = """
  const network = document.getElementById('networkGrid');
  if(network){
    network.innerHTML=`
      <div class="note-card">
        <div class="note-title">Recommended Majors (推荐读的专业)</div>
        <div class="note-value" style="font-size:14px">Culinary Arts & Hospitality Mgt</div>
        <div class="note-meta">Secondary: Food Science, Nutrition, or Business Administration.</div>
      </div>
      <div class="note-card">
        <div class="note-title">Target Courses (推荐读的课)</div>
        <div class="note-value" style="font-size:14px">Kitchen Ops & Cost Control</div>
        <div class="note-meta">Also highly recommended: Molecular Gastronomy, Sustainable Sourcing, and Staff Leadership.</div>
      </div>
      <div class="note-card">
        <div class="note-title">Majors to Strive For (努力学的专业)</div>
        <div class="note-value" style="font-size:14px">F&B Tech & Innovation</div>
        <div class="note-meta">To beat AI risk, transition into tech-enabled food systems or high-end molecular research.</div>
      </div>
      <div class="note-card">
        <div class="note-title">People to Network With (推荐认识的人)</div>
        <div class="note-value" style="font-size:14px">Michelin Execs & F&B Directors</div>
        <div class="note-meta">Connect with suppliers, specialized food critics, and affluent club managers.</div>
      </div>
      <div class="note-card" style="grid-column:span 2">
        <div class="note-title">Hall of Fame (收入靠前的名人)</div>
        <div class="note-value" style="font-size:14px">Gordon Ramsay, Wolfgang Puck, René Redzepi</div>
        <div class="note-meta">These chefs scaled by leveraging personal brand, media, and multi-venue empires rather than just line cooking.</div>
      </div>
    `;
  }
"""

content = content.replace("function renderRequirementExtensions(country){", "function renderRequirementExtensions(country){" + new_js_logic)


# Write to new file
now_str = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
output_filename = f"career_data_exports/GeminiPro_{now_str}.html"

with open(output_filename, 'w', encoding='utf-8') as f:
    f.write(content)

print(f"Created file: {output_filename}")
