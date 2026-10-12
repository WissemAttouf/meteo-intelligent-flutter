# 🌦️ Météo Simple

A weather application built with **Flutter** and **Dart** that lets users search for a city and view current weather conditions, weather details, and a five-day forecast.

<p align="center">
  <strong>Flutter · Dart · REST APIs · OpenWeather · Open-Meteo</strong>
</p>

## 📌 Overview

**Météo Simple** is a weather app with a French-localized interface and a dynamic background that adapts to weather conditions and day/night. It is built with Flutter and supports Web builds as well as Flutter's other supported targets.

## ✨ Features

- 🔎 **City search** — search for weather by city name.
- 🌡️ **Current conditions** — view temperature and a weather description.
- 💧 **Weather details** — humidity, wind speed, feels-like temperature, and sunrise/sunset times.
- 📅 **Five-day forecast** — see daily weather conditions and minimum/maximum temperatures.
- ⭐ **Favorite cities screen** — access the app's favorite-cities section.
- 🎨 **Dynamic weather UI** — weather-related icons, colors, and background gradients.
- 🇫🇷 **French date and locale formatting** — with English also listed as a supported locale.
- 🌐 **Web build support** — compile the app for browsers using Flutter Web.

## 🧰 Tech Stack

| Technology | Purpose |
| --- | --- |
| [Flutter](https://flutter.dev/) | Cross-platform UI framework |
| [Dart](https://dart.dev/) | Application programming language |
| [HTTP](https://pub.dev/packages/http) | HTTP requests to weather services |
| [Intl](https://pub.dev/packages/intl) | Date and locale-aware formatting |
| Flutter Localizations | Material, Widgets, and Cupertino localization |
| [OpenWeather](https://openweathermap.org/api) | City lookup / geocoding |
| [Open-Meteo](https://open-meteo.com/) | Weather and forecast data |

## 🚀 Getting Started

### Prerequisites

Install the following:

- Flutter SDK (stable channel recommended)
- Dart SDK compatible with your Flutter version
- Android Studio or Visual Studio Code
- A browser such as Chrome for Web testing

Check your setup:

```bash
flutter doctor
```

### 1. Clone the repository

```bash
git clone https://github.com/WissemAttouf/meteo-intelligent-flutter.git
cd meteo-intelligent-flutter
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure the weather API

The app uses OpenWeather for city lookup and Open-Meteo for forecast data. Configure a valid OpenWeather API key in the app's API configuration before running the project.

**Security note:** do not commit API keys or other secrets to a public repository. For a production release, move secrets out of source control and review the provider's terms and key restrictions.

### 4. Run the application

Run on a connected device:

```bash
flutter run
```

Run in Chrome:

```bash
flutter run -d chrome
```

## 🌐 Build for the Web

Create a production web build:

```bash
flutter build web
```

Flutter generates the deployable static files in:

```
build/web/
```

You can deploy the contents of this directory to a static web host such as Vercel. After changing the app, run `flutter build web` again before deploying the updated output.

## 🧪 Quality Checks

Run the project's tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

## 📁 Project Structure

```
lib/
├── config/       # API configuration
├── models/       # Weather data models
├── screens/      # Main and favorite-cities screens
├── services/     # Weather API requests
├── utils/        # Weather presentation and formatting helpers
└── main.dart     # Application entry point
web/              # Flutter Web entry point and web assets
```

## 👨‍💻 Author

**Wissem Attouf**  
Software Engineer | Full Stack Developer  
Tunis, Tunisia

- **GitHub:** [WissemAttouf](https://github.com/WissemAttouf)
- **LinkedIn:** [Wissem Attouf](https://www.linkedin.com/in/wissem-attouf-452509226/)
- **Email:** [wattouf35@gmail.com](mailto:wattouf35@gmail.com)
- **Portfolio:** [wissem-portfolio.vercel.app](https://wissem-portfolio.vercel.app/)

## 📄 License

No license has been specified in this repository yet. Contact the author before redistributing or reusing the project.

---

<p align="center">Built with Flutter and Dart ☁️</p>
