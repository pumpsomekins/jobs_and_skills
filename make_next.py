import re
import datetime

input_file = "career_data_exports/GeminiPro_20260419_220242.html"

with open(input_file, 'r', encoding='utf-8') as f:
    html = f.read()

# 1 & 2. Income Projection to Death and Dynamic LTV
# In `GeminiPro_20260419_220242.html`, `calcLTV` is:
# function calcLTV(c){
#   const ltv = c.annualUSD * c.career; const ltvLocal = c.annualLocal * c.career; ...

# We need `calcLTV` to be aware of `currentLevel` and project to "death" (let's say 60 years of career/life post-start).
calc_ltv_pattern = r'function calcLTV\(c\)\{.*?return \{ ltv, safe, risk, carCount, safeCarCount, riskCarCount, safeYears, totalWorkYears \};\n\}'

new_calc_ltv = """function calcLTV(c){
  const levelMults = [0.6, 0.9, 1.1, 1.5, 2.2]; // approximate multipliers for levels
  const mult = levelMults[currentLevel] || 1;
  const yearsToDeath = 60; // Projecting to death (e.g., age 25 to 85)
  
  // Calculate LTV assuming they stay at current title to death
  const ltvUSD = c.annualUSD * mult * yearsToDeath; 
  const safeUSD = Math.round(ltvUSD * (1 - c.automationIdx/100));
  
  const ltv = c.annualLocal * mult * yearsToDeath;
  const safe = Math.round(ltv * (1 - c.automationIdx/100));
  const risk = ltv - safe;
  
  const carCount = Math.round(ltvUSD / c.carPriceUSD);
  const safeCarCount = Math.round(safeUSD / c.carPriceUSD);
  const riskCarCount = carCount - safeCarCount;
  
  const safeYears = c.riskAge - c.startAge;
  const totalWorkYears = yearsToDeath;
  
  return { ltv, safe, risk, carCount, safeCarCount, riskCarCount, safeYears, totalWorkYears };
}"""

html = re.sub(calc_ltv_pattern, new_calc_ltv, html, flags=re.DOTALL)

# Update renderCountry to trigger correctly when level changes
# `GeminiPro_20260419_220242.html` level tabs:
# document.getElementById('levelTabs')?.addEventListener('click',e=>{ ... renderIncomeChart(currentCountry); ... })
# We need it to also re-render the LTV by calling renderCountry.
level_listener_pattern = r"currentLevel=parseInt\(tab\.dataset\.level\)\|\|0;\n\s*renderPromoFlow\(currentCountry\);\n\s*renderIncomeChart\(currentCountry\);"
new_level_listener = "currentLevel=parseInt(tab.dataset.level)||0;\n  renderCountryFull(currentCountry);"
html = re.sub(level_listener_pattern, new_level_listener, html)

# Update chart to show projection to death
# The current chart renders `buildIncomePoints` to 30 years.
build_income_pattern = r'function buildIncomePoints\(country\)\{.*?return pts;\n\}'
new_build_income = """function buildIncomePoints(country){
  const salaries=LEVEL_USD[country]||LEVEL_USD.US;
  const transitions=[0,2,5,8,16];
  const pts=[];
  const deathYear = 60; // project to death
  
  // 1. The "Optimal/Standard" Ladder (Climbing to Exec)
  for(let yr=0;yr<=deathYear;yr++){
    let lvl=0;
    for(let i=transitions.length-1;i>=0;i--){if(yr>=transitions[i]){lvl=i;break;}}
    const nextTrans=transitions[lvl+1]||deathYear;
    const frac=lvl<4?(yr-transitions[lvl])/(nextTrans-transitions[lvl]):1;
    const baseSal=salaries[lvl];
    const nextSal=lvl<4?salaries[lvl+1]:salaries[4]*1.15;
    const sal=baseSal+(nextSal-baseSal)*frac*0.4;
    pts.push({yr,sal,lvl, type:'optimal'});
  }
  
  // 2. The "Current Title to Death" Projection
  const curBaseSal = salaries[currentLevel];
  for(let yr=0;yr<=deathYear;yr++){
    // Modest 0.5% annual growth in current title
    const sal = curBaseSal * Math.pow(1.005, yr);
    pts.push({yr, sal, lvl:currentLevel, type:'stagnant'});
  }
  
  return pts;
}"""
html = re.sub(build_income_pattern, new_build_income, html, flags=re.DOTALL)

# Update the renderIncomeChart to draw two lines
render_income_pattern = r'let d=\'\';\n\s*pts\.forEach\(\(p,i\)=>\{d\+=\(i===0\?\'M\':\'L\'\)\+xOf\(p\.yr\)\.toFixed\(1\)\+\',\'\+yOf\(p\.sal\)\.toFixed\(1\);\}\);\n\s*html\+=`<path d="\$\{d\}" fill="none" stroke="#333" stroke-width="1\.5"/>`;\n\s*// Colored dots at level transitions \+ at year 30\n\s*const transYears=\[0,2,5,8,16,30\];\n\s*transYears\.forEach\(yr=>\{.*?\n\s*\}\);'
new_render_income = """
  // Draw optimal ladder path
  const optPts = pts.filter(p=>p.type==='optimal');
  let dOpt='';
  optPts.forEach((p,i)=>{dOpt+=(i===0?'M':'L')+xOf(p.yr).toFixed(1)+','+yOf(p.sal).toFixed(1);});
  html+=`<path d="${dOpt}" fill="none" stroke="#aaa" stroke-width="1.5" stroke-dasharray="4,4"/>`;
  
  // Draw stagnant to death path
  const stagPts = pts.filter(p=>p.type==='stagnant');
  let dStag='';
  stagPts.forEach((p,i)=>{dStag+=(i===0?'M':'L')+xOf(p.yr).toFixed(1)+','+yOf(p.sal).toFixed(1);});
  html+=`<path d="${dStag}" fill="none" stroke="${LEVELS[currentLevel].color}" stroke-width="2.5"/>`;
  
  // X axis labels up to 60
  // (We replace the existing x-axis labels logic inside the string replace)
"""

# Actually, I'll just replace the whole renderIncomeChart function because it's safer.
render_chart_func = r'function renderIncomeChart\(country\)\{.*?document\.getElementById\(\'chartCountryLabel\'\)\.textContent=COUNTRY_NAMES\[country\]\|\|country;\n\}'

new_render_chart = """function renderIncomeChart(country){
  const svg=document.getElementById('incomeSVG');
  if(!svg)return;
  const pts=buildIncomePoints(country);
  const W=900,H=220,padL=55,padR=20,padT=20,padB=35;
  const cW=W-padL-padR,cH=H-padT-padB;
  const maxSal=Math.max(...pts.map(p=>p.sal))*1.1;
  const minSal=Math.min(...pts.map(p=>p.sal))*0.8;
  const xOf=yr=>padL+(yr/60)*cW; // 60 years scale
  const yOf=sal=>padT+cH-((sal-minSal)/(maxSal-minSal))*cH;
  
  let html='';
  // Grid lines
  for(let g=0;g<=4;g++){
    const y=padT+(g/4)*cH;
    const val=Math.round(maxSal-(g/4)*(maxSal-minSal));
    html+=`<line x1="${padL}" y1="${y}" x2="${W-padR}" y2="${y}" stroke="var(--border-hi)" stroke-width="1"/>`;
    html+=`<text x="${padL-5}" y="${y+4}" text-anchor="end" fill="var(--text-faint)" font-size="10">${val>=1000?'$'+(val/1000).toFixed(0)+'K':val}</text>`;
  }
  // X axis labels
  [0,10,20,30,40,50,60].forEach(yr=>{
    html+=`<text x="${xOf(yr)}" y="${H-5}" text-anchor="middle" fill="var(--text-faint)" font-size="10">${yr===60?'End of Life':'Yr '+yr}</text>`;
  });
  
  // Optimal path
  const optPts = pts.filter(p=>p.type==='optimal');
  let dOpt='';
  optPts.forEach((p,i)=>{dOpt+=(i===0?'M':'L')+xOf(p.yr).toFixed(1)+','+yOf(p.sal).toFixed(1);});
  html+=`<path d="${dOpt}" fill="none" stroke="var(--text-muted)" stroke-width="1.5" stroke-dasharray="4,4"/>`;
  
  // Current title path (to death)
  const stagPts = pts.filter(p=>p.type==='stagnant');
  let dStag='';
  stagPts.forEach((p,i)=>{dStag+=(i===0?'M':'L')+xOf(p.yr).toFixed(1)+','+yOf(p.sal).toFixed(1);});
  html+=`<path d="${dStag}" fill="none" stroke="${LEVELS[currentLevel].color}" stroke-width="2.5"/>`;
  
  // Colored dots at level transitions for optimal path
  const transYears=[0,2,5,8,16,60];
  transYears.forEach(yr=>{
    const p=optPts.find(pp=>pp.yr===yr);
    if(!p)return;
    const col=LEVELS[p.lvl].color;
    html+=`<circle cx="${xOf(p.yr)}" cy="${yOf(p.sal)}" r="5" fill="${col}" stroke="var(--surface)" stroke-width="2"/>`;
  });
  
  svg.innerHTML=html;
  document.getElementById('chartCountryLabel').textContent=COUNTRY_NAMES[country]||country;
}"""

html = re.sub(render_chart_func, new_render_chart, html, flags=re.DOTALL)

# Update KPI subtitle from 30 yrs to 60 yrs
html = html.replace('30 yrs ·', 'Lifetime (60 yrs) ·')
html = html.replace('30 yrs at current trajectory', 'Lifetime projection')

# 3. Light version CSS
# We'll replace the CSS :root variables
css_root_pattern = r':root\{.*?--radius-lg:12px;\n\}'
light_css = """:root{
  --bg:#f8fafc; --surface:#ffffff; --surface-2:#f1f5f9; --surface-3:#e2e8f0;
  --border:#e2e8f0; --border-hi:#cbd5e1;
  --text:#0f172a; --text-muted:#475569; --text-faint:#64748b;
  --green:#16a34a; --yellow:#d97706; --orange:#ea580c; --red:#dc2626;
  --accent:#0284c7; --accent-hover:#0369a1;
  --font-body:'Satoshi','Inter',sans-serif;
  --font-display:'Cabinet Grotesk','Satoshi',sans-serif;
  --ease:cubic-bezier(0.16,1,0.3,1);
  --radius-sm:4px;--radius-md:8px;--radius-lg:12px;
}"""
html = re.sub(css_root_pattern, light_css, html, flags=re.DOTALL)

# Some specific text colors were hardcoded to #fff or #000
html = html.replace('color:#fff', 'color:var(--text)')
html = html.replace('fill="#fff"', 'fill="var(--text)"')
html = html.replace('fill="#000"', 'fill="var(--surface)"')
html = html.replace('stroke="#0e0e0e"', 'stroke="var(--surface)"')
html = html.replace('color:rgba(255,255,255,.5)', 'color:var(--text-faint)')
html = html.replace('color:rgba(255,255,255,.55)', 'color:var(--text-faint)')

# 4. "MBTI Recommendation" change
html = html.replace('MBTI Recommendation', 'How My MBTI Fits This Role')

# 5. Remove "Startup Preparation" and change to "Finding Sifu"
html = html.replace('Startup Readiness', 'Finding Sifu')
html = html.replace('How naturally this market supports private dining, cloud kitchen, or consulting pivots.', 'Availability of traditional masters and culinary mentors for direct lineage and skill transfer.')
html = html.replace("{title:'Startup Preparation',desc:'Cloud kitchen, private dining, meal prep, consulting, SOP packaging'}", "{title:'Finding Sifu (Master-Apprentice)',desc:'Connect with traditional masters and culinary mentors for direct lineage and skill transfer.'}")


# Export new file
now = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
output_filename = f"career_data_exports/GeminiPro_LightVersion_{now}.html"

with open(output_filename, 'w', encoding='utf-8') as f:
    f.write(html)

print(output_filename)
