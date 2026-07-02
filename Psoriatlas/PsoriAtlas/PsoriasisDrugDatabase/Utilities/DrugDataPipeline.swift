import Foundation

struct ExternalDrugInfo {
    let fdaLink: URL?
    let manufacturerLink: URL?
    let psoriasisFoundationLink: URL?
    let notes: String?
}

final class DrugDataPipeline {
    static let shared = DrugDataPipeline()
    private init() {}

    func buildLinks(for drug: Drug) -> ExternalDrugInfo {
        ExternalDrugInfo(
            fdaLink: urlForFDA(drug),
            manufacturerLink: urlForManufacturer(drug),
            psoriasisFoundationLink: urlForPsoriasisFoundation(drug),
            notes: "External scraping is not enabled in this build. Use the links above for FDA, manufacturer, and National Psoriasis Foundation resources."
        )
    }

    private func urlForFDA(_ drug: Drug) -> URL? {
        let query = drug.genericName ?? drug.name
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return URL(string: "https://www.fda.gov/search?search_api_fulltext=\(encodedQuery)")
    }

    private func urlForManufacturer(_ drug: Drug) -> URL? {
        let query = "\(drug.manufacturer) \(drug.name)"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return URL(string: "https://www.google.com/search?q=\(encodedQuery)")
    }

    private func urlForPsoriasisFoundation(_ drug: Drug) -> URL? {
        let query = drug.name
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return URL(string: "https://www.psoriasis.org/?s=\(encodedQuery)")
    }
}
