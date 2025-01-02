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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "꿈"
        
        // button handlers
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        
        loadData()
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
}
