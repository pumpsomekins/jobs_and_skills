#!/bin/bash

# 配置你的 API Key
API_KEY="sk-3b227102823d48d499796908610a3e54"
BASE_URL="https://api.deepseek.com/chat/completions"

# 检查输入
if [ -z "$1" ]; then
    echo "使用方法: ./deepseek.sh '你的问题'"
    exit 1
fi

# 调用 API
curl -s $BASE_URL \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "{
        \"model\": \"deepseek-v4-flash\",
        \"messages\": [
          {\"role\": \"user\", \"content\": \"$1\"}
        ],
        \"stream\": false
      }" | jq -r '.choices[0].message.content'