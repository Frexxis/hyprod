# Add local/bin to PATH for CLI tools (claude, lazygit, etc.)
set -gx PATH ~/.local/bin $PATH

# Dynamically add NVM bin to PATH if NVM is installed
# This works with any NVM version
if test -d ~/.local/share/nvm
    # Find the latest Node version directory
    set nvm_latest (ls -1 ~/.local/share/nvm/ 2>/dev/null | grep '^v' | sort -V | tail -1)

    if test -n "$nvm_latest" && test -d ~/.local/share/nvm/$nvm_latest/bin
        set -gx PATH ~/.local/share/nvm/$nvm_latest/bin $PATH
    end
end
