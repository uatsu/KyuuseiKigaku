# Complete Build Instructions for Kyuusei Kigaku Fortune App

## Overview

This is a COMPLETE, BUILDABLE iOS SwiftUI project. All source files, resources, and configurations are included.

## Prerequisites

- **macOS** with Xcode 15.0 or later
- **iOS 17.0+** deployment target
- **No external dependencies** - Pure Swift/SwiftUI

## Step-by-Step Build Instructions

### Step 1: Create New Xcode Project

1. Launch **Xcode**
2. Select **File** → **New** → **Project**
3. Choose **iOS** → **App** → **Next**
4. Configure the project:
   - **Product Name**: `KyuuseiKigaku`
   - **Team**: Select your team (or leave as "None" for simulator)
   - **Organization Identifier**: `com.kyuseikigaku` (or your own)
   - **Interface**: **SwiftUI**
   - **Storage**: **SwiftData** ✅ IMPORTANT
   - **Language**: **Swift**
   - **Include Tests**: Unchecked (optional)
5. Click **Next** and choose a location to save
6. Click **Create**

### Step 2: Set Project Configuration

1. In Project Navigator, select the **KyuuseiKigaku** project (blue icon at top)
2. Select the **KyuuseiKigaku** target
3. Go to **General** tab:
   - **Minimum Deployments**: Set to **iOS 17.0**
4. Go to **Info** tab:
   - Add key: **Privacy - Location When In Use Usage Description**
   - Value: `We need your location to provide accurate fortune readings based on your region.`

### Step 3: Add All Source Files

**Delete the default generated files first:**
- Delete `ContentView.swift` (we'll replace it)
- Keep `KyuuseiKigakuApp.swift` but we'll replace its contents

#### 3.1 App Files (Replace)

**File: `KyuuseiKigaku/App/KyuuseiKigakuApp.swift`**
- Location: Already exists at root of project
- Action: REPLACE with the provided file

**File: `KyuuseiKigaku/App/ContentView.swift`**
- Location: Root of project
- Action: CREATE NEW from provided file

#### 3.2 Create Folder Structure

In Xcode, create these groups (right-click → New Group):
```
KyuuseiKigaku/
├── App/               (move KyuuseiKigakuApp.swift and ContentView.swift here)
├── Models/            (create new)
├── Views/             (create new)
├── Services/          (create new)
├── Utils/             (create new)
└── Resources/         (create new)
    └── i18n/          (create new inside Resources)
```

#### 3.3 Add Model Files

Create **Models** group, then add these files:

**Right-click Models** → **New File** → **Swift File**

1. `UserProfile.swift` - Copy contents from provided file
2. `Reading.swift` - Copy contents from provided file

#### 3.4 Add View Files

Create **Views** group, then add these files:

1. `HomeView.swift`
2. `InputView.swift`
3. `FakeAdView.swift`
4. `ResultView.swift`
5. `HistoryView.swift`
6. `HistoryDetailView.swift`
7. `SettingsView.swift`

#### 3.5 Add Service Files

Create **Services** group, then add these files:

1. `KigakuCalculator.swift`
2. `OpenAIService.swift`
3. `LocationService.swift`

#### 3.6 Add Utility Files

Create **Utils** group, then add:

1. `I18n.swift`

#### 3.7 Add Resource Files (.po files)

**IMPORTANT: These must be added as actual file references, not just group folders**

1. In Finder, create folder: `KyuuseiKigaku/Resources/i18n/`
2. Copy all 4 .po files to this folder:
   - `ja.po` (Japanese - default)
   - `en.po` (English)
   - `id.po` (Indonesian)
   - `th.po` (Thai)
3. In Xcode, right-click on the **Resources/i18n** group
4. Select **Add Files to "KyuuseiKigaku"...**
5. Navigate to the i18n folder and select ALL 4 .po files
6. **CHECK** these options:
   - ✅ "Copy items if needed"
   - ✅ "Create groups" (NOT folder references)
   - ✅ Add to target: KyuuseiKigaku
7. Click **Add**

### Step 4: Verify File Structure

Your Xcode project should now look like this:

```
KyuuseiKigaku
├── App
│   ├── KyuuseiKigakuApp.swift
│   └── ContentView.swift
├── Models
│   ├── UserProfile.swift
│   └── Reading.swift
├── Views
│   ├── HomeView.swift
│   ├── InputView.swift
│   ├── FakeAdView.swift
│   ├── ResultView.swift
│   ├── HistoryView.swift
│   ├── HistoryDetailView.swift
│   └── SettingsView.swift
├── Services
│   ├── KigakuCalculator.swift
│   ├── OpenAIService.swift
│   └── LocationService.swift
├── Utils
│   └── I18n.swift
└── Resources
    └── i18n
        ├── ja.po
        ├── en.po
        ├── id.po
        └── th.po
```

### Step 5: Configure OpenAI API Key (Optional)

The app works in **two modes**:

#### Mode 1: Dummy Mode (Default - No API Key)
- App generates fortune readings using a template
- No internet required
- Good for testing

#### Mode 2: OpenAI Mode (Requires API Key)
- App uses GPT-3.5-turbo for AI-generated fortunes
- Requires internet connection

**To enable OpenAI mode:**

1. Get an OpenAI API key from https://platform.openai.com/api-keys
2. In Xcode, select **Product** → **Scheme** → **Edit Scheme...**
3. Select **Run** on the left
4. Go to **Arguments** tab
5. Under **Environment Variables**, click **+**
6. Add:
   - **Name**: `OPENAI_API_KEY`
   - **Value**: `sk-...` (your actual API key)
7. Click **Close**

**Security Note:** The API key is stored in the scheme and NOT in code or version control.

### Step 6: Build and Run

1. Select a simulator or connected device:
   - Recommended: **iPhone 15** or **iPhone 15 Pro** simulator
   - Or any physical device running iOS 17.0+

2. Press **Cmd + R** or click the **Play** button

3. If you get build errors:
   - Clean Build Folder: **Product** → **Clean Build Folder** (Cmd+Shift+K)
   - Rebuild: **Product** → **Build** (Cmd+B)

### Step 7: First Run Setup

When the app launches for the first time:

1. You'll see the home screen
2. **IMPORTANT**: Tap the **Settings gear icon** (top-right)
3. Enter your profile information:
   - **Name**: Your name
   - **Gender**: Select one
   - **Birth Date**: Your birth date (this is used for Kigaku calculation)
   - **Prefecture**: e.g., "Tokyo" (optional)
   - **Municipality**: e.g., "Shibuya" (optional)
4. Tap **Save**

**Why this is required:** The Kigaku calculation needs your birth date. Without a profile, the app cannot generate readings.

### Step 8: Test the App

#### Test 1: Basic Fortune Reading
1. From home screen, tap **"Get New Reading"** (新しい占いをする)
2. Select a category: Love, Work, Health, Money, or General
3. Enter a question (max 200 characters)
4. Tap **"Get Fortune"** (占う)
5. Watch the 2-second fake ad
6. View your Kigaku results:
   - **Honmei Star** (本命星): Main destiny number
   - **Getsumei Star** (月命星): Monthly destiny number
   - Fortune reading text (from OpenAI or dummy)

#### Test 2: Kigaku Calculation Verification

Test the **Risshun boundary** (Feb 4):

**Example 1: Born January 15, 1990**
- Expected: Uses year **1989** for calculation (before Feb 4)
- Honmei/Getsumei will be based on 1989

**Example 2: Born February 10, 1990**
- Expected: Uses year **1990** for calculation (after Feb 4)
- Honmei/Getsumei will be based on 1990

#### Test 3: History
1. Create 2-3 different readings
2. Go back to home
3. Tap **"View History"** (履歴を見る)
4. Verify all readings are listed
5. Tap any reading to see full details
6. Swipe left on a reading to delete it

#### Test 4: Multilingual Support
1. Change device language:
   - iOS Settings → General → Language & Region
   - Add and select: English, Indonesian (Bahasa Indonesia), or Thai (ภาษาไทย)
2. Reopen the app
3. Verify UI is in the selected language
4. Change back to Japanese to see original text

#### Test 5: Location (Optional)
1. Go to Settings in app
2. Toggle **"Use Current Location"** ON
3. Grant location permission when prompted
4. Tap **"Get Current Location"**
5. Verify prefecture and municipality are filled
6. Save and create a new reading
7. Check that region is saved in reading

## Troubleshooting

### Build Error: "Cannot find 'I18n' in scope"

**Solution:**
- Verify `Utils/I18n.swift` is added to the target
- Select the file in Project Navigator
- Check **Target Membership** in File Inspector (right panel)
- Ensure **KyuuseiKigaku** is checked

### Build Error: "Cannot find type 'UserProfile'"

**Solution:**
- Verify all Model files are added to target
- Clean build folder (Cmd+Shift+K)
- Rebuild (Cmd+B)

### Runtime Error: "No po files found" or translations showing as keys

**Solution:**
1. Verify .po files are in the project
2. Check they're added to the target:
   - Select each .po file
   - In File Inspector, check **Target Membership**
   - Ensure **KyuuseiKigaku** is checked
3. If still not working:
   - Delete .po files from Xcode (Keep reference)
   - Re-add using **Add Files...** with "Copy items if needed" checked

### App Error: "profiles.first is nil" or crash when creating reading

**Solution:**
- Go to Settings and create your profile
- Enter at least: name and birth date
- Tap Save
- Try creating a reading again

### Location not working

**Solution:**
1. Check Info.plist has location permission key
2. Test on real device (simulator location is limited)
3. Check iOS Settings → Privacy → Location Services
4. Verify app has permission

### OpenAI not working (using dummy readings)

**Expected behavior if:**
- No API key configured (this is normal)
- Invalid API key
- No internet connection
- OpenAI API is down

**To verify OpenAI is being used:**
- Check console logs in Xcode for "OpenAI API error:"
- Readings from OpenAI are typically longer and more specific
- Dummy readings always follow the template pattern

## File Descriptions

### Core App Files

| File | Purpose |
|------|---------|
| `KyuuseiKigakuApp.swift` | App entry point, SwiftData container setup |
| `ContentView.swift` | Root view with navigation and profile initialization |

### Data Models (SwiftData)

| File | Purpose |
|------|---------|
| `UserProfile.swift` | User info: name, gender, birthDate, prefecture, municipality, locationPermission |
| `Reading.swift` | Fortune reading record with Kigaku numbers and text |

### Views

| File | Purpose |
|------|---------|
| `HomeView.swift` | Main screen with "New Reading" and "View History" buttons |
| `InputView.swift` | Fortune input form: category picker, question TextEditor (200 chars max) |
| `FakeAdView.swift` | 2-second countdown timer simulating reward ad |
| `ResultView.swift` | Displays Kigaku numbers (Honmei/Getsumei) and fortune text |
| `HistoryView.swift` | List of past readings, swipe-to-delete |
| `HistoryDetailView.swift` | Full details of a single reading |
| `SettingsView.swift` | Profile editor: name, gender, birthdate, location, language |

### Services

| File | Purpose |
|------|---------|
| `KigakuCalculator.swift` | Calculates Honmei/Getsumei with Risshun boundary (Feb 4) |
| `OpenAIService.swift` | Generates fortunes via GPT-3.5-turbo or dummy template |
| `LocationService.swift` | CoreLocation wrapper for reverse geocoding |

### Utilities

| File | Purpose |
|------|---------|
| `I18n.swift` | Gettext .po parser, I18n.t("key") function, fallback logic |

### Resources

| File | Language | Purpose |
|------|----------|---------|
| `ja.po` | Japanese | Default translations (fallback) |
| `en.po` | English | English translations |
| `id.po` | Indonesian | Indonesian translations |
| `th.po` | Thai | Thai translations |

## Architecture Summary

### Data Flow

```
User Input (InputView)
    ↓
Fake Ad (2s countdown)
    ↓
Calculate Kigaku (KigakuCalculator)
    ↓
Generate Fortune (OpenAIService)
    ↓
Display Result (ResultView)
    ↓
Save to SwiftData (Reading model)
    ↓
View in History (HistoryView)
```

### i18n Flow

```
App Launch
    ↓
I18n.swift loads all .po files
    ↓
Detect device locale (ja/en/id/th)
    ↓
I18n.t("key") looks up translation
    ↓
Fallback: current locale → ja → show key
```

### Kigaku Calculation

```
Input: Birth Date
    ↓
Apply Risshun Rule: if before Feb 4, use previous year
    ↓
Calculate Honmei: sum_digits(year + month + day) → reduce to 1-9
    ↓
Calculate Getsumei: sum_digits(honmei + day) → reduce to 1-9
    ↓
Map to Japanese names (e.g., 1 = 一白水星)
    ↓
Return KigakuResult
```

## Nine Stars (Kigaku) Reference

| Number | Japanese Name | Romanization |
|--------|---------------|--------------|
| 1 | 一白水星 | Ippaku Suisei |
| 2 | 二黒土星 | Jikoku Dosei |
| 3 | 三碧木星 | Sanpeki Mokusei |
| 4 | 四緑木星 | Shiroku Mokusei |
| 5 | 五黄土星 | Goo Dosei |
| 6 | 六白金星 | Roppaku Kinsei |
| 7 | 七赤金星 | Shichiseki Kinsei |
| 8 | 八白土星 | Happaku Dosei |
| 9 | 九紫火星 | Kyushi Kasei |

## API Reference

### OpenAI Integration

**Endpoint:** `https://api.openai.com/v1/chat/completions`
**Model:** `gpt-3.5-turbo`
**Max Tokens:** 500
**Temperature:** 0.8

**Request Format:**
```json
{
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "user",
      "content": "<localized prompt from i18n>"
    }
  ],
  "max_tokens": 500,
  "temperature": 0.8
}
```

**Dummy Mode Trigger:**
- No `OPENAI_API_KEY` environment variable
- Empty API key
- API request fails (network error, invalid key, etc.)

## Testing Checklist

Before submitting or distributing:

- [ ] App builds without errors
- [ ] Profile can be created and saved
- [ ] Fortune reading flow works end-to-end
- [ ] Kigaku calculation is correct (test Feb 4 boundary)
- [ ] History saves and displays readings
- [ ] History detail view shows all info
- [ ] Swipe-to-delete works in history
- [ ] Settings can update profile
- [ ] All 5 categories work (Love, Work, Health, Money, General)
- [ ] 200-character limit enforced in input
- [ ] Fake ad shows 2-second countdown
- [ ] Dummy mode works (no API key)
- [ ] OpenAI mode works (with valid API key)
- [ ] Location permission can be granted
- [ ] Reverse geocoding populates prefecture/municipality
- [ ] Manual location input works
- [ ] App works in Japanese (default)
- [ ] App works in English
- [ ] App works in Indonesian
- [ ] App works in Thai
- [ ] Translations fall back to Japanese if missing
- [ ] No crashes or errors in console

## Project Status

✅ **MVP Complete**
- Full fortune reading flow
- Kigaku calculation with Risshun boundary
- Gettext i18n (4 languages)
- SwiftData persistence
- CoreLocation integration
- OpenAI integration with fallback
- Fake reward ad (2-second timer)
- Complete history management
- Settings and profile

🚧 **Not Included (Future)**
- Real AdMob integration
- Advanced Kigaku calculations (solar terms)
- Cloud sync
- Social sharing
- Push notifications
- Premium features

## Support

For issues or questions:
1. Check this BUILD.md file
2. Review QUICKSTART.md for quick reference
3. Check README.md for detailed documentation
4. Review PROJECT_STRUCTURE.md for architecture

## License

Copyright © 2024. All rights reserved.

---

**Ready to build!** Follow the steps above and the app will compile and run successfully in Xcode.
