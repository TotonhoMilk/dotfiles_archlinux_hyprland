#!/usr/bin/env bash

# ===============================================================
# Pacotes para instalação
# ===============================================================
VIDEO_SOM=(pipewire pipewire-pulse pipewire-alsa wireplumber xdg-desktop-portal xdg-desktop-portal-hyprland)
HYPRLAND=(hyprland kitty ttf-font-awesome ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji hyprpaper hyprlock hypridle hyprshot)
QML=(qt6-base qt6-declarative qt6-svg qt6-wayland qt6-5compat qt6-imageformats quickshell)
UTILITARIOS=(brightnessctl playerctl pamixer networkmanager bluez bluez-utils grim slurp wl-clipboard)
THUNAR=(thunar thunar-archive-plugin thunar-volman gvfs gvfs-mtp gvfs-gphoto2 file-roller p7zip unrar unzip tumbler ffmpegthumbnailer poppler-glib freetype2 libgsf)
YAZI=(yazi fd ripgrep fzf zoxide imagemagick fontforge jq resvg ffmpeg)
NEOVIM=(neovim git curl nodejs npm python python-pip base-devel cmake lazygit ast-grep lua51 luarocks tectonic mermaid-cli ghostscript)
EXTRAS_HYPR=(hyprpolkitagent hyprlauncher hyprpwcenter hyprshutdown)
EXTRAS_SYSTEM=(waybar upower greetd greetd-tuigreet zsh zsh-syntax-highlighting zsh-autosuggestions firefox fastfetch mako libnotify lxappearance htop btop stow)

# ===============================================================
# Cores
# ===============================================================
BLINK='\033[5m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ===============================================================
# Funções de instalação e configuração
# ===============================================================
notices() {
  echo
  echo -e "${BLUE}=============================================================${NC}"
  echo -e "${GREEN}$1${NC}"
  echo -e "${BLUE}=============================================================${NC}"
}

confirmation() {
  echo
  local awnser
  while true; do
    read -r -p "$(echo -e "${YELLOW}$1 [S/n]: ${NC}")" awnser

    case "$awnser" in
    [sS] | "")
      return 0
      ;;
    [nN])
      return 1
      ;;
    *)
      echo -e "${RED}Opção inválida! Digite 's' para sim ou 'n' para não.${NC}"
      ;;
    esac
  done
}

internet_test() {
  echo
  echo -e "${GREEN} ==> Verificando a conexão com a internet"
  echo

  while ! ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; do
    echo -e "${RED} ==> Sem conexão com a internet!${NC}"

    if command -v nmtui &>/dev/null; then
      echo
      echo -e "${GREEN} ==> NetworkManager encontrado"
      echo -ne "${GREEN} ==> Iniciando o NetworkManager (nmtui)"
      sleep 1
      echo -n " ...1"
      sleep 1
      echo -n "...2"
      sleep 1
      echo -n "...3"
      sleep 1
      echo -n "  e..!${NC}"
      echo
      sleep 1

      nmtui

      if ! ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
        clear
        echo
        echo -e "${RED} ==> Não foi possível conectar à internet"
        if confirmation "\tDeseja tentar conectar novamente?"; then
          continue
        else
          clear
          notices "\tInstalação cancelada pelo usuário."
          exit 0
        fi
      fi

    else
      echo -e "${RED}\t==> O pacote networkmanager não foi encontrado."
      echo -e "${RED}\t==> Não é possível prosseguir."
      read -r -p "$(echo -e "${YELLOW}\tDigite qualquer tecla para sair. . .${NC}")" -n 1
      exit 1
    fi
  done

  echo
  echo -e "${GREEN}${BLINK} ==> Conexão com a internet confirmada!${NC}"
}

configure_yay() {
  if ! command -v yay &>/dev/null; then
    echo -e "${GREEN} ==> 'yay' não encontrado. Compilando e instalando. . .${NC}"

    # sudo pacman -S --needed --noconfirm base-devel git

    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay || exit
    makepkg -si --noconfirm
    cd - || exit
    rm -rf /tmp/yay
  fi

  echo
  echo -e "${GREEN} ==> 'yay' pronto para uso!${NC}"
}

update_pkg() {
  echo
  notices "\tAtualizando o sistema"
  sudo pacman -Syu --noconfirm
}

install_pkg() {
  sudo pacman -S --needed --noconfirm "$@"
}

yay_pkg() {
  yay -S --needed --noconfirm "$@"
}

configure_git() {
  local name
  local email

  echo -e "${RED} ==> ATENÇÃO: ${NC} Deverá ser informado seu nome e seu email para configuração do 'git'"
  echo

  while true; do
    read -r -p "$(echo -e "${GREEN} ==> Informe seu nome: ${NC}")" name
    read -r -p "$(echo -e "${GREEN} ==> Informe seu email: ${NC}")" email

    echo
    echo -e "${GREEN} ==> Seu nome: ${YELLOW}$name${NC}"
    echo -e "${GREEN} ==> Seu email: ${YELLOW}$email${NC}"
    echo

    if confirmation "\tSuas credenciais estão corretas?"; then
      git config --global user.name "$name"
      git config --global user.email "$email"

      echo
      echo -e "${GREEN} ==> Credenciais do Git configuradas com sucesso!${NC}"

      break
    else
      if confirmation "\tDeseja tentar novamente?"; then
        continue
      else
        clear
        notices "\tInstalação cancelada pelo usuário."
        exit 0
      fi
    fi
  done

  if [ ! -d "$HOME/.dotfiles" ]; then
    git clone https://github.com/TotonhoMilk/dotfiles_archlinux_hyprland.git ~/.dotfiles
  else
    echo -e "${RED} ==> O diretório ~/.dotfiles já existe${NC}"
    echo -e "${GREEN} ==> Atualizando o repositório${NC}"
    git -C ~/.dotfiles pull
  fi
}

configure_greetd() {
  chmod 755 $HOME
  chmod 755 $HOME/.dotfiles
  sudo usermod -aG video,render greeter

  if [ -f /etc/greetd/config.toml ]; then
    sudo mv /etc/greetd/config.toml /etc/greetd/config.toml.bak
  fi

  sudo mkdir -p /var/cache/tuigreet
  sudo shown -R greeter:greeter /var/cache/tuigreet

  cd "$HOME/.dotfiles" || exit 1
  sudo stow -t / greetd
  sudo systemctl enable greetd.service
}

configure_zsh() {
  if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
  fi

  if [ -f "$HOME/.zshrc" ] || [ -L "$HOME/.zshrc" ]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
  fi

  cd "$HOME/.dotfiles" || exit 1
  stow zsh
}

configure_p10k() {
  yay_pkg "zsh-theme-powerlevel10k-git"

  if [ -f "$HOME/.p10k.zsh" ] || [ -L "$HOME/.p10k.zsh" ]; then
    mv "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.bak"
  fi

  cd "$HOME/.dotfiles" || exit 1
  stow p10k
}

configure_hyprland() {
  if [ -d "$HOME/.config/hypr/" ] || [ -L "$HOME/.config/hypr" ]; then
    rm -rf "$HOME/.config/hypr"
  fi

  cd "$HOME/.dotfiles" || exit 1
  stow hypr
}

configure_waybar() {
  if [ -d "$HOME/.config/waybar" ] || [ -L "$HOME/.config/waybar" ]; then
    rm -rf "$HOME/.config/waybar"
  fi

  cd "$HOME/.dotfiles" || exit 1
  stow waybar
}

configure_kitty() {
  if [ -d "$HOME/.config/kitty" ] || [ -L "$HOME/.config/kitty" ]; then
    rm -rf "$HOME/.config/kitty"
  fi

  cd "$HOME/.dotfiles" || exit 1
  stow kitty
}
# ===============================================================
# Execução do script
# ===============================================================
clear
notices "\tSua senha de root poderá ser solicitada. . ."

internet_test

if confirmation "\tDeseja prosseguir com a instalação?"; then
  clear

  notices "\tIniciando o processo de instalação"
  echo
  sudo -v
  clear

  update_pkg

  notices "\tInstalando Stackbase de vídeo e som"
  install_pkg "${VIDEO_SOM[@]}"

  notices "\tIntalando os componentes básicos do Hyperland"
  install_pkg "${HYPRLAND[@]}"

  notices "\tInstalando o QuickShell e componentes do QT6"
  install_pkg "${QML[@]}"

  notices "\tInstalando utilitários do sistema"
  install_pkg "${UTILITARIOS[@]}"

  notices "\tInstalando Gerenciador de arquivos"
  install_pkg "${THUNAR[@]}"

  notices "\tInstalando Gerenciador de Arquivos em Terminal"
  install_pkg "${YAZI[@]}"

  notices "\tInstalando o Neovim"
  install_pkg "${NEOVIM[@]}"

  notices "\tInstalando componentes extras do Hyprland"
  install_pkg "${EXTRAS_HYPR[@]}"

  notices "\tInstalando componentes extras do sistema"
  install_pkg "${EXTRAS_SYSTEM[@]}"

  notices "\tConfigurando o Git e baixando arquivos"
  configure_git

  notices "\tInstalando e configurando 'yay'"
  configure_yay

  notices "\tConfigurando o ZSH"
  configure_zsh

  notices "\tInstalando PowerLevel10K"
  configure_p10k

  notices "\tConfigurando o Greetd"
  configure_greetd

  notices "\tConfigurando o Hyprland"
  configure_hyprland

  notices "\tConfigurando a Waybar"
  configure_waybar

  notices "\tConfigurando a Kitty"
  configure_kitty

  notices "\tInstalação concluída com sucesso!"
else
  clear
  notices "\tInstalação cancelada pelo usuário."
  exit 0
fi
