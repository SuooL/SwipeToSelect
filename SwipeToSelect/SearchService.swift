//
//  SearchService.swift
//  SwipeToSelect
//
//  Created by 胡振生 on 3/24/17.
//  Copyright © 2017 suool. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class SearchService: NSObject {
    static let shareInstance = SearchService()
    
    class func instance() -> SearchService {
        return shareInstance
    }
    
    func getSearchResults(query: String) -> Observable<[Word]> {
        let realm = try! Realm()
        
        let predicate = query.characters.count > 0 ? NSPredicate(format: "name CONTAINS '\(query.lowercased())'") : NSPredicate(format: "name LIKE '*'")
        
        let words: Array<Word> = realm.objects(Word.self).filter(predicate).sorted(byKeyPath: "name").toArray()
        return Observable.just(words)
    }
    
    func T(results: [Word]) -> Observable<[SearchTableViewCellViewModel]> {
        let models = results.map { result in
            SearchTableViewCellViewModel(searchResult: result)
        }
        return Observable.just(models)
    }
}
