//
//  Search.swift
//  SwipeToSelect
//
//  Created by 胡振生 on 3/24/17.
//  Copyright © 2017 suool. All rights reserved.
//

protocol SearchDelegate {
    func hideSearchView(status: Bool)
    func selectWord(word: Word)
}

import UIKit
import RxSwift
import RxCocoa

class Search: UIView, UITableViewDelegate{
    
    // Mark: Properties
    var disposeBag = DisposeBag()
    
    var controller: UIViewController?
    
    let statusView: UIView = {
        let st = UIView.init(frame: UIApplication.shared.statusBarFrame)
        st.backgroundColor = UIColor.black
        st.alpha = 0.15
        return st
    }()
    
    lazy var searchView: UIView = {
        let sv = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: 68))
        sv.backgroundColor = UIColor.white
        sv.alpha = 0
        return sv
    }()
    lazy var backgroundView: UIView = {
        let bv = UIView.init(frame: self.frame)
        bv.backgroundColor = UIColor.black
        bv.alpha = 0.7
        return bv
    }()
    lazy var backButton: UIButton = {
        let bb = UIButton.init(frame: CGRect.init(x: self.frame.width-48, y: 20, width: 44, height: 44))
        bb.setTitle("取消", for: UIControlState.normal)
        bb.setTitleColor( .blue, for: UIControlState.highlighted)
        bb.setTitleColor( .gray, for: UIControlState.normal)
        bb.addTarget(self, action: #selector(Search.dismiss), for: .touchUpInside)
        return bb
    }()
    lazy var searchField: UITextField = {
        let sf = UITextField.init(frame: CGRect.init(x: 8, y: 20, width: self.frame.width - 50, height: 47))
        
        sf.placeholder = "查找单词"
        return sf
    }()
    
    lazy var line: UIView = {
       let line = UIView.init(frame: CGRect.init(x: 0, y: 67, width: self.frame.width, height: 1) )
        line.backgroundColor = .black
        line.alpha = 0.4
        return line
    }()
    
    lazy var tableView: UITableView = {
        let tv: UITableView = UITableView.init(frame: CGRect.init(x: 0, y: 68, width: self.frame.width, height: self.frame.height - 68))
        return tv
    }()
    lazy var items: Array<Word> = {
        var wordArray: Array <Word> = Array <Word>()
        
        for (index, item) in  WordSource.getwords().enumerated() {
            let word = Word();
            word.id = index
            word.name = item
            wordArray.append(word)
        }

        wordArray = wordArray.sorted(by: { $0.name!.localizedStandardCompare($1.name!) == ComparisonResult.orderedAscending
        })
        return wordArray
    }()
    
    
    
    var delegate:SearchDelegate?
    
    // Mark: Methods
    private func customization()  {
        self.addSubview(self.backgroundView)
        self.backgroundView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(Search.dismiss)))
        self.addSubview(self.searchView)
        self.searchView.addSubview(self.searchField)
        self.searchView.addSubview(self.backButton)
        self.searchView.addSubview(self.line)
        self.tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.white
        self.addSubview(self.statusView)
        self.addSubview(self.tableView)
        let searchQuary = self.searchField.rx.text.orEmpty.asObservable()
        
        let viewModel = ViewModel(searchQuary: searchQuary)
        
        viewModel.results
            .drive(self.tableView.rx.items(cellIdentifier: "cell", cellType: TableViewCell.self)) {
                (tableView, element, cell) in
                cell.cellViewModel = element
            }
            .addDisposableTo(disposeBag)
        
    }
    
    func animate()  {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.alpha = 0.5
            self.searchView.alpha = 1
            self.searchField.becomeFirstResponder()
            self.tableView.delegate = self
            self.addSubview(self.tableView)
        })

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = self.tableView.cellForRow(at: indexPath) as! TableViewCell
        let word = Word()
        word.name = cell.wordLabel.text
        word.note = cell.detailLabel.text!
        self.searchField.text = ""
        self.tableView.removeFromSuperview()
        UIView.animate(withDuration: 0.01, animations: {
            self.backgroundView.alpha = 0
            self.searchView.alpha = 0
            self.searchField.resignFirstResponder()
        }, completion: {(Bool) in
            self.delegate?.hideSearchView(status: true)
            self.delegate?.selectWord(word: word)
        })
    }
    
    func  dismiss()  {
        self.searchField.text = ""
        self.tableView.removeFromSuperview()
        UIView.animate(withDuration: 0.15, animations: {
            self.backgroundView.alpha = 0
            self.searchView.alpha = 0
            self.searchField.resignFirstResponder()
        }, completion: {(Bool) in
            self.delegate?.hideSearchView(status: true)
        })
    }
    
//    // Mark:
//     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        dismiss()
//        return true
//    }
    
    //MARK: Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        customization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.tableView.separatorStyle = .singleLine
    }
}

class ViewModel: NSObject {
    var results: Driver<[SearchTableViewCellViewModel]>
    
    init(searchQuary: Observable<String>) {
        let service = SearchService()
        
        self.results = searchQuary
            .throttle(1, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .distinctUntilChanged()
            .flatMap { quary in
                return service.getSearchResults(query: quary)
                    .catchErrorJustReturn([])
            }
            .map { words in
                return words.map {word in
                    SearchTableViewCellViewModel(searchResult: word)
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
}


