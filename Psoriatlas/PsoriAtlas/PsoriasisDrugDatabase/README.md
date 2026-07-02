# Psoriatlas: FDA-Approved Psoriasis Drug Database

A comprehensive iOS app for browsing and referencing FDA-approved psoriasis treatments with detailed information organized by drug class.

## Features

✅ **Complete Drug Database** - 40+ FDA-approved psoriasis medications
✅ **Organized by Drug Class** - TNF inhibitors, IL-17 inhibitors, IL-23 inhibitors, and more
✅ **Rich Drug Information** - Approval dates, manufacturers, administration methods, dosing, side effects
✅ **Search Functionality** - Search by drug name, generic name, manufacturer, or drug class
✅ **Filter by Type** - Biologics, biosimilars, generics, small molecules, topicals
✅ **Favorites System** - Bookmark important drugs for quick access
✅ **SQLite Database** - Fast local database with no internet required
✅ **Professional UI** - Clean, medical-grade interface design

## Drug Information Included

- Drug name and generic names
- FDA approval date
- Manufacturer
- Drug type (Biologic, Biosimilar, Generic, Small Molecule, Topical)
- Drug class (TNF-alpha, IL-17, IL-23, JAK inhibitors, etc.)
- Administration method (injection, oral, topical, IV)
- Dosing information
- Known side effects
- Approved age groups
- Indications
- Biological targets (for biologics)
- Biosimilar relationships

## Technical Stack

- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Database:** SQLite3
- **Architecture:** MVVM
- **Minimum iOS:** 14.0

## Project Structure

```
PsoriasisDrugDatabase/
├── Models/
│   └── Drug.swift              # Drug data model and grouping
├── Database/
│   ├── DatabaseManager.swift   # SQLite database operations
│   └── DrugSeedData.swift      # Pre-populated drug data
├── ViewModels/
│   ├── DrugListViewModel.swift # List view state management
│   └── DrugDetailViewModel.swift # Detail view state management
├── Views/
│   ├── ContentView.swift       # Main navigation view
│   ├── DrugRowView.swift       # Drug list item component
│   ├── DrugDetailView.swift    # Drug detail screen
│   ├── SearchBarView.swift     # Search component
│   └── FilterButtonsView.swift # Filter controls
├── Utilities/
│   └── DateFormatters.swift    # Date formatting utilities
└── PsoriasisDrugDatabaseApp.swift # App entry point
```

## Building & Running

### Requirements
- Xcode 14.0 or later
- iOS 14.0 or later
- Swift 5.9+

### Steps

1. Open Xcode
2. Create a new iOS App project
3. Copy all files from the `PsoriasisDrugDatabase` folder into your project
4. Add SQLite3 framework: Xcode → Build Phases → Link Binary With Libraries → Add `libsqlite3.tbd`
5. Build and run on simulator or device

## Drug Database Contents

### TNF-alpha Inhibitors (Biologics & Biosimilars)
- Adalimumab (Humira)
- Etanercept (Enbrel)
- Infliximab (Remicade)
- Infliximab-dyyb (Inflectra) - Biosimilar

### IL-17 Inhibitors
- Secukinumab (Cosentyx)
- Ixekizumab (Taltz)
- Brodalumab (Siliq)

### IL-23 Inhibitors
- Risankizumab (Skyrizi)
- Guselkumab (Tremfya)
- Tildrakizumab (Ilumya)

### Small Molecule & Oral Treatments
- Apremilast (Otezla) - PDE-4 inhibitor
- Tofacitinib (Xeljanz) - JAK inhibitor
- Baricitinib (Olumiant) - JAK inhibitor
- Methotrexate
- Cyclosporine
- Acitretin

### Topical Treatments
- Ruxolitinib cream (Opzelura) - JAK inhibitor
- Roflumilast foam - PDE-4 inhibitor
- Clobetasol propionate - Corticosteroid
- Triamcinolone acetonide - Corticosteroid
- Calcipotriene (Dovonex) - Vitamin D analogue

## App Features in Detail

### Search
- Real-time search across drug names, generic names, manufacturers, and drug classes
- Clear button for quick reset

### Filtering
- Filter by drug type: Biologics, Biosimilars, Generics, Small Molecules, Topicals
- Combined with search for powerful discovery

### Drug Details
- Comprehensive information page
- Side effects list
- Dosing guidelines
- Approved age groups
- Additional clinical notes
- Favorite/bookmark functionality
- Heart icon to save drugs

### Database
- Local SQLite database (no internet required)
- Fast searches and filtering
- Persistent favorites
- Easy to update with new drugs

## Design Philosophy

The app follows Apple's Human Interface Guidelines with:
- Clean, minimal aesthetic
- Professional medical color palette
- Clear typography hierarchy
- Intuitive navigation
- Accessible design

## Color Scheme

- **Primary Blue** (#0066CC) - Biologics, primary actions
- **Teal** (#00998D) - Biosimilars
- **Gray** (#666666) - Generics
- **Coral** (#FF6B6B) - Small molecules, important warnings
- **Green** (#4CAF50) - Topical treatments
- **System Gray** - Backgrounds and secondary elements

## Future Enhancements

- [ ] Real-time data sync from FDA database
- [ ] Detailed clinical trial data
- [ ] Drug comparison tool
- [ ] Patient dosing calculator
- [ ] Insurance coverage information
- [ ] Cost/copay data
- [ ] Side effect severity ratings
- [ ] Drug interaction checker
- [ ] Apple Health integration
- [ ] iCloud sync for favorites

## Disclaimer

This app is for informational purposes only and should not replace professional medical advice. Always consult with a dermatologist or healthcare provider before starting any new treatment. The information provided is accurate as of the development date but may be subject to change.

## License

This project is provided as-is for educational and reference purposes.

## Support

For issues, suggestions, or updates, please create an issue or contact the development team.

---

**Version:** 1.0.0
**Last Updated:** February 2026
