//
//  ViewController.swift
//  SFAttributedStringSwiftDemo
//
//  Created by MeterWhite on 2020/7/18.
//  Copyright © 2020 Meterwhite. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lb: UILabel!
    
    @IBOutlet weak var bt: UIButton!
    
    @IBOutlet weak var txtv: UITextView!
    
    @IBOutlet weak var txtfd: UITextField!
    
    @IBOutlet weak var lb2: UILabel!
    
    required init?(coder: NSCoder) {
        ViewController.configBeforeUse()
        super.init(coder: coder)
    }
    
    static func configBeforeUse() {
        SFAtStringCore.registerAttributes([
            NSAttributedString.Key.foregroundColor : UIColor.systemBlue,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 21, weight: .medium),
            NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue
            ], forLabel: "A")
        SFAtStringCore.registerAttributes([
            NSAttributedString.Key.foregroundColor : UIColor.darkGray,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular),
            ], forLabel: "B")
        SFAtStringCore.registerAttributes([
        NSAttributedString.Key.foregroundColor : UIColor.systemRed,
        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 21, weight: .medium),
        NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue
        ], forLabel: "A1")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sf = "[A][[!]star]012345[[!]star,0,-5.00,21,21]6789[B]][[][[!]][[[[!]star,0,-5.00,21,21]"
        print(sf.sf_unformattedString as Any)
        lb2.sf_text = sf
        lb2.sf_text = sf
    }
}

