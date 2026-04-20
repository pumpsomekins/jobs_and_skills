import re
import datetime

input_file = "career_data_exports/GeminiPro_20260419_220242.html"

with open(input_file, 'r', encoding='utf-8') as f:
    html = f.read()

# 1. Update calcLTV
old_calcLTV_match = re.search(r'function calcLTV\(c\)\{.*?return \{ ltv, safe, risk, carCount, safeCarCount, riskCarCount, safeYears, totalWorkYears \};\n\}', html, re.DOTALL)
if old_calcLTV_match:
    old_calcLTV = old_calcLTV_match.group(0)
    new_calcLTV = """function calcLTV(c){
      const mults = [0.6, 0.9, 1.1, 1.5, 2.2];
      const mult = mults[currentLevel] || 1;
      const careerYrs = 60; // projection to death (approx 60 years working/living)
      const ltvUSD = c.annualUSD * mult * careerYrs;
      const ltvLocal = c.annualLocal * mult * careerYrs;
      const safeLocal = Math.round(ltvLocal * (1 - c.automationIdx/100));
      const riskLocal = ltvLocal - safeLocal;
      const safeUSD = Math.round(ltvUSD * (1 - c.automationIdx/100));

      const carCount = Math.round(ltvUSD / c.carPriceUSD);
      const safeCarCount = Math.round(safeUSD / c.carPriceUSD);
      const riskCarCount = carCount - safeCarCount;
      const safeYears = c.riskAge - c.startAge;
      const totalWorkYears = careerYrs;
      return { ltv:ltvLocal, safe:safeLocal, risk:riskLocal, carCount, safeCarCount, riskCarCount, safeYears, totalWorkYears };
    }"""
    html = html.replace(old_calcLTV, new_calcLTV)

# 2. Update level click listener to also re-render LTV (renderCountryFull instead of just chart/promo)
html = re.sub(
    r'currentLevel=parseInt\(tab\.dataset\.level\)\|\|0;\n\s*renderPromoFlow\(currentCountry\);\n\s*renderIncomeChart\(currentCountry\);',
    'currentLevel=parseInt(tab.dataset.level)||0;\n  renderCountryFull(currentCountry);',
    html
)

# 3. Income projection charting
old_buildPts_match = re.search(r'function buildIncomePoints\(country\)\{.*?return pts;\n\}', html, re.DOTALL)
if old_buildPts_match:
    old_buildPts = old_buildPts_match.group(0)
    new_buildPts = """function buildIncomePoints(country){
      const salaries=LEVEL_USD[country]||LEVEL_USD.US;
      const transitions=[0,2,5,8,16];
      const pts=[];
      const deathYear=60;
      // standard ladder
      for(let yr=0;yr<=deathYear;yr++){
        let lvl=0;
        for(let i=transitions.length-1;i>=0;i--){if(yr>=transitions[i]){lvl=i;break;}}
        const nextTrans=transitions[lvl+1]||deathYear;
        const frac=lvl<4?(yr-transitions[lvl])/(nextTrans-transitions[lvl]):1;
        const baseSal=salaries[lvl];
        const nextSal=lvl<4?salaries[lvl+1]:salaries[4]*1.15;
        const sal=baseSal+(nextSal-baseSal)*frac*0.4;
        pts.push({yr,sal,lvl,type:'ladder'});
      }
      // stagnant at current level
      const curBaseSal = salaries[currentLevel] || salaries[0];
      for(let yr=0;yr<=deathYear;yr++){
        const sal = curBaseSal * Math.pow(1.005, yr);
        pts.push({yr,sal,lvl:currentLevel,type:'stagnant'});
      }
      return pts;
    }"""
    html = html.replace(old_buildPts, new_buildPts)

old_renderChart_match = re.search(r'function renderIncomeChart\(country\)\{.*?document\.getElementById\(\'chartCountryLabel\'\)\.textContent=COUNTRY_NAMES\[country\]\|\|country;\n\}', html, re.DOTALL)
if old_renderChart_match:
    old_renderChart = old_renderChart_match.group(0)
    new_renderChart = """function renderIncomeChart(country){
      const svg=document.getElementById('incomeSVG');
      if(!svg)return;
      const pts=buildIncomePoints(country);
      const W=900,H=220,padL=55,padR=20,padT=20,padB=35;
      const cW=W-padL-padR,cH=H-padT-padB;
      const maxSal=Math.max(...pts.map(p=>p.sal))*1.1;
      const minSal=Math.min(...pts.map(p=>p.sal))*0.8;
      const xOf=yr=>padL+(yr/60)*cW;
      const yOf=sal=>padT+cH-((sal-minSal)/(maxSal-minSal))*cH;
      let html='';
      for(let g=0;g<=4;g++){
        const y=padT+(g/4)*cH;
        const val=Math.round(maxSal-(g/4)*(maxSal-minSal));
        html+=`<line x1="${padL}" y1="${y}" x2="${W-padR}" y2="${y}" stroke="var(--border-hi)" stroke-width="1"/>`;
        html+=`<text x="${padL-5}" y="${y+4}" text-anchor="end" fill="var(--text-faint)" font-size="10">${val>=1000?'$'+(val/1000).toFixed(0)+'K':val}</text>`;
      }
      [0,10,20,30,40,50,60].forEach(yr=>{
        html+=`<text x="${xOf(yr)}" y="${H-5}" text-anchor="middle" fill="var(--text-faint)" font-size="10">${yr===60?'Death':yr}</text>`;
      });
      // ladder path
      const ladderPts = pts.filter(p=>p.type==='ladder');
      let dLad='';
      ladderPts.forEach((p,i)=>{dLad+=(i===0?'M':'L')+xOf(p.yr).toFixed(1)+','+yOf(p.sal).toFixed(1);});
      html+=`<path d="${dLad}" fill="none" stroke="var(--text-muted)" stroke-width="1.5" stroke-dasharray="4,4" opacity="0.6"/>`;
      // stagnant path
      const stagPts = pts.filter(p=>p.type==='stagnant');
      let dStag='';
      stagPts.forEach((p,i)=>{dStag+=(i===0?'M':'L')+xOf(p.yr).toFixed(1)+','+yOf(p.sal).toFixed(1);});
      html+=`<path d="${dStag}" fill="none" stroke="${LEVELS[currentLevel].color}" stroke-width="3"/>`;

      const transYears=[0,2,5,8,16,60];
      transYears.forEach(yr=>{
        const p=ladderPts.find(pp=>pp.yr===yr);
        if(!p)return;
        html+=`<circle cx="${xOf(p.yr)}" cy="${yOf(p.sal)}" r="5" fill="${LEVELS[p.lvl].color}" stroke="var(--surface)" stroke-width="2"/>`;
      });
      svg.innerHTML=html;
      document.getElementById('chartCountryLabel').textContent=COUNTRY_NAMES[country]||country;
    }"""
    html = html.replace(old_renderChart, new_renderChart)

html = html.replace('30 yrs ·', 'Lifetime (60 yrs) ·')
html = html.replace('30 yrs at current trajectory', 'To death (60 yrs) at current role')

# 4. Light theme CSS
css_vars = r':root\{.*?--radius-lg:12px;\n\}'
light_vars = """:root{
  --bg:#f8fafc;--surface:#ffffff;--surface-2:#f1f5f9;--surface-3:#e2e8f0;
  --border:#e2e8f0;--border-hi:#cbd5e1;
  --text:#0f172a;--text-muted:#475569;--text-faint:#64748b;
  --green:#16a34a;--yellow:#d97706;--orange:#ea580c;--red:#dc2626;
  --accent:#0ea5e9;--accent-hover:#0284c7;
  --font-body:'Satoshi','Inter',sans-serif;
  --font-display:'Cabinet Grotesk','Satoshi',sans-serif;
  --ease:cubic-bezier(0.16,1,0.3,1);
  --radius-sm:4px;--radius-md:8px;--radius-lg:12px;
}"""
html = re.sub(css_vars, light_vars, html, flags=re.DOTALL)

html = html.replace('color:#fff', 'color:var(--text)')
html = html.replace('fill="#fff"', 'fill="var(--text)"')
html = html.replace('fill="#000"', 'fill="var(--surface)"')
html = html.replace('stroke="#0e0e0e"', 'stroke="var(--surface)"')
html = html.replace('color:rgba(255,255,255,.5)', 'color:var(--text-faint)')
html = html.replace('color:rgba(255,255,255,.55)', 'color:var(--text-faint)')

# 5. Text replacements
html = html.replace('MBTI Recommendation', 'How does my MBTI fit this job')

# 6. Startup to Sifu
html = html.replace('Startup Readiness', 'Finding Sifu')
html = html.replace('How naturally this market supports private dining, cloud kitchen, or consulting pivots.', 'Availability of traditional masters and culinary mentors for direct lineage and skill transfer.')
html = html.replace("{title:'Startup Preparation',desc:'Cloud kitchen, private dining, meal prep, consulting, SOP packaging'}", "{title:'Finding Sifu',desc:'Connect with traditional masters and culinary mentors for direct lineage and skill transfer.'}")

html = html.replace('30 yrs · $56K/yr median', 'Lifetime (60 yrs)')

now = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
output_filename = f"career_data_exports/GeminiPro_LightVersion_{now}.html"
with open(output_filename, "w", encoding="utf-8") as f:
    f.write(html)
print(output_filename)
