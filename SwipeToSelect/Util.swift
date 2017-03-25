//
//  Util.swift
//  SwipeToSelect
//
//  Created by 胡振生 on 3/23/17.
//  Copyright © 2017 suool. All rights reserved.
//

import Foundation
import RealmSwift

public func shuffle <T> (array :Array<T>) -> Array<T> {
    var list = array
    for index in 0..<array.count {
        let newIndex = Int(arc4random_uniform(UInt32(list.count-index))) + index
        if index != newIndex {
            swap(&list[index], &list[newIndex])
        }
    }
    return list
}

extension Results {
    func toArray() -> [Results.Generator.Element] {
        return map { $0 }
    }
}

extension Array where Element: Equatable {
    
    mutating func remove(object: Element) {
        
        if let index = index(of: object) {
            
            remove(at: index)
        }
    }
}
