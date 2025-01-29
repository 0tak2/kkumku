//
//  DIContainerFactory.swift
//  kkumku
//
//  Created by 임영택 on 1/29/25.
//

import Swinject
import SwinjectStoryboard
import UIKit

final class DIContainerProvider {
    private(set) static var container: Container = {
        let container = Container()
        
        // MARK: Storyboard DI
        container.storyboardInitCompleted(EditViewController.self) { r, c in
            c.dreamRepository = r.resolve(DreamRepositoryProtocol.self)
        }
        
        container.storyboardInitCompleted(CalendarViewController.self) { r, c in
            c.dreamRepository = r.resolve(DreamRepositoryProtocol.self)
        }
        
        container.storyboardInitCompleted(ExploreViewController.self) { r, c in
            c.dreamRepository = r.resolve(DreamRepositoryProtocol.self)
        }
        
        container.storyboardInitCompleted(SettingViewController.self) { r, c in
            c.dreamRepository = r.resolve(DreamRepositoryProtocol.self)
        }
        
        container.storyboardInitCompleted(DetailDreamViewController.self) { r, c in
            c.dreamRepository = r.resolve(DreamRepositoryProtocol.self)
        }
        
        container.storyboardInitCompleted(SearchDreamViewController.self) { r, c in
            c.dreamRepository = r.resolve(DreamRepositoryProtocol.self)
        }
        
        // MARK: Register Components
        container.register(CoreDataProvider.self) { _ in
            CoreDataStack()
        }
        .inObjectScope(.container)
        
        container.register(DreamRepositoryProtocol.self) { r in
            DreamRepository(coreData: r.resolve(CoreDataProvider.self)!)
        }
        .inObjectScope(.container)
        
        return container
    }()
    
    static func getStoryboardWithContainer(name: String, bundle: Bundle?) -> SwinjectStoryboard {
        return SwinjectStoryboard.create(name: name, bundle: bundle, container: container)
    }
}
