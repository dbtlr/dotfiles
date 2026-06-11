# macOS-specific settings

# macOS aliases
alias o="open"
alias finder="open -a Finder"

# Use GNU tools if installed
for tool in coreutils findutils gnu-sed grep; do
  [[ -d "/opt/homebrew/opt/$tool/libexec/gnubin" ]] && \
    PATH="/opt/homebrew/opt/$tool/libexec/gnubin:$PATH"
done
