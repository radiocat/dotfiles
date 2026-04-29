import os
import sys
from google import genai
import argparse

# 文字化け防止
sys.stdin.reconfigure(encoding='utf-8')
sys.stdout.reconfigure(encoding='utf-8')

def get_best_model(client):
    """
    APIから利用可能なモデル一覧を取得し、最適なモデル名を自動で返します。
    優先順位:
    1. 'gemini' かつ 'flash' を含むモデル (新しい順)
    2. 'gemini' を含むその他のモデル (新しい順)
    """
    try:
        # ページネーション対応で全モデルを取得
        all_models = list(client.models.list(config={'page_size': 100}))
    except Exception as e:
        print(f"Error listing models: {e}", file=sys.stderr)
        sys.exit(1)

    # フィルタリング条件: 名前が 'gemini' を含み、'embedding' (埋め込み用) を含まない
    candidates = [
        m for m in all_models 
        if "gemini" in m.name.lower() 
        and "embedding" not in m.name.lower()
    ]

    if not candidates:
        print("Error: No Gemini models found available for your API key.", file=sys.stderr)
        sys.exit(1)

    # 戦略1: Flashモデルを優先 (CLIでの応答速度重視)
    flash_models = [m for m in candidates if "flash" in m.name.lower()]
    
    # モデルリストをソート (名前の降順)
    # これにより 'gemini-2.0' > 'gemini-1.5' のように新しいバージョンが先頭に来ることを期待
    # また 'latest' が付くエイリアスも辞書順で上位に来やすい
    target_list = flash_models if flash_models else candidates
    target_list.sort(key=lambda x: x.name, reverse=True)

    best_model = target_list[0].name
    return best_model

def main():
    api_key = os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        print("Error: GOOGLE_API_KEY is not set.", file=sys.stderr)
        sys.exit(1)

    try:
        client = genai.Client(api_key=api_key)
    except Exception as e:
        print(f"Error initializing Client: {e}", file=sys.stderr)
        sys.exit(1)

    parser = argparse.ArgumentParser()
    parser.add_argument("prompt", nargs="*", help="Prompt")
    parser.add_argument("--verbose", "-v", action="store_true", help="Show selected model name")
    args = parser.parse_args()

    user_input = ""
    if not sys.stdin.isatty():
        user_input += sys.stdin.read() + "\n"
    if args.prompt:
        user_input += " ".join(args.prompt)

    if not user_input.strip():
        print("Usage: gemini 'prompt' OR 'echo input | gemini'", file=sys.stderr)
        sys.exit(0)

    try:
        # 最適なモデルを動的に解決
        model_name = get_best_model(client)
        
        if args.verbose:
            print(f"Debug: Selected model -> {model_name}", file=sys.stderr)

        # 生成実行
        response = client.models.generate_content(
            model=model_name, 
            contents=user_input
        )
        print(response.text)

    except Exception as e:
        print(f"Error calling Gemini API: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()