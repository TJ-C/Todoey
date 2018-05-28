//
//  Data.swift
//  Todoey
//
//  Created by Theo Carper on 24/05/2018.
//  Copyright © 2018 Theo Carper. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var title = ""
    @objc dynamic var done = false
    @objc dynamic var dateCreated = Date()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items") // reverse lookup
    
}
