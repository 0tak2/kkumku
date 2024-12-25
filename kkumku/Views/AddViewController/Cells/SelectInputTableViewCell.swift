//
//  DateInputTableViewCell.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

class SelectInputTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var segementedControl: UISegmentedControl!
    
    var onChange: (_: UISegmentedControl) -> Void = { _ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        segementedControl.removeAllSegments()
        segementedControl.addTarget(self, action: #selector(didValueChanged(sender:)), for: .valueChanged)
    }
    
    override func prepareForReuse() {
        segementedControl.removeAllSegments()
        onChange = {_ in }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ labelText: String, choices: [String], onChange: @escaping (_: UISegmentedControl) -> Void) {
        label.text = labelText
        
        for (index, choice) in choices.enumerated() {
            segementedControl.insertSegment(withTitle: choice, at: index, animated: false)
        }
        
        segementedControl.selectedSegmentIndex = 0
        
        self.onChange = onChange
    }
    
    @objc private func didValueChanged(sender: UISegmentedControl) {
        onChange(sender)
    }
}
