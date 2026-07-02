import Foundation

struct Drug: Identifiable, Codable {
    let id: UUID
    let name: String
    let genericName: String?
    let manufacturer: String
    let drugClass: String
    let type: DrugType
    let fdaApprovalDate: Date
    let administrationMethod: String
    let dosing: String
    let sideEffects: [String]
    let approvedAgeGroups: [String]
    let indications: String
    let biologicalTarget: String?
    let biosimilarOf: String?
    let isBiosimilar: Bool
    let notes: String?
    var isFavorite: Bool = false
    
    var canonicalName: String {
        biosimilarOf ?? genericName ?? name
    }
    
    var aliasNames: [String] {
        var aliases: [String] = []
        if let genericName = genericName, genericName != name {
            aliases.append("Generic: \(genericName)")
        }
        if let biosimilarOf = biosimilarOf, biosimilarOf != name && biosimilarOf != genericName {
            aliases.append("Biosimilar of \(biosimilarOf)")
        }
        return aliases
    }
    
    var searchTerms: [String] {
        var terms = [name, manufacturer, drugClass, indications, administrationMethod]
        if let genericName = genericName { terms.append(genericName) }
        if let biosimilarOf = biosimilarOf { terms.append(biosimilarOf) }
        return terms
    }
    
    enum DrugType: String, Codable {
        case biologic = "Biologic"
        case small_molecule = "Small Molecule"
        case topical = "Topical"
        
        static var filterCases: [DrugType] {
            [.biologic, .small_molecule, .topical]
        }
        
        var displayName: String {
            self.rawValue
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        genericName: String?,
        manufacturer: String,
        drugClass: String,
        type: DrugType,
        fdaApprovalDate: Date,
        administrationMethod: String,
        dosing: String,
        sideEffects: [String],
        approvedAgeGroups: [String],
        indications: String,
        biologicalTarget: String?,
        biosimilarOf: String?,
        isBiosimilar: Bool,
        notes: String?
    ) {
        self.id = id
        self.name = name
        self.genericName = genericName
        self.manufacturer = manufacturer
        self.drugClass = drugClass
        self.type = type
        self.fdaApprovalDate = fdaApprovalDate
        self.administrationMethod = administrationMethod
        self.dosing = dosing
        self.sideEffects = sideEffects
        self.approvedAgeGroups = approvedAgeGroups
        self.indications = indications
        self.biologicalTarget = biologicalTarget
        self.biosimilarOf = biosimilarOf
        self.isBiosimilar = isBiosimilar
        self.notes = notes
    }
}

// MARK: - Drug Class Grouping
struct DrugFamily: Identifiable {
    let canonicalName: String
    let drugs: [Drug]
    var id: String { canonicalName }
    
    var representativeDrug: Drug {
        if let match = drugs.first(where: { $0.name == canonicalName }) {
            return match
        }
        return drugs.first!
    }
    
    var aliasNames: [String] {
        var aliases: [String] = []
        for drug in drugs where drug.id != representativeDrug.id {
            if drug.biosimilarOf != nil {
                aliases.append("Biosimilar: \(drug.name)")
            } else if drug.genericName != nil {
                aliases.append("Brand: \(drug.name)")
            } else {
                aliases.append(drug.name)
            }
        }
        return aliases
    }
}

struct DrugClassGroup: Identifiable {
    let className: String
    let drugFamilies: [DrugFamily]
    var id: String { className }
}

extension Array where Element == Drug {
    func drugFamilies() -> [DrugFamily] {
        let grouped = Dictionary(grouping: self, by: { $0.canonicalName })
        return grouped.map { DrugFamily(canonicalName: $0.key, drugs: $0.value.sorted { $0.fdaApprovalDate > $1.fdaApprovalDate }) }
            .sorted { $0.canonicalName < $1.canonicalName }
    }
}

extension Array where Element == DrugFamily {
    func groupedByClass() -> [DrugClassGroup] {
        let grouped = Dictionary(grouping: self, by: { $0.representativeDrug.drugClass })
        return grouped.map { DrugClassGroup(className: $0.key, drugFamilies: $0.value.sorted { $0.canonicalName < $1.canonicalName }) }
            .sorted { $0.className < $1.className }
    }
}
