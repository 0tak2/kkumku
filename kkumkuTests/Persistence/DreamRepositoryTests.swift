//
//  DreamRepositoryTests.swift
//  kkumkuTests
//
//  Created by 임영택 on 2/2/25.
//

import Testing
@testable import kkumku
import CoreData

struct DreamRepositoryTests {
    let coreDataProvider: CoreDataProvider!
    let repository: DreamRepository!
    
    init() {
        self.coreDataProvider = InMemoryCoreDataStack()
        self.repository = DreamRepository(coreData: coreDataProvider)
    }
    
    @Test("꿈 엔티티를 저장할 수 있어야 한다")
    func saveNewDreamEntity() throws {
        let testDate = Date(timeIntervalSince1970: 1738482192.891276)
        
        let dream = Dream(startAt: testDate, endAt: testDate, memo: "Test Dream", dreamClass: .ambiguous, isLucid: false)
        let savedModel = repository.save(dream)
        
        let container = coreDataProvider.persistentContainer
        let context = container.viewContext
        let fetchRequest = DreamEntity.fetchRequest()
        let fetchedResult = try context.fetch(fetchRequest)
        
        let savedEntity = try #require(fetchedResult.first)
        #expect(savedEntity.id == savedModel?.id // TODO: 개선
                && savedEntity.startAt == savedModel?.startAt
                && savedEntity.endAt == savedModel?.endAt
                && Int(savedEntity.dreamClass) == savedModel?.dreamClass.rawValue
                && savedEntity.isLucid == savedModel?.isLucid)
    }
    
    @Test("꿈 엔티티를 수장할 수 있어야 한다")
    func updateNewDreamEntity() throws {
        let testDate = Date(timeIntervalSince1970: 1738482192.891276)
        
        let dream = Dream(startAt: Date.now, endAt: Date.now, memo: "Test Dream", dreamClass: .ambiguous, isLucid: false)
        var savedModel = try #require(repository.save(dream))
        savedModel.startAt = testDate
        savedModel.endAt = testDate
        savedModel.memo = "It was updated!"
        let updatedModel = repository.save(savedModel)
        
        let container = coreDataProvider.persistentContainer
        let context = container.viewContext
        let fetchRequest = DreamEntity.fetchRequest()
        let fetchedResult = try context.fetch(fetchRequest)
        
        let savedEntity = try #require(fetchedResult.first)
        #expect(savedEntity.id == updatedModel?.id // TODO: 개선
                && savedEntity.startAt == updatedModel?.startAt
                && savedEntity.endAt == updatedModel?.endAt
                && Int(savedEntity.dreamClass) == updatedModel?.dreamClass.rawValue
                && savedEntity.isLucid == updatedModel?.isLucid)
    }
    
    struct InMemoryCoreDataStack: CoreDataProvider {
        var persistentContainer: NSPersistentContainer = {
            let container = InMeomoryContainer(name: "kkumku")
            
            container.loadPersistentStores { storeDescription, error in
                if let error = error as? NSError {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            
            return container
        }()
    }
    
    // ref: https://useyourloaf.com/blog/core-data-in-memory-store/
    final class InMeomoryContainer: NSPersistentContainer, @unchecked Sendable {
        public init(name: String, bundle: Bundle = .main) {
            guard let mom = NSManagedObjectModel.mergedModel(from: [bundle]) else {
              fatalError("Failed to create mom")
            }
            super.init(name: name, managedObjectModel: mom)
            configureInMemory()
        }
        
        private func configureInMemory() {
            if let storeDescription = persistentStoreDescriptions.first {
                storeDescription.shouldAddStoreAsynchronously = true
                storeDescription.url = URL(fileURLWithPath: "/dev/null")
                storeDescription.shouldAddStoreAsynchronously = false
            }
        }
    }
}
