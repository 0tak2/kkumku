//
//  SearchDreamViewController.swift
//  kkumku
//
//  Created by 임영택 on 1/6/25.
//

import UIKit

class SearchDreamViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: DataSource!
    var headerCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Item>!
    var tagCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Item>!
    var currentSections: [Section]?
    
    let dreamRepository: DreamRepository = DreamRepository.shared
    
    var loadedDreams: [Dream] = []
    var loadedTags: [String] = []
    
    let searchActionDebouncer = Utils.Debouncer(seconds: 0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.setHidesBackButton(true, animated: false)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "꿈 찾기"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        initCollectionView()
        collectionView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationItem.searchController?.isActive = true
        navigationItem.searchController?.becomeFirstResponder()
    }
}
