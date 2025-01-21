//
//  OnboardingPage.swift
//  kkumku
//
//  Created by 임영택 on 1/21/25.
//

import UIKit

struct OnboardingPage: Hashable {
    let image: UIImage?
    let title: String
    
    static let pages: [OnboardingPage] = [
        OnboardingPage(image: nil, title: "꿈꾸는\n꿈꾸는 일기장입니다."),
        OnboardingPage(image: UIImage(systemName: "plus"), title: "꿈의 기억이 달아나기 전에,\n빠르게 기록해보세요."),
        OnboardingPage(image: UIImage(systemName: "calendar"), title: "기록한 꿈을 한 눈에\n달력에서 확인해보세요."),
        OnboardingPage(image: UIImage(systemName: "magnifyingglass"), title: "키워드와 태그로\n꿈을 찾고 탐색해보세요."),
    ]
}
