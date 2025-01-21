//
//  OnboardingSettingViewController+TableView.swift
//  kkumku
//
//  Created by 임영택 on 1/21/25.
//

import UIKit

extension OnboardingSettingViewController {
    enum Section: Int, CaseIterable {
        case title
        case time
        case notification
        
        func getHeaderText() -> String? {
            switch self {
            case .time: "설정한 시각에 맞게 앱을 개인화해요"
            case .notification: "기상 시각에 알림을 보내드려요"
            default: nil
            }
        }
    }
    
    enum Item {
        case titleLabel(label: String)
        case datePicker(label: String, currentValue: Date, onChange: (Date) -> Void)
        case select(label: String, currentValue: Bool, onChange: (Bool) -> Void)
    }
}

extension OnboardingSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = Section(rawValue: section), let items = settingItems[section] {
            return items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return nil }
        return section.getHeaderText()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section),
              let items = settingItems[section],
              let cell = tableView.dequeueReusableCell(withIdentifier: cellReusableId)
        else { return UITableViewCell() }
        
        var content = cell.defaultContentConfiguration()
        
        let item = items[indexPath.item]
        if case let .titleLabel(label) = item {
            content.text = label
            content.textProperties.font = .systemFont(ofSize: 32, weight: .bold)
        }
        
        if case let .datePicker(label, currentValue, onChange) = item {
            content.text = label
            
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .time
            datePicker.date = currentValue
            datePicker.addAction(UIAction(handler: { action in
                guard let datePicker = action.sender as? UIDatePicker else { return }
                onChange(datePicker.date)
            }), for: .valueChanged)
            cell.accessoryView = datePicker
        }
        
        if case let .select(label, currentValue, onChange) = item {
            content.text = label
            
            let select = UISwitch()
            select.isOn = currentValue
            select.addAction(UIAction(handler: { action in
                guard let select = action.sender as? UISwitch else { return }
                onChange(select.isOn)
            }), for: .valueChanged)
            cell.accessoryView = select
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
}

extension OnboardingSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
