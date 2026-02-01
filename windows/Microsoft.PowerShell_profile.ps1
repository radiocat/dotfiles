# Starship init
Invoke-Expression (&starship init powershell)

# Aliases
Set-Alias vim nvim
Set-Alias ll ls

# --- Gemini CLI Function ---
# 使用法: 
#   gemini "質問内容"
#   Get-Content note.md | gemini "これを要約して"
function gemini {
    $scriptPath = "$HOME\dotfiles\scripts\gemini.py"
    # Pythonスクリプトに引数とパイプ入力を渡す
    if ($input.MoveNext()) {
        $input.Reset()
        $input | python $scriptPath $args
    } else {
        python $scriptPath $args
    }
}

# --- Environment Variables ---
# APIキーを設定 (セキュリティのため、実際はここには書かず、Windowsの環境変数設定画面で設定することを推奨しますが、
# 手軽に試すなら以下のように記述します)
# $env:GOOGLE_API_KEY = "ここにAPIキーを入れる"