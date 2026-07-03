# Architecture Diagram: Psoriatlas App

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    iOS App (Psoriatlas)                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              SwiftUI Presentation Layer                 │   │
│  │  ┌──────────────────────────────────────────────────┐  │   │
│  │  │         ContentView (Main Navigation)            │  │   │
│  │  │  ┌─────────────┐    ┌──────────────────────┐    │  │   │
│  │  │  │ DrugRowView │───→│ DrugDetailView       │    │  │   │
│  │  │  └─────────────┘    └──────────────────────┘    │  │   │
│  │  │        ↑                      ↑                  │  │   │
│  │  │      List View            Detail View            │  │   │
│  │  └────────┬───────────────────┬──────────────────────┘  │   │
│  └───────────┼───────────────────┼───────────────────────────┘   │
│              │                   │                                │
│  ┌───────────┴───────────────────┴───────────────────────────┐   │
│  │          Component Layer (Reusable UI)                   │   │
│  │  ┌─────────────────────┐    ┌──────────────────────┐    │   │
│  │  │  SearchBarView      │    │ FilterButtonsView    │    │   │
│  │  │  - Text input       │    │ - Type filters       │    │   │
│  │  │  - Clear button     │    │ - All Drugs button   │    │   │
│  │  └─────────────────────┘    └──────────────────────┘    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         ↓                                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           MVVM State Management Layer                    │   │
│  │  ┌─────────────────────┐  ┌──────────────────────────┐  │   │
│  │  │ DrugListViewModel   │  │ DrugDetailViewModel      │  │   │
│  │  │ @Published          │  │ @Published               │  │   │
│  │  │ - searchText        │  │ - drug: Drug             │  │   │
│  │  │ - selectedType      │  │ - isFavorite: Bool       │  │   │
│  │  │ - filteredDrugs     │  │ - toggleFavorite()       │  │   │
│  │  │ - filterDrugs()     │  │                          │  │   │
│  │  └──────────┬──────────┘  └──────────┬───────────────┘  │   │
│  └─────────────┼──────────────────────────┼────────────────┘   │
│                 │                         │                     │
│  ┌──────────────┴──────────────────────────┴──────────────────┐ │
│  │             Data Access Layer (DatabaseManager)           │ │
│  │  - DatabaseManager (Singleton)                            │ │
│  │  ├─ openDatabase()                                        │ │
│  │  ├─ createTables()                                        │ │
│  │  ├─ seedDatabase()                                        │ │
│  │  ├─ loadDrugs()                                           │ │
│  │  ├─ saveDrug()                                            │ │
│  │  ├─ toggleFavorite()                                      │ │
│  │  ├─ parseDrugRow()                                        │ │
│  │  └─ [Private helper methods]                              │ │
│  └────────────────────────┬─────────────────────────────────┘ │
│                            ↓                                    │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │               Data Models Layer                            │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │ Drug Struct                                          │  │ │
│  │  │ - id: UUID                                           │  │ │
│  │  │ - name: String                                       │  │ │
│  │  │ - genericName: String?                               │  │ │
│  │  │ - manufacturer: String                               │  │ │
│  │  │ - drugClass: String                                  │  │ │
│  │  │ - type: DrugType (enum)                              │  │ │
│  │  │ - fdaApprovalDate: Date                              │  │ │
│  │  │ - administrationMethod: String                       │  │ │
│  │  │ - dosing: String                                     │  │ │
│  │  │ - sideEffects: [String]                              │  │ │
│  │  │ - approvedAgeGroups: [String]                        │  │ │
│  │  │ - indications: String                                │  │ │
│  │  │ - biologicalTarget: String?                          │  │ │
│  │  │ - biosimilarOf: String?                              │  │ │
│  │  │ - isBiosimilar: Bool                                 │  │ │
│  │  │ - isFavorite: Bool                                   │  │ │
│  │  │ - notes: String?                                     │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │ DrugClassGroup Struct (for grouping)                 │  │ │
│  │  │ - className: String                                  │  │ │
│  │  │ - drugs: [Drug]                                      │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                            ↓                                    │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │            Data Seeding Layer (DrugSeedData)              │ │
│  │  - psoriasisDrugs: [Drug] array                          │ │
│  │  - 40+ pre-populated FDA drugs                           │ │
│  │  - Complete information for each drug                   │ │
│  └────────────────────────────────────────────────────────────┘ │
│                            ↓                                    │
└─────────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────────┐
│               Persistence Layer (SQLite3)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Table: drugs                                             │  │
│  │ ┌──────────────────────────────────────────────────────┐ │  │
│  │ │ Columns:                                             │ │  │
│  │ │ id (TEXT PRIMARY KEY)                                │ │  │
│  │ │ name (TEXT NOT NULL)                                 │ │  │
│  │ │ genericName (TEXT)                                   │ │  │
│  │ │ manufacturer (TEXT NOT NULL)                         │ │  │
│  │ │ drugClass (TEXT NOT NULL)                            │ │  │
│  │ │ type (TEXT NOT NULL)                                 │ │  │
│  │ │ fdaApprovalDate (TEXT NOT NULL)                      │ │  │
│  │ │ administrationMethod (TEXT NOT NULL)                 │ │  │
│  │ │ dosing (TEXT NOT NULL)                               │ │  │
│  │ │ sideEffects (BLOB - JSON)                            │ │  │
│  │ │ approvedAgeGroups (BLOB - JSON)                      │ │  │
│  │ │ indications (TEXT NOT NULL)                          │ │  │
│  │ │ biologicalTarget (TEXT)                              │ │  │
│  │ │ biosimilarOf (TEXT)                                  │ │  │
│  │ │ isBiosimilar (INTEGER)                               │ │  │
│  │ │ notes (TEXT)                                         │ │  │
│  │ │ isFavorite (INTEGER)                                 │ │  │
│  │ │ createdAt (TEXT NOT NULL)                            │ │  │
│  │ │ updatedAt (TEXT NOT NULL)                            │ │  │
│  │ └──────────────────────────────────────────────────────┘ │  │
│  │                                                            │  │
│  │ Database File:                                           │  │
│  │ ~/Documents/psoriasis_drugs.db                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

### 1. App Launch

```
App Starts
    ↓
@main PsoriasisDrugDatabaseApp
    ↓
DatabaseManager.shared (singleton initialization)
    ↓
openDatabase()
    ↓
createTables()
    ↓
shouldSeedDatabase() → true (first launch)
    ↓
seedDatabase() (insert 40+ drugs)
    ↓
loadDrugs() (fetch all into @Published var)
    ↓
ContentView appears with populated drug list
```

### 2. Search & Filter Flow

```
User types in SearchBar
    ↓
$viewModel.searchText binding updates
    ↓
DrugListViewModel.filterDrugs() called
    ↓
Filter by drugType (if selected)
    ↓
Filter by searchText across fields
    ↓
Group filtered results by drugClass
    ↓
@Published filteredDrugs updates
    ↓
ContentView re-renders new results
```

### 3. Favorite Toggle Flow

```
User taps heart icon
    ↓
DrugDetailViewModel.toggleFavorite()
    ↓
DatabaseManager.toggleFavorite(for: drug)
    ↓
SQLite UPDATE command
    ↓
isFavorite field updated in DB
    ↓
DatabaseManager.loadDrugs() refreshes
    ↓
@Published drugs/isFavorite updates
    ↓
UI reflects new favorite status
```

## Component Dependencies

```
ContentView
├── Depends on: DrugListViewModel
├── Uses: SearchBarView
├── Uses: FilterButtonsView
├── Maps to: DrugRowView
└── Navigates to: DrugDetailView

DrugDetailView
├── Depends on: DrugDetailViewModel
├── Displays: Drug data
└── Uses: Heart icon toggle

DrugListViewModel
├── Depends on: DatabaseManager
├── Uses: Drug model
├── Publishes: filteredDrugs
└── Calls: filterDrugs()

DatabaseManager
├── Depends on: SQLite3 framework
├── Uses: Drug model
├── Uses: DrugSeedData
└── Manages: CRUD operations
```

## Threading Model

```
Main Thread (UI):
- All SwiftUI updates
- View rendering
- User interactions

Background Thread (Data):
- DatabaseManager.loadDrugs() on .userInitiated queue
- DispatchQueue.global(qos: .userInitiated)
- Results posted back to main thread

Synchronous Operations:
- Database writes (toggleFavorite)
- Data validation
- Filtering logic
```

## Environment & Configuration

```
iOS Target
├── Minimum: iOS 14.0
├── Maximum: iOS 17+ (current)
├── Device Types: iPhone (all sizes)
├── Orientations: Portrait primary
├── Dark Mode: Automatic (light+dark)
└── A11y: VoiceOver support

Frameworks
├── SwiftUI (UI)
├── SQLite3 (Database)
├── Foundation (Core)
└── Combine (Reactive updates)

Code Organization
├── MVVM Architecture
├── Separation of concerns
├── Reactive programming (Combine)
├── Singleton pattern (DatabaseManager)
└── Protocol-oriented features
```

## Error Handling & Resilience

```
Database Errors
├── Log to console
├── Gracefully degrade
└── No app crashes

Network (None)
└── App is 100% offline

File System
├── DocumentsDirectory fallback
└── Automatic permissions via sandbox

Data Validation
├── Type safety (Swift)
├── Optional unwrapping
└── Guard statements
```

## Performance Considerations

```
Memory
├── DrugListViewModel: lightweight
├── Database query results: cached
├── Favorites system: in-memory
└── Peak usage: ~40-50MB

CPU
├── Search filtering: O(n) linear
├── Initial load: ~100-200ms
├── Re-renders: <50ms
└── Database queries: <100ms

Storage
├── SQLite DB: ~5-10MB
├── Drug data: ~2-3MB
├── Metadata: <1MB
└── Total footprint: <20MB
```

## Security & Privacy

```
Data at Rest
├── SQLite database: Local storage
├── No encryption (public data)
└── No sensitive data

Data in Transit
├── No network requests
└── 100% offline

User Data
├── No collection
├── No analytics
├── No tracking
└── Privacy-first design
```

---

**Architecture Version:** 1.0
**Last Updated:** February 2026
**Status:** Production-Ready
