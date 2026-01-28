# 🔧 Инженерный План Исправления Деплоя Admin Panel на Vercel

**Дата анализа:** 28 января 2026  
**Проблема:** `pnpm install exited with 1` на Vercel  
**Статус:** Требуется комплексное исправление конфигурации monorepo

---

## 📋 ДИАГНОСТИКА: Выявленные Проблемы

### 🔴 Критические Проблемы

| # | Проблема | Файл | Описание |
|---|----------|------|----------|
| 1 | **Конфликт lockfile** | Root: `package-lock.json` + `pnpm-lock.yaml` | Vercel не понимает какой менеджер использовать |
| 2 | **Дублирование workspace файлов** | `apps/admin/pnpm-lock.yaml`, `apps/admin/pnpm-workspace.yaml` | Копии в субпроекте ломают резолюцию |
| 3 | **Неправильный .npmrc** | `apps/admin/.npmrc` содержит `workspaces=false` | Конфликтует с pnpm workspace протоколом |
| 4 | **Отсутствует tailwindcss-animate** | `tailwind.config.js` line 73 | `require("tailwindcss-animate")` но пакет не в dependencies |
| 5 | **Отсутствует class-variance-authority** | UI компоненты | Используется `cva` но пакет не установлен |
| 6 | **Отсутствует @radix-ui/react-select** | `components/ui/select.tsx` | Import есть, dependency нет |

### 🟡 Конфигурационные Проблемы

| # | Проблема | Файл | Описание |
|---|----------|------|----------|
| 7 | **Root Directory не установлен** | Vercel Dashboard | Vercel ищет Next.js в корне, а не в `apps/admin` |
| 8 | **Нет ENABLE_EXPERIMENTAL_COREPACK** | Vercel Env Vars | Corepack не активирован для pnpm |
| 9 | **workspaces в package.json (npm формат)** | Root `package.json` | pnpm использует `pnpm-workspace.yaml`, не `workspaces` field |

---

## 🛠️ ПЛАН ИСПРАВЛЕНИЯ

### Фаза 1: Очистка Конфликтующих Файлов

```bash
# 1.1 Удалить npm lockfile из корня (конфликтует с pnpm)
rm package-lock.json

# 1.2 Удалить дублирующие workspace файлы из apps/admin
rm apps/admin/pnpm-lock.yaml
rm apps/admin/pnpm-workspace.yaml

# 1.3 Удалить проблемный .npmrc
rm apps/admin/.npmrc

# 1.4 Удалить .vercel папки (сбросить кэш деплоя)
rm -rf .vercel
rm -rf apps/admin/.vercel

# 1.5 Удалить все node_modules
rm -rf node_modules
rm -rf apps/admin/node_modules
```

### Фаза 2: Исправление package.json файлов

#### 2.1 Root `package.json` - УДАЛИТЬ workspaces field
```json
{
  "name": "audio-guide-2026",
  "version": "0.0.0",
  "private": true,
  "packageManager": "pnpm@8.15.4",
  "scripts": {
    "dev": "pnpm --filter admin dev",
    "build": "pnpm --filter admin build",
    "lint": "pnpm --filter admin lint"
  }
}
```
**ВАЖНО:** Удалить `"workspaces": [...]` — это npm/yarn синтаксис, pnpm использует `pnpm-workspace.yaml`

#### 2.2 `apps/admin/package.json` - Добавить недостающие зависимости
```json
{
  "dependencies": {
    // ... существующие ...
    "@radix-ui/react-select": "^2.0.0",
    "class-variance-authority": "^0.7.0",
    "tailwindcss-animate": "^1.0.7"
  }
}
```
**УДАЛИТЬ:** `"packageManager": "pnpm@8.15.4"` — должен быть только в root

### Фаза 3: Конфигурация pnpm-workspace.yaml (Root)

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```
**Проверить:** Файл должен быть ТОЛЬКО в корне монорепо

### Фаза 4: Создать правильный .npmrc в корне

```ini
# /Audiogid/.npmrc
auto-install-peers=true
strict-peer-dependencies=false
shamefully-hoist=true
```
**Объяснение:**
- `shamefully-hoist=true` — поднимает зависимости для совместимости с Vercel
- `strict-peer-dependencies=false` — игнорирует peer dep конфликты

### Фаза 5: Исправить vercel.json

```json
{
  "installCommand": "pnpm install --frozen-lockfile",
  "buildCommand": "pnpm build",
  "outputDirectory": ".next",
  "framework": "nextjs",
  "rewrites": [
    {
      "source": "/api/proxy/:path*",
      "destination": "https://api.audiogid.app/v1/:path*"
    }
  ]
}
```
**Изменения:**
- Добавить `--frozen-lockfile` для детерминированных билдов
- Добавить `outputDirectory` явно

### Фаза 6: Регенерация Lockfile

```bash
# Из корня монорепо
cd /path/to/Audiogid

# Полная очистка
rm -rf node_modules apps/*/node_modules pnpm-lock.yaml

# Регенерация
pnpm install

# Проверка
pnpm --filter admin build
```

### Фаза 7: Настройка Vercel Dashboard

#### 7.1 Project Settings → General
```
Root Directory: apps/admin
```

#### 7.2 Project Settings → Build & Development Settings
```
Framework Preset: Next.js
Build Command: pnpm build
Output Directory: .next
Install Command: pnpm install --frozen-lockfile
```

#### 7.3 Project Settings → Environment Variables
```
ENABLE_EXPERIMENTAL_COREPACK = 1
NPM_CONFIG_SHAMEFULLY_HOIST = true
```

### Фаза 8: Git Commit и Push

```bash
git rm package-lock.json
git rm apps/admin/pnpm-lock.yaml
git rm apps/admin/pnpm-workspace.yaml
git rm apps/admin/.npmrc
git add .
git commit -m "fix(deploy): clean up conflicting configs, add missing deps, configure pnpm monorepo for Vercel"
git push origin master
```

---

## ✅ ЧЕКЛИСТ ВЕРИФИКАЦИИ

### Локальная проверка
- [ ] `pnpm install` в корне успешен
- [ ] `pnpm --filter admin build` успешен
- [ ] Нет `package-lock.json` в репозитории
- [ ] `pnpm-lock.yaml` только в корне
- [ ] `pnpm-workspace.yaml` только в корне

### Структура файлов после исправления
```
Audiogid/
├── .npmrc                    # NEW: shamefully-hoist
├── package.json              # MODIFIED: без workspaces field
├── pnpm-lock.yaml            # REGENERATED
├── pnpm-workspace.yaml       # OK
├── apps/
│   └── admin/
│       ├── package.json      # MODIFIED: +deps, -packageManager
│       ├── vercel.json       # MODIFIED: frozen-lockfile
│       ├── next.config.js    # OK
│       ├── tailwind.config.js# OK
│       └── ... (NO .npmrc, NO pnpm-lock.yaml, NO pnpm-workspace.yaml)
```

### Vercel Dashboard проверка
- [ ] Root Directory = `apps/admin`
- [ ] Install Command = `pnpm install --frozen-lockfile`
- [ ] Build Command = `pnpm build`
- [ ] `ENABLE_EXPERIMENTAL_COREPACK` = `1`

---

## 🚀 АЛЬТЕРНАТИВНЫЙ ПОДХОД: Standalone Deploy

Если monorepo подход продолжает вызывать проблемы, можно перейти на standalone:

### Вариант А: Eject admin из monorepo
```bash
# Создать отдельный репозиторий
mkdir audiogid-admin
cp -r apps/admin/* audiogid-admin/
cd audiogid-admin

# Инициализировать как standalone
rm -rf pnpm-* .npmrc
npm init -y
npm install

# Деплой как отдельный проект
vercel --prod
```

### Вариант Б: Turborepo для управления monorepo
```bash
# В корне
pnpm add -D turbo

# turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**"]
    }
  }
}
```
Vercel имеет нативную поддержку Turborepo.

---

## 📊 ПРИОРИТЕТ ИСПРАВЛЕНИЙ

| Приоритет | Действие | Время |
|-----------|----------|-------|
| P0 | Удалить package-lock.json | 1 мин |
| P0 | Удалить apps/admin/pnpm-* файлы | 1 мин |
| P0 | Удалить apps/admin/.npmrc | 1 мин |
| P1 | Добавить class-variance-authority | 2 мин |
| P1 | Добавить tailwindcss-animate | 2 мин |
| P1 | Добавить @radix-ui/react-select | 2 мин |
| P1 | Исправить root package.json | 3 мин |
| P2 | Создать root .npmrc | 2 мин |
| P2 | Обновить vercel.json | 2 мин |
| P3 | Регенерировать pnpm-lock.yaml | 5 мин |
| P3 | Настроить Vercel Dashboard | 5 мин |
| P4 | Локальный тест build | 3 мин |
| P4 | Push и redeploy | 5 мин |

**Общее время:** ~30-40 минут

---

## 📝 КОМАНДЫ ДЛЯ КОПИРОВАНИЯ

### Полный скрипт исправления (PowerShell)
```powershell
# Шаг 1: Очистка
Remove-Item -Force package-lock.json -ErrorAction SilentlyContinue
Remove-Item -Force apps/admin/pnpm-lock.yaml -ErrorAction SilentlyContinue
Remove-Item -Force apps/admin/pnpm-workspace.yaml -ErrorAction SilentlyContinue
Remove-Item -Force apps/admin/.npmrc -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .vercel -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force apps/admin/.vercel -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force node_modules -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force apps/admin/node_modules -ErrorAction SilentlyContinue

# Шаг 2: Регенерация
pnpm install

# Шаг 3: Тест
pnpm --filter admin build

# Шаг 4: Коммит
git add -A
git commit -m "fix(deploy): clean monorepo config for Vercel pnpm"
git push origin master
```

---

**Автор:** Antigravity AI  
**Версия плана:** 1.0  
**Статус:** Готов к исполнению
