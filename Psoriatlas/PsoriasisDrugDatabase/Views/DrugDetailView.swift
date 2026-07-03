import SwiftUI

struct DrugDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: DrugDetailViewModel
    let family: DrugFamily
    private var drug: Drug { family.representativeDrug }
    
    init(family: DrugFamily, viewModel: DrugDetailViewModel) {
        self.family = family
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerView
                    
                    // Drug Information
                    informationSection
                    
                    // Administration & Dosing
                    administrationSection
                    
                    // Side Effects
                    sideEffectsSection
                    
                    // Approved Age Groups
                    ageGroupsSection
                    
                    // Additional Info
                    additionalInfoSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.toggleFavorite()
                }) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(drug.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if let genericName = drug.genericName {
                        Text(genericName)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                drugTypeBadgeLarge(drug.type)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "building.2")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    Text(drug.manufacturer)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.primary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    Text("FDA Approved: \(formatDate(drug.fdaApprovalDate))")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var informationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Drug Information")
            
            infoRow(label: "Drug Class", value: drug.drugClass)
            infoRow(label: "Indications", value: drug.indications)
            
            if let target = drug.biologicalTarget {
                infoRow(label: "Biological Target", value: target)
            }
            
            if let biosimilarOf = drug.biosimilarOf {
                HStack(spacing: 8) {
                    Text("Biosimilar of:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text(biosimilarOf)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0, green: 153/255, blue: 141/255).opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            if !family.aliasNames.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Related Names")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text(family.aliasNames.joined(separator: " • "))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    @ViewBuilder
    private var administrationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Administration & Dosing")
            
            infoRow(label: "Method", value: drug.administrationMethod)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Dosing")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Text(drug.dosing)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    @ViewBuilder
    private var sideEffectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Known Side Effects")
            
            if drug.sideEffects.isEmpty {
                Text("No side effects documented")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(drug.sideEffects, id: \.self) { effect in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6, weight: .bold))
                                .foregroundColor(.red)
                                .padding(.top, 4)
                            
                            Text(effect)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var ageGroupsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Approved Age Groups")
            
            if drug.approvedAgeGroups.isEmpty {
                Text("Age information not available")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            } else {
                HStack(spacing: 8) {
                    ForEach(drug.approvedAgeGroups, id: \.self) { ageGroup in
                        Text(ageGroup)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(red: 0, green: 102/255, blue: 204/255))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var additionalInfoSection: some View {
        if let notes = drug.notes {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Additional Information")
                
                Text(notes)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color(.systemYellow).opacity(0.1))
                    .borderRadius(8)
            }
        }
        
        if let externalInfo = viewModel.externalInfo {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("External Resources")
                
                if let fdaLink = externalInfo.fdaLink {
                    Link(destination: fdaLink) {
                        Label("FDA Search", systemImage: "link")
                            .font(.system(size: 14, weight: .regular))
                    }
                }
                
                if let manufacturerLink = externalInfo.manufacturerLink {
                    Link(destination: manufacturerLink) {
                        Label("Manufacturer Website", systemImage: "building.2")
                            .font(.system(size: 14, weight: .regular))
                    }
                }
                
                if let psoriasisLink = externalInfo.psoriasisFoundationLink {
                    Link(destination: psoriasisLink) {
                        Label("National Psoriasis Foundation", systemImage: "heart.text.square")
                            .font(.system(size: 14, weight: .regular))
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Helper Functions
    
    @ViewBuilder
    private func drugTypeBadgeLarge(_ type: Drug.DrugType) -> some View {
        Text(type.displayName)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(badgeColor(type))
            .cornerRadius(10)
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
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    @ViewBuilder
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.primary)
    }
    
    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            Spacer()
        }
    }
}

extension View {
    func borderRadius(_ radius: CGFloat) -> some View {
        padding(12)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(radius)
    }
}
