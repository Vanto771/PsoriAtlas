//
//  PsoriAtlasTests.swift
//  PsoriAtlasTests
//
//  Created by Heather Young on 6/27/26.
//

import Testing
@testable import PsoriAtlas

struct PsoriAtlasTests {

    @Test func search_terms_include_administration_method() async throws {
        let drug = Drug(
            name: "Humira",
            genericName: "Adalimumab",
            manufacturer: "AbbVie",
            drugClass: "TNF-alpha Inhibitor (Biologic)",
            type: .biologic,
            fdaApprovalDate: Date(),
            administrationMethod: "Subcutaneous injection",
            dosing: "40 mg every other week",
            sideEffects: [],
            approvedAgeGroups: [],
            indications: "Plaque psoriasis",
            biologicalTarget: nil,
            biosimilarOf: nil,
            isBiosimilar: false,
            notes: nil
        )

        #expect(drug.searchTerms.contains { $0.localizedCaseInsensitiveContains("subcutaneous") })
    }

    @Test func external_links_include_drug_name_in_query() async throws {
        let drug = Drug(
            name: "Skyrizi",
            genericName: "Risankizumab",
            manufacturer: "AbbVie",
            drugClass: "IL-23 Inhibitor (Biologic)",
            type: .biologic,
            fdaApprovalDate: Date(),
            administrationMethod: "Subcutaneous injection",
            dosing: "150 mg every 12 weeks",
            sideEffects: [],
            approvedAgeGroups: [],
            indications: "Plaque psoriasis",
            biologicalTarget: nil,
            biosimilarOf: nil,
            isBiosimilar: false,
            notes: nil
        )

        let viewModel = DrugDetailViewModel(drug: drug, databaseManager: DatabaseManager.shared)

        let fdaURLString = viewModel.externalInfo?.fdaLink?.absoluteString
        let psoriasisURLString = viewModel.externalInfo?.psoriasisFoundationLink?.absoluteString

        #expect(fdaURLString?.contains("https://www.fda.gov/search?s=Skyrizi") == true)
        #expect(fdaURLString?.contains("sort_bef_combine=rel_DESC") == true)
        #expect(psoriasisURLString?.contains("https://www.psoriasis.org/search-results/?q=Skyrizi") == true)
    }

}
