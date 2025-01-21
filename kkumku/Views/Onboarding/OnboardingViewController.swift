//
//  OnboardingViewController.swift
//  kkumku
//
//  Created by 임영택 on 1/21/25.
//

import UIKit

class OnboardingViewController: UIViewController {
    private let titleImage = UIImageView()
    private let titleLabel = UILabel()
    private let nextButton = UIButton()
    
    private var titleConstraints: [NSLayoutConstraint] = []
    
    private let data = OnboardingPage.pages
    private var pageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(titleImage)
        view.addSubview(titleLabel)
        view.addSubview(nextButton)

        style()
        layout()
        loadPage()
    }
    
    private func nextButtonTapped() {
        guard pageIndex + 1 < data.count else {
            let onboardingSettingViewController = OnboardingSettingViewController()
            onboardingSettingViewController.modalPresentationStyle = .fullScreen
            onboardingSettingViewController.modalTransitionStyle = .flipHorizontal
            present(onboardingSettingViewController, animated: true)
            return
        }
        
        pageIndex += 1
        loadPage()
        
        let imageExisting = data[pageIndex].image != nil
        updateTitleLayout(withImage: imageExisting)
    }
}

extension OnboardingViewController {
    private func style() {
        titleImage.translatesAutoresizingMaskIntoConstraints = false
        titleImage.contentMode = .scaleAspectFit
        titleImage.tintColor = .white
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.numberOfLines = 0
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.image = UIImage(systemName: "arrow.right")
        buttonConfig.imagePlacement = .trailing
        buttonConfig.imagePadding = 8
        buttonConfig.baseForegroundColor = .black
        buttonConfig.baseBackgroundColor = .primary
        var attributedString = AttributedString()
        attributedString.font = .systemFont(ofSize: 18, weight: .bold)
        buttonConfig.attributedTitle = attributedString
        nextButton.configuration = buttonConfig
        nextButton.addAction(UIAction(handler: { [weak self] _ in
            self?.nextButtonTapped()
        }), for: .touchUpInside)
    }
    
    private func layout() {
        let imageExisting = data[pageIndex].image != nil
        updateTitleLayout(withImage: imageExisting)
        
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 4),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: nextButton.trailingAnchor, multiplier: 4),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: nextButton.bottomAnchor, multiplier: 1),
            nextButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func updateTitleLayout(withImage: Bool) {
        NSLayoutConstraint.deactivate(titleConstraints)
        
        if withImage {
            titleImage.isHidden = false
            titleConstraints = [
                titleImage.heightAnchor.constraint(equalToConstant: 48),
                titleImage.widthAnchor.constraint(equalToConstant: 48),
                titleImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
                titleImage.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 4),
                titleLabel.topAnchor.constraint(equalTo: titleImage.bottomAnchor, constant: 32),
                titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 4),
            ]
        } else {
            titleImage.isHidden = true
            titleConstraints = [
                titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -64),
                titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 4),
            ]
        }
        
        NSLayoutConstraint.activate(titleConstraints)
    }
    
    private func updateButtonTitle(isLast: Bool) {
        let title: String
        if isLast {
            title = "시작하기"
        } else {
            title = "다음"
        }
        
        var buttonConfig = nextButton.configuration
        var attributedString = AttributedString(title)
        attributedString.font = .systemFont(ofSize: 18, weight: .bold)
        buttonConfig?.attributedTitle = attributedString
        nextButton.configuration = buttonConfig
    }
    
    private func loadPage() {
        titleImage.image = data[pageIndex].image
        titleLabel.text = data[pageIndex].title
        updateButtonTitle(isLast: pageIndex == data.count - 1)
    }
}
