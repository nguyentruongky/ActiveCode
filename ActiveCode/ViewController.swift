//
//  ViewController.swift
//  ActiveCode
//
//  Created by Ky Nguyen on 5/23/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var codeView: CodeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Add code view programmatically
//        codeView.removeFromSuperview()
//        addCodeViewProgrammatically()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Code view by IB
        codeView.numberOfCharacter = 6
    }
    
    func addCodeViewProgrammatically() {
        let marginLeft:CGFloat = 8
        let frame = CGRect(x: marginLeft, y: 100, width: UIScreen.mainScreen().bounds.width - marginLeft * 2, height: 100)
        let codeView = CodeView(frame: frame)
        codeView.numberOfCharacter = 8
        codeView.codeCharacter = "•"
        view.addSubview(codeView)
        addValidateFunction(codeView)
    }
    
    func addValidateFunction(codeArea: CodeView) {
        
        codeArea.validateCode = { (code) in
            let alert = UIAlertController(title: "Active Code", message: "Your code is \(code)", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

