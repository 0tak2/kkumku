//
//  SearchDreamViewController+Search.swift
//  kkumku
//
//  Created by 임영택 on 1/6/25.
//

import UIKit

extension SearchDreamViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            applyInitailSnapshot()
            return
        }
        
        let searchResult = dreamRepository.findAll(containing: query)
        loadedDreams = searchResult
        applySnapshot(of: loadedDreams)
    }
}

extension SearchDreamViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }
}
