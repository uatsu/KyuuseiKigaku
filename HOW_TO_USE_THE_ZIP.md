# How to Use KyuuseiKigaku.zip

## Quick Start (3 Steps)

### 1. Download
Download `KyuuseiKigaku.zip` from this project

### 2. Extract
Double-click `KyuuseiKigaku.zip` to extract it

### 3. Open in Xcode
Navigate to the extracted folder and double-click:
```
KyuuseiKigaku/KyuuseiKigaku.xcodeproj
```

This will open the complete project in Xcode.

## What's Inside

The ZIP contains a **complete, ready-to-run Xcode project**:

```
KyuuseiKigaku/
├── KyuuseiKigaku.xcodeproj/     ← Double-click this to open in Xcode
│   └── project.pbxproj
├── KyuuseiKigaku/               ← Source code
│   ├── App/
│   │   ├── KyuuseiKigakuApp.swift
│   │   └── ContentView.swift
│   ├── Models/
│   │   ├── Reading.swift
│   │   └── UserProfile.swift
│   ├── Views/
│   │   ├── HomeView.swift
│   │   ├── InputView.swift
│   │   ├── ResultView.swift
│   │   ├── HistoryView.swift
│   │   ├── HistoryDetailView.swift
│   │   ├── SettingsView.swift
│   │   └── FakeAdView.swift
│   ├── Services/
│   │   ├── KigakuCalculator.swift
│   │   ├── LocationService.swift
│   │   └── OpenAIService.swift
│   ├── Utils/
│   │   └── I18n.swift
│   ├── Resources/
│   │   └── i18n/
│   │       ├── ja.po (Japanese)
│   │       ├── en.po (English)
│   │       ├── id.po (Indonesian)
│   │       └── th.po (Thai)
│   └── Info.plist
├── README.md
├── GITHUB_SETUP.md
└── .gitignore
```

## Running the App

1. **Open in Xcode**: Double-click `KyuuseiKigaku.xcodeproj`
2. **Select Target Device**: Choose an iOS Simulator or connected device
3. **Build & Run**: Press `Cmd + R` or click the Play button

## Requirements

- **Xcode**: 15.0 or later
- **macOS**: Sonoma (14.0) or later
- **iOS Deployment Target**: 17.0+

## Features Included

✅ **Complete Kigaku Calculator**
- Honmei (本命) calculation using correct formula: `11 - (year % 9)`
- Getsumei (月命) monthly star calculation
- Nissei (日精) daily energy calculation

✅ **SwiftUI + SwiftData**
- Modern SwiftUI interface
- SwiftData for local persistence
- Reading history with detailed view

✅ **Internationalization (i18n)**
- Japanese (ja)
- English (en)
- Indonesian (id)
- Thai (th)
- Uses gettext .po format
- Runtime language switching

✅ **OpenAI Integration**
- Fortune reading generation
- Fallback to dummy data if API key not provided
- Configurable in Settings

✅ **Location Services**
- Automatic location detection
- Timezone-aware calculations
- Manual location input option

## No Manual Setup Required

This is a **complete Xcode project**. You do NOT need to:
- ❌ Create a new Xcode project
- ❌ Add files manually
- ❌ Configure build settings
- ❌ Set up targets or schemes

Everything is pre-configured and ready to build.

## Testing Without OpenAI Key

The app works perfectly without an OpenAI API key:
- Uses intelligent fallback fortune readings
- All features remain functional
- Add API key in Settings when ready

## Git Repository (Optional)

The project includes `.gitignore` and is git-ready. To initialize:

```bash
cd KyuuseiKigaku
git init
git branch -m main
git add .
git commit -m "Initial commit"
```

Then push to GitHub or any git hosting service.

---

**Need Help?** Check `README.md` inside the extracted folder for detailed documentation.
