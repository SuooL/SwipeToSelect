//
//  WordSource.swift
//  SwipeToSelect
//
//  Created by 胡振生 on 3/21/17.
//  Copyright © 2017 suool. All rights reserved.
//

import UIKit
import Foundation

class WordSource: NSObject {
    static func getwords() -> Array<String> {
        let manager = FileManager.default
        let file = Bundle.main.path(forResource: "words", ofType: "txt");
        
        let data2 = manager.contents(atPath: file!)
        let readString2 = String(data: data2!, encoding: String.Encoding.utf8)
        
        let wordsArray = (readString2?.components(separatedBy: "\n"))!
        
        let orderSet: NSOrderedSet = NSOrderedSet.init(array: wordsArray)
        
        return orderSet.array as! Array<String>
    }
    
}
