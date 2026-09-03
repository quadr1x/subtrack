# SubTrack

> **Offline-first subscription manager** for Web, Windows, Linux and macOS — built with Flutter.

SubTrack helps you keep track of recurring subscriptions, visualize your spending by category, forecast yearly cost, and never miss a payment with reminder notifications. Everything is stored locally on your device; no account or cloud required.

## ✨ Features

- 📊 **Dashboard** with monthly/yearly expense totals, breakdown by category and a 12-month bar chart
- ➕ **Add / edit / delete** subscriptions with full control over name, price, currency, category, billing cycle, payment method, color and logo
- 🔍 **Live search & filter** by name or category
- 🔔 **Local notifications** (Windows / macOS / Linux) one day before each charge
- 🌐 **Offline-first**: Hive box for local storage, no network needed
- 🌍 **i18n** via `easy_localization` — bundled English & Russian
- 🌓 **Material 3** themed UI with light/dark surfaces

## 📦 Downloads

Pre-built binaries for every supported platform are available on the [Releases](../../releases) page:

| Platform | File |
|---|---|
| **Web** | `subtrack-web.zip` (static files) |
| **Windows** | `subtrack-windows-x64.zip` |
| **Linux** | `subtrack-linux-x64.tar.gz` |
| **macOS** | `subtrack-macos.dmg` (or `.zip`) |

> macOS builds are unsigned. First launch: right-click → Open → confirm.

## 🚀 Run from source

Requires **Flutter 3.11+** and the platform toolchain for the target OS.

```bash
flutter pub get
flutter run -d chrome          # Web
flutter run -d windows          # Windows desktop
flutter run -d linux            # Linux desktop
flutter run -d macos            # macOS desktop
```

## 🛠 Build release binaries

```bash
flutter build web --release                 # → build/web/
flutter build windows --release             # → build/windows/x64/runner/Release/
flutter build linux --release               # → build/linux/x64/release/bundle/
flutter build macos --release               # → build/macos/Build/Products/Release/
```

## 🌐 Host the web build for free

The web release is a static SPA. Drop `build/web/` into any of these (all have free tiers sufficient for a personal project):

- **[Vercel](https://vercel.com)** — easiest: `vercel deploy build/web --prod` or connect the GitHub repo
- **[Netlify](https://app.netlify.com/drop)** — drag-and-drop `build/web/`
- **[Cloudflare Pages](https://pages.cloudflare.com)** — connect GitHub, build command: `flutter build web --release`, output: `build/web`
- **[GitHub Pages](https://pages.github.com)** — push `build/web/` to the `gh-pages` branch

## 🧰 Tech stack

- [Flutter](https://flutter.dev) + Dart 3
- [Hive](https://pub.dev/packages/hive) for local storage
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) for state management
- [go_router](https://pub.dev/packages/go_router) for navigation
- [fl_chart](https://pub.dev/packages/fl_chart) for charts
- [easy_localization](https://pub.dev/packages/easy_localization) for i18n
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) for reminders

## 📂 Project layout

```
lib/
  main.dart                 # App entry point, Hive + i18n init
  models/                   # Plain data classes
  screens/                  # Top-level pages (Dashboard, Subscriptions, …)
  services/                 # Notification scheduling, template loading
  widgets/                  # Reusable UI (subscription dialog, …)
  features/                 # Feature-first slices (subscriptions, templates, …)
  core/                     # Errors, constants, extensions, utils
  app/                      # DI, router, theme
assets/
  translations/             # en.json, ru.json
  templates/                # Predefined subscription templates
```

## 🤝 Contributing

PRs welcome. For substantial changes, please open an issue first to discuss.

## 📄 License

MIT — see [LICENSE](LICENSE).
