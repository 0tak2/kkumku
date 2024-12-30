//
//  DreamRepository.swift
//  kkumku
//
//  Created by 임영택 on 12/25/24.
//

import CoreData

final class DreamRepository {
    let coreData: CoreDataStack
    
    func withContext<T>(_ task: (_ context: NSManagedObjectContext) throws -> T,
                     onFailure: ((_ context: NSManagedObjectContext, _ error: Error) -> Void)? = nil ) -> T? {
        let container = coreData.persistentContainer
        
        let context = container.viewContext
        
        do {
            return try task(context)
        } catch let error as NSError {
            print("[DreamRepository] failed job... \(error) \(error.userInfo)")
            if let onFailure = onFailure {
                onFailure(context, error)
            }
            return nil
        }
    }
    
    func save(_ dream: Dream) {
        withContext { context in
            let fetchRequest = DreamEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", dream.id as NSUUID)
            
            let fetchResult: [DreamEntity] = try context.fetch(fetchRequest)
            let originalEntity: DreamEntity? = fetchResult.first
            
            if let originalEntity = originalEntity {
                try update(context: context, dream: dream, found: originalEntity)
            } else {
                try insert(context: context, dream: dream)
            }
        } onFailure: { context, error in
            context.rollback()
        }
    }
    
    func update(context: NSManagedObjectContext, dream: Dream, found originalEntity: DreamEntity) throws {
        originalEntity.startAt = dream.startAt
        originalEntity.endAt = dream.endAt
        originalEntity.memo = dream.memo
        originalEntity.isLucid = dream.isLucid
        originalEntity.dreamClass = Int16(dream.dreamClass.rawValue)
        
        // TODO: 태그 업데이트
        let shouldRemoveTags: [String]? = originalEntity.dreamAndTags?.compactMap({ dreamAndTagEntity in
            // 현재 저장된 모든 태그를 순회
            guard let dreamAndTagEntity = dreamAndTagEntity as? DreamAndTagEntity else {
                return nil
            }
            
            let tagStr: String? = dreamAndTagEntity.tag?.tag
            
            if let tagStr = tagStr, !dream.tags.contains(tagStr) { // 새로운 모델에 없는 태그라면 제거해야함
                return tagStr
            } else {
                return nil
            }
        })
        
//        let shouldAddTags: [String] = dream.tags.compactMap { tag in
//            if DreamEntity
//        }
        
        try context.save()
    }
    
    func insert(context: NSManagedObjectContext, dream: Dream) throws {
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
    }
    
    func fetchAll(sortBy: AnyKeyPath = \DreamEntity.endAt, ascending: Bool = false, numberOfItems: Int = 10, page: Int = 1) -> [Dream] {
        let result = withContext { context -> [Dream] in
            let fetchRequest = DreamEntity.fetchRequest()
            fetchRequest.fetchLimit = numberOfItems
            fetchRequest.fetchOffset = numberOfItems * (page - 1)
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
    
    init(coreData: CoreDataStack) {
        self.coreData = coreData
    }
    
    convenience init() {
        self.init(coreData: CoreDataStack.shared)
    }
}
