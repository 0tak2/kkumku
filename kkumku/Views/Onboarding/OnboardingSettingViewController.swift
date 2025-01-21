//
//  OnboardingSettingViewController.swift
//  kkumku
//
//  Created by 임영택 on 1/21/25.
//

import UIKit

class OnboardingSettingViewController: UIViewController {
    private let tableView = UITableView()
    let cellReusableId = "OnboardingSettingViewControllerTableViewCell"
    var settingItems: [Section: [Item]] = [:]
    
    let nextButton = UIButton()
    
    private var bedTime = Date.fromHourAndMinute(hour: 00, minute: 00)!
    private var wakingTime = Date.fromHourAndMinute(hour: 07, minute: 00)!
    private var notificationEnabled = true
    
    // MARK: - Settings
    let settings = UserSettings.shared
    
    // MARK: - Notification
    let notification = NotificationSupport.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        view.addSubview(nextButton)

        style()
        layout()
        
        // MARK: - Table View
        settingItems = [
            .title: [
                .titleLabel(label: "시작하기 전에\n몇 가지만 설정해주세요."),
            ],
            .time: [
                .datePicker(label: "취침 시각", currentValue: bedTime, onChange: { [weak self] date in
                    self?.bedTime = date
                }),
                .datePicker(label: "기상 시각", currentValue: wakingTime, onChange: { [weak self] date in
                    self?.wakingTime = date
                }),
            ],
            .notification: [
                .select(label: "알림", currentValue: notificationEnabled, onChange: { [weak self] isOn in
                    self?.notificationEnabled = isOn
                }),
            ],
        ]
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReusableId)
        tableView.dataSource = self // weak
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    private func nextButtonTapped() {
        saveUserSettings()
        
        // MARK: Go to Main Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let mainViewController = storyboard.instantiateInitialViewController() else {
            fatalError("Main.storyboard의 초기 ViewController를 찾을 수 없습니다.")
        }

        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = mainViewController
            }, completion: nil)
        }
    }
    
    private func saveUserSettings() {
        settings.set(true, for: .onboardingCompleted)
        settings.set(wakingTime.toISOString(), for: .wakingTime)
        settings.set(bedTime.toISOString(), for: .bedTime)
        settings.set(notificationEnabled, for: .notificationEnabled)
        
        let wakingTimeHourAndMinute = wakingTime.toHourAndMinute()
        let (hour, minute) = (wakingTimeHourAndMinute[0], wakingTimeHourAndMinute[1])
        let _ = registerDailyNotification(hour: hour, minute: minute)
    }
    
    // FIXME: 알림 등록 로직 중복 - SettingViewController
    
    private func checkNotificationAuthorization() async throws {
        let isAuthorized = try await notification.isAuthorized()
        if !isAuthorized {
            notificationEnabled = false
            tableView.reloadData()
        }
    }
    
    private func registerDailyNotification(hour: Int, minute: Int) -> Task<Bool, Never> {
        Task {
            do {
                let isAuthorized = try await notification.isAuthorized()
                guard isAuthorized else {
                    Log.info("알림 등록을 시도했으나 권한이 없었습니다.")
                    return false
                }
                
                notification.removeAll()
                try await self.notification.registerDailyNotification(hour: hour, minute: minute, title: "안녕히 주무셨나요?", body: "이번 꿈에 대해 기록해주세요")
                Log.info("알림을 잘 등록했습니다. hour \(hour) minute \(minute)")
                return true
            } catch let error as NSError {
                Log.error("알림을 등록하는 중 문제가 발생했습니다 error \(error.domain) \(error.userInfo)")
                self.notification.removeAll()
                return false
            }
        }
    }
}

extension OnboardingSettingViewController {
    private func style() {
        view.backgroundColor = .black
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.image = UIImage(systemName: "arrow.right")
        buttonConfig.imagePlacement = .trailing
        buttonConfig.imagePadding = 8
        buttonConfig.baseForegroundColor = .black
        buttonConfig.baseBackgroundColor = .primary
        var attributedString = AttributedString("설정 완료")
        attributedString.font = .systemFont(ofSize: 18, weight: .bold)
        buttonConfig.attributedTitle = attributedString
        nextButton.configuration = buttonConfig
        nextButton.addAction(UIAction(handler: { [weak self] _ in
            self?.nextButtonTapped()
        }), for: .touchUpInside)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            tableView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: tableView.trailingAnchor, multiplier: 1),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: tableView.bottomAnchor, multiplier: 1),
        ])
        
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 4),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: nextButton.trailingAnchor, multiplier: 4),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: nextButton.bottomAnchor, multiplier: 1),
            nextButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
