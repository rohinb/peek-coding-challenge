//
//  ViewController.swift
//  PeekInternDemo
//
//  Created by Rohin Bhushan on 3/12/16.
//  Copyright © 2016 rohinbhushan. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit


class ViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Twitter.sharedInstance().startWithConsumerKey("cwYtwlK2bFyoWTyiAkhCsWWG8", consumerSecret: "xnCWJE8ulUwPxvkJ0YvWDTbFAsHdA5paC6SMygy5VlKrN14iNT")
        Fabric.with([Twitter.sharedInstance()])
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            self.performSegueWithIdentifier("toSearch", sender: nil)
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
    
}

