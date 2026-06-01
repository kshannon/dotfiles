# ~/.zprofile
# Loaded for LOGIN shells only

clear
echo "Welcome, Keil. Be not afraid. The shell loves you."

# ------------------------------------------------------------
# Homebrew setup
# ------------------------------------------------------------
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
