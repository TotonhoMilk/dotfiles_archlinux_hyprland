#!/usr/bin/env bash

# ===============================================================
#         ░█░█░█░█░█▀█░█▀▄░▀█▀░█▀█░█▀▀░▀█▀░█▀█░█░░░█░░
#         ░█▀█░░█░░█▀▀░█▀▄░░█░░█░█░▀▀█░░█░░█▀█░█░░░█░░
#         ░▀░▀░░▀░░▀░░░▀░▀░▀▀▀░▀░▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀▀
# ===============================================================

START_TIME=$(date +%s)

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

exit_script() {
  local END_TIME=$(date +%s)
  local ELAPSED=$((END_TIME - START_TIME))

  local HORAS=$((ELAPSED / 3600))
  local MINUTOS=$(((ELAPSED % 3600) / 60))
  local SEGUNDOS=$((ELAPSED % 60))

  local MESSAGE="${1:-"Operação finalizada!"}"

  local SHOULD_EXIT="${2:-false}"

  clear
  echo -e "${BLUE}=============================================================${NC}"
  echo -e "${GREEN}\t\t${MESSAGE}"
  echo -e "\t\tFeito com ❤️ por TotonhoMilk"
  echo -ne "\t\tTempo de execução: "

  if [ "$HORAS" -gt 0 ]; then
    echo -e "${HORAS}h${MINUTOS}m${SEGUNDOS}s"
  elif [ "$MINUTOS" -gt 0 ]; then
    echo -e "${MINUTOS}m${SEGUNDOS}s"
  else
    echo -e "${SEGUNDOS}s"
  fi

  echo -e "${BLUE}=============================================================${NC}"

  if [ "$SHOULD_EXIT" = true ] || [ "$SHOULD_EXIT" = "1" ]; then
    exit 0
  fi
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

instalation_countdown() {
  clear
  echo -ne "${NC}\tIniciando em"
  for i in {5..0}; do
    for j in {1..3}; do
      sleep 0.25
      echo -n "."
    done
    sleep 0.25
    echo -n "$i"
  done
  sleep 0.3
  clear
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
          exit_script "Operação cancelada pelo Usuário!" true
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
  echo -e "${GREEN}${BLINK} ==> ${NC}${GREEN}Conexão com a internet confirmada!${NC}"
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
        exit_script "Operação cancelada pelo Usuário!" true
      fi
    fi
  done

  if [ ! -d "$HOME/.dotfiles" ]; then
    echo -e "${GREEN} ==> Clonando o repositório de dotfiles. . .${NC}"
    git clone https://github.com/TotonhoMilk/dotfiles_archlinux_hyprland.git "$HOME/.dotfiles"
  else
    echo -e "${RED} ==> O diretório $HOME/.dotfiles já existe${NC}"
    echo -e "${GREEN} ==> Atualizando o repositório${NC}"

    if ! git -C "$HOME/.dotfiles" pull; then
      echo -e "${RED} ==> Erro ao atualizar o repositório via git pull!${NC}"
    else
      echo -e "${GREEN} ==> Arquivos atualizados com sucesso!${NC}"
    fi
  fi
}

configure_greetd() {
  chmod 755 "$HOME"
  chmod 755 "$HOME/.dotfiles"
  sudo usermod -aG video,render greeter

  if [ -f /etc/greetd/config.toml ]; then
    sudo mv /etc/greetd/config.toml /etc/greetd/config.toml.bak
  fi

  sudo mkdir -p /var/cache/tuigreet
  sudo chown -R greeter:greeter /var/cache/tuigreet

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

configure_nvim() {
  if [ -d "$HOME/.config/nvim" ] || [ -L "$HOME/.config/nvim" ]; then
    rm -rf "$HOME/.config/nvim"
    rm -rf "$HOME/.local/state/nvim"
    rm -rf "$HOME/.cache/nvim"
  fi

  cd "$HOME/.dotfiles" || exit 1
  stow nvim
}

welcome_animation() {
  trap 'tput cnorm; exit' TERM INT EXIT

  while true; do
    printf "\033[3;1H${GREEN}"
    printf "\t\t┃ ┃┃ ┃┏━┃┏━┃┛┏━ ┏━┛━┏┛┏━┃┃  ┃  \n"
    printf "\t\t┏━┃━┏┛┏━┛┏┏┛┃┃ ┃━━┃ ┃ ┏━┃┃  ┃  \n"
    printf "\t\t┛ ┛ ┛ ┛  ┛ ┛┛┛ ┛━━┛ ┛ ┛ ┛━━┛━━┛${NC}\n"
    sleep 0.33

    printf "\033[3;1H${GREEN}"
    printf "\t\t║ ║║ ║╔═║╔═║╝╔═ ╔═╝═╔╝╔═║║  ║  \n"
    printf "\t\t╔═║═╔╝╔═╝╔╔╝║║ ║══║ ║ ╔═║║  ║  \n"
    printf "\t\t╝ ╝ ╝ ╝  ╝ ╝╝╝ ╝══╝ ╝ ╝ ╝══╝══╝${NC}\n"
    sleep 0.33
  done
}

welcome_text() {
  echo
  echo -e "${BLUE}
  Esse script de instalação do Hyprland e pacotes derivados.
  para maior garantia de sucesso, realize uma instalação nova 
  do archlinux, utilizando o script archinstall no mínimo.
  ${NC}"
}

# ===============================================================
# Execução do script
# ===============================================================
trap 'tput cnorm' EXIT

clear
welcome_animation &
ANIM_PID=$!

printf "\033[8;1H"

tput civis

welcome_text

echo
read -r -p "$(echo -e "${YELLOW}\tDigite qualquer tecla para continuar. . .${NC}")" -n 1
kill "$ANIM_PID" 2>/dev/null
wait "$ANIM_PID" 2>/dev/null

tput civis

instalation_countdown

tput cnorm

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

  notices "\tInstalando os componentes básicos do Hyprland"
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

  clear
  echo -e "${GREEN} ==> Todas as etapas de instalação foram concluídas!${NC}\n"

  if confirmation "Deseja reiniciar o computador agora?"; then
    echo -e "${YELLOW}Reiniciando o sistema. . .${NC}"
    sleep 2
    reboot
  else
    exit_script "Instalação concluída com sucesso!" true
  fi
else
  exit_script "Operação cancelada pelo Usuário!" true
fi
