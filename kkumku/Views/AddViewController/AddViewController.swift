//
//  AddViewController.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

class AddViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var newDream: Dream = Dream(startAt: Date.now, endAt: Date.now, memo: "", dreamClass: .auspicious, isLucid: false)
    var isEditStarted: Bool = false {
        didSet {
            navigationItem.rightBarButtonItem?.tintColor = isEditStarted ? nil : .gray
        }
    }
    let dreamRepository = DreamRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "새 꿈"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(onTappedSave))
        navigationItem.rightBarButtonItem?.tintColor = .gray
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        
        dreamRepository.fetchAll().forEach { dream in
            print("=================")
            print(dream)
            print("")
        }
    }
}
