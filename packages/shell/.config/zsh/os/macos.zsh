# macOS-specific settings

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# macOS aliases
alias o="open"
alias finder="open -a Finder"

# Use GNU tools if installed
for tool in coreutils findutils gnu-sed grep; do
  [[ -d "/opt/homebrew/opt/$tool/libexec/gnubin" ]] && \
    PATH="/opt/homebrew/opt/$tool/libexec/gnubin:$PATH"
done
