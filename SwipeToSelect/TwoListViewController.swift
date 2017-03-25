//
//  TwoListViewController.swift
//  SwipeToSelect
//
//  Created by 胡振生 on 3/23/17.
//  Copyright © 2017 suool. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift
import RxSwift
import RxCocoa
import KCFloatingActionButton

class TwoListViewController: UIViewController, UIGestureRecognizerDelegate,UIScrollViewDelegate, SearchDelegate {
    
    // Mark: Properties
    @IBOutlet weak var topPanel: UIView!
    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var secondBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    

    var disposeBag = DisposeBag()
    
    var isLeftPan: Bool = false;
    var lastSelectIndex: IndexPath? = nil
    var presentSelectIndex: IndexPath? = nil
    
    var fab = KCFloatingActionButton()
    // segment controll indicator
    let scrollBar = UIView()
    // 列表
    var tableViewLeft: UITableView = UITableView()
    var tableViewRight: UITableView = UITableView()
    // 当前
    var isLeftTable: Bool = true
    // 随机
    var isShuffle: Variable<Int> = Variable(0)
    // 选中的单词
    var selectWord: Word = Word()
    
    lazy var search: Search = {
        let se = Search.init(frame: UIScreen.main.bounds)
        se.delegate = self
        return se
    }()
    
    let swipeGestureUp = UIPanGestureRecognizer()
    
    // Mark: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Mark: initView
        initTableView()
        initFBtn()
        // Mark: addGestureRecognizer
        self.swipeGestureUp.delegate = self;
        self.swipeGestureUp.addTarget(self, action: #selector(handleSwipeUpDown(_:)))
        self.scrollView.addGestureRecognizer(self.swipeGestureUp)
        // Mark: viewmodel
        let order = self.isShuffle.asObservable()
        let viewModel = TwoListViewModel(order: order)
        viewModel.modelsRight
            .drive(self.tableViewRight.rx.items(cellIdentifier: "cell", cellType: TableViewCell.self)) { (row, element, cell) in
                cell.setCellModel(element)
            }
            .addDisposableTo(disposeBag)
        viewModel.modelsLeft
            .drive(self.tableViewLeft.rx.items(cellIdentifier: "cell", cellType: TableViewCell.self)) { (row, element, cell) in
                cell.setCellModel(element)
            }
            .addDisposableTo(self.disposeBag)
        
        // Mark: Rx table delegate
        self.tableViewLeft.rx.setDelegate(self).addDisposableTo(self.disposeBag)
        self.tableViewLeft.rx
            .itemSelected
            .subscribe(onNext: { indexPath in
                let cell = self.tableViewLeft.cellForRow(at: indexPath) as! TableViewCell
                self.selectWord.name = cell.wordLabel.text
                self.selectWord.note = cell.detailLabel.text!
                self.performSegue(withIdentifier: "showDetail", sender: nil)
            })
            .disposed(by: disposeBag)
        self.tableViewRight.rx.setDelegate(self).addDisposableTo(self.disposeBag)
        self.tableViewRight.rx
            .itemSelected
            .subscribe(onNext: { indexPath in
                let cell = self.tableViewLeft.cellForRow(at: indexPath) as! TableViewCell
                self.selectWord.name = cell.wordLabel.text
                self.selectWord.note = cell.detailLabel.text!
                self.performSegue(withIdentifier: "showDetail", sender: nil)
            })
            .disposed(by: disposeBag)
    }
    
    // Mark: private method
    private func initTableView(){
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        self.tableViewLeft.register(nib, forCellReuseIdentifier: "cell")
        self.tableViewRight.register(nib, forCellReuseIdentifier: "cell")
        self.tableViewLeft.tableFooterView = UIView()
        self.tableViewRight.tableFooterView = UIView()
        
        self.topPanel.layer.shadowColor = COLOR_GREY.cgColor
        self.topPanel.layer.shadowRadius = 0.5
        self.topPanel.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        self.topPanel.layer.shadowOpacity = 1

        self.view.addSubview(self.scrollBar)
        self.scrollBar.backgroundColor = COLOR_LIGHT_BLUE
        self.scrollBar.frame = CGRect(x: 0, y: 104, width: kScreenWidth / 2, height: 3)

        self.firstBtn.setTitleColor(COLOR_LIGHT_BLUE, for: UIControlState())
        
        // Mark: scrollView
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width: kScreenWidth * 2, height: 0)
        self.scrollView.addSubview(self.tableViewLeft)
        self.scrollView.addSubview(self.tableViewRight)
        self.tableViewLeft.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: self.view.frame.height - 64 - 41)
        self.tableViewRight.frame = CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: self.view.frame.height - 64 - 41)
    }
    
    private func initFBtn(){
        fab.addItem(title: "随机排列") {_ in
            self.isShuffle.value = self.isShuffle.value + 1
            self.fab.close()
        }
        fab.addItem(title: "选择确定"){_ in
            let realm = try! Realm()
            let words: Array<Word> = realm.objects(Word.self).filter("isSelect == true").sorted(byKeyPath: "name").toArray()
            print("选择的单词是: \(words)");
            self.fab.close()
        }
        
        fab.sticky = true
        self.view.addSubview(fab)
    }
    
    @objc private func handleSwipeUpDown (_ gesture: UISwipeGestureRecognizer){
        
        let tableView: UITableView = self.isLeftTable ? self.tableViewLeft : self.tableViewRight
        
        switch gesture.state {
        case .began:
            let point = gesture.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at: point);
            
            if (indexPath != nil) {
                let cell = tableView.cellForRow(at: indexPath!) as! TableViewCell
                if point.x < 40 {
                    tableView.isScrollEnabled = false;
                    self.scrollView.isScrollEnabled = false;
                    self.isLeftPan = true;
                    lastSelectIndex = indexPath
                    presentSelectIndex = lastSelectIndex
                    cell.processWithBlock()
                }else{
                    tableView.isScrollEnabled = true;
                }
            }
        case .changed:
            if self.isLeftPan {
                let point = gesture.location(in: tableView)
                self.setCheck(tableView: tableView, point: point)
            }
            
        case .ended:
            tableView.isScrollEnabled = true;
            self.scrollView.isScrollEnabled = true;
            self.isLeftPan = false;
        default:
            print("\(gesture.state)")
        }
        
    }
    
    private func setCheck(tableView: UITableView, point: CGPoint){
        let indexPath = tableView.indexPathForRow(at: point);
        
        if (indexPath != nil) {
            let cell = tableView.cellForRow(at: indexPath!) as! TableViewCell
            
            if lastSelectIndex == nil {
                lastSelectIndex = indexPath;
                presentSelectIndex = lastSelectIndex;
            }else{
                lastSelectIndex = presentSelectIndex;
                presentSelectIndex = indexPath;
            }
            
            if lastSelectIndex != presentSelectIndex {
                cell.processWithBlock()
            }
        }
    }
    
    // Mark: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }

    // Mark: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let offsetX = scrollView.contentOffset.x
            self.scrollBar.frame = CGRect(x: offsetX / 2, y: 104, width: self.view.frame.width / 2, height: 3)
            if offsetX > self.view.frame.width / 2 {
                self.firstBtn.setTitleColor(UIColor.black, for: UIControlState())
                self.secondBtn.setTitleColor(COLOR_LIGHT_BLUE, for: UIControlState())
                 self.isLeftTable = false
            } else {
                self.firstBtn.setTitleColor(COLOR_LIGHT_BLUE, for: UIControlState())
                self.secondBtn.setTitleColor(UIColor.black, for: UIControlState())
                self.isLeftTable = true
            }
        }
    }
    
    // Mark: Action
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.scrollView.contentOffset.x = 0
            self.isLeftTable = true
        }, completion: nil)
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.scrollView.contentOffset.x = self.view.frame.width
            self.isLeftTable = false
        }, completion: nil)
    }
    
    @IBAction func searchBtnPressed(_ sender: UIBarButtonItem) {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(self.search)
            self.search.animate()
            self.search.controller = self;
        }
    }
    
    // Mark: SearchDelegate
    func hideSearchView(status : Bool){
        if status == true {
            self.search.removeFromSuperview()
        }
        self.tableViewRight.reloadData()
        self.tableViewLeft.reloadData()
    }
    
    func selectWord(word: Word) {
        self.selectWord = word
        self.performSegue(withIdentifier: "showDetail", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let viewController = segue.destination as! DetailViewController
            viewController.select = self.selectWord
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

