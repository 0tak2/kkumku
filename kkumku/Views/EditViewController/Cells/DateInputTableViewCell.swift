//
//  DateInputTableViewCell.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

class DateInputTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    private var onChange: (UIDatePicker) -> Void = { _ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.addTarget(self, action: #selector(didValueChanged(sender:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        onChange = { _ in }
    }
    
    func configure(_ labelText: String, value: Date, onChange: @escaping (UIDatePicker) -> Void) {
        label.text = labelText
        datePicker.date = value
        self.onChange = onChange
    }
    
    @objc private func didValueChanged(sender: UIDatePicker) -> Void {
        onChange(sender)
    }
}
