#!/bin/bash -e

packages=(
    ansible-core
    ansible
    stow
)

sudo pacman -Sy --noconfirm --needed "${packages[@]}"

ansible-playbook -v -K ansible/playbook.yaml
