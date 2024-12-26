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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wrapperView.backgroundColor = .systemGray6
        wrapperView.layer.cornerRadius = 25
        initTagStackView()
    }
    
    override func prepareForReuse() {
        initTagStackView()
    }
    
    func configure(dream: Dream) {
        switch dream.dreamClass {
        case .auspicious:
            dreamClassEmoji.text = "😀"
        case .ominous:
            dreamClassEmoji.text = "😱"
        case .ambiguous:
            dreamClassEmoji.text = "😶"
        }
        
        dreamDateLabel.text = dateToString(dream.endAt)
        
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
    
    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        let calendar = NSCalendar.current.dateComponents([.year], from: date)
        let calendarNow = NSCalendar.current.dateComponents([.year], from: Date.now)
        if calendar.year != calendarNow.year {
            dateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분"
        } else {
            dateFormatter.dateFormat = "MM월 dd일 a hh시 mm분"
        }
        
        return dateFormatter.string(from: date)
    }
    
    func initTagStackView() {
        let subtagviews = tagStackView.arrangedSubviews
        subtagviews.forEach { tagView in
            tagView.removeFromSuperview()
        }
    }
}
