import datetime
import re

input_file = "career_data_exports/GeminiPro_WarmTone_20260419_223111.html"

with open(input_file, 'r', encoding='utf-8') as f:
    html = f.read()

# --- 1. Top Right MBTI Input ---
# Locate header-right and prepend MBTI input
mbti_input = '''
      <div style="display:flex; flex-direction:column; gap:4px; align-items:flex-end;">
        <div style="font-size:9px; color:var(--text-faint); text-transform:uppercase; letter-spacing:0.05em">Personalize via MBTI</div>
        <input type="text" placeholder="ENTJ..." style="background:var(--surface); border:1px solid var(--border-hi); border-radius:4px; padding:4px 8px; font-size:11px; color:var(--text); width:70px; outline:none; text-align:center" id="mbtiInput">
      </div>
'''
html = html.replace('<div class="header-right">', f'<div class="header-right">{mbti_input}')

# --- 2. Networking (推荐认识的人) ---
# Replace content to "Login to see..."
old_network_html = """<div class="note-card">
        <div class="note-title">People to Network With (推荐认识的人)</div>
        <div class="note-value" style="font-size:14px">Michelin Execs & F&B Directors</div>
        <div class="note-meta">Connect with suppliers, specialized food critics, and affluent club managers.</div>
      </div>"""
new_network_html = """<div class="note-card">
        <div class="note-title">People to Network With (推荐认识的人)</div>
        <div class="note-value" style="font-size:14px; color:var(--text-faint)">Locked Content</div>
        <div class="note-meta">Please login to see exactly who you should make friends with to secure a better career path.</div>
      </div>"""
html = html.replace(old_network_html, new_network_html)

# --- 3. Startup -> Entrepreneurial Foundation ---
html = html.replace("Startup Readiness", "Entrepreneurial Foundation")
html = html.replace("How naturally this market supports private dining, cloud kitchen, or consulting pivots.",
                    "Market baseline for food ventures. (Risk Note: 90% of food startups fail without deep SOP preparation. [View Requirements Guide](https://example.com/items-needed))")

# --- 4. Career Recommendations ---
# Add "Potential expands as you refine your craft"
html = html.replace("Similar Career Paths (Skill-based)", "Similar Career Paths (Refining your craft unlocks higher tiers)")

# --- 5. Retirement & Private School ---
# Add these to the notes grid
retirement_html = """
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
# Find notes-grid closing and inject
html = html.replace('<!-- Education & Networking -->', retirement_html + '\n  <!-- Education & Networking -->')

# --- 6. Access Links: Remove Startup, Add Sifu (拜师) ---
html = html.replace('<div class="link-card-title">Startup Preparation</div>', '<div class="link-card-title">Finding Sifu (Master-Apprentice)</div>')
html = html.replace('Cloud kitchen, private dining, meal prep, consulting, SOP packaging', 'Connect with traditional masters and culinary mentors for direct lineage and skill transfer.')

# --- 7. MBTI Recommendation: Delete from Grid ---
# The previous code had it in note-grid, let's find and remove it if it exists.
# Based on the previous output, it was in a card.
mbti_card_regex = r'<div class="note-card">\s*<div class="note-title">MBTI Recommendation</div>.*?</div>\s*</div>'
html = re.sub(mbti_card_regex, '', html, flags=re.DOTALL)

# --- 8. Hall of Fame with Net Worth ---
# Update names/worth
fame_old = """• Gordon Ramsay (Brand Icon)<br>
        • Wolfgang Puck (Commercial Lead)<br>
        • René Redzepi (Innovation Lead)<br>
        • David Chang (Media &amp; Product)"""
fame_new = """• Gordon Ramsay ($220M · Global Brand CEO)<br>
        • Wolfgang Puck ($120M · Catering Empire Lead)<br>
        • Jamie Oliver ($200M · Media & Restaurant Group)<br>
        • Nobu Matsuhisa ($50M · Luxury Fusion Founder)"""
html = html.replace(fame_old, fame_new)

# --- 9. User Resume Applied Note ---
html = html.replace("My Application Tracker (Self-Apply)", "My Application Tracker (Applied Resumes - Login to View Full Details)")

# Final naming and save
now_str = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
output_filename = f"career_data_exports/GeminiPro_NewReq_{now_str}.html"

with open(output_filename, 'w', encoding='utf-8') as f:
    f.write(html)

print(output_filename)
