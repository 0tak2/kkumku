//
//  SettingViewController.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

class SettingViewController: UIViewController {
    // MARK: - Table View
    @IBOutlet weak var tableView: UITableView!
    private let cellReusableId = "SettingViewControllerTableViewCell"
    private var settingItems: [Section: [Item]] = [:]
    
    // MARK: - Settings
    let wakingTimeKey = "wakingTime"
    let bedTimeKey = "bedTimeKey"
    let notificationEnabledKey = "notificationEnabled"
    
    private var wakingTime: Date {
        get {
            let wakingTimeRaw = UserDefaults.standard.string(forKey: wakingTimeKey)
            if let wakingTimeRaw = wakingTimeRaw {
                return Date.fromISOString(isoString: wakingTimeRaw)!
            } else {
                let wakingTime = Date.fromHourAndMinute(hour: 22, minute: 00)!
                UserDefaults.standard.set(wakingTime.toISOString(), forKey: wakingTimeKey)
                return wakingTime
            }
        }
        
        set {
            UserDefaults.standard.set(newValue.toISOString(), forKey: wakingTimeKey)
        }
    }
    
    private var bedTime: Date {
        get {
            let bedTimeRaw = UserDefaults.standard.string(forKey: bedTimeKey)
            if let bedTimeRaw = bedTimeRaw {
                return Date.fromISOString(isoString: bedTimeRaw)!
            } else {
                let bedTime = Date.fromHourAndMinute(hour: 07, minute: 00)!
                UserDefaults.standard.set(bedTime.toISOString(), forKey: bedTimeKey)
                return bedTime
            }
        }
        
        set {
            UserDefaults.standard.set(newValue.toISOString(), forKey: bedTimeKey)
        }
    }
    
    private var notificationEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: notificationEnabledKey)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: notificationEnabledKey)
        }
    }
    
    // MARK: - Debug
    let initUserDefaultsOnViewDidLoad: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "설정"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        Log.debug("current wakingTime \(wakingTime)")
        Log.debug("current bedTime \(bedTime)")
        Log.debug("current notificationEnabled \(notificationEnabled)")
        
        if initUserDefaultsOnViewDidLoad {
            Log.info("UserDefaults 초기화 (initUserDefaultsOnViewDidLoad=true)")
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                UserDefaults.standard.removeObject(forKey: key.description)
            }
        }
        
        settingItems = [
            .time: [
                .datePicker(label: "기상 시각", currentValue: wakingTime, onChange: { [weak self] date in
                    self?.wakingTime = date
                }),
                .datePicker(label: "취침 시각", currentValue: bedTime, onChange: { [weak self] date in
                    self?.bedTime = date
                }),
            ],
            .notification: [
                .select(label: "알림", currentValue: notificationEnabled, onChange: { [weak self] isOn in
                    self?.notificationEnabled = isOn
                }),
            ],
            .backup: [
                .button(label: "모든 꿈 백업하기 (JSON)", onTapped: {
                    Log.info("Started to backup dreams in JSON")
                })
            ],
        ]
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReusableId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    enum Section: Int, CaseIterable {
        case time
        case notification
        case backup
    }
    
    enum Item {
        case datePicker(label: String, currentValue: Date, onChange: (Date) -> Void)
        case select(label: String, currentValue: Bool, onChange: (Bool) -> Void)
        case button(label: String, onTapped: () -> Void)
    }
}

extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = Section(rawValue: section), let items = settingItems[section] {
            return items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section),
              let items = settingItems[section],
              let cell = tableView.dequeueReusableCell(withIdentifier: cellReusableId)
        else { return UITableViewCell() }
        
        var content = cell.defaultContentConfiguration()
        
        let item = items[indexPath.item]
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
        
        if case let .button(label, _) = item {
            content.text = label
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let section = Section(rawValue: indexPath.section),
           let items = settingItems[section],
           case .button = items[indexPath.item] {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section),
              let items = settingItems[section] else { return }
        
        let item = items[indexPath.item]
        if case let .button(_, onTapped) = item {
            onTapped()
        }
    }
}
