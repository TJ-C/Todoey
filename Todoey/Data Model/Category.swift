//
//  Category.swift
//  Todoey
//
//  Created by Theo Carper on 24/05/2018.
//  Copyright © 2018 Theo Carper. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var backgroundColor = ""
    let items = List<Item>()
    
}
