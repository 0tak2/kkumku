//
//  ExploreViewController.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

class ExploreViewController: UIViewController {
    @IBOutlet weak var sortRecentButton: UIButton!
    @IBOutlet weak var sortOldestButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: DataSource!
    
    let dreamRepository = DreamRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDataSource()
        collectionView.collectionViewLayout = setLayout()
        
        sortRecentButton.isSelected = true
    }
}
