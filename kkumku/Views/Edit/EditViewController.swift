//
//  AddViewController.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    var isInsertingNewDream = true
    var workingDream = Dream(startAt: Date.now, endAt: Date.now, memo: "", dreamClass: .auspicious, isLucid: false)
    
    var isEditStarted: Bool = false {
        didSet {
            navigationItem.rightBarButtonItem?.tintColor = isEditStarted ? nil : .gray
        }
    }
    let dreamRepository = DreamRepository.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isInsertingNewDream {
            navigationItem.title = "새 꿈"
        } else {
            navigationItem.title = "수정하기"
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .primary
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(onTappedSave))
        navigationItem.rightBarButtonItem?.tintColor = .gray
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willKeyboardShow(_:)), name: UIView.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willKeyboardHide(_:)), name: UIView.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recheckDates()
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    @objc private func appBecameActive() {
        recheckDates()
    }
    
    func recheckDates() {
        if isInsertingNewDream {
            workingDream.setStartDateWithSetting()
            workingDream.endAt = Date.now
            tableView.reloadData()
        }
    }
    
    @objc private func willKeyboardShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight: CGFloat = keyboardFrame.cgRectValue.height - view.safeAreaInsets.bottom
            adjustBottomConstraint(with: keyboardHeight)
            Log.debug("EditViewController willKeyboardShow - keyboardHeight=\(keyboardHeight)")
        }
    }
    
    @objc private func willKeyboardHide(_ notification: Notification) {
        adjustBottomConstraint(with: 0)
        Log.debug("EditViewController willKeyboardHide")
    }
    
    private func adjustBottomConstraint(with constant: CGFloat) {
        tableViewBottomConstraint.constant = constant
    }
}
