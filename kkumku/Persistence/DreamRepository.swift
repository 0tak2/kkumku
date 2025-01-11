//
//  DreamRepository.swift
//  kkumku
//
//  Created by 임영택 on 12/25/24.
//

import CoreData

final class DreamRepository {
    static let shared = DreamRepository()
    
    let coreData: CoreDataStack
    
    func withContext<T>(_ task: (_ context: NSManagedObjectContext) throws -> T,
                     onFailure: ((_ context: NSManagedObjectContext, _ error: Error) -> Void)? = nil ) -> T? {
        let container = coreData.persistentContainer
        
        let context = container.viewContext
        
        do {
            return try task(context)
        } catch let error as NSError {
            Log.error("[DreamRepository] failed job... \(error) \(error.userInfo)")
            if let onFailure = onFailure {
                onFailure(context, error)
            }
            return nil
        }
    }
    
    func save(_ dream: Dream) -> Dream? {
        withContext { context in
            let fetchRequest = DreamEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", dream.id as NSUUID)
            
            let fetchResult: [DreamEntity] = try context.fetch(fetchRequest)
            let originalEntity: DreamEntity? = fetchResult.first
            
            let savedEntity: DreamEntity
            if let originalEntity = originalEntity {
                savedEntity = try update(context: context, dream: dream, found: originalEntity)
            } else {
                savedEntity = try insert(context: context, dream: dream)
            }
            
            // convert saved entity to model
            // FIXME: dupliacted. TODO: 모델-엔티티 전환 로직 구분
            var tags = [String]()
            for dreamAndTagEntity in savedEntity.dreamAndTags ?? NSSet() {
                if let dreamAndTagEntity = dreamAndTagEntity as? DreamAndTagEntity,
                   let tagEntity = dreamAndTagEntity.tag,
                   let tag = tagEntity.tag {
                    tags.append(tag)
                }
            }
            return Dream(id: savedEntity.id!, startAt: savedEntity.startAt!, endAt: savedEntity.endAt!, memo: savedEntity.memo!, dreamClass: DreamClass(rawValue: Int(savedEntity.dreamClass))!, isLucid: savedEntity.isLucid, tags: tags)
        } onFailure: { context, error in
            context.rollback()
        }
    }
    
    func update(context: NSManagedObjectContext, dream: Dream, found originalEntity: DreamEntity) throws -> DreamEntity {
        originalEntity.startAt = dream.startAt
        originalEntity.endAt = dream.endAt
        originalEntity.memo = dream.memo
        originalEntity.isLucid = dream.isLucid
        originalEntity.dreamClass = Int16(dream.dreamClass.rawValue)
        
        var currentTags: [String: DreamAndTagEntity] = [:] // [tag: DreamAndTagEntity]
        originalEntity.dreamAndTags?.forEach({ dreamAndTagEntity in
            guard let dreamAndTagEntity = dreamAndTagEntity as? DreamAndTagEntity else {
                return
            }
            
            if let tagEntity = dreamAndTagEntity.tag, let tagStr = tagEntity.tag {
                currentTags[tagStr] = dreamAndTagEntity
            }
        })
        
        // 현재 저장된 모든 태그를 순회
        currentTags.forEach { (tagStr, connectEntity) in
            if !dream.tags.contains(tagStr) { // 새로운 모델에 없는 태그라면 삭제
                context.delete(connectEntity)
            }
        }
        
        // 새로운 모든 태그를 순회
        // FIXME: Duplicated codes
        try dream.tags.forEach { tagStr in
            if !currentTags.keys.contains(tagStr) { // 저장된 엔티티에 없는 태그라면 추가
                let tagFetchRequest = DreamTagEntity.fetchRequest()
                tagFetchRequest.predicate = NSPredicate(format: "tag == %@", tagStr)
                
                let tagFetchResult = try context.fetch(tagFetchRequest)
                let tagEntity: DreamTagEntity
                if let foundTagEntity = tagFetchResult.first {
                    tagEntity = foundTagEntity
                } else {
                    tagEntity = NSEntityDescription.insertNewObject(forEntityName: "DreamTagEntity", into: context) as! DreamTagEntity
                    tagEntity.id = UUID()
                    tagEntity.tag = tagStr
                    tagEntity.tagAndDreams = []
                }
                
                let dreamAndTagEntity = NSEntityDescription.insertNewObject(forEntityName: "DreamAndTagEntity", into: context) as! DreamAndTagEntity
                dreamAndTagEntity.dream = originalEntity
                dreamAndTagEntity.tag = tagEntity
                
                tagEntity.addToTagAndDreams(dreamAndTagEntity)
                originalEntity.addToDreamAndTags(dreamAndTagEntity)
            }
        }
        
        try context.save()
        return originalEntity
    }
    
    func insert(context: NSManagedObjectContext, dream: Dream) throws -> DreamEntity {
        let dreamEntity = NSEntityDescription.insertNewObject(forEntityName: "DreamEntity", into: context) as! DreamEntity
        
        dreamEntity.id = dream.id
        dreamEntity.startAt = dream.startAt
        dreamEntity.endAt = dream.endAt
        dreamEntity.memo = dream.memo
        dreamEntity.isLucid = dream.isLucid
        dreamEntity.dreamClass = Int16(dream.dreamClass.rawValue)
        dreamEntity.dreamAndTags = []
        
        for tag in dream.tags {
            let tagFetchRequest = DreamTagEntity.fetchRequest()
            tagFetchRequest.predicate = NSPredicate(format: "tag == %@", tag)
            
            let tagFetchResult = try context.fetch(tagFetchRequest)
            let tagEntity: DreamTagEntity
            if let foundTagEntity = tagFetchResult.first {
                tagEntity = foundTagEntity
            } else {
                tagEntity = NSEntityDescription.insertNewObject(forEntityName: "DreamTagEntity", into: context) as! DreamTagEntity
                tagEntity.id = UUID()
                tagEntity.tag = tag
                tagEntity.tagAndDreams = []
            }
            
            let dreamAndTagEntity = NSEntityDescription.insertNewObject(forEntityName: "DreamAndTagEntity", into: context) as! DreamAndTagEntity
            dreamAndTagEntity.dream = dreamEntity
            dreamAndTagEntity.tag = tagEntity
            
            tagEntity.addToTagAndDreams(dreamAndTagEntity)
            dreamEntity.addToDreamAndTags(dreamAndTagEntity)
        }
        
        try context.save()
        return dreamEntity
    }
    
    /**
     꿈 엔티티를 모두 조회한다.
     numberOfItems를 음수로 지정하면 모든 데이터를 읽어온다.
     */
    func fetchAll(sortBy: AnyKeyPath = \DreamEntity.endAt, ascending: Bool = false, numberOfItems: Int = 10, page: Int = 1) -> [Dream] {
        let result = withContext { context -> [Dream] in
            let fetchRequest = DreamEntity.fetchRequest()
            
            if numberOfItems >= 0 {
                fetchRequest.fetchLimit = numberOfItems
                fetchRequest.fetchOffset = numberOfItems * (page - 1)
            }
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DreamEntity.endAt, ascending: ascending)]

            let dreams = try context.fetch(fetchRequest)
            
            return dreams.map { dreamEntity in
                var tags: [String] = []
                
                for dreamAndTagEntity in dreamEntity.dreamAndTags ?? NSSet() {
                    if let dreamAndTagEntity = dreamAndTagEntity as? DreamAndTagEntity,
                       let tagEntity = dreamAndTagEntity.tag,
                       let tag = tagEntity.tag {
                        tags.append(tag)
                    }
                }
                
                return Dream(
                    id: dreamEntity.id!,
                    startAt: dreamEntity.startAt!,
                    endAt: dreamEntity.endAt!,
                    memo: dreamEntity.memo!,
                    dreamClass: DreamClass(rawValue: Int(dreamEntity.dreamClass))!,
                    isLucid: dreamEntity.isLucid,
                    tags: tags)
            }
        }
        
        return result ?? []
    }
    
    func find(id: UUID) -> Dream? {
        return withContext { context in
            let fetchRequest = DreamEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as NSUUID)
            let result = try context.fetch(fetchRequest)
            if let dreamEntity = result.first {
                var tags: [String] = []
                
                for dreamAndTagEntity in dreamEntity.dreamAndTags ?? NSSet() {
                    if let dreamAndTagEntity = dreamAndTagEntity as? DreamAndTagEntity,
                       let tagEntity = dreamAndTagEntity.tag,
                       let tag = tagEntity.tag {
                        tags.append(tag)
                    }
                }
                
                return Dream(
                    id: dreamEntity.id!,
                    startAt: dreamEntity.startAt!,
                    endAt: dreamEntity.endAt!,
                    memo: dreamEntity.memo!,
                    dreamClass: DreamClass(rawValue: Int(dreamEntity.dreamClass))!,
                    isLucid: dreamEntity.isLucid,
                    tags: tags)
            }
            
            throw NSError(domain: "entity not found", code: 0)
        }
    }
    
    func findAll(containing query: String) -> [Dream] {
        let result = withContext { context in
            let fetchRequest = DreamEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "memo contains[cd] %@", query)
            let result = try context.fetch(fetchRequest)
            
            return result.map { entity in
                // FIXME: Duplicated (태그 넣는 부분)
                var tags: [String] = []
                
                for dreamAndTagEntity in entity.dreamAndTags ?? NSSet() {
                    if let dreamAndTagEntity = dreamAndTagEntity as? DreamAndTagEntity,
                       let tagEntity = dreamAndTagEntity.tag,
                       let tag = tagEntity.tag {
                        tags.append(tag)
                    }
                }
                
                return Dream(
                    id: entity.id!,
                    startAt: entity.startAt!,
                    endAt: entity.endAt!,
                    memo: entity.memo!,
                    dreamClass: DreamClass(rawValue: Int(entity.dreamClass))!,
                    isLucid: entity.isLucid,
                    tags: tags)
            }
        }
        
        return result ?? []
    }
    
    func findAll(from startDate: Date, to endDate: Date) -> [Dream] {
        let result = withContext { context in
            let fetchRequest = DreamEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "endAt >= %@ && endAt <= %@", startDate as NSDate, endDate as NSDate)
            let result = try context.fetch(fetchRequest)
            
            return result.map { entity in
                // FIXME: Duplicated (태그 넣는 부분)
                var tags: [String] = []
                
                for dreamAndTagEntity in entity.dreamAndTags ?? NSSet() {
                    if let dreamAndTagEntity = dreamAndTagEntity as? DreamAndTagEntity,
                       let tagEntity = dreamAndTagEntity.tag,
                       let tag = tagEntity.tag {
                        tags.append(tag)
                    }
                }
                
                return Dream(
                    id: entity.id!,
                    startAt: entity.startAt!,
                    endAt: entity.endAt!,
                    memo: entity.memo!,
                    dreamClass: DreamClass(rawValue: Int(entity.dreamClass))!,
                    isLucid: entity.isLucid,
                    tags: tags)
            }
        }
        
        return result ?? []
    }
    
    func delete(by id: UUID) {
        withContext { context in
            let fetchRequest = DreamEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as NSUUID)
            
            let fetchResult: [DreamEntity] = try context.fetch(fetchRequest)
            
            if let entity = fetchResult.first {
                context.delete(entity)
                try context.save()
            }
        } onFailure: { context, error in
            context.rollback()
        }
    }
    
    func fetchAllTags() -> [String] {
        let result = withContext { context in
            let fetchRequest = DreamTagEntity.fetchRequest()
            let tagEntities = try context.fetch(fetchRequest)
            
            return tagEntities.compactMap { entity in
                entity.tag
            }
        }
        
        return result ?? []
    }
    
    private init(coreData: CoreDataStack) {
        self.coreData = coreData
        Log.info("DreamRepository 초기화", for: .system)
    }
    
    private convenience init() {
        self.init(coreData: CoreDataStack.shared)
    }
}
