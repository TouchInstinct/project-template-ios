# project-template-ios
Template and config files for liftoff

## Setup

### Fix liftoff (https://github.com/liftoffcli/liftoff/issues/285)


You need to edit the file named project.rb located in /usr/local/Cellar/liftoff/{lastest version}/rubylib/liftoff/ And add theses lines in function named 'new_app_target' :

```
configuration.build_settings['SWIFT_VERSION'] = '3.1'
```

### Setup liftoff config

```sh
./setup_config.sh
```

## Bootstrap project:

```sh
./bootstrap.sh PROJECT_NAME path/to/projects
```