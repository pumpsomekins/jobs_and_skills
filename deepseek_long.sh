#!/bin/bash

# ==============================================================================
# 1. 区域：输入你的内容
# 使用 'EOF' 确保其中的特殊字符不会被 bash 提前解析
# ==============================================================================
read -r -d '' CONTENT << 'EOF'
在干嘛
EOF
# ==============================================================================

# 2. 区域：逻辑处理（无需修改）
API_KEY="sk-3b227102823d48d499796908610a3e54" # 确保已通过 export 设置

if [ -z "$CONTENT" ]; then
    echo "错误：CONTENT 为空，请在脚本的 CONTENT_AREA 中输入内容。"
    exit 1
fi

JSON_PAYLOAD=$(jq -n \
  --arg model "deepseek-chat" \
  --arg system "完成要求规定的任务。" \
  --arg user "$CONTENT" \
  '{
    model: $model,
    messages: [
      {role: "system", content: $system},
      {role: "user", content: $user}
    ],
    stream: false
  }')

# 3. 区域：执行请求
curl -s https://api.deepseek.com/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$JSON_PAYLOAD" | jq -r '.choices[0].message.content'