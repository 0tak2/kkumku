//
//  ExploreViewController.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

class ExploreViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isAscending = false
    var numberOfItems = 5
    var page = 1
    var pageEnded = false
    
    var dataSource: DataSource!
    
    let dreamRepository = DreamRepository.shared
    
    var toggleRecentButton: ((Bool) -> Void)?
    var toggleOldestButton: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "모아보기"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchButtonTapped))
        
        setDataSource()
        loadCurrentData()
        collectionView.collectionViewLayout = setLayout()
        collectionView.delegate = self
        collectionView.register(SortButtonCollectionViewCell.self, forCellWithReuseIdentifier: "SortButtonCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 데이터가 추가되었을 수 있으므로 강제로 업데이트 해준다
        reloadData()
    }
    
    @objc func searchButtonTapped() {
        Log.debug("Will go to SearchView")
    }
}
