//
//  Word.swift
//  SwipeToSelect
//
//  Created by 胡振生 on 3/21/17.
//  Copyright © 2017 suool. All rights reserved.
//

import Foundation
import RealmSwift

class Word: Object {
    // Mark: Properties
    dynamic var id: Int = 0
    dynamic var name: String? = nil;
    dynamic var note: String = ""
    dynamic var isSelect: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }

    func save() {
        do {
            let realm = try! Realm()
            
            try realm.write {
                    realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func update(){
        do {
            let realm = try Realm()
            try! realm.write {
                let predicate = NSPredicate(format: "name = '\(self.name!)'")
                let word = realm.objects(Word.self).filter(predicate)
                word.first!.note = self.note
                word.first!.isSelect = self.isSelect
                if (word.first != nil) { realm.add(word.first!, update: true) }
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}
