import os
import sys
import google.generativeai as genai
import argparse

# 文字化け防止（Windows環境用）
sys.stdin.reconfigure(encoding='utf-8')
sys.stdout.reconfigure(encoding='utf-8')

def main():
    # APIキーの取得
    api_key = os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        print("Error: GOOGLE_API_KEY environment variable is not set.", file=sys.stderr)
        print("Please set it in your PowerShell profile: $env:GOOGLE_API_KEY='your_key'", file=sys.stderr)
        sys.exit(1)

    genai.configure(api_key=api_key)

    # 引数解析
    parser = argparse.ArgumentParser(description="Gemini CLI Tool")
    parser.add_argument("prompt", nargs="*", help="The prompt to send to Gemini")
    args = parser.parse_args()

    # プロンプトの構築
    user_input = ""
    
    # パイプ入力がある場合 (例: Get-Content file.txt | gemini)
    if not sys.stdin.isatty():
        user_input += sys.stdin.read() + "\n"
    
    # 引数がある場合 (例: gemini "Hello")
    if args.prompt:
        user_input += " ".join(args.prompt)

    if not user_input.strip():
        print("Usage: gemini 'Your prompt here' OR 'echo input | gemini'", file=sys.stderr)
        sys.exit(0)

    try:
        # モデル設定 (最新のFlashモデルを使用)
        model = genai.GenerativeModel('gemini-1.5-flash')
        response = model.generate_content(user_input)
        print(response.text)
    except Exception as e:
        print(f"Error calling Gemini API: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()