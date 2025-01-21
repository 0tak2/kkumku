//
//  SortButtonCollectionViewCell.swift
//  kkumku
//
//  Created by 임영택 on 1/6/25.
//

import UIKit

class SortButtonCollectionViewCell: UICollectionViewCell {
    private let sortButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 16)
        return button
    }()
    
    private var onTappedHandler: () -> Void = { }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(sortButton)
        
        sortButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        sortButton.widthAnchor.constraint(equalToConstant: 56).isActive = true
        sortButton.addTarget(self, action: #selector(onSortButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        onTappedHandler = { }
    }
    
    @objc func onSortButtonTapped() {
        onTappedHandler()
    }
    
    func configure(title: String, isSelected: Bool, do onTappedHandler: @escaping () -> Void) {
        sortButton.setTitle(title, for: .normal)
        sortButton.isSelected = isSelected
        if isSelected {
            sortButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        }
        
        self.onTappedHandler = onTappedHandler
    }
    
    func getToggler() -> (Bool) -> Void {
        return { [weak self] (isSelected: Bool) -> Void in
            self?.sortButton.isSelected = isSelected
            if isSelected {
                self?.sortButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
            } else {
                self?.sortButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
            }
        }
    }
}
