//
//  CoreDateService.swift
//  kkumku
//
//  Created by 임영택 on 12/24/24.
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    private var containerName: String = "kkumku"
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as? NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    private init() {
        Log.info("CoreDataStack 초기화", for: .system)
    }
}
