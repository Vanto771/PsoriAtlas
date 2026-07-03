import Foundation
import Combine
import SQLite3

private let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

class DatabaseManager: ObservableObject {
    static let shared = DatabaseManager()
    
    @Published var drugs: [Drug] = []
    @Published var isLoading = false
    
    private var db: OpaquePointer?
    private let dbPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("psoriasis_drugs.db").path
    
    init() {
        openDatabase()
        createTables()
        seedDatabase()
        loadDrugs()
    }
    
    private func openDatabase() {
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("✅ Database opened successfully")
        } else {
            print("❌ Unable to open database")
        }
    }
    
    private func createTables() {
        let createTableSQL = """
        CREATE TABLE IF NOT EXISTS drugs (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            genericName TEXT,
            manufacturer TEXT NOT NULL,
            drugClass TEXT NOT NULL,
            type TEXT NOT NULL,
            fdaApprovalDate TEXT NOT NULL,
            administrationMethod TEXT NOT NULL,
            dosing TEXT NOT NULL,
            sideEffects TEXT NOT NULL,
            approvedAgeGroups TEXT NOT NULL,
            indications TEXT NOT NULL,
            biologicalTarget TEXT,
            biosimilarOf TEXT,
            isBiosimilar INTEGER NOT NULL,
            notes TEXT,
            isFavorite INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
        );
        """
        
        var errorMessage: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, createTableSQL, nil, nil, &errorMessage) == SQLITE_OK {
            print("✅ Tables created successfully")
        } else {
            let message = errorMessage.map { String(cString: $0) } ?? "unknown error"
            print("❌ Error creating tables: \(message)")
            sqlite3_free(errorMessage)
        }
    }
    
    private func shouldSeedDatabase() -> Bool {
        let query = "SELECT COUNT(*) FROM drugs"
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            return true
        }
        defer { sqlite3_finalize(statement) }
        
        if sqlite3_step(statement) == SQLITE_ROW {
            let count = sqlite3_column_int(statement, 0)
            return count == 0
        }
        return true
    }
    
    private func seedDatabase() {
        let sampleDrugs = DrugSeedData.psoriasisDrugs
        for drug in sampleDrugs {
            upsertDrug(drug)
        }
    }

    private func upsertDrug(_ drug: Drug) {
        if existingDrugID(for: drug.name) != nil {
            updateDrug(drug)
        } else {
            saveDrug(drug)
        }
    }

    private func existingDrugID(for name: String) -> String? {
        let query = "SELECT id FROM drugs WHERE name = ? LIMIT 1"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            return nil
        }
        defer { sqlite3_finalize(statement) }

        bindText(statement, index: 1, value: name)

        if sqlite3_step(statement) == SQLITE_ROW {
            return string(for: statement!, column: 0)
        }
        return nil
    }

    private func updateDrug(_ drug: Drug) {
        let updateSQL = """
        UPDATE drugs SET
            genericName = ?, manufacturer = ?, drugClass = ?, type = ?, fdaApprovalDate = ?,
            administrationMethod = ?, dosing = ?, sideEffects = ?, approvedAgeGroups = ?, indications = ?,
            biologicalTarget = ?, biosimilarOf = ?, isBiosimilar = ?, notes = ?, updatedAt = ?
        WHERE name = ?
        """

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK else {
            return
        }
        defer { sqlite3_finalize(statement) }

        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: drug.fdaApprovalDate)
        let sideEffectsJSON = try? JSONSerialization.data(withJSONObject: drug.sideEffects)
        let ageGroupsJSON = try? JSONSerialization.data(withJSONObject: drug.approvedAgeGroups)

        bindText(statement, index: 1, value: drug.genericName)
        bindText(statement, index: 2, value: drug.manufacturer)
        bindText(statement, index: 3, value: drug.drugClass)
        bindText(statement, index: 4, value: drug.type.rawValue)
        bindText(statement, index: 5, value: dateString)
        bindText(statement, index: 6, value: drug.administrationMethod)
        bindText(statement, index: 7, value: drug.dosing)
        bindBlob(statement, index: 8, data: sideEffectsJSON)
        bindBlob(statement, index: 9, data: ageGroupsJSON)
        bindText(statement, index: 10, value: drug.indications)
        bindText(statement, index: 11, value: drug.biologicalTarget)
        bindText(statement, index: 12, value: drug.biosimilarOf)
        sqlite3_bind_int(statement, 13, drug.isBiosimilar ? 1 : 0)
        bindText(statement, index: 14, value: drug.notes)
        bindText(statement, index: 15, value: ISO8601DateFormatter().string(from: Date()))
        bindText(statement, index: 16, value: drug.name)

        _ = sqlite3_step(statement)
    }
    
    func saveDrug(_ drug: Drug) {
        let insertSQL = """
        INSERT INTO drugs (
            id, name, genericName, manufacturer, drugClass, type, fdaApprovalDate,
            administrationMethod, dosing, sideEffects, approvedAgeGroups, indications,
            biologicalTarget, biosimilarOf, isBiosimilar, notes, isFavorite, createdAt, updatedAt
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Failed to prepare insert statement")
            return
        }
        defer { sqlite3_finalize(statement) }
        
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: drug.fdaApprovalDate)
        let sideEffectsJSON = try? JSONSerialization.data(withJSONObject: drug.sideEffects)
        let ageGroupsJSON = try? JSONSerialization.data(withJSONObject: drug.approvedAgeGroups)
        
        bindText(statement, index: 1, value: drug.id.uuidString)
        bindText(statement, index: 2, value: drug.name)
        bindText(statement, index: 3, value: drug.genericName)
        bindText(statement, index: 4, value: drug.manufacturer)
        bindText(statement, index: 5, value: drug.drugClass)
        bindText(statement, index: 6, value: drug.type.rawValue)
        bindText(statement, index: 7, value: dateString)
        bindText(statement, index: 8, value: drug.administrationMethod)
        bindText(statement, index: 9, value: drug.dosing)
        bindBlob(statement, index: 10, data: sideEffectsJSON)
        bindBlob(statement, index: 11, data: ageGroupsJSON)
        bindText(statement, index: 12, value: drug.indications)
        bindText(statement, index: 13, value: drug.biologicalTarget)
        bindText(statement, index: 14, value: drug.biosimilarOf)
        sqlite3_bind_int(statement, 15, drug.isBiosimilar ? 1 : 0)
        bindText(statement, index: 16, value: drug.notes)
        sqlite3_bind_int(statement, 17, drug.isFavorite ? 1 : 0)
        bindText(statement, index: 18, value: ISO8601DateFormatter().string(from: Date()))
        bindText(statement, index: 19, value: ISO8601DateFormatter().string(from: Date()))
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("✅ Drug '\(drug.name)' saved successfully")
        } else {
            print("❌ Failed to insert drug: \(String(cString: sqlite3_errmsg(db)))")
        }
    }
    
    func loadDrugs() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var drugs: [Drug] = []
            let query = "SELECT * FROM drugs ORDER BY fdaApprovalDate DESC"
            var statement: OpaquePointer?
            
            guard let self = self, sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK else {
                print("❌ Failed to prepare query")
                DispatchQueue.main.async { self?.isLoading = false }
                return
            }
            defer { sqlite3_finalize(statement) }
            
            while sqlite3_step(statement) == SQLITE_ROW {
                if let statement = statement, let drug = self.parseDrugRow(statement) {
                    drugs.append(drug)
                }
            }
            
            DispatchQueue.main.async {
                self.drugs = drugs
                self.isLoading = false
                print("✅ Loaded \(drugs.count) drugs")
            }
        }
    }
    
    private func parseDrugRow(_ statement: OpaquePointer) -> Drug? {
        let dateFormatter = ISO8601DateFormatter()
        
        guard let id = string(for: statement, column: 0),
              let name = string(for: statement, column: 1),
              let manufacturer = string(for: statement, column: 3),
              let drugClass = string(for: statement, column: 4),
              let typeStr = string(for: statement, column: 5),
              let dateStr = string(for: statement, column: 6),
              let administrationMethod = string(for: statement, column: 7),
              let dosing = string(for: statement, column: 8),
              let indications = string(for: statement, column: 11),
              let type = Drug.DrugType(rawValue: typeStr),
              let fdaApprovalDate = dateFormatter.date(from: dateStr)
        else {
            return nil
        }
        
        let genericName = string(for: statement, column: 2)
        let biologicalTarget = string(for: statement, column: 12)
        let biosimilarOf = string(for: statement, column: 13)
        let notes = string(for: statement, column: 15)
        
        var sideEffects: [String] = []
        if let data = data(for: statement, column: 9) {
            if let effects = try? JSONSerialization.jsonObject(with: data) as? [String] {
                sideEffects = effects
            }
        }
        
        var approvedAgeGroups: [String] = []
        if let data = data(for: statement, column: 10) {
            if let ages = try? JSONSerialization.jsonObject(with: data) as? [String] {
                approvedAgeGroups = ages
            }
        }
        
        let isBiosimilar = sqlite3_column_int(statement, 14) != 0
        let isFavorite = sqlite3_column_int(statement, 16) != 0
        
        var drug = Drug(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            genericName: genericName,
            manufacturer: manufacturer,
            drugClass: drugClass,
            type: type,
            fdaApprovalDate: fdaApprovalDate,
            administrationMethod: administrationMethod,
            dosing: dosing,
            sideEffects: sideEffects,
            approvedAgeGroups: approvedAgeGroups,
            indications: indications,
            biologicalTarget: biologicalTarget,
            biosimilarOf: biosimilarOf,
            isBiosimilar: isBiosimilar,
            notes: notes
        )
        drug.isFavorite = isFavorite
        
        return drug
    }
    
    private func string(for statement: OpaquePointer, column: Int32) -> String? {
        guard let cString = sqlite3_column_text(statement, column) else { return nil }
        return String(cString: cString)
    }
    
    private func data(for statement: OpaquePointer, column: Int32) -> Data? {
        let ptr = sqlite3_column_blob(statement, column)
        let len = sqlite3_column_bytes(statement, column)
        guard ptr != nil, len > 0 else { return nil }
        return Data(bytes: ptr!, count: Int(len))
    }

    private func bindText(_ statement: OpaquePointer?, index: Int32, value: String?) {
        guard let statement = statement else { return }
        if let value = value {
            sqlite3_bind_text(statement, index, value, -1, sqliteTransient)
        } else {
            sqlite3_bind_null(statement, index)
        }
    }
    
    private func bindBlob(_ statement: OpaquePointer?, index: Int32, data: Data?) {
        guard let statement = statement else { return }
        if let data = data {
            _ = data.withUnsafeBytes { bytes in
                sqlite3_bind_blob(statement, index, bytes.baseAddress, Int32(data.count), sqliteTransient)
            }
        } else {
            sqlite3_bind_null(statement, index)
        }
    }
    
    func toggleFavorite(for drug: Drug) {
        let newFavoriteStatus = !drug.isFavorite
        let updateSQL = "UPDATE drugs SET isFavorite = ? WHERE id = ?"
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Failed to prepare update statement")
            return
        }
        defer { sqlite3_finalize(statement) }
        
        sqlite3_bind_int(statement, 1, newFavoriteStatus ? 1 : 0)
        bindText(statement, index: 2, value: drug.id.uuidString)
        
        if sqlite3_step(statement) == SQLITE_DONE {
            loadDrugs()
        } else {
            print("❌ Failed to update favorite status")
        }
    }
    
    deinit {
        sqlite3_close(db)
    }
}
