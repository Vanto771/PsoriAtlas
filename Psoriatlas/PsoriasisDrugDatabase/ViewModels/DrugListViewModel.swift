import Foundation
import Combine

class DrugListViewModel: ObservableObject {
    @Published var filteredDrugs: [DrugClassGroup] = []
    @Published var searchText: String = "" {
        didSet {
            filterDrugs()
        }
    }
    @Published var selectedDrugType: Drug.DrugType? = nil {
        didSet {
            filterDrugs()
        }
    }
    @Published var showFavoritesOnly: Bool = false {
        didSet {
            filterDrugs()
        }
    }
    
    let databaseManager: DatabaseManager
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseManager: DatabaseManager = DatabaseManager.shared) {
        self.databaseManager = databaseManager
        updateFiltered()
        
        databaseManager.$drugs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterDrugs()
            }
            .store(in: &cancellables)
    }
    
    func updateFiltered() {
        filterDrugs()
    }
    
    private func filterDrugs() {
        var families = databaseManager.drugs.drugFamilies()
        
        if let selectedType = selectedDrugType {
            families = families.filter { family in
                family.drugs.contains { $0.type == selectedType }
            }
        }
        
        if showFavoritesOnly {
            families = families.filter { family in
                family.drugs.contains { $0.isFavorite }
            }
        }

        if !searchText.isEmpty {
            families = families.filter { family in
                family.drugs.contains { drug in
                    drug.searchTerms.contains { term in
                        term.localizedCaseInsensitiveContains(searchText)
                    }
                }
            }
        }
        
        filteredDrugs = families.groupedByClass()
    }
    
    func toggleFavorite(for drug: Drug) {
        databaseManager.toggleFavorite(for: drug)
    }
}
