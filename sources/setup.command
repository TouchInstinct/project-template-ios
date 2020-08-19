#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

# Устанавливаем необходимые пакеты через Homebrew
brew bundle

# Устанавливаем bundler

gem install bundler

# Устанавливаем ruby зависимости.
# Cocoapods and Fastlane
bundle install

# Обновляем репозиторий подов и запускаем их установку.
bundle exec pod install --repo-update