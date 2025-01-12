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
    let settings = UserSettings.shared
    
    // MARK: - Data
    let dreamRepository = DreamRepository.shared
    
    private var wakingTime: Date {
        get {
            let defaultWakingTime = Date.fromHourAndMinute(hour: 22, minute: 00)!.toISOString()
            let wakingTimeRaw = settings.string(.wakingTime, or: defaultWakingTime)
            return Date.fromISOString(isoString: wakingTimeRaw)!
        }
        
        set {
            settings.set(newValue.toISOString(), for: .wakingTime)
        }
    }
    
    private var bedTime: Date {
        get {
            let defaultBedTime = Date.fromHourAndMinute(hour: 07, minute: 00)!.toISOString()
            let bedTimeRaw = settings.string(.bedTime, or: defaultBedTime)
            return Date.fromISOString(isoString: bedTimeRaw)!
        }
        
        set {
            settings.set(newValue.toISOString(), for: .bedTime)
        }
    }
    
    private var notificationEnabled: Bool {
        get {
            settings.bool(.notificationEnabled)
        }
        
        set {
            settings.set(newValue, for: .notificationEnabled)
        }
    }
    
    // MARK: - Debug
    let initUserDefaultsOnViewDidLoad: Bool = false // fixme: 커밋에 포함되지 않는 방식으로 토글할 수 있도록 개선
    
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
                .button(label: "모든 꿈 내보내기 (JSON)", onTapped: { [weak self] in
                    self?.dumpToJson()
                })
            ],
        ]
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReusableId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    private func dumpToJson() {
        Log.info("Started to backup dreams in JSON")
        
        let data = dreamRepository.fetchAll(numberOfItems: -1)
        let encodableEntities = data.map { DreamEncodable(from: $0) }
        
        do {
            let encodedData = try JSONEncoder().encode(encodableEntities)
            if let jsonOutput = String(data: encodedData, encoding: .utf8) {
                let shareObject = [jsonOutput]
                
                let activityViewController = UIActivityViewController(activityItems : shareObject, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view

                self.present(activityViewController, animated: true)
            }
        } catch {
            let alert = UIAlertController(title: "백업 실패", message: "데이터를 인코딩하는 중 문제가 발생했습니다.", preferredStyle: .alert)
            present(alert, animated: true)
        }
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
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
