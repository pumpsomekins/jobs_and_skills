import datetime
import re

input_file = "career_data_exports/GeminiPro_20260419_220242.html"

with open(input_file, 'r', encoding='utf-8') as f:
    html = f.read()

# --- 1. Warm Tone Replacements ---
replacements = {
    "Job Automation Compatibility List": "Career Opportunity & Evolution Landscape",
    "Job Automation<br>Compatibility List": "Career Opportunity<br>& Evolution Landscape",
    "Subscribe to AI Threat Alerts": "Subscribe to Career Evolution Alerts",
    "automation risk changes": "technology & industry trends evolve",
    "Select Region — LTV &amp; Risk Age by Country": "Select Region — Career Value & Pivot Age",
    "Job Lifetime Value Analysis": "Lifetime Career Value & Growth Potential",
    "Career LTV": "Career Lifetime Value",
    "Human-Safe LTV": "Unique Human Value",
    "AI cannot replicate": "Irreplaceable human touch",
    "At-Risk LTV": "Tech-Assisted Value",
    "Threatened by AI": "Tasks enhanced by tech",
    "Automation Index": "Tech Synergy Index",
    "Peak Risk Age": "Career Pivot Milestone",
    "Safe window:": "Golden growth window:",
    "Safe (": "Human Core (",
    "At Risk (": "Tech-Assisted (",
    "Human-Safe —": "Human-Centric —",
    "At-Risk —": "Tech-Assisted —",
    "Safe earnings": "Human core value",
    "At-risk earnings": "Tech-assisted value",
    "Occupational Hazards": "Workplace Realities",
    "Survival Strategy": "Thriving Strategy",
    "Highest Threat": "Key Evolution Area",
    "AI Risk 加权": "技术协同加权",
    "AI 最难渗透的高价值节点": "展现独特人类创意和温度的黄金节点",
    "最脆弱节点": "最容易被技术赋能和优化的节点",
    "Replace Ratio": "Tech Synergy Ratio",
    "AI / Bot Workflow": "AI Synergy Workflow",
    "~10% at risk": "~10% tech-assisted",
    "~30% partial": "~30% tech synergy",
    "~20% partial": "~20% tech synergy",
    "~40% protected": "~40% uniquely human",
    "Automated": "Assisted",
    "To beat AI risk": "To leverage new tech trends",
    "Financial Value &amp; AI Risk": "Financial Value & Tech Synergy",
    "automation threshold age": "key pivot opportunity age",
    "Job Hardship": "Role Intensity",
    "AI Threat Alerts": "Career Growth Insights",
    "Risk Age": "Pivot Age",
    "LTV & Risk Age": "Value & Pivot Age",
    "At-Risk": "Tech-Assisted",
    "Human-Safe": "Human-Centric",
    "automation risk": "automation opportunity"
}
for old, new in replacements.items():
    html = html.replace(old, new)

# --- 2. New Requirements Implementation ---

# MBTI Input in Top Right
mbti_input = '''
      <div style="display:flex; flex-direction:column; gap:4px; align-items:flex-end;">
        <div style="font-size:9px; color:var(--text-faint); text-transform:uppercase; letter-spacing:0.05em">Personalize via MBTI</div>
        <input type="text" placeholder="ENTJ..." style="background:var(--surface); border:1px solid var(--border-hi); border-radius:4px; padding:4px 8px; font-size:11px; color:var(--text); width:70px; outline:none; text-align:center" id="mbtiInput">
      </div>
'''
html = html.replace('<div class="header-right">', f'<div class="header-right">{mbti_input}')

# Networking (Login to see)
old_network = """<div class="note-card">
        <div class="note-title">People to Network With (推荐认识的人)</div>
        <div class="note-value" style="font-size:14px">Michelin Execs & F&B Directors</div>
        <div class="note-meta">Connect with suppliers, specialized food critics, and affluent club managers.</div>
      </div>"""
new_network = """<div class="note-card">
        <div class="note-title">People to Network With (推荐认识的人)</div>
        <div class="note-value" style="font-size:14px; color:var(--text-faint)">Locked Content</div>
        <div class="note-meta">Please login to see exactly who you should make friends with to secure a better career path.</div>
      </div>"""
html = html.replace(old_network, new_network)

# Entrepreneurial Foundation (Renamed Startup Readiness)
html = html.replace("Startup Readiness", "Entrepreneurial Foundation")
html = html.replace("How naturally this market supports private dining, cloud kitchen, or consulting pivots.",
                    "Market baseline for food ventures. (Risk Note: 90% of food startups fail without deep SOP preparation. [View Requirements Guide](https://example.com/items-needed))")

# Skill Refinement Wording in Recommendations
html = html.replace("Similar Career Paths (Skill-based)", "Similar Career Paths (Refining your craft unlocks higher tiers)")

# Retirement & Education Capacity
extra_notes = """
      <div class="note-card">
        <div class="note-title">Elderly Care & Retirement (养老问题)</div>
        <div class="note-value" style="font-size:14px">Multi-Tier Strategy</div>
        <div class="note-meta">Capacity to care for parents and self depends on reaching 'Head Chef' tier by age 35. Corporate paths offer better pension stability.</div>
      </div>
      <div class="note-card">
        <div class="note-title">Private School & Heir Education (私校问题)</div>
        <div class="note-value" style="font-size:14px">Executive Tier Required</div>
        <div class="note-meta">Affording elite private schooling for yourself or children typically requires the Executive Chef or multi-outlet owner income level.</div>
      </div>
"""
html = html.replace('<!-- Education & Networking -->', extra_notes + '\n  <!-- Education & Networking -->')

# Sifu Link (Replacing Startup Preparation)
html = html.replace('<div class="link-card-title">Startup Preparation</div>', '<div class="link-card-title">Finding Sifu (Master-Apprentice)</div>')
html = html.replace('Cloud kitchen, private dining, meal prep, consulting, SOP packaging', 'Connect with traditional masters and culinary mentors for direct lineage and skill transfer.')

# Hall of Fame with Net Worth & Country Specific Titles
fame_old = """• Gordon Ramsay (Brand Icon)<br>
        • Wolfgang Puck (Commercial Lead)<br>
        • René Redzepi (Innovation Lead)<br>
        • David Chang (Media &amp; Product)"""
fame_new = """• Gordon Ramsay ($220M · Global Brand CEO)<br>
        • Wolfgang Puck ($120M · Catering Empire Lead)<br>
        • Jamie Oliver ($200M · Media & Restaurant Group)<br>
        • Nobu Matsuhisa ($50M · Luxury Fusion Founder)"""
html = html.replace(fame_old, fame_new)

# Tracker Applied Note
html = html.replace("My Application Tracker (Self-Apply)", "My Application Tracker (Applied Resumes - Login to View Full Details)")

# --- Save New File ---
now_str = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
output_filename = f"career_data_exports/GeminiPro_FinalReq_{now_str}.html"

with open(output_filename, 'w', encoding='utf-8') as f:
    f.write(html)

print(output_filename)
