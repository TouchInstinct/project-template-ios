# project-template-ios

## Разворачивание нового проекта

### Шаг 1. Настройка конфигурации.

- Создать в аккаунтах разработчика AppID с имененем проекта в нижнем регистре. При генерации проекта создаются 4 базовых конфигурации:
	- StandardDebug, StandardRelease - для них использовать префикс `ru.touchin. + ИМЯ_ПРОЕКТ_В_НИЖНЕМ_РЕГИСТРЕ`. Аккаунт `apple@touchin.ru`
	- EnterpriseDebug, EnterpriseRelease - для них использовать префикс `com.touchin. + ИМЯ_ПРОЕКТ_В_НИЖНЕМ_РЕГИСТРЕ`. Аккаунт `enterpriseapple@touchin.ru`

- Создать `*.mobileprovision` для разработки (в случае Standard) и для развертывания (в случае Enterprise)

- Создать организацию в Фабрике и создать группу тестировщиков `touch-instinct`

### Шаг 2. Настройка окружения

*Необходимо поставить ruby версии 2.4.0 и выше!*

Необходимо убедиться, что на вашей локальной машине стоит ruby version 2.4+. Это можно сделать командой

```
ruby -v
```

Если версия меньше, то в консоли необходимо выполнить следующие команды

```sh
\curl -sSL https://get.rvm.io | bash -s stable --ruby
```

После этого закройте терминал и откройте заново.
Убедитесь, что версия ruby стала 2.4+. Если не сработало, то выполните команду

```
rvm use ruby-2.4.0
```

### Шаг 3. Запуск скрипта развертки проекта

Очень важно **НЕ ПЕРЕПУТАТЬ!!!** порядок параметров.

```sh
./bootstrap.sh ПАРАМЕТР_1 ПАРАМЕТР_2 ПАРАМЕТР_3
```

Параметры:

- ПАРАМЕТР_1 = Родительская папка для расположения проекта, в ней будет создана папка проекта.
- ПАРАМЕТР_2 = Имя проекта. Папка проекта будет создана с постфиксом `-ios`.

> Пример: если ПАРАМЕТР_2 называется `Bank`, то папка проекта будет называться `Bank-ios`. Уже внутри папки проекта уже будут находится остальные файлы. Пример

```sh
├── Bank
│   ├── Analytics
│   ├── AppDelegate.swift
│   ├── Cells
│   ├── Controllers
│   ├── Extensions
│   ├── Generated
│   │   └── models.swift
│   ├── Info.plist
│   ├── Models
│   ├── Networking
│   ├── Protocols
│   ├── Realm
│   ├── Resources
│   │   ├── Assets.xcassets
│   │   │   └── AppIcon.appiconset
│   │   │       └── Contents.json
│   │   ├── LaunchScreen.storyboard
│   │   └── Localization
│   │       ├── Base.lproj
│   │       │   └── Localizable.strings
│   │       ├── String+Localization.swift
│   │       └── ru.lproj
│   │           └── Localizable.strings
│   ├── Services
│   │   ├── BankDateFormattingService.swift
│   │   ├── BankNumberFormattingService.swift
│   │   └── NavigationService.swift
│   └── Views
├── Bank.xcodeproj
├── Bank.xcworkspace
├── Downloads
├── Podfile
├── Podfile.lock
├── Pods
├── README.md
├── Rambafile
├── build-scripts
├── common
├── cpd-output.xml
└── fastlane
    └── Fastfile

93 directories, 138 files

```

- ПАРАМЕТР_3 = Название репозитория с общими строками, без указания расширения `.git` и названия компании. Пример: `Bank-Common`, `Bank2-Common`. Пример скрипта

```sh
igorkislyuk$ ./bootstrap.sh ~/Documents/projects/ Bank BankSpbJur-common
```

### Шаг 4. После установки:

- поменять версию `*.xcodeproject` на Xcode-compatible 8.0
- **ВЫКЛЮЧИТЬ** автоматическое подписывание
- выставить необходимые провижены для каждой конфигурации
- *Опционально* при необходимости добавить конфигурации вручную
- Вставить ключ фабрика в Info.plist
- Перенести билд фазу `Fabric` в конец, и добавить к ней ключи организации
- Проставить необходимые схемы для действий и сделать схему `shared`
