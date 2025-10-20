# ~/.zprofile
# Loaded for LOGIN shells only

clear

# ------------------------------------------------------------
# Greeting messages
# ------------------------------------------------------------
greeting_matrix=$'Welcome, Keil. 🐇 The terminal has been expecting you.\nInitializing caffeine levels... ☕️\nBe not afraid. The shell loves you.'
greeting_brain=$'Welcome, Keil.🐀 🐀 What are we doing tonight?\nThe same thing we do every night.\nTrying to take over the 🌎 world!'

# ------------------------------------------------------------
# Randomly choose one theme
# ------------------------------------------------------------
themes=("matrix" "pinky")
choice=$((RANDOM % 2))

if [[ $choice -eq 0 ]]; then
    echo -e "$greeting_matrix"
else
    echo -e "$greeting_brain"
fi

echo
echo "[🐀 & the 🧠] >> 💢 (ง'̀-'́)ง  <:3 )~~  <:3 )~~ 💢 (╯°□°）╯︵ ┻━┻  💥  'Narf!' "
echo

# ------------------------------------------------------------
# Homebrew setup
# ------------------------------------------------------------
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
