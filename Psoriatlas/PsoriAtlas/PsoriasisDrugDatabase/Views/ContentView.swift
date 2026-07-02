import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DrugListViewModel()
    @StateObject private var databaseManager = DatabaseManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let horizontalPadding = max(12.0, width * 0.04)
            let verticalPadding = max(10.0, height * 0.015)
            let titleSize = max(24.0, min(32.0, width * 0.08))
            let secondarySize = max(12.0, min(14.0, width * 0.035))
            let compactSpacing = max(8.0, height * 0.01)

            NavigationView {
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()

                    if databaseManager.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    } else {
                        VStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: compactSpacing) {
                                Text("Psoriasis Treatments")
                                    .font(.system(size: titleSize, weight: .bold, design: .default))
                                    .foregroundColor(.primary)

                                Text("FDA-Approved Drug Reference")
                                    .font(.system(size: secondarySize, weight: .regular, design: .default))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalPadding)

                            Divider()

                            SearchBarView(searchText: $viewModel.searchText)
                                .padding(.horizontal, horizontalPadding)
                                .padding(.vertical, verticalPadding)

                            FilterButtonsView(selectedType: $viewModel.selectedDrugType)
                                .padding(.horizontal, horizontalPadding)
                                .padding(.bottom, verticalPadding / 1.2)

                            Button(action: {
                                viewModel.showFavoritesOnly.toggle()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: viewModel.showFavoritesOnly ? "heart.fill" : "heart")
                                        .foregroundColor(.red)
                                    Text(viewModel.showFavoritesOnly ? "Showing hearted drugs" : "Show hearted drugs")
                                        .font(.system(size: secondarySize, weight: .semibold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(viewModel.showFavoritesOnly ? Color.red.opacity(0.12) : Color(.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(999)
                            }
                            .padding(.horizontal, horizontalPadding)
                            .padding(.bottom, verticalPadding / 1.2)

                            Divider()

                            if viewModel.filteredDrugs.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: min(48, max(36, width * 0.12)), weight: .light))
                                        .foregroundColor(.secondary)

                                    Text("No drugs found")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text(viewModel.showFavoritesOnly ? "Heart some drugs to see them here." : "Try adjusting your search or filters")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: max(8.0, height * 0.012), pinnedViews: []) {
                                        ForEach(viewModel.filteredDrugs) { classGroup in
                                            VStack(alignment: .leading, spacing: compactSpacing) {
                                                Text(classGroup.className)
                                                    .font(.system(size: max(14.0, min(16.0, width * 0.04)), weight: .semibold, design: .default))
                                                    .foregroundColor(.blue)
                                                    .padding(.horizontal, horizontalPadding)
                                                    .padding(.top, verticalPadding)

                                                ForEach(classGroup.drugFamilies) { family in
                                                    NavigationLink(destination: DrugDetailView(family: family, viewModel: DrugDetailViewModel(drug: family.representativeDrug))) {
                                                        DrugRowView(family: family)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.vertical, verticalPadding)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }

                            VStack(alignment: .leading, spacing: compactSpacing) {
                                Text("Educational reference")
                                    .font(.system(size: max(12.0, min(14.0, width * 0.035)), weight: .semibold))
                                    .foregroundColor(.secondary)

                                Text("This app summarizes publicly available treatment information for educational purposes. It is not a substitute for medical advice, diagnosis, or treatment.")
                                    .font(.system(size: max(11.0, min(13.0, width * 0.032)), weight: .regular))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.bottom, verticalPadding)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                }
                .navigationBarHidden(true)
            }
            .navigationViewStyle(.stack)
        }
    }
}

#Preview("Psoriatlas content") {
    ContentView()
}
