# Starship init
Invoke-Expression (&starship init powershell)

# Aliases
Set-Alias vim nvim
Set-Alias ll ls

# --- GenAI CLI Function ---
# 使用法: 
#   genai "質問内容"
#   Get-Content note.md | genai "これを要約して"
# --- GenAI CLI Function ---
function genai {
    # 呼び出し先のファイル名を genai.py に変更
    $scriptPath = "$HOME\dotfiles\scripts\genai.py"
    
    $data = @($input)

    if ($data.Count -gt 0) {
        $data | python $scriptPath $args
    } else {
        python $scriptPath $args
    }
}

# --- Environment Variables ---
# APIキーを設定 (セキュリティのため、実際はここには書かず、Windowsの環境変数設定画面で設定することを推奨しますが、
# 手軽に試すなら以下のように記述します)
# $env:GOOGLE_API_KEY = "ここにAPIキーを入れる"