ZSHRC_FILE="$HOME/.zshrc"

# COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m'

echo "\n${YELLOW}Setting up this new computer!!${NC}"

# Install ohmyzsh
echo "\n- ${GREEN}ohmyzsh${NC}"
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "  Already installed!"
else
  echo "  ${YELLOW}Installing ohmyzsh...${NC}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install NVM
echo "\n- ${GREEN}NVM${NC}"
if [ -d "${HOME}/.nvm/.git" ]; then
    echo "  Already installed!"
else
    echo "  ${YELLOW}Installing NVM...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

# Install pnpm
echo "\n- ${GREEN}pnpm${NC}"
if command -v pnpm &> /dev/null; then
    echo "  Already installed!"
else
    echo "  ${YELLOW}Installing pnpm...${NC}"
    curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

# Installing homebrew
echo "\n- ${GREEN}homebrew${NC}"
if command -v brew &> /dev/null; then
    echo "  Already installed!"
else
    echo "  ${YELLOW}Installing homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Installing bat
echo "\n- ${GREEN}bat${NC}"
if command -v bat &> /dev/null; then
    echo "  Already installed!"
else
  # Installing bat
  echo "  ${YELLOW}Installing bat through homebrew...${NC}"
  brew install bat
fi

# Installing fzf
echo "\n- ${GREEN}fzf${NC}"
if command -v fzf &> /dev/null; then
    echo "  Already installed!"
else
  # Installing fzf
  echo "  ${YELLOW}Installing fzf through homebrew...${NC}"
  brew install fzf
fi

FZF_SOURCE_LINE="source <(fzf --zsh)"
if ! grep -qxF "$FZF_SOURCE_LINE" "$ZSHRC_FILE"; then
  # If the line does not exist, append it
  echo "  $FZF_SOURCE_LINE" >> "$ZSHRC_FILE"
  echo "  Added the setup line for ${GREEN}fzf${NC} to $ZSHRC_FILE"
else
  echo "  The setup line for ${GREEN}fzf${NC} already exists in ${CYAN}$ZSHRC_FILE${NC}"
fi

# Installing diff-so-fancy
echo "\n- ${GREEN}diff-so-fancy${NC}"
if command -v diff-so-fancy &> /dev/null; then
    echo "  Already installed..."
else
  # Installing diff-so-fancy
  echo "  ${YELLOW}Installing diff-so-fancy through homebrew...${NC}"
  brew install diff-so-fancy
  echo "  Configuring git to use diff-so-fancy..."
  git config --global core.pager "diff-so-fancy | less --tabs=4 -RF"
  git config --global interactive.diffFilter "diff-so-fancy --patch"
fi

echo "\n${YELLOW}Updating shell...${NC}"
source ~/.zshrc

echo "\n${GREEN}Git${NC}"
if [ -d "$HOME/Projects" ]; then
  echo "  Git folder already exists!"
else
  echo "  ${YELLOW}Creating ~/Projects folder...${NC}"
  mkdir -p "$HOME/Projects"
fi

echo "  \n${YELLOW}Configuring git...${NC}"
git config --global user.name "Enrique Ramírez"
git config --global user.email "hello@enriqueramirez.com"
git config --global core.editor "cursor --wait"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.cm "commit"
git config --global alias.st "status"
git config --global alias.df "diff"
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
git config --global alias.ll "log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"

echo "\n--------------------------------"
echo "\n${GREEN}Done!${NC}\nEnjoy your new setup!\n"

# read -p "${YELLOW}Do you want to update OSX software now? (y/n):${NC}" yn
# case $yn in
#     [Yy]* ) echo "  Updating OSX software..."; break;;
#     [Nn]* ) echo "  Exiting..."; exit;;
#     * ) echo "${RED}Invalid response${NC}. Please answer ${CYAN}'y'${NC} or ${CYAN}'n'${NC}.";;
# esac

# softwareupdate -i -a;
