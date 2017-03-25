//
//  TableViewCell.swift
//  SwipeToSelect
//
//  Created by 胡振生 on 3/21/17.
//  Copyright © 2017 suool. All rights reserved.
//

import UIKit
import M13Checkbox
import RxSwift
import RxCocoa

class TableViewCell: UITableViewCell {

    // Mark: Properties
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var checkBox: M13Checkbox!
    
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    typealias fucBlock = (_ backMsg :String) ->()
    
    var model :Word = Word()
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    func setCellModel(_ word: Word){
        self.model = word;
        self.wordLabel.text = word.name
        self.checkBox.checkState = word.isSelect ? .checked : .unchecked
    }
    
    @IBAction func selectWord(_ sender: UIButton) {
        
        let modelWord :Word = Word()
        if self.checkBox.checkState == .checked {
            self.checkBox.checkState = .unchecked
            modelWord.isSelect = false
        }else {
            self.checkBox.checkState = .checked
            modelWord.isSelect = true
        }
        modelWord.name = self.wordLabel.text
        modelWord.update()
    }

    var cellViewModel: SearchTableViewCellViewModel? {
        didSet {
            let disposeBag = DisposeBag()
            
            guard let cellViewModel = cellViewModel else {
                return
            }
            
            cellViewModel.name
                .drive(wordLabel.rx.text)
                .addDisposableTo(disposeBag)
            
            cellViewModel.isSelect
                .drive(checkBox.ex_validState)
                .addDisposableTo(disposeBag)
            
            cellViewModel.desc
                .drive(detailLabel.rx.text)
                .addDisposableTo(disposeBag)
        }
    }
    
    func processWithBlock(){
        let modelWord :Word = Word()
        if self.checkBox.checkState == .checked {
            self.checkBox.checkState = .unchecked
            modelWord.isSelect = false
        }else {
            self.checkBox.checkState = .checked
            modelWord.isSelect = true
        }
        modelWord.name = self.wordLabel.text
        modelWord.update()
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
}

extension M13Checkbox{
    var ex_validState:AnyObserver<Bool>{
        return UIBindingObserver(UIElement: self) { m13Checkbox, valid in
            m13Checkbox.checkState = valid ? .checked : .unchecked
            }.asObserver()
    }
}
