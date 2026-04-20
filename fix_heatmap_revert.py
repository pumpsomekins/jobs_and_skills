import sys

with open('career_data_exports/GeminiPro_20260419_220242.html', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(
    '<div class="city-salary">${COUNTRIES[country].symbol || "$"}${salK}</div>',
    '<div class="city-salary">$${salK}</div>'
)

content = content.replace(
    'Avg. cook salary (local currency)',
    'Avg. cook salary (local equiv. USD)'
)

with open('career_data_exports/GeminiPro_20260419_220242.html', 'w', encoding='utf-8') as f:
    f.write(content)

