//
//  DreamCollectionViewCell.swift
//  kkumku
//
//  Created by 임영택 on 12/26/24.
//

import UIKit

class DreamCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var dreamClassEmoji: UILabel!
    @IBOutlet weak var dreamDateLabel: UILabel!
    @IBOutlet weak var dreamContentLabel: UILabel!
    @IBOutlet weak var tagStackView: UIStackView!
    @IBOutlet weak var seperatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initTagStackView()
        
        seperatorView.backgroundColor = .darkGray
    }
    
    override func prepareForReuse() {
        initTagStackView()
    }
    
    func configure(dream: Dream) {
        dreamClassEmoji.text = dream.dreamClass.descriptionEmoji()
        dreamDateLabel.text = dream.endAt.localizedString
        dreamContentLabel.text = dream.memo
        
        if dream.isLucid {
            let label = UILabel()
            label.text = "#루시드"
            label.font = .systemFont(ofSize: 12, weight: .light)
            tagStackView.addArrangedSubview(label)
        }
        
        dream.tags.forEach { tag in
            let label = UILabel()
            label.text = "#\(tag)"
            label.font = .systemFont(ofSize: 12, weight: .light)
            tagStackView.addArrangedSubview(label)
        }
    }
    
    func initTagStackView() {
        let subtagviews = tagStackView.arrangedSubviews
        subtagviews.forEach { tagView in
            tagView.removeFromSuperview()
        }
    }
}
