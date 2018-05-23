//
//  item.swift
//  Todoey
//
//  Created by Theo Carper on 22/05/2018.
//  Copyright © 2018 Theo Carper. All rights reserved.
//

import Foundation

class Item: Codable {
    
    var title: String
    var done: Bool
    
    init(title: String, done: Bool = false) {
        self.title = title
        self.done = done
    }
}
