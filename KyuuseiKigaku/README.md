# Kyuusei Kigaku Fortune App

A SwiftUI iOS application for Kyusei Kigaku (Nine Star Ki) fortune readings, built with SwiftData for local persistence and gettext for internationalization.

## Features

- **Kyusei Kigaku Calculation**: Deterministic calculation of:
  - **Honmei (本命星)**: Life Star based on birth year (with Risshun boundary)
  - **Getsumei (月命星)**: Month Star based on birth month
  - **Nichimei (日命星)**: Daily Star based on 9-day cyclic rotation
- **Fortune Readings**: AI-powered or dummy fortune readings based on your birth chart
- **Multi-language Support**: Japanese (default), English, Indonesian, Thai using gettext .po files
- **Local Data Persistence**: SwiftData for user profiles and reading history
- **Location Services**: Optional location-based readings
- **Ad Flow**: Simulated reward ad before showing results

## Requirements

- **Xcode**: 15.0 or later
- **iOS**: 17.0 or later
- **macOS**: Ventura 13.0 or later (for development)
- **Swift**: 5.9 or later

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/kyuusei-kigaku-app.git
cd kyuusei-kigaku-app
```

### 2. Open in Xcode

```bash
open KyuuseiKigaku.xcodeproj
```

Or double-click `KyuuseiKigaku.xcodeproj` in Finder.

### 3. Build and Run

1. Select a simulator (iPhone 15 recommended) or your device
2. Press `Cmd+R` or click the Play button
3. The app will build and launch

**That's it!** No additional setup required for basic functionality.

## Optional: OpenAI API Configuration

By default, the app uses dummy fortune readings. To enable AI-powered readings:

### Get an API Key

1. Sign up at [OpenAI Platform](https://platform.openai.com/)
2. Navigate to [API Keys](https://platform.openai.com/api-keys)
3. Create a new secret key

### Configure in Xcode

1. In Xcode, go to **Product → Scheme → Edit Scheme...**
2. Select **Run** in the left sidebar
3. Go to the **Arguments** tab
4. Under **Environment Variables**, click **+**
5. Add:
   - Name: `OPENAI_API_KEY`
   - Value: `sk-...` (your API key)
6. Click **Close**

**Without API key:** App uses dummy readings (works perfectly for testing)

## First Launch

When you first run the app:

1. The home screen appears
2. Tap the **Settings** icon (gear in top-right)
3. Enter your profile:
   - **Name**: Required
   - **Gender**: Required
   - **Birth Date**: **Required** (used for Kigaku calculation)
   - **Prefecture**: Optional
   - **Municipality**: Optional
4. Tap **Save**

**Why required?** The birth date is essential for calculating your Honmei and Getsumei stars.

## Using the App

### Get a Fortune Reading

1. From home, tap **"新しい占いをする"** (Get New Reading)
2. Select a category:
   - 恋愛 (Love)
   - 仕事 (Work)
   - 健康 (Health)
   - 金運 (Money)
   - 総合 (General)
3. Enter your question (max 200 characters)
4. Tap **"占う"** (Get Fortune)
5. Watch the 2-second simulated ad
6. View your results with Honmei and Getsumei stars
7. Reading is automatically saved to History

### View History

1. Tap **"履歴を見る"** (View History) from home
2. See all your past readings
3. Tap any reading to view details
4. Swipe left to delete

### Change Language

1. Go to **iOS Settings → General → Language & Region**
2. Change device language to English/Indonesian/Thai
3. Reopen the app
4. All UI text will be in the selected language

## Project Structure

```
KyuuseiKigaku/
├── KyuuseiKigaku.xcodeproj/      # Xcode project
└── KyuuseiKigaku/
    ├── App/
    │   ├── KyuuseiKigakuApp.swift     # App entry point
    │   └── ContentView.swift          # Root view
    ├── Models/
    │   ├── UserProfile.swift          # User profile model (SwiftData)
    │   └── Reading.swift              # Reading history model (SwiftData)
    ├── Views/
    │   ├── HomeView.swift             # Home screen
    │   ├── InputView.swift            # Question input
    │   ├── FakeAdView.swift           # Simulated ad
    │   ├── ResultView.swift           # Fortune result
    │   ├── HistoryView.swift          # Reading history list
    │   ├── HistoryDetailView.swift    # Reading detail
    │   └── SettingsView.swift         # User settings
    ├── Services/
    │   ├── KigakuCalculator.swift     # Kigaku calculation logic
    │   ├── OpenAIService.swift        # OpenAI API integration
    │   └── LocationService.swift      # Location services
    ├── Utils/
    │   └── I18n.swift                 # Internationalization (gettext)
    ├── Resources/i18n/
    │   ├── ja.po                      # Japanese translations
    │   ├── en.po                      # English translations
    │   ├── id.po                      # Indonesian translations
    │   └── th.po                      # Thai translations
    └── Info.plist                     # App configuration
```

## Kigaku Calculation

### Honmei (本命星) - Life Star

**Formula:**

```swift
// Adjust year for Risshun boundary (Feb 4)
adjustedYear = (month < 2 || (month == 2 && day < 4)) ? year - 1 : year

// Calculate Honmei (1-9)
honmei = 11 - (adjustedYear % 9)
if honmei > 9: honmei -= 9
if honmei == 0: honmei = 9
```

**Examples:**

| Birth Date | Adjusted Year | Honmei | Star |
|------------|---------------|--------|------|
| Jan 15, 1990 | 1989 | 2 | 二黒土星 |
| Feb 3, 1990 | 1989 | 2 | 二黒土星 |
| Feb 4, 1990 | 1990 | 1 | 一白水星 |
| Dec 25, 1990 | 1990 | 1 | 一白水星 |

**This is the standard Kyusei Kigaku formula.**

### Getsumei (月命星) - Monthly Star

**Note:** This implementation uses a **simplified monthly star calculation** for MVP purposes.

**Formula:**

```swift
monthOffset = [2, 5, 8, 2, 5, 8, 2, 5, 8, 2, 5, 8]
offset = monthOffset[month - 1]
getsumei = honmei + offset
while getsumei > 9: getsumei -= 9
```

**Limitation:** This is NOT traditional solar term-based Getsumei. It's a simplified deterministic calculation suitable for entertainment fortune reading.

For detailed calculation notes, see [KIGAKU_CALCULATION_NOTES.md](../KIGAKU_CALCULATION_NOTES.md) in the parent directory.

## Nine Stars (九星)

| Number | Japanese | English | Element |
|--------|----------|---------|---------|
| 1 | 一白水星 | One White Water Star | Water |
| 2 | 二黒土星 | Two Black Earth Star | Earth |
| 3 | 三碧木星 | Three Blue Wood Star | Wood |
| 4 | 四緑木星 | Four Green Wood Star | Wood |
| 5 | 五黄土星 | Five Yellow Earth Star | Earth |
| 6 | 六白金星 | Six White Metal Star | Metal |
| 7 | 七赤金星 | Seven Red Metal Star | Metal |
| 8 | 八白土星 | Eight White Earth Star | Earth |
| 9 | 九紫火星 | Nine Purple Fire Star | Fire |

## Internationalization

This app uses **gettext .po files** for translations, NOT `Localizable.strings`.

### Translation Files

All translations are in `Resources/i18n/*.po`:
- `ja.po` - Japanese (default)
- `en.po` - English
- `id.po` - Indonesian
- `th.po` - Thai

### How It Works

The app includes a custom `I18n.swift` utility that:
1. Detects device language
2. Parses the appropriate .po file
3. Provides translations via `I18n.t("key")`
4. Falls back to Japanese if key not found

### All Strings Are Internationalized

- ✅ All UI strings use `I18n.t("key")`
- ✅ OpenAI prompts from i18n
- ✅ Dummy reading templates from i18n
- ✅ Kigaku star names from i18n
- ✅ No hardcoded Japanese/English in Swift files

## Development

### Technologies Used

- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Local data persistence
- **Combine**: Reactive programming
- **CoreLocation**: Location services
- **URLSession**: Network requests
- **Gettext**: i18n via .po files

### Build Configuration

- **Deployment Target**: iOS 17.0
- **Language**: Swift 5.9
- **Interface**: SwiftUI
- **Development Region**: Japanese (ja)

### Testing

To verify Kigaku calculations:

1. Go to Settings
2. Set birth date to **January 15, 1990**
3. Create a reading
4. **Expected Honmei**: 2 (二黒土星) ✓

5. Change birth date to **February 4, 1990**
6. Create a reading
7. **Expected Honmei**: 1 (一白水星) ✓

## Troubleshooting

### Build Errors

**Clean build folder:**
```
Product → Clean Build Folder (Cmd+Shift+K)
```

**Check deployment target:**
- Must be iOS 17.0 or later

### Location Not Working

- Normal on simulator (limited simulation)
- Test on real device for full functionality
- Manual entry available as fallback

### Translations Not Loading

- Verify .po files are in `Resources/i18n/`
- Check they're included in Copy Bundle Resources
- Clean and rebuild

## License

This project is provided as-is for educational and entertainment purposes.

## Acknowledgments

- Kyusei Kigaku (九星気学) traditional calculation methods
- OpenAI GPT for fortune reading generation (optional)
- Gettext for internationalization

## Support

For issues or questions:
- Check [KIGAKU_CALCULATION_NOTES.md](../KIGAKU_CALCULATION_NOTES.md) for formula details
- See [BUILD.md](../BUILD.md) for build troubleshooting

---

**Made with SwiftUI** | **iOS 17.0+** | **Swift 5.9+**
