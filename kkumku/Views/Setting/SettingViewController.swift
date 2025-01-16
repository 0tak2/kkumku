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
    
    // MARK: - Notification
    let notification = NotificationSupport.shared
    
    private var wakingTime: Date {
        get {
            let defaultWakingTime = Date.fromHourAndMinute(hour: 07, minute: 00)!.toISOString()
            let wakingTimeRaw = settings.string(.wakingTime, or: defaultWakingTime)
            return Date.fromISOString(isoString: wakingTimeRaw)!
        }
        
        set {
            settings.set(newValue.toISOString(), for: .wakingTime)
        }
    }
    
    private var bedTime: Date {
        get {
            let defaultBedTime = Date.fromHourAndMinute(hour: 22, minute: 00)!.toISOString()
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
    private let initUserDefaultsOnViewDidLoad: Bool = {
        guard let filePath = Bundle.main.path(forResource: "Configs", ofType: "plist"),
              let configDict = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Configs.plist를 불러오지 못했습니다")
        }
        
        guard let logConfigDict = configDict.object(forKey: "Setting") as? NSDictionary,
              let shouldInitUserDefaultsOnViewDidLoad = logConfigDict.object(forKey: "initUserDefaultsOnSettingViewDidLoad") as? Bool else {
            fatalError("Configs.plist / Log / LogWithPrint 설정을 불러오지 못했습니다.")
        }
        
        return shouldInitUserDefaultsOnViewDidLoad
    }()
    
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
                .datePicker(label: "취침 시각", currentValue: bedTime, onChange: { [weak self] date in
                    self?.bedTime = date
                }),
                .datePicker(label: "기상 시각", currentValue: wakingTime, onChange: { [weak self] date in
                    self?.wakingTime = date
                    
                    if let notificationEnabled = self?.notificationEnabled,
                        notificationEnabled {
                        
                        Log.debug("notificationEnabled \(notificationEnabled)")
                        
                        let wakingTimeHourAndMinute = date.toHourAndMinute()
                        let (hour, minute) = (wakingTimeHourAndMinute[0], wakingTimeHourAndMinute[1])
                        
                        Task {
                            self?.registerDailyNotification(hour: hour, minute: minute)
                        }
                    }
                }),
            ],
            .notification: [
                .select(label: "알림", currentValue: notificationEnabled, onChange: { [weak self] isOn in
                    self?.notificationEnabled = isOn
                    
                    if !isOn {
                        self?.notification.removeAll()
                        Log.info("알림 요청을 잘 해제했습니다.")
                        return true
                    }
                    
                    guard let wakingTimeHourAndMinute = self?.wakingTime.toHourAndMinute() else { return false }
                    let (hour, minute) = (wakingTimeHourAndMinute[0], wakingTimeHourAndMinute[1])
                    
                    if let task = self?.registerDailyNotification(hour: hour, minute: minute) {
                        return await task.value
                    } else {
                        return false
                    }
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkNotificationAndUpdateUI()
    }
    
    @objc private func appBecameActive() {
        checkNotificationAndUpdateUI()
    }
    
    private func checkNotificationAndUpdateUI() {
        if notificationEnabled {
            notification.getAllRequest { [weak self] requests in
                DispatchQueue.main.async {
                    if requests.isEmpty {
                        self?.notificationEnabled = false
                        self?.tableView.reloadData()
                    }
                }
            }
            
            Task {
                do {
                    try await checkNotificationAuthorizationAndUpdateUI()
                } catch let error as NSError {
                    Log.error("알림 권한을 체크하던 중 예상할 수 없었던 오류가 발생했습니다. \(error.domain) \(error.userInfo)")
                }
            }
        }
    }
    
    @MainActor
    private func checkNotificationAuthorizationAndUpdateUI() async throws {
        let isAuthorized = try await notification.isAuthorized()
        if !isAuthorized {
            notificationEnabled = false
            tableView.reloadData()
        }
    }
    
    private func registerDailyNotification(hour: Int, minute: Int) -> Task<Bool, Never> {
        Task {
            do {
                notification.removeAll()
                try await self.notification.registerDailyNotification(hour: hour, minute: minute, title: "이번 꿈은 어떠셨나요?", body: "좋은 꿈 꾸셨나요? 꿈을 꾸셨다면 지금, 기억날 떄 기록해주세요")
                Log.info("알림을 잘 등록했습니다. hour \(hour) minute \(minute)")
                return true
            } catch let error as NSError {
                Log.error("알림을 등록하는 중 문제가 발생했습니다 error \(error.domain) \(error.userInfo)")
                self.notification.removeAll()
                let alert = UIAlertController(title: "알림 기능을 사용할 수 없어요", message: "\"설정 → 앱 → 꿈꾸\"에서 알림 허용이 활성화되어 있는지 확인해주세요", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
                return false
            }
        }
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
        case select(label: String, currentValue: Bool, onChange: (Bool) async -> Bool) // onChange: false를 반환하면 이전 값으로 롤백
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
                
                Task {
                    let rollback = !(await onChange(select.isOn))
                    if rollback {
                        select.isOn.toggle()
                    }
                }
            }), for: .valueChanged)
            cell.accessoryView = select
        }
        
        if case let .button(label, _) = item {
            content.text = label
            cell.accessoryView = nil // 재사용될 때 이전에 할당해뒀던 악세서리 뷰를 해제/
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
