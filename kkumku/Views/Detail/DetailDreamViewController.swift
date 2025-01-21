//
//  DetailDreamViewController.swift
//  kkumku
//
//  Created by 임영택 on 12/26/24.
//

import UIKit

class DetailDreamViewController: UIViewController {
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dreamClassLabel: UILabel!
    @IBOutlet weak var tagStackView: UIStackView!
    @IBOutlet weak var isLucidLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    var dream: Dream!
    let dreamRepository = DreamRepository.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "꿈"
        navigationController?.navigationBar.tintColor = .primary
        
        // button handlers
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func loadData() {
        guard let dream = dream else {
            fatalError("dream을 지정해야 합니다.")
        }
        
        contentTextView.text = dream.memo
        
        // Text View Height
        let size = CGSize(width: self.contentTextView.frame.width, height: .infinity)
        let estimatedSize = contentTextView.sizeThatFits(size)
        contentTextView.constraints.forEach { (constraint) in
            constraint.constant = estimatedSize.height
        }
        contentTextView.sizeToFit()
        contentTextView.isScrollEnabled = false
        
        dateLabel.text = "\(dream.startAt.localizedString) ~ \(dream.endAt.localizedStringNoYear)"
        dreamClassLabel.text = dream.dreamClass.descriptionFull()
        
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dream.tags.forEach { tag in
            let label = UILabel()
            label.text = "#\(tag)"
            label.font = .systemFont(ofSize: 14, weight: .light)
            label.textColor = .calm
            tagStackView.addArrangedSubview(label)
        }
        
        isLucidLabel.isHidden = !dream.isLucid
    }
    
    private func deleteDream(by dreamId: UUID) {
        // MARK: Delete the dream from CoreData
        dreamRepository.delete(by: dreamId)
        
        // MARK: Publish event via NotificationCenter
        let nc = NotificationCenter.default
        nc.post(name: .dreamDeleted, object: self, userInfo: [
            "targetId": dreamId
        ])
    }
}

extension DetailDreamViewController {
    @objc func editButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "EditViewController") as? EditViewController else {
            return
        }
        vc.isInsertingNewDream = false
        vc.workingDream = dream
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func deleteButtonTapped() {
        let alert = UIAlertController(title: "정말로 삭제하시겠습니까?", message: "이 작업은 돌이킬 수 없습니다.", preferredStyle: .actionSheet)
        let no = UIAlertAction(title: "취소", style: .default)
        let yes = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            if let id = self?.dream.id {
                self?.deleteDream(by: id)
            }
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(no)
        alert.addAction(yes)
        present(alert, animated: true)
    }
}
