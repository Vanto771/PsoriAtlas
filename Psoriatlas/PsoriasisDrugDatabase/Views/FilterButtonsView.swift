import SwiftUI

struct FilterButtonsView: View {
    @Binding var selectedType: Drug.DrugType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter by Type")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Clear All button
                    Button(action: { selectedType = nil }) {
                        Text("All Drugs")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(selectedType == nil ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedType == nil ? Color.blue : Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Type filter buttons
                    ForEach(Drug.DrugType.filterCases, id: \.self) { type in
                        Button(action: { selectedType = selectedType == type ? nil : type }) {
                            Text(type.displayName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(selectedType == type ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedType == type ? badgeColor(type) : Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
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
}

#Preview {
    FilterButtonsView(selectedType: .constant(nil))
}
