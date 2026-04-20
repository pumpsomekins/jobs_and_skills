import sys

with open('career_data_exports/GeminiPro_20260419_220242.html', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(
    '<div class="city-salary">$${salK}</div>',
    '<div class="city-salary">${COUNTRIES[country].symbol || "$"}${salK}</div>'
)

# And let's make sure the car viz text also gets the right symbol
# The original code had: `Based on $${c.carPriceUSD.toLocaleString('en-US')}/unit reference price`
content = content.replace(
    'Based on $${c.carPriceUSD.toLocaleString(\'en-US\')}/unit',
    'Based on $${c.carPriceUSD.toLocaleString(\'en-US\')} (USD)/unit'
)

# Replace the "Avg. cook salary (local equiv. USD)" in the heatmap header
content = content.replace(
    'Avg. cook salary (local equiv. USD)',
    'Avg. cook salary (local currency)'
)

with open('career_data_exports/GeminiPro_20260419_220242.html', 'w', encoding='utf-8') as f:
    f.write(content)

