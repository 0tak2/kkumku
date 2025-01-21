//
//  ExploreViewController.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

class ExploreViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: DataSource!
    var sortButtonCellRegistration: UICollectionView.CellRegistration<SortButtonCollectionViewCell, Item>!
    var infoLabelCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Item>!
    
    let dreamRepository = DreamRepository.shared
    
    var isAscending = false
    var numberOfItems = 5
    var page = 1
    var pageEnded = false
    
    var toggleRecentButton: ((Bool) -> Void)?
    var toggleOldestButton: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "모아보기"
        navigationController?.navigationBar.tintColor = .primary
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchButtonTapped))
        
        registerCells()
        setDataSource()
        loadCurrentData()
        collectionView.collectionViewLayout = setLayout()
        collectionView.delegate = self
        
        // MARK: - NotificationCenter
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(onDataSourceUpdated), name: .dreamAdded, object: nil)
        nc.addObserver(self, selector: #selector(onDataSourceUpdated), name: .dreamEdited, object: nil)
        nc.addObserver(self, selector: #selector(onDataSourceUpdated), name: .dreamDeleted, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @objc func searchButtonTapped() {
        let storyboard = UIStoryboard(name: "SearchDreamView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchDreamViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentDetailView(for dream: Dream, animated: Bool) {
        let storyboard = UIStoryboard(name: "DetailDreamView", bundle: nil)
        guard let detailViewController = storyboard.instantiateViewController(identifier: "DetailDreamViewController")
                as? DetailDreamViewController else { return }
        detailViewController.dream = dream
        navigationController?.pushViewController(detailViewController, animated: animated)
    }
    
    @objc private func onDataSourceUpdated(_ notification: Notification) {
        Log.debug("ExploreViewController onDataSourceUpdated - notification name \(notification.name) - userInfo \(String(describing: notification.userInfo))")
        reloadData()
    }
}
