import Foundation
import Combine

struct ExternalDrugInfo {
    let fdaLink: URL?
    let manufacturerLink: URL?
    let psoriasisFoundationLink: URL?
    let notes: String?
}

private enum DrugLinkResolver {
    static func externalInfo(for drug: Drug) -> ExternalDrugInfo {
        ExternalDrugInfo(
            fdaLink: fdaLink(for: drug),
            manufacturerLink: manufacturerLink(for: drug),
            psoriasisFoundationLink: psoriasisLink(for: drug),
            notes: nil
        )
    }

    private static func manufacturerLink(for drug: Drug) -> URL? {
        guard let urlString = manufacturerURLString(for: drug) else { return nil }
        return URL(string: urlString)
    }

    private static func manufacturerURLString(for drug: Drug) -> String? {
        let lookupNames = [drug.name, drug.genericName].compactMap { $0?.lowercased() }
        let nameSet = Set(lookupNames)

        for (name, url) in manufacturerURLs where nameSet.contains(name.lowercased()) {
            return url
        }

        return nil
    }

    private static func fdaLink(for drug: Drug) -> URL? {
        let subject = drug.name ?? drug.genericName ?? ""
        let encodedQuery = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
        return URL(string: "https://www.fda.gov/search?s=\(encodedQuery)&sort_bef_combine=rel_DESC")
    }

    private static func psoriasisLink(for drug: Drug) -> URL? {
        let subject = drug.name ?? drug.genericName ?? ""
        let encodedQuery = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
        return URL(string: "https://www.psoriasis.org/search-results/?q=\(encodedQuery)")
    }

    private static let manufacturerURLs: [String: String] = [
        "adalimumab": "https://www.humira.com/",
        "humira": "https://www.humira.com/",
        "etanercept": "https://www.enbrel.com/",
        "enbrel": "https://www.enbrel.com/",
        "infliximab": "https://www.remicade.com/",
        "remicade": "https://www.remicade.com/",
        "infliximab-dyyb": "https://www.inflectra.com/",
        "inflectra": "https://www.inflectra.com/",
        "secukinumab": "https://www.cosentyx.com/",
        "cosentyx": "https://www.cosentyx.com/",
        "ixekizumab": "https://www.taltz.com/",
        "taltz": "https://www.taltz.com/",
        "risankizumab": "https://www.skyrizi.com/",
        "skyrizi": "https://www.skyrizi.com/",
        "guselkumab": "https://www.tremfya.com/",
        "tremfya": "https://www.tremfya.com/",
        "tildrakizumab": "https://www.ilumya.com/",
        "ilumya": "https://www.ilumya.com/",
        "apremilast": "https://www.otezla.com/",
        "otezla": "https://www.otezla.com/",
        "tofacitinib": "https://www.xeljanz.com/",
        "xeljanz": "https://www.xeljanz.com/",
        "baricitinib": "https://www.olumiant.com/",
        "olumiant": "https://www.olumiant.com/",
        "ruxolitinib": "https://www.opzelura.com/",
        "opzelura": "https://www.opzelura.com/",
        "brodalumab": "https://www.siliq.com/",
        "siliq": "https://www.siliq.com/",
        "ustekinumab": "https://www.stelara.com/",
        "stelara": "https://www.stelara.com/",
        "bimekizumab": "https://www.bimzelx.com/",
        "bimzelx": "https://www.bimzelx.com/",
        "certolizumab": "https://www.cimzia.com/",
        "cimzia": "https://www.cimzia.com/",
        "abatacept": "https://www.orencia.com/",
        "orencia": "https://www.orencia.com/",
        "spesolimab": "https://www.spevigo.com/",
        "spevigo": "https://www.spevigo.com/"
    ]
}

class DrugDetailViewModel: ObservableObject {
    let drug: Drug
    @Published var isFavorite: Bool
    @Published var externalInfo: ExternalDrugInfo?
    
    let databaseManager: DatabaseManager
    
    init(drug: Drug, databaseManager: DatabaseManager = DatabaseManager.shared) {
        self.drug = drug
        self.isFavorite = drug.isFavorite
        self.databaseManager = databaseManager
        self.loadExternalInfo()
    }

    private func loadExternalInfo() {
        externalInfo = DrugLinkResolver.externalInfo(for: drug)
    }
    
    func toggleFavorite() {
        databaseManager.toggleFavorite(for: drug)
        isFavorite = !isFavorite
    }
}
