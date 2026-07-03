import SwiftUI

struct DrugRowView: View {
    let family: DrugFamily
    
    private var drug: Drug { family.representativeDrug }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Drug Name and Type
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(drug.name)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                    
                    if !family.aliasNames.isEmpty {
                        Text(family.aliasNames.joined(separator: " • "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                
                Spacer()
                
                drugTypeBadge(drug.type)
            }
            
            // Manufacturer and Approval Date
            HStack(spacing: 8) {
                Label(drug.manufacturer, systemImage: "building.2")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label(formatDate(drug.fdaApprovalDate), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Administration Method
            Label(drug.administrationMethod, systemImage: "pills")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func drugTypeBadge(_ type: Drug.DrugType) -> some View {
        Text(type.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(badgeColor(type))
            .cornerRadius(8)
    }
    
    private func badgeColor(_ type: Drug.DrugType) -> Color {
        switch type {
        case .biologic:
            return Color(red: 0, green: 102/255, blue: 204/255)
        case .small_molecule:
            return Color(red: 255/255, green: 107/255, blue: 107/255)
        case .topical:
            return Color(red: 76/255, green: 175/255, blue: 80/255)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    let sampleDrug = Drug(
        name: "Adalimumab",
        genericName: nil,
        manufacturer: "AbbVie",
        drugClass: "TNF-alpha Inhibitor",
        type: .biologic,
        fdaApprovalDate: Date(),
        administrationMethod: "Subcutaneous injection",
        dosing: "40 mg every 2 weeks",
        sideEffects: ["Injection site reactions"],
        approvedAgeGroups: ["Adults"],
        indications: "Moderate to severe psoriasis",
        biologicalTarget: "TNF-alpha",
        biosimilarOf: nil,
        isBiosimilar: false,
        notes: nil
    )
    let family = DrugFamily(canonicalName: sampleDrug.canonicalName, drugs: [sampleDrug])
    ZStack {
        Color(.systemBackground)
        
        DrugRowView(family: family)
    }
    .ignoresSafeArea()
}
