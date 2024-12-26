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
        
        guard let dream = dream else {
            fatalError("dream을 지정해야 합니다.")
        }

        contentTextView.text = dream.memo
        dateLabel.text = "\(dream.startAt.localizedString) ~ \(dream.endAt.localizedString)"
        dreamClassLabel.text = dream.dreamClass.descriptionFull()
        
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dream.tags.forEach { tag in
            let label = UILabel()
            label.text = "#\(tag)"
            label.font = .systemFont(ofSize: 14, weight: .light)
            label.textColor = .calm
            tagStackView.addArrangedSubview(label)
        }
        
        if !dream.isLucid {
            isLucidLabel.isHidden = true
        }
        
        // Text View Height
        let size = CGSize(width: self.contentTextView.frame.width, height: .infinity)
        let estimatedSize = contentTextView.sizeThatFits(size)
        contentTextView.constraints.forEach { (constraint) in
            constraint.constant = estimatedSize.height
        }
        contentTextView.sizeToFit()
        contentTextView.isScrollEnabled = false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
