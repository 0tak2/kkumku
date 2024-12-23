//
//  DateInputTableViewCell.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

class LabelOnlyTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ labelText: String) {
        label.text = labelText
    }
}
