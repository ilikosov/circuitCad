# Compakt circuits (fork)

Форк мода [Compakt circuits](https://mods.factorio.com/mod/compaktcircuit)
([исходники оригинала](https://github.com/Telkine2018/compaktcircuit)) для Factorio 2.0.
Мод упаковывает целую логическую сеть комбинаторов в один компактный entity
(«процессор») — аналог Factorissimo, но для сигналов.

## Разработка

Архитектура и соглашения описаны в [CLAUDE.md](CLAUDE.md).

### Проверка кода

Автотестов нет (логика завязана на движок Factorio). Статическая проверка —
синтаксис и опечатки в глобалах:

```sh
luacheck .        # конфиг в .luacheckrc; в Debian/Ubuntu пакет называется lua-check
```

Для IDE есть конфиг lua-language-server (`.luarc.json`, `.vscode/settings.json`).

### Сборка релиза

```sh
./package.sh      # -> dist/compaktcircuit_<version>.zip
```

### Запуск в игре

- Симлинк на репозиторий в директорию модов Factorio:
  `ln -s $(pwd) ~/.factorio/mods/compaktcircuit` — игра подхватит мод из папки.
- Либо положить собранный zip из `dist/` в `mods/`.
- Отладка: расширение VS Code [Factorio Mod Debug](https://marketplace.visualstudio.com/items?itemName=justarandomgeek.factoriomod-debug),
  конфигурации в `.vscode/launch.json`.

### Релиз

1. Поднять `version` в `info.json`.
2. Добавить запись в `changelog.txt` (строгий формат changelog Factorio).
3. Обновить обе локали: `locale/en/base.cfg` и `locale/ru/base.cfg`.
4. Смержить в `main` — CI сам создаст тег `v<version>` и GitHub-релиз
   с собранным zip (`.github/workflows/release.yml`); в описание релиза
   попадает секция этой версии из `changelog.txt`. Если тег уже
   существует, релизная задача молча пропускается.

Локальная сборка по-прежнему: `./package.sh`.
