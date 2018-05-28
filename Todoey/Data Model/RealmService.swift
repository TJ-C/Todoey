//
//  RealmService.swift
//  Todoey
//
//  Created by Theo Carper on 26/05/2018.
//  Copyright © 2018 Theo Carper. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

// Protocol and extensions from here https://gist.github.com/krodak/b47ea81b3ae25ca2f10c27476bed450c

protocol CascadeDeleting: class {
    func delete<S: Sequence>(_ objects: S, cascading: Bool) where S.Iterator.Element: Object
    func delete<Entity: Object>(_ entity: Entity, cascading: Bool)
}

class RealmService {
    
    private init() {}
    static let shared = RealmService()
    
    var realm = try! Realm()
    
    func create<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            post(error)
        }
    }
    
    func appendToList<T: Object>(_ category: List<T>,  _ child: T) {
        do {
            try realm.write {
                category.append(child)
            }
        } catch {
            post(error)
        }
    }
    
    func update<T: Object>(_ object: T, with dictionary: [String: Any?])  {
        do {
            try realm.write {
                for (key, value) in dictionary {
                    object.setValue(value, forKey: key)
                }
            }
        } catch {
            post(error)
        }
    }
    
    func delete<T: Object>(_ object: T)  {
        do {
            try realm.write {
                realm.delete(object, cascading: true)
            }
        } catch {
            post(error)
        }
    }

    func post(_ error: Error) {
        NotificationCenter.default.post(name: NSNotification.Name("Realm Error"), object: error)
    }
    
    func ObserveRealmErrors(in vc: UIViewController, completion: @escaping (Error?) -> Void) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("RealmError"), object: nil, queue: nil) { (notification) in
            completion(notification.object as? Error)
        }
    }
    
    func stopObservingErrors(in vc: UIViewController) {
        NotificationCenter.default.removeObserver(vc, name: NSNotification.Name("RealmError"), object: nil)
    }

}

extension Realm: CascadeDeleting {
    func delete<S: Sequence>(_ objects: S, cascading: Bool) where S.Iterator.Element: Object {
        for obj in objects {
            delete(obj, cascading: cascading)
        }
    }

    func delete<Entity: Object>(_ entity: Entity, cascading: Bool) {
        if cascading {
            cascadeDelete(entity)
        } else {
            delete(entity)
        }
    }
}

private extension Realm {
    private func cascadeDelete(_ entity: RLMObjectBase) {
        guard let entity = entity as? Object else { return }
        var toBeDeleted = Set<RLMObjectBase>()
        toBeDeleted.insert(entity)
        while !toBeDeleted.isEmpty {
            guard let element = toBeDeleted.removeFirst() as? Object,
                !element.isInvalidated else { continue }
            resolve(element: element, toBeDeleted: &toBeDeleted)
        }
    }

    private func resolve(element: Object, toBeDeleted: inout Set<RLMObjectBase>) {
        element.objectSchema.properties.forEach {
            guard let value = element.value(forKey: $0.name) else { return }
            if let entity = value as? RLMObjectBase {
                toBeDeleted.insert(entity)
            } else if let list = value as? RealmSwift.ListBase {
                for index in 0..<list._rlmArray.count {
                    toBeDeleted.insert(list._rlmArray.object(at: index) as! RLMObjectBase)
                }
            }
        }
        delete(element)
    }
}

