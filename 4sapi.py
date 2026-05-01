import openai

api_key = "sk-eO6YaNyvsoXPlU9plEDi57MaQMF9RxZle2Y9XhsfH07HoFpc"          # 你的 key
base_url = "https://4sapi.com/v1"

client = openai.OpenAI(api_key=api_key, base_url=base_url)

model_list = ["gemini-2.5-flash"]           # 请替换为你能用的真实模型名

# ========== 原先的单轮测试 ==========
prompt = "你写一首唐诗好不好"
for model_name in model_list:
    print(f"--- 测试模型: {model_name} ---")
    try:
        response = client.chat.completions.create(
            model=model_name,
            messages=[{"role": "user", "content": prompt}],
            temperature=0,
            max_tokens=10000
        )
        print(response.choices[0].message.content)
    except Exception as e:
        print(f"调用模型 {model_name} 时出错: {e}")
    print("\n")

# ========== 新增：测试历史对话继续 ==========
print("===== 测试多轮对话记忆 =====")
history_messages = [
    {"role": "user", "content": "我叫小明，今天天气真好，请记住我的名字。"}
]

for model_name in model_list:
    print(f"--- 多轮测试模型: {model_name} ---")
    try:
        # 第一轮
        resp1 = client.chat.completions.create(
            model=model_name,
            messages=history_messages,
            temperature=0,
            max_tokens=1000
        )
        reply1 = resp1.choices[0].message.content
        print("第一轮回复:", reply1)

        # 把助手回复加入历史
        history_messages.append({"role": "assistant", "content": reply1})

        # 第二轮：询问名字
        history_messages.append({"role": "user", "content": "请问我刚才告诉你我叫什么名字？"})
        resp2 = client.chat.completions.create(
            model=model_name,
            messages=history_messages,
            temperature=0,
            max_tokens=1000
        )
        reply2 = resp2.choices[0].message.content
        print("第二轮回复:", reply2)

        # 判断是否记住（简单字符检查）
        if "小明" in reply2:
            print("✅ 支持历史对话继续：模型记住了名字")
        else:
            print("❌ 可能不支持历史对话：未找到名字信息")

    except Exception as e:
        print(f"多轮测试模型 {model_name} 时出错: {e}")
    print("\n")