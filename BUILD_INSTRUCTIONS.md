# Инструкция по запуску сборки

## 1. Создай GitHub репозиторий
- Зайди на github.com → New repository
- Назови как хочешь (например `rosstabak-manager`)
- Публичный или приватный — не важно

## 2. Запушь код
```bash
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/ТВОЙ_НИК/rosstabak-manager.git
git push -u origin main
```

## 3. Запусти сборку
- Зайди в свой репозиторий на GitHub
- Вкладка **Actions** → **Build Release** → **Run workflow** → **Run workflow**
- Подожди ~15 минут
- Готовые файлы скачаются по ссылке "Artifacts"

## Что получишь
- **macOS**: `Rosstabak.app` — один файл, открывается двойным кликом
- **Windows**: папка `Rosstabak-Windows` — внутри `Rosstabak.exe`, скидывай начальнику

## Для Windows 10+
Программа работает на Windows 10 и выше. Никакого дополнительного софта не нужно.
