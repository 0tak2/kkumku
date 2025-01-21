//
//  MiniDreamCollectionViewCell.swift
//  kkumku
//
//  Created by 임영택 on 1/21/25.
//

import UIKit

class CalendarDreamCollectionViewCell: UICollectionViewCell {
    let dreamMemoLabel = UILabel()
    let dreamSubtitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(dreamMemoLabel)
        addSubview(dreamSubtitleLabel)
        
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not implemented")
    }
    
    func configure(dream: Dream) {
        dreamMemoLabel.text = dream.memo
        
        let sleepingHours = (dream.endAt.timeIntervalSince1970 - dream.startAt.timeIntervalSince1970) / 60 / 60
        dreamSubtitleLabel.text = "\(dream.dreamClass.descriptionEmoji()) \(dream.isLucid ? "⚡️" : "") \(dream.endAt.localizedHourAndMinute) 기상 (\(String(format: "%.1f", sleepingHours))시간)"
    }
    
    private func style() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        
        dreamMemoLabel.translatesAutoresizingMaskIntoConstraints = false
        dreamMemoLabel.font = .systemFont(ofSize: 18)
        dreamMemoLabel.numberOfLines = 8
        
        dreamSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dreamSubtitleLabel.font = .systemFont(ofSize: 14)
        dreamSubtitleLabel.numberOfLines = 1
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            dreamMemoLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 2),
            dreamMemoLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
            trailingAnchor.constraint(equalToSystemSpacingAfter: dreamMemoLabel.trailingAnchor, multiplier: 2),
            dreamSubtitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
            trailingAnchor.constraint(equalToSystemSpacingAfter: dreamSubtitleLabel.trailingAnchor, multiplier: 2),
            bottomAnchor.constraint(equalToSystemSpacingBelow: dreamSubtitleLabel.bottomAnchor, multiplier: 2),
        ])
    }
}
