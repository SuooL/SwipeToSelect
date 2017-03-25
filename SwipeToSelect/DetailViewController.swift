//
//  DetailViewController.swift
//  SwipeToSelect
//
//  Created by 胡振生 on 3/23/17.
//  Copyright © 2017 suool. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var noteLabel: UILabel!
    
    var select: Word = Word()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.select.name
        self.noteLabel.text = self.select.note
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
