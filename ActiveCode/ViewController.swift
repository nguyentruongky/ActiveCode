//
//  ViewController.swift
//  ActiveCode
//
//  Created by Ky Nguyen on 5/23/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let characterCount = 6
        let marginLeft:CGFloat = 8
        let codeView = CodeView(frame: CGRect(x: marginLeft, y: 100, width: UIScreen.mainScreen().bounds.width - marginLeft * 2, height: 100), numberOfCharacter: characterCount)
        self.view.addSubview(codeView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
