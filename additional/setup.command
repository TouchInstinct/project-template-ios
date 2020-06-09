#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

# Устанавливаем необходимые пакеты через Homebrew
brew bundle

# Устанавливаем ruby зависимости.
# Cocoapods and Fastlane
bundle install

# Обновляем репозиторий подов и запускаем их установку.
bundle exec pod pod install --repo-update