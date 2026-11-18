# Coinmoney — Flutter-приложение по макету из Figma

Полная реализация мобильного крипто-приложения **Coinmoney** на Flutter по дизайн-макетам из папки `Сайт/Untitled`, со всеми экранами, интерактивными графиками, светлой и тёмной темой (`Dark mode`), а также настроенными переходами между всеми сценариями.

## Что реализовано (экраны и переходы)

1. **Онбординг и вход (`lib/screens/onboarding/`, `lib/screens/auth/`)**
   - `OnboardingScreen` — 3 слайда (`Take hold of your finances`, `Smart trading tools`, `Invest in the future`) с кастомными иллюстрациями и волнами.
   - `WelcomeScreen` — выбор входа (Facebook / Google / Apple / Sign up with email / Sign In).
   - `LoginScreen` — форма входа с валидацией email/пароля, переключателем `Unlock with Touch ID?` и переходом на сброс пароля.
   - `PasswordResetScreen` — 2 шага сброса пароля (`Password reset` → `Confirm your email`).
   - `RegistrationFlowScreen` — полный 9-шаговый мастер регистрации и KYC-верификации:
     - `Get started in 3 easy steps`
     - Ввод Email → 6-значный OTP-код (клик по иконке письма или `Send again` быстро подставляет демо-код) → Создание пароля
     - `Submit documents` (выбор страны `Ukraine` и типа документа: National ID Card / Passport / Driver license)
     - `Scan document` → предпросмотр камеры с паспортом (`Tomashuk Dmutro`) → `Selfie verification` → `Verification Success` → вход в главное приложение.

2. **Главный экран и нижняя навигация (`lib/screens/main_shell.dart`)**
   - **Home** (`HomeScreen`) — общий баланс (`$2,760.23`), интерактивный график (можно водить пальцем/мышкой), горизонтальная лента `Market Movers` и список `Portfolio`.
   - **Trade** (`TradeSpotScreen`) — спотовый стакан (`Order bk`), переключение `Spot | Margin | Grid | Fiat`, выбор пары `BTC/USDT`, клик по цене в стакане подставляет её в форму, слайдер процентов `0%–100%`, размещение ордеров в `Open Orders`.
   - **Графики монеты** (`CoinGraphScreen` и `HorizontalGraphScreen`) — переключение таймфреймов (`1Hour | 1Day | 1Month | 1Year`), переключение между линейным графиком и свечами (`Candlestick`), популярные пары (`BTC/USD`, `ETH/USD`, `LTC/USD`, `XRP/USD`), история сделок и полноэкранный горизонтальный график с индикаторами (`MA`, `BOLL`, `MACD`, `KDJ`, `RSI`, `WR`) и объёмами.
   - **Market** (`MarketScreen`) — поиск с историей (`DOGE`, `KRB`, `QMALL`), фильтры (`All Coins`, `Most Trade`, `Most Lose`, `New Coin`), сортировка, свайп влево / долгое нажатие открывает оранжевую кнопку **Add to Favorites**.
   - **Favorites** (`FavoritesScreen`) — избранные пары; свайп влево / долгое нажатие открывает кнопки **Move** и **Remove**.
   - **Wallet** (`WalletScreen`) — переключение `Cards | Portfolio`:
     - *Cards*: карусель виртуальных карт Coinmoney, скрытие/показ баланса, история транзакций.
     - *Portfolio*: кольцевой график долей активов (`BTC 46%`, `ATOM 35%`, `ETH 10%`, `CRO 7%`, `ADA 2%`) и раскрывающаяся шторка `My Assets`.

3. **Операции с криптовалютой (`lib/screens/operations/crypto_operation_screen.dart`)**
   - Вкладки `Buy | Sell | Exchange | Withdraw`, кастомная цифровая клавиатура, выбор способа оплаты в модальном окне (`Coinmoney Wallet`, `PayPal`, `monobank`, `Debit card`), экран подтверждения `Confirmation` и экран успеха `Transaction Success` / `Exchange Successful`.

4. **Настройки и тёмная тема (`lib/screens/settings/settings_screen.dart`)**
   - Карточка профиля (`Dmutro`, `Verified`, копирование `ID 28954761`), разделы `Privacy`, `Finance`, `Account`, `More`, кнопка `Log Out` и рабочий переключатель **Dark mode**, мгновенно меняющий тему всего приложения.

---

## Как запустить проект (если Flutter ещё не установлен)

1. Откройте PowerShell и установите Flutter SDK (или скачайте архив с [docs.flutter.dev](https://docs.flutter.dev/get-started/install/windows)):
   ```powershell
   winget install Google.Flutter
   ```
2. Перезапустите терминал (или VS Code) и проверьте:
   ```powershell
   flutter doctor
   ```
3. Запустите приложение двойным кликом по [`run_app.bat`](run_app.bat) или в терминале из папки `C:\Study\Dasha\coinmoney`:
   ```powershell
   flutter pub get
   flutter run -d chrome
   ```
   *(На широком экране браузера приложение автоматически отобразится в аккуратной мобильной рамке, а на эмуляторе Android/iOS откроется на весь экран).*
