//
//  SearchTableViewCellViewModel.swift
//  SwipeToSelect
//
//  Created by 胡振生 on 3/24/17.
//  Copyright © 2017 suool. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SearchTableViewCellViewModel: NSObject {
    var name: Driver<String>
    var desc: Driver<String>
    var isSelect: Driver<Bool>
    var word: Driver<Word>
    
    init(searchResult: Word) {
        self.name = Observable.just(searchResult.name!).asDriver(onErrorJustReturn: "Wrong")
        self.desc = Observable.just(searchResult.note).asDriver(onErrorJustReturn: "No such word")
        self.isSelect = Observable.just(searchResult.isSelect).asDriver(onErrorJustReturn: false)
        self.word = Observable.just(searchResult).asDriver(onErrorJustReturn: Word())
    }
}
