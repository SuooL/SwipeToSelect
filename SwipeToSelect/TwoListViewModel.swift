//
//  TwoListViewModel.swift
//  SwipeToSelect
//
//  Created by 胡振生 on 3/25/17.
//  Copyright © 2017 suool. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class TwoListViewModel: NSObject {
    // output:
    var modelsRight: Driver<[Word]>
    var modelsLeft: Driver<[Word]>
    
    init(order: Observable<Int>) {
        
        let realm = try! Realm()

        var left: Array<Word> = Array<Word>()
        var right: Array<Word> = Array<Word>()
        
        let words = realm.objects(Word.self).sorted(byKeyPath: "name").toArray()
        
        for word in words {
            if (word.name?.uppercased())! < "N" {
                left.append(word)
            }else{
                right.append(word)
            }
        }
        
        let modelR = order.map({ or -> [Word] in
            return or == 0 ? right : shuffle(array: right)
        })
        
        let modelL = order.map({ or -> [Word] in
            return or == 0 ? left : shuffle(array: left)
        })
     
        modelsRight = modelR.asDriver(onErrorJustReturn: Array<Word>())
        modelsLeft = modelL.asDriver(onErrorJustReturn: Array<Word>())
    }
    
}
