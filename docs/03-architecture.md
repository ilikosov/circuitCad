# System Architecture

> Архитектура LogicCAD.

Version 0.1

---

# 1. Назначение

Данный документ описывает взаимодействие всех подсистем проекта.

Он отвечает не на вопрос:

> "Что хранится?"

а на вопрос

> "Кто за что отвечает?"

После прочтения этого документа разработчик должен понимать:

* где находится логика;
* кто имеет право изменять Document;
* как происходит компиляция;
* как связаны Editor и Runtime.

---

# 2. Архитектурные цели

Архитектура строится вокруг пяти требований.

* простота
* предсказуемость
* тестируемость
* расширяемость
* независимость от API Factorio

---

# 3. Общая схема

```
+-----------------------------------------------------------+
|                      LogicCAD                             |
+-----------------------------------------------------------+

              User

               │

               ▼

        Editor Controller

               │

               ▼

            Document

               │

      +--------+--------+

      │                 │

      ▼                 ▼

Validation         Render System

      │

      ▼

 Net Builder

      │

      ▼

 Compiler

      │

      ▼

 Runtime Package

      │

      ▼

 Runtime Builder

      │

      ▼

 Factorio Runtime
```

---

# 4. Подсистемы

Проект состоит из независимых модулей.

```
core/
editor/
compiler/
runtime/
factorio/
gui/
```

Каждый модуль имеет строго определённую ответственность.

---

# 5. Core

Core является ядром проекта.

Он ничего не знает о Factorio.

Содержит:

* Document
* Component
* Track
* Net
* Validation
* Compiler Model

Core можно тестировать вне игры.

---

# 6. Editor

Editor отвечает исключительно за изменение Document.

Editor никогда:

* не строит Runtime;
* не вычисляет сигналы;
* не создаёт LuaEntity.

Editor изменяет только модели.

---

# 7. GUI

GUI отображает состояние Document.

GUI не содержит бизнес-логики.

GUI вызывает Editor API.

```
GUI

↓

Editor API

↓

Document
```

---

# 8. Validation

Validation выполняется после каждого изменения документа.

Проверяются:

* пересечения компонентов;
* корректность портов;
* допустимость настроек;
* ошибки схемы.

Validation ничего не исправляет автоматически.

Он только сообщает об ошибках.

---

# 9. Net Builder

Net Builder анализирует дорожки.

Результат:

```
Tracks

↓

Net Graph
```

После построения графа дорожки больше не используются компилятором.

---

# 10. Compiler

Компилятор принимает Document.

Создает Runtime Package.

```
Document

↓

Compiler

↓

Runtime Package
```

Компилятор никогда не вызывает API Factorio.

---

# 11. Runtime Package

Runtime Package —

промежуточное представление схемы.

Например

```
Entities

Connections

Metadata
```

Он существует только во время компиляции.

---

# 12. Runtime Builder

Runtime Builder —

единственная подсистема,

имеющая право работать с API Factorio.

Только Runtime Builder может выполнять

```
surface.create_entity()

entity.connect_neighbour()

entity.destroy()
```

Ни один другой модуль не должен обращаться к игровому API напрямую.

---

# 13. Runtime

Runtime —

это набор реальных игровых объектов.

Например

```
Arithmetic

Decider

Constant
```

Runtime полностью пересоздается.

---

# 14. Storage

Storage отвечает только за сериализацию.

Он:

* сохраняет Document;
* загружает Document;
* выполняет миграции.

Storage никогда не знает о Runtime.

---

# 15. Render

Render отвечает исключительно за отображение редактора.

Например

* подсветка дорожек;
* выделение;
* сетка;
* превью размещения.

Render ничего не изменяет.

---

# 16. Controller

Controller связывает все подсистемы.

Например

```
Click

↓

Editor Command

↓

Validation

↓

Render
```

При сохранении

```
Save

↓

Validation

↓

Compiler

↓

Runtime Builder
```

---

# 17. Document Flow

Главный поток данных проекта.

```
Player

↓

Editor

↓

Document

↓

Validation

↓

Compiler

↓

Runtime

↓

Factorio
```

Document всегда находится в центре.

---

# 18. Runtime Flow

```
Compile

↓

Runtime Package

↓

Destroy Runtime

↓

Create Runtime

↓

Connect Wires

↓

Ready
```

Это делает поведение полностью детерминированным.

---

# 19. Dependency Rule

Разрешённые зависимости.

```
GUI

↓

Editor

↓

Core

Compiler

↓

Core

Runtime

↓

Compiler

↓

Factorio API
```

Запрещены обратные зависимости.

Например

Core не может использовать Runtime.

---

# 20. Command Architecture

Все изменения документа выполняются командами.

Например

```
Place Component

Delete Component

Rotate Component

Place Track

Delete Track
```

Команды являются единственным способом изменить Document.

---

# 21. Event Flow

После выполнения команды.

```
Execute

↓

Update Document

↓

Validation

↓

Dirty Flags

↓

Render
```

Компиляция не запускается автоматически.

---

# 22. Dirty Flags

Каждая команда помечает изменённые подсистемы.

Например

```
Dirty Geometry

Dirty Nets

Dirty Render

Dirty Storage
```

Это позволит позже отказаться от полного пересчёта редактора.

---

# 23. Принцип изоляции

Editor не знает о Runtime.

Runtime не знает о GUI.

GUI не знает о Compiler.

Каждая подсистема отвечает только за свою область.

---

# 24. Расширяемость

Добавление нового компонента должно требовать:

* регистрации определения;
* реализации компилятора;
* реализации визуализации.

Остальная архитектура не должна изменяться.

---

# 25. Следующий документ

Следующий документ

```
docs/04-editor.md
```

полностью описывает архитектуру редактора.
