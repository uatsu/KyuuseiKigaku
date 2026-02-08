# How to Open and Run This Project in Xcode

## ✅ This is a Complete Xcode Project

Unlike the previous delivery, this now includes:
- ✅ **KyuuseiKigaku.xcodeproj** - Complete Xcode project file
- ✅ All source files properly referenced
- ✅ Build settings configured
- ✅ Ready to open and run immediately

---

## 🚀 Quick Start (2 Steps)

### Step 1: Open the Project

**Option A: Double-click**
```
Navigate to: KyuuseiKigaku/
Double-click: KyuuseiKigaku.xcodeproj
```

**Option B: Command line**
```bash
cd KyuuseiKigaku/
open KyuuseiKigaku.xcodeproj
```

**Option C: From Xcode**
```
Xcode → File → Open → Select KyuuseiKigaku.xcodeproj
```

### Step 2: Build and Run

1. Select a simulator (iPhone 15 recommended) or your device
2. Press **Cmd + R** or click the Play button
3. App will build and launch

**That's it!** No manual project creation needed.

---

## 📋 What's Included

### Project Structure
```
KyuuseiKigaku/
├── KyuuseiKigaku.xcodeproj/    ← XCODE PROJECT (NEW!)
│   └── project.pbxproj
└── KyuuseiKigaku/
    ├── App/
    ├── Models/
    ├── Views/
    ├── Services/
    ├── Utils/
    ├── Resources/i18n/
    └── Info.plist
```

### All Files Properly Referenced

The .xcodeproj includes references to:
- ✅ 15 Swift source files
- ✅ 4 .po translation files
- ✅ Info.plist with location permission
- ✅ Proper build phases (Sources, Resources, Frameworks)
- ✅ iOS 17.0 deployment target
- ✅ SwiftUI + SwiftData enabled

---

## ⚙️ Configuration (Optional)

### OpenAI API Key (Optional)

To enable AI-powered fortune readings:

1. **Get API Key**: https://platform.openai.com/api-keys
2. **In Xcode**: Product → Scheme → Edit Scheme
3. **Run → Arguments → Environment Variables**
4. **Add**:
   - Name: `OPENAI_API_KEY`
   - Value: `sk-...` (your key)

**Without API key**: App uses dummy fortune readings (works great!)

---

## 🔧 Build Settings

### Pre-configured Settings

- **iOS Deployment Target**: 17.0
- **Interface**: SwiftUI
- **Storage**: SwiftData
- **Language**: Swift 5.0
- **Bundle ID**: com.kyuseikigaku.app
- **Development Region**: Japanese (ja)
- **Supported Regions**: ja, en, id, th

### If Build Fails

1. **Clean Build Folder**
   ```
   Product → Clean Build Folder (Cmd+Shift+K)
   ```

2. **Verify Deployment Target**
   ```
   Target → General → Minimum Deployments → iOS 17.0
   ```

3. **Check Simulator/Device**
   ```
   Must be running iOS 17.0 or later
   ```

4. **Reset Package Cache** (if needed)
   ```
   File → Packages → Reset Package Caches
   ```

---

## 📱 First Run

### Initial Setup Required

When the app launches for the first time:

1. You'll see the home screen
2. **Tap Settings** (gear icon in top-right)
3. **Enter your profile**:
   - Name: Required
   - Gender: Required
   - Birth Date: **Required** (used for Kigaku calculation)
   - Prefecture: Optional
   - Municipality: Optional
4. **Tap Save**

**Why required?** The Kigaku calculation needs your birth date to compute Honmei and Getsumei stars.

### Test the App

1. Go back to home
2. Tap **"新しい占いをする"** (Get New Reading)
3. Select category (Love, Work, Health, Money, General)
4. Enter your question (max 200 characters)
5. Tap **"占う"** (Get Fortune)
6. Watch 2-second fake ad
7. View your results:
   - Honmei Star (本命星)
   - Getsumei Star (月命星)
   - Fortune reading
8. Reading is auto-saved to History

---

## 🧪 Verification Tests

### Test 1: Kigaku Calculation

**Verify Risshun boundary (Feb 4):**

| Birth Date | Expected Adjusted Year | Expected Honmei |
|------------|----------------------|-----------------|
| Jan 15, 1990 | 1989 | 2 (二黒土星) |
| Feb 3, 1990 | 1989 | 2 (二黒土星) |
| Feb 4, 1990 | 1990 | 1 (一白水星) |
| Feb 5, 1990 | 1990 | 1 (一白水星) |

**How to test:**
1. Go to Settings
2. Change birth date
3. Create a new reading
4. Check the Honmei number matches expected value

### Test 2: Multi-language

1. iOS Settings → General → Language & Region
2. Change to English/Indonesian/Thai
3. Reopen app
4. Verify UI is in selected language
5. Create a reading and verify all text is translated

### Test 3: History

1. Create 3 different readings
2. Go to History
3. Verify all 3 are listed
4. Tap one to see details
5. Swipe left to delete
6. Verify it's removed

---

## 🎯 Kigaku Calculation Details

### Honmei (本命星)

**Formula (deterministic):**
```
adjustedYear = (month < 2 OR (month == 2 AND day < 4)) ? year - 1 : year
honmei = 11 - (adjustedYear % 9)
if honmei > 9: honmei -= 9
if honmei == 0: honmei = 9
```

**This is the standard Kyusei Kigaku formula.**

### Getsumei (月命星)

**Simplified calculation:**
```
monthOffset = [2, 5, 8, 2, 5, 8, 2, 5, 8, 2, 5, 8]
offset = monthOffset[month - 1]
getsumei = honmei + offset
while getsumei > 9: getsumei -= 9
```

**IMPORTANT:** This is a simplified monthly star for MVP.
- NOT traditional solar term-based calculation
- Deterministic and consistent
- Suitable for entertainment purposes
- See `KIGAKU_CALCULATION_NOTES.md` for details

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| **OPEN_IN_XCODE.md** | This file - how to open & run |
| **KIGAKU_CALCULATION_NOTES.md** | Detailed calculation formulas |
| **BUILD.md** | Build instructions & troubleshooting |
| **README.md** | Full project documentation |

---

## 🆘 Troubleshooting

### "Cannot find 'I18n' in scope"
- This shouldn't happen with .xcodeproj
- If it does: Clean build folder (Cmd+Shift+K)

### "No such file" errors
- Verify you opened KyuuseiKigaku.xcodeproj
- NOT the folder, the .xcodeproj file itself

### Build succeeds but app crashes
- Check console for errors
- Most likely: Profile not created
- Solution: Go to Settings and create profile

### Location not working
- Normal on simulator (limited location simulation)
- Test on real device for full functionality
- Manually enter prefecture/municipality as fallback

### Translations showing as keys
- This shouldn't happen with .xcodeproj
- .po files should be included as resources
- If it happens: Verify .po files are in Resources/i18n/

---

## ✅ Success Checklist

After opening the project:

- [ ] Xcode opened without errors
- [ ] All files visible in Project Navigator
- [ ] No missing file warnings
- [ ] Build succeeds (Cmd+B)
- [ ] App launches on simulator/device
- [ ] Home screen displays with Japanese text
- [ ] Settings can be opened
- [ ] Profile can be saved
- [ ] Fortune reading completes end-to-end
- [ ] Kigaku numbers display correctly
- [ ] History saves readings

---

## 🎉 You're Ready!

This is a **complete, buildable Xcode project**.

- ✅ No manual project creation
- ✅ No file copying needed
- ✅ Just open and run

**Enjoy the app!**

---

**Questions?** See `BUILD.md` for detailed troubleshooting.

**Kigaku Details?** See `KIGAKU_CALCULATION_NOTES.md` for formula explanations.
