# Integration Guide: Setting Up the Psoriatlas App in Xcode

## Prerequisites

- Xcode 14.0 or later
- iOS 14.0 or later deployment target
- Swift 5.9 or later
- Apple Developer Account (for App Store distribution)

## Step-by-Step Setup

### 1. Create a New iOS App Project

```bash
# In Xcode:
File → New → Project
Select iOS → App
Product Name: Psoriatlas
Organization Identifier: com.yourcompany.psoriatlas (update as needed)
Team: Select your Apple Developer Team
Interface: SwiftUI
Language: Swift
Include Tests: Optional
```

### 2. Link SQLite3 Framework

This is **critical** for the database to work:

1. Select the project in Xcode navigator
2. Select the target "Psoriatlas"
3. Go to Build Phases
4. Expand "Link Binary With Libraries"
5. Click the "+" button
6. Search for "libsqlite3.tbd"
7. Select and click "Add"

Verify the library appears in the list.

### 3. Copy Source Files

Copy all Swift files to your project:

```
Models/
  └── Drug.swift
Database/
  ├── DatabaseManager.swift
  └── DrugSeedData.swift
Views/
  ├── ContentView.swift
  ├── DrugRowView.swift
  ├── DrugDetailView.swift
  ├── SearchBarView.swift
  └── FilterButtonsView.swift
ViewModels/
  ├── DrugListViewModel.swift
  └── DrugDetailViewModel.swift
Utilities/
  └── DateFormatters.swift
```

**Important:** When copying files into Xcode:
- Right-click the project folder in Xcode
- Select "Add Files to Psoriatlas"
- Select all the Swift files
- Ensure "Copy items if needed" is checked
- Select target "Psoriatlas"
- Choose "Create groups" for folder structure

### 4. Update the App Entry Point

Replace the contents of the auto-generated app file (usually `PsoriasisDrugDatabaseApp.swift` or similar):

```swift
import SwiftUI

@main
struct PsoriasisDrugDatabaseApp: App {
    @StateObject private var databaseManager = DatabaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(databaseManager)
        }
    }
}
```

### 5. Build and Run

1. Select your target device or simulator (iOS 14+)
2. Press Cmd+R or Product → Run
3. The app should launch with the drug database pre-populated

If you see build errors:
- Verify SQLite3 framework is linked (Step 2)
- Check that all files are in the correct folders
- Ensure Swift version is 5.9+

## Configuration

### Deployment Target

1. Select Project → Build Settings
2. Search for "iOS Deployment Target"
3. Set to 14.0 or your preferred minimum version
4. Repeat for the target

### App Display Name

Go to Build Settings and configure:
- Bundle Display Name: "Psoriatlas"
- Product Bundle Identifier: "com.yourcompany.psoriatlas"

### App Icon

1. Open Assets.xcassets
2. Select AppIcon
3. Drag your app icon (1024x1024 PNG) to the "iPhone App" slot
4. Xcode will generate all other sizes automatically

### Launch Screen (Optional)

To customize the launch screen:
1. File → New → File → Launch Screen
2. Add your branding
3. In Build Settings, set Launch Screen File Name to your custom file

## Testing the App

### Verify Database

1. Run the app
2. Check Console output for:
   - "✅ Database opened successfully"
   - "✅ Tables created successfully"
   - "✅ Loaded XX drugs" (should be 40+)

### Test Features

- [ ] Search works (type in search bar)
- [ ] Filters work (tap filter buttons)
- [ ] Can tap drugs to see details
- [ ] Heart icon toggles favorites
- [ ] Works offline (all data is local)

## Preparing for App Store

### 1. Create Certificates and Profiles

- Go to developer.apple.com
- Create Development and Distribution certificates
- Create App Store provisioning profiles

### 2. App Store Metadata

In Xcode:
- Product → Scheme → Edit Scheme
- Archive to validate your build
- Once validated, upload to App Store Connect

Required metadata:
- **App Name:** Psoriatlas
- **Subtitle:** FDA-Approved Psoriasis Treatment Reference
- **Description:** Comprehensive reference guide to FDA-approved psoriasis treatments with detailed information on biologics, biosimilars, and other therapies
- **Keywords:** psoriasis, treatments, drugs, biologics, dermatology
- **Category:** Medical
- **Privacy Policy:** Update with your privacy policy
- **Support URL:** Add support contact

### 3. Screenshots and Preview

App Store requires 2-5 screenshots:
1. Main drug list screen
2. Drug detail view with full information
3. Search/filter demonstration
4. Favorites feature

### 4. Review Guidelines

Ensure compliance with Apple Review Guidelines:
- ✅ Disclaimer about medical advice
- ✅ No claims about treating skin conditions
- ✅ Clear that it's informational only
- ✅ No personal health data storage (unless you're HIPAA compliant)

Add this disclaimer to the About screen or first launch:

```
Medical Disclaimer

This app is for informational purposes only and should not replace 
professional medical advice from a dermatologist or healthcare provider. 
Always consult with a qualified medical professional before starting 
any new treatment. The drug information contained herein is accurate 
as of the publication date but may be subject to change.
```

### 5. Version and Build Numbers

In Xcode:
- Project Settings → Version: 1.0.0
- Project Settings → Build: 1

Increment these with each update.

## Troubleshooting

### Build Errors

**Error: "libsqlite3.tbd not found"**
- Verify framework is added in Build Phases → Link Binary With Libraries
- Check iOS deployment target is compatible

**Error: "SwiftUI commands are not recognized"**
- Ensure Development Team is set in Build Settings
- Update to latest Xcode version

**Error: "Database file not found"**
- Run on simulator first (not preview)
- Check console for "Database opened successfully"

### Runtime Issues

**App crashes when opening drugs list**
- Verify DatabaseManager is properly initialized
- Check console for SQLite errors
- Restart the simulator

**Search not working**
- Verify search text binding in SearchBarView
- Check filterDrugs() function in DrugListViewModel

**Database appears empty**
- Wait a moment for DatabaseManager to initialize
- Check console output for seed data messages
- Try restarting the app

## Next Steps

1. Test thoroughly on multiple devices/iOS versions
2. Gather beta testers
3. Implement analytics (Firebase, etc.)
4. Plan future features (drug interactions, dosing calculator, etc.)
5. Submit to App Store

## Additional Resources

- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [iOS App Development Guide](https://developer.apple.com/ios/resources/)
- [App Store Connect Help](https://appstoreconnect.apple.com/resources)

## Support

For technical questions or issues, refer to:
- Swift Forums: forums.swift.org
- Apple Developer Forums: developer.apple.com/forums
- Stack Overflow: tag [swift] and [swiftui]

---

Good luck with your app launch! 🚀
