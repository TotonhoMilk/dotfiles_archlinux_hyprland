#!/usr/bin/env bash

if [ -f "$HOME/.p10k.zsh" ] && [ ! -L "$HOME/.p10k.zsh" ]; then
  mkdir -p "$HOME/.dotfiles/p10k"

  mv -f "$HOME/.p10k.zsh" "$HOME/.dotfiles/p10k/.p10k.zsh"

  cd "$HOME/.dotfiles" || exit 1

  stow --restow p10k

  echo -e "\n ==> Configuração do P10k atualizada com sucesso no seu repositório de dotfiles!"
else
  echo -e "\n ==> [ERRO] O arquivo $HOME/.p10k.zsh não existe ou já é um link simbólico."
fi

mv "$HOME/.p10k.zsh" "$HOME/.dotfiles/p10k/.p10k.zsh"

cd "$HOME/.dotfiles"
stow --restow p10k
