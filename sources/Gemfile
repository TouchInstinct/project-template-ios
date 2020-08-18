source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/strongself/Generamba.git" }

gem "cocoapods"
gem "fastlane"
gem 'generamba', github: 'strongself/develop'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
