#!/bin/bash

# ==============================================================================
# 1. 区域：输入你的内容 + 自定义输出文件名
# 使用 'EOF' 确保其中的特殊字符不会被 bash 提前解析
# ==============================================================================
# 你的提问内容
read -r -d '' CONTENT << 'EOF'
我是开发者时间有先，一天只能学一个东西，帮我排下序第一是省成本第二是好用第三是好玩：【DeepSeek V4 CLI，SKILL（AI SKILL)，命中缓存(AI API USING CACHE HIT)，龙虾(OPENCLAW)，Hermes，我的世界AI，COZE，美国工作流，中转站，大模型生成成本对比】不需要解释和介绍


EOF

# 【新增】自定义输出文档名（支持txt/md等格式）
OUTPUT_FILE="deepseek回答.md"
# ==============================================================================

# 2. 区域：逻辑处理（无需修改）
# 建议：不要硬编码API_KEY！推荐在终端执行 export API_KEY="你的key" 后运行脚本
API_KEY="${API_KEY:-sk-3b227102823d48d499796908610a3e54}"

if [ -z "$CONTENT" ]; then
    echo "错误：CONTENT 为空，请在脚本的 CONTENT 中输入内容。"
    exit 1
fi

JSON_PAYLOAD=$(jq -n \
  --arg model "deepseek-v4-pro" \
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

# 3. 区域：执行请求 + 保存结果到文档
echo "正在请求 DeepSeek API..."
# 核心修改：用 tee 命令 同时输出到终端 + 写入文件
curl -s https://api.deepseek.com/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$JSON_PAYLOAD" | jq -r '.choices[0].message.content' | tee "$OUTPUT_FILE"

# 提示保存成功
echo -e "\n========================================"
echo "✅ 回答已保存到文档：$OUTPUT_FILE"
echo "========================================"