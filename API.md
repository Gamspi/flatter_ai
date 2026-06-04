# REST API Авторизации — sibkredit

> **Для агента-разработчика:** этот документ полностью описывает API и требования к UI. Реализуй формы авторизации и регистрации согласно разделам «Форма» и «Логика на клиенте». Все запросы к API делай через JS fetch/axios. Токен храни в `localStorage` под ключом `sk_access_token`.

Базовый URL: `/rest/auth/`  
Формат запросов/ответов: `application/json`  
Аутентификация защищённых эндпоинтов: `Authorization: Bearer <access_token>`

---

## Обзор флоу

### Авторизация (2 шага)
```
POST /rest/auth/login        → temp_token (отправляет SMS)
POST /rest/auth/confirm      → access_token
```

### Регистрация (2 шага)
```
POST /rest/auth/register         → temp_token (отправляет SMS)
POST /rest/auth/register/confirm → access_token
```

### Управление сессией
```
GET  /rest/auth/me       🔒 → данные пользователя
POST /rest/auth/refresh  🔒 → продление токена
POST /rest/auth/logout   🔒 → выход
```

🔒 — требует заголовок `Authorization: Bearer <access_token>`

---

## Эндпоинты авторизации

### POST `/rest/auth/login`

Шаг 1: проверяет телефон и пароль, отправляет SMS-код (4 цифры, действует 3 минуты).

**Request**
```json
{
  "phone":    "9001234567",
  "password": "Abc12345"
}
```

`phone` — номер телефона в любом формате (+7, 8, 10 цифр — будет нормализован до 10 цифр).

**Response 200**
```json
{
  "success": true,
  "data": {
    "temp_token": "a3f9...",
    "expires_in": 300
  }
}
```

`temp_token` действует 5 минут и используется только для шага подтверждения.

**Ошибки**

| HTTP | Сообщение |
|------|-----------|
| 422  | Поля phone и password обязательны |
| 404  | Пользователь не найден |
| 401  | Неверный пароль |

---

### POST `/rest/auth/confirm`

Шаг 2: подтверждает SMS-код, подключается к 1C, возвращает постоянный токен.

**Request**
```json
{
  "temp_token": "a3f9...",
  "code":       "1234"
}
```

**Response 200**
```json
{
  "success": true,
  "data": {
    "access_token": "b7e2...",
    "expires_at":   "2026-07-04 12:00:00",
    "user": {
      "id":          42,
      "name":        "Иван",
      "last_name":   "Иванов",
      "second_name": "Иванович",
      "phone":       "9001234567"
    }
  }
}
```

`access_token` действует 30 дней. После получения сохраните его на клиенте и передавайте во всех защищённых запросах.

**Ошибки**

| HTTP | Сообщение |
|------|-----------|
| 422  | Поля temp_token и code обязательны |
| 401  | Токен не найден или истёк |
| 401  | Неверный код подтверждения |
| 401  | Код подтверждения истёк |
| 502  | Ошибка 1C (текст из системы) |

---

## Эндпоинты регистрации

### POST `/rest/auth/register`

Шаг 1: находит клиента в 1C по номеру договора и ФИО, отправляет SMS на телефон клиента (6 цифр).

**Request**
```json
{
  "reg_type": "loan",
  "doc":      "З-00012345",
  "fio":      "Иванов Иван Иванович",
  "phone":    "9001234567"
}
```

| Поле | Обязательное | Описание |
|------|-------------|----------|
| `reg_type` | ✅ | `"loan"` — займ, `"deposit"` — сбережения |
| `doc`      | ✅ | Номер договора |
| `fio`      | ✅ | ФИО клиента (только кириллица, пробелы, дефисы) |
| `phone`    | ❌ | Телефон для уточнения (если несколько совпадений) |

**Response 200**
```json
{
  "success": true,
  "data": {
    "temp_token":   "c8d1...",
    "masked_phone": "90****67",
    "expires_in":   300
  }
}
```

`masked_phone` — маскированный номер, на который отправлен код (показывает первые и последние 2 цифры).

**Ошибки**

| HTTP | Сообщение |
|------|-----------|
| 422  | Поля reg_type, doc и fio обязательны |
| 422  | ФИО содержит недопустимые символы |
| 422  | Невалидный номер договора |
| 422  | reg_type должен быть loan или deposit |
| 404  | Клиент по указанным данным не найден |
| 502  | Ошибка 1C |

---

### POST `/rest/auth/register/confirm`

Шаг 2: подтверждает SMS-код, устанавливает пароль, создаёт пользователя в системе.

**Request**
```json
{
  "temp_token":       "c8d1...",
  "code":             "123456",
  "password":         "Abc12345",
  "password_confirm": "Abc12345"
}
```

Требования к паролю: минимум 6 символов, должны присутствовать цифры, строчные и прописные латинские буквы.

**Response 200**
```json
{
  "success": true,
  "data": {
    "access_token": "d4f7...",
    "expires_at":   "2026-07-04 12:00:00",
    "user": {
      "id":          43,
      "name":        "Иван",
      "last_name":   "Иванов",
      "second_name": "Иванович",
      "phone":       "9001234567"
    }
  }
}
```

**Ошибки**

| HTTP | Сообщение |
|------|-----------|
| 422  | Поля temp_token, code, password и password_confirm обязательны |
| 401  | Токен не найден или истёк |
| 401  | Неверный код подтверждения |
| 401  | Код подтверждения истёк |
| 422  | Пароли не совпадают |
| 422  | Текст ошибки политики пароля |
| 502  | Ошибка регистрации в 1C |
| 500  | Не удалось создать пользователя |

---

## Управление сессией

### GET `/rest/auth/me` 🔒

Возвращает данные авторизованного пользователя.

**Headers**
```
Authorization: Bearer <access_token>
```

**Response 200**
```json
{
  "success": true,
  "data": {
    "id":          42,
    "login":       "9001234567",
    "name":        "Иван",
    "last_name":   "Иванов",
    "second_name": "Иванович",
    "phone":       "9001234567",
    "ak3_guid":    "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

`ak3_guid` — GUID клиента в системе 1C, используется для запросов к личному кабинету.

---

### POST `/rest/auth/refresh` 🔒

Продлевает срок действия токена на 30 дней от текущего момента.

**Headers**
```
Authorization: Bearer <access_token>
```

**Response 200**
```json
{
  "success": true,
  "data": {
    "expires_at": "2026-08-04 12:00:00"
  }
}
```

---

### POST `/rest/auth/logout` 🔒

Инвалидирует токен. После этого он перестаёт работать немедленно.

**Headers**
```
Authorization: Bearer <access_token>
```

**Response 200**
```json
{
  "success": true
}
```

---

## Общая структура ошибок

Все ошибки возвращаются в едином формате:

```json
{
  "success": false,
  "error":   "Текст ошибки"
}
```

Некоторые ошибки содержат дополнительные поля (например `"field": "fio"` для ошибок валидации).

**Типичные HTTP-коды:**

| Код | Значение |
|-----|----------|
| 200 | Успех |
| 204 | Preflight OPTIONS (CORS) |
| 401 | Не авторизован / неверные учётные данные |
| 404 | Ресурс не найден |
| 422 | Ошибка валидации входных данных |
| 500 | Внутренняя ошибка сервера |
| 502 | Ошибка интеграции с 1C |

---

## Примеры — полный флоу авторизации

### cURL

```bash
# Шаг 1: запрос SMS
curl -X POST https://example.com/rest/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"9001234567","password":"Abc12345"}'

# Ответ: {"success":true,"data":{"temp_token":"a3f9...","expires_in":300}}

# Шаг 2: подтверждение кода
curl -X POST https://example.com/rest/auth/confirm \
  -H "Content-Type: application/json" \
  -d '{"temp_token":"a3f9...","code":"1234"}'

# Ответ: {"success":true,"data":{"access_token":"b7e2...","expires_at":"...","user":{...}}}

# Защищённый запрос
curl https://example.com/rest/auth/me \
  -H "Authorization: Bearer b7e2..."
```

---

## Примеры — полный флоу регистрации

```bash
# Шаг 1: поиск клиента в 1C и отправка SMS
curl -X POST https://example.com/rest/auth/register \
  -H "Content-Type: application/json" \
  -d '{"reg_type":"loan","doc":"З-00012345","fio":"Иванов Иван Иванович"}'

# Ответ: {"success":true,"data":{"temp_token":"c8d1...","masked_phone":"90****67","expires_in":300}}

# Шаг 2: подтверждение и создание аккаунта
curl -X POST https://example.com/rest/auth/register/confirm \
  -H "Content-Type: application/json" \
  -d '{"temp_token":"c8d1...","code":"123456","password":"Abc12345","password_confirm":"Abc12345"}'

# Ответ: {"success":true,"data":{"access_token":"d4f7...","expires_at":"...","user":{...}}}
```

---

## Технические детали

### Хранение токенов
Токены хранятся в таблице `b_sk_api_token`. Временные токены (IS_TEMP=Y) автоматически истекают через 5 минут. Постоянные токены (IS_TEMP=N) действуют 30 дней.

### Инициализация таблицы
При установке модуля `paraweb.sibkredit` таблица создаётся автоматически. Для ручного создания:
```php
\Paraweb\Sibkredit\Model\ApiTokenTable::createTable();
```

### CORS
API поддерживает CORS запросы с любого домена (`Access-Control-Allow-Origin: *`). Preflight OPTIONS запросы обрабатываются автоматически (204).

### Совместимость с веб-флоу
REST API работает параллельно с существующей веб-авторизацией через форму на сайте. Они не мешают друг другу: веб использует PHP-сессии, REST — токены в БД.

---

## Руководство по реализации UI

### Хранение состояния на клиенте

```js
// Сохранить токен после успешной авторизации
localStorage.setItem('sk_access_token', data.access_token);
localStorage.setItem('sk_expires_at', data.expires_at);

// Читать токен для защищённых запросов
const token = localStorage.getItem('sk_access_token');

// Проверить авторизован ли пользователь
function isAuthorized() {
  const token = localStorage.getItem('sk_access_token');
  const expiresAt = localStorage.getItem('sk_expires_at');
  if (!token || !expiresAt) return false;
  return new Date(expiresAt) > new Date();
}

// Очистить при logout
function clearSession() {
  localStorage.removeItem('sk_access_token');
  localStorage.removeItem('sk_expires_at');
}
```

---

### Базовый fetch-хелпер

```js
const API_BASE = '/rest/auth';

async function apiRequest(endpoint, options = {}) {
  const token = localStorage.getItem('sk_access_token');
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const res = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers: { ...headers, ...(options.headers || {}) },
    body: options.body ? JSON.stringify(options.body) : undefined,
  });

  const json = await res.json();
  if (!json.success) throw { status: res.status, message: json.error, data: json };
  return json.data;
}
```

---

## Форма авторизации

### Структура (2 шага)

**Шаг 1 — Вход**

| Поле | Тип | Маска | Валидация |
|------|-----|-------|-----------|
| Номер телефона | `tel` | `+7 (___) ___-__-__` | обязательное, 10 цифр |
| Пароль | `password` | — | обязательное, мин. 6 символов |

Кнопка: **«Войти»** — активна когда оба поля заполнены.

**Шаг 2 — SMS-код**

| Поле | Тип | Валидация |
|------|-----|-----------|
| Код из SMS | `text` / `tel` | 4 цифры, только числа |

- Показывать обратный таймер 3:00 (180 сек).
- После истечения — кнопка «Получить новый код» (повторный вызов `/login`).
- Кнопка: **«Подтвердить»**.

### JS-логика авторизации

```js
// --- Шаг 1: отправить телефон и пароль ---
async function loginStep1(phone, password) {
  // phone нормализуем: оставляем только цифры, берём последние 10
  const cleanPhone = phone.replace(/\D/g, '').slice(-10);

  const data = await apiRequest('/login', {
    method: 'POST',
    body: { phone: cleanPhone, password },
  });

  // Сохранить temp_token для шага 2
  sessionStorage.setItem('sk_temp_token', data.temp_token);

  // Запустить таймер и показать форму шага 2
  startSmsTimer(data.expires_in);
  showStep(2);
}

// --- Шаг 2: подтвердить SMS-код ---
async function loginStep2(code) {
  const tempToken = sessionStorage.getItem('sk_temp_token');

  const data = await apiRequest('/confirm', {
    method: 'POST',
    body: { temp_token: tempToken, code },
  });

  sessionStorage.removeItem('sk_temp_token');
  localStorage.setItem('sk_access_token', data.access_token);
  localStorage.setItem('sk_expires_at', data.expires_at);

  // Перенаправить в личный кабинет
  window.location.href = '/personal/';
}

// --- Таймер обратного отсчёта ---
function startSmsTimer(seconds, onExpire) {
  const el = document.getElementById('sms-timer');
  let remaining = seconds;
  const interval = setInterval(() => {
    remaining--;
    const m = String(Math.floor(remaining / 60)).padStart(2, '0');
    const s = String(remaining % 60).padStart(2, '0');
    el.textContent = `${m}:${s}`;
    if (remaining <= 0) {
      clearInterval(interval);
      if (onExpire) onExpire();
    }
  }, 1000);
}

// --- Обработка ошибок ---
async function handleAuthError(err) {
  if (err.status === 401) showError('Неверный телефон, пароль или код');
  else if (err.status === 404) showError('Пользователь не найден');
  else if (err.status === 502) showError('Сервис временно недоступен');
  else showError(err.message || 'Неизвестная ошибка');
}
```

---

## Форма регистрации

### Структура (2 шага)

**Шаг 1 — Данные клиента**

| Поле | Тип | Валидация |
|------|-----|-----------|
| Тип договора | `select` | обязательное: `loan` = «Займ», `deposit` = «Сбережения» |
| Номер договора | `text` | обязательное |
| ФИО | `text` | обязательное, только кириллица/пробелы/дефисы, формат «Фамилия Имя Отчество» |
| Телефон | `tel` | необязательное, для уточнения при нескольких совпадениях |

Кнопка: **«Найти»** — отправляет запрос в 1C.

**Шаг 2 — Подтверждение и пароль**

| Поле | Тип | Валидация |
|------|-----|-----------|
| Код из SMS | `text` | 6 цифр |
| Пароль | `password` | мин. 6 символов, цифры + строчные + прописные буквы |
| Подтверждение пароля | `password` | совпадает с паролем |

Показать `masked_phone` из ответа шага 1 — пример: «Код отправлен на номер 90\*\*\*\*67».  
Таймер обратного отсчёта 3:00.  
Кнопка: **«Зарегистрироваться»**.

### JS-логика регистрации

```js
// --- Шаг 1: найти клиента в 1C ---
async function registerStep1({ regType, doc, fio, phone }) {
  const data = await apiRequest('/register', {
    method: 'POST',
    body: { reg_type: regType, doc, fio, phone: phone || undefined },
  });

  sessionStorage.setItem('sk_temp_token', data.temp_token);

  showMaskedPhone(data.masked_phone); // «Код отправлен на номер 90****67»
  startSmsTimer(data.expires_in);
  showStep(2);
}

// --- Шаг 2: подтвердить код и задать пароль ---
async function registerStep2({ code, password, passwordConfirm }) {
  const tempToken = sessionStorage.getItem('sk_temp_token');

  const data = await apiRequest('/register/confirm', {
    method: 'POST',
    body: {
      temp_token:       tempToken,
      code,
      password,
      password_confirm: passwordConfirm,
    },
  });

  sessionStorage.removeItem('sk_temp_token');
  localStorage.setItem('sk_access_token', data.access_token);
  localStorage.setItem('sk_expires_at', data.expires_at);

  window.location.href = '/personal/';
}

// --- Валидация пароля на клиенте (зеркалит checkPasswdPolicy) ---
function validatePassword(password) {
  if (password.length < 6) return 'Минимум 6 символов';
  if (!/[0-9]/.test(password)) return 'Пароль должен содержать цифры';
  if (!/[a-z]/.test(password)) return 'Пароль должен содержать строчные буквы';
  if (!/[A-Z]/.test(password)) return 'Пароль должен содержать прописные буквы';
  return true;
}
```

---

## Защищённые запросы (после авторизации)

```js
// Получить данные пользователя
async function getCurrentUser() {
  return apiRequest('/me');
}

// Продлить токен (вызывать при старте приложения если expires_at < 7 дней)
async function refreshTokenIfNeeded() {
  const expiresAt = localStorage.getItem('sk_expires_at');
  if (!expiresAt) return;
  const daysLeft = (new Date(expiresAt) - new Date()) / 86400000;
  if (daysLeft < 7) {
    const data = await apiRequest('/refresh', { method: 'POST' });
    localStorage.setItem('sk_expires_at', data.expires_at);
  }
}

// Выйти
async function logout() {
  try {
    await apiRequest('/logout', { method: 'POST' });
  } finally {
    clearSession();
    window.location.href = '/';
  }
}
```

---

## Обработка ошибок API — полная таблица

| HTTP | `error` (текст) | Что показать пользователю |
|------|----------------|--------------------------|
| 401 | Неверный пароль | «Неверный пароль» |
| 401 | Неверный код подтверждения | «Неверный код» |
| 401 | Код подтверждения истёк | «Код истёк, запросите новый» |
| 401 | Токен не найден или истёк | Редирект на форму входа |
| 401 | Токен недействителен или истёк | Редирект на форму входа |
| 404 | Пользователь не найден | «Пользователь не найден» |
| 404 | Клиент по указанным данным не найден | «Клиент не найден — проверьте номер договора и ФИО» |
| 422 | Пароли не совпадают | Подсветить поле подтверждения |
| 422 | ФИО содержит недопустимые символы | Подсветить поле ФИО |
| 422 | (текст политики пароля) | Показать под полем пароля |
| 502 | (текст от 1C) | «Сервис временно недоступен. Попробуйте позже» |
| 500 | Не удалось создать пользователя | «Ошибка регистрации. Обратитесь в поддержку» |

---

## Минимальный HTML-скелет

```html
<!-- Контейнер авторизации -->
<div id="auth-container">

  <!-- Шаг 1: телефон + пароль -->
  <form id="login-step1" class="auth-step active">
    <input type="tel"      id="phone"    placeholder="+7 (___) ___-__-__" required>
    <input type="password" id="password" placeholder="Пароль"             required>
    <div id="login-error" class="error-msg" hidden></div>
    <button type="submit">Войти</button>
    <a href="#" id="go-register">Регистрация</a>
  </form>

  <!-- Шаг 2: SMS-код -->
  <form id="login-step2" class="auth-step" hidden>
    <p>Код отправлен на номер</p>
    <input type="tel" id="sms-code" maxlength="4" placeholder="____" required>
    <div id="sms-timer">3:00</div>
    <button type="submit">Подтвердить</button>
    <button type="button" id="resend-code" disabled>Получить новый код</button>
  </form>

</div>

<!-- Контейнер регистрации -->
<div id="register-container" hidden>

  <!-- Шаг 1: данные договора -->
  <form id="reg-step1" class="reg-step active">
    <select id="reg-type" required>
      <option value="">Тип договора</option>
      <option value="loan">Займ</option>
      <option value="deposit">Сбережения</option>
    </select>
    <input type="text" id="reg-doc" placeholder="Номер договора" required>
    <input type="text" id="reg-fio" placeholder="Фамилия Имя Отчество" required>
    <input type="tel"  id="reg-phone" placeholder="Телефон (необязательно)">
    <div id="reg-error" class="error-msg" hidden></div>
    <button type="submit">Найти</button>
  </form>

  <!-- Шаг 2: код + пароль -->
  <form id="reg-step2" class="reg-step" hidden>
    <p id="reg-masked-phone"></p>
    <input type="tel"      id="reg-code"     maxlength="6" placeholder="______" required>
    <input type="password" id="reg-password" placeholder="Придумайте пароль"   required>
    <input type="password" id="reg-password2" placeholder="Повторите пароль"   required>
    <div id="reg-step2-error" class="error-msg" hidden></div>
    <div id="reg-timer">3:00</div>
    <button type="submit">Зарегистрироваться</button>
  </form>

</div>
```
