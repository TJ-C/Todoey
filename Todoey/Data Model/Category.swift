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
    let items = List<Item>()
    
}
