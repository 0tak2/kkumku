//
//  DateInputTableViewCell.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
    
    var placeholder = ""
    var isPlaceholderShowing = true
    var onChange: (UITextView) -> Void = { _ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
        textView.backgroundColor = .systemGray6
        textView.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        placeholder = ""
        textView.text = ""
        isPlaceholderShowing = true
        onChange = { _ in }
    }
    
    func configure(_ placeholder: String?, value: String, onChange: @escaping (UITextView) -> Void) {
        if let placeholder = placeholder {
            self.placeholder = placeholder
            textView.text = placeholder
        } else {
            self.placeholder = ""
        }
        
        if !value.isEmpty {
            textView.text = value
            isPlaceholderShowing = false
        }
        
        self.onChange = onChange
    }
}

extension TextViewTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isPlaceholderShowing {
            textView.text = ""
            isPlaceholderShowing = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            isPlaceholderShowing = true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        onChange(textView)
    }
}
