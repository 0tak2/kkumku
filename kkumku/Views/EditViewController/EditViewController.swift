//
//  AddViewController.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var isInsertingNewDream = true
    var workingDream: Dream = Dream(startAt: Date.now, endAt: Date.now, memo: "", dreamClass: .auspicious, isLucid: false)
    
    var isEditStarted: Bool = false {
        didSet {
            navigationItem.rightBarButtonItem?.tintColor = isEditStarted ? nil : .gray
        }
    }
    let dreamRepository = DreamRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isInsertingNewDream {
            navigationItem.title = "새 꿈"
        } else {
            navigationItem.title = "수정하기"
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(onTappedSave))
        navigationItem.rightBarButtonItem?.tintColor = .gray
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
}
