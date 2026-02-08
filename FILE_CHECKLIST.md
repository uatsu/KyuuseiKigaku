# File Checklist - Verify All Files Present

## Required Files for Build

Use this checklist to verify all files are present before building.

### ✅ App Entry Point (2 files)
- [ ] `KyuuseiKigaku/App/KyuuseiKigakuApp.swift` - Main @main app entry
- [ ] `KyuuseiKigaku/App/ContentView.swift` - Root navigation view

### ✅ Data Models (2 files)
- [ ] `KyuuseiKigaku/Models/UserProfile.swift` - SwiftData model for user
- [ ] `KyuuseiKigaku/Models/Reading.swift` - SwiftData model for readings

### ✅ Views (7 files)
- [ ] `KyuuseiKigaku/Views/HomeView.swift` - Main screen
- [ ] `KyuuseiKigaku/Views/InputView.swift` - Fortune input form
- [ ] `KyuuseiKigaku/Views/FakeAdView.swift` - 2-second ad simulation
- [ ] `KyuuseiKigaku/Views/ResultView.swift` - Shows Kigaku + fortune
- [ ] `KyuuseiKigaku/Views/HistoryView.swift` - List of readings
- [ ] `KyuuseiKigaku/Views/HistoryDetailView.swift` - Single reading detail
- [ ] `KyuuseiKigaku/Views/SettingsView.swift` - Profile editor

### ✅ Services (3 files)
- [ ] `KyuuseiKigaku/Services/KigakuCalculator.swift` - Honmei/Getsumei calculation
- [ ] `KyuuseiKigaku/Services/OpenAIService.swift` - AI fortune generation
- [ ] `KyuuseiKigaku/Services/LocationService.swift` - CoreLocation wrapper

### ✅ Utilities (1 file)
- [ ] `KyuuseiKigaku/Utils/I18n.swift` - Gettext .po parser

### ✅ Resources (4 files)
- [ ] `KyuuseiKigaku/Resources/i18n/ja.po` - Japanese (default)
- [ ] `KyuuseiKigaku/Resources/i18n/en.po` - English
- [ ] `KyuuseiKigaku/Resources/i18n/id.po` - Indonesian
- [ ] `KyuuseiKigaku/Resources/i18n/th.po` - Thai

### ✅ Configuration (1 file)
- [ ] `KyuuseiKigaku/Info.plist` - App configuration with location permission

### ✅ Documentation (5 files)
- [ ] `README.md` - Complete documentation
- [ ] `BUILD.md` - Detailed build instructions (THIS FILE IS CRITICAL)
- [ ] `QUICKSTART.md` - Quick reference
- [ ] `PROJECT_STRUCTURE.md` - Architecture overview
- [ ] `FILE_CHECKLIST.md` - This file

---

## Total File Count

- **Swift Source Files**: 15
- **Resource Files**: 4 (.po)
- **Configuration**: 1 (Info.plist)
- **Documentation**: 5 (.md)
- **TOTAL**: 25 files

---

## Quick Verification Command

If you have all files in a directory, run this from the project root:

```bash
# Count Swift files (should be 15)
find KyuuseiKigaku -name "*.swift" | wc -l

# Count .po files (should be 4)
find KyuuseiKigaku/Resources/i18n -name "*.po" | wc -l

# List all Swift files
find KyuuseiKigaku -name "*.swift" | sort

# List all .po files
find KyuuseiKigaku/Resources/i18n -name "*.po" | sort
```

---

## File Dependencies

### Critical Dependencies (Must exist for build)

1. **KyuuseiKigakuApp.swift** depends on:
   - UserProfile.swift (SwiftData model)
   - Reading.swift (SwiftData model)
   - ContentView.swift

2. **ContentView.swift** depends on:
   - HomeView.swift
   - SettingsView.swift
   - UserProfile.swift

3. **HomeView.swift** depends on:
   - I18n.swift
   - InputView.swift
   - HistoryView.swift

4. **InputView.swift** depends on:
   - I18n.swift
   - FakeAdView.swift

5. **FakeAdView.swift** depends on:
   - I18n.swift
   - ResultView.swift

6. **ResultView.swift** depends on:
   - I18n.swift
   - KigakuCalculator.swift
   - OpenAIService.swift
   - UserProfile.swift
   - Reading.swift
   - HomeView.swift

7. **HistoryView.swift** depends on:
   - I18n.swift
   - Reading.swift
   - HistoryDetailView.swift

8. **HistoryDetailView.swift** depends on:
   - I18n.swift
   - Reading.swift

9. **SettingsView.swift** depends on:
   - I18n.swift
   - UserProfile.swift
   - LocationService.swift

10. **KigakuCalculator.swift** depends on:
    - I18n.swift (for star names)

11. **OpenAIService.swift** depends on:
    - I18n.swift (for prompts and dummy template)

12. **LocationService.swift** depends on:
    - CoreLocation (iOS framework)

13. **I18n.swift** depends on:
    - All 4 .po files in Resources/i18n/

---

## Verification Steps

### Step 1: Verify File Presence
Check that all 25 files listed above exist in your project directory.

### Step 2: Verify File Contents
Ensure no file is empty or contains only comments:

```bash
# Find empty Swift files (should return nothing)
find KyuuseiKigaku -name "*.swift" -type f -empty

# Check file sizes (all should be > 0 bytes)
find KyuuseiKigaku -name "*.swift" -exec ls -lh {} \;
```

### Step 3: Verify .po File Format
Each .po file should:
- Start with header: `msgid ""`
- Contain multiple `msgid "key"` entries
- Have corresponding `msgstr "translation"` entries
- Be UTF-8 encoded

Example check:
```bash
# Count msgid entries in ja.po (should be ~50+)
grep -c "^msgid" KyuuseiKigaku/Resources/i18n/ja.po
```

### Step 4: Verify Info.plist
Info.plist must contain:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to provide accurate fortune readings based on your region.</string>
```

---

## Common Missing Files

If build fails, check these commonly forgotten files:

1. **.po files not added to target**
   - Symptom: "Cannot find i18n files" or all text shows as keys
   - Fix: Re-add .po files with "Copy items if needed" checked

2. **I18n.swift missing**
   - Symptom: "Cannot find 'I18n' in scope"
   - Fix: Add Utils/I18n.swift to project

3. **Model files missing**
   - Symptom: "Cannot find 'UserProfile' in scope"
   - Fix: Add both UserProfile.swift and Reading.swift

4. **Views not imported**
   - Symptom: "Cannot find 'HomeView' in scope"
   - Fix: Add all 7 view files to project

5. **Info.plist missing location key**
   - Symptom: Location request crashes app
   - Fix: Add NSLocationWhenInUseUsageDescription to Info.plist

---

## Build Success Indicators

When all files are correctly added, you should see:

✅ **No compiler errors**
✅ **App launches successfully**
✅ **Home screen displays with translations**
✅ **Settings can be opened**
✅ **Profile can be saved**
✅ **Fortune reading flow completes**

---

## Next Steps After Verification

Once all files are verified:

1. Follow **BUILD.md** for detailed build instructions
2. Run through the test scenarios in BUILD.md
3. Verify all features work as expected
4. (Optional) Add OpenAI API key for AI-powered readings

---

**All 25 files must be present for a successful build!**
