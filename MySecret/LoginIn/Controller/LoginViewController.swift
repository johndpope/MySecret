//
//  LoginViewController.swift
//  MySecret
//
//  Created by Amir lahav on 09/02/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    var loggedIn:()->() = { }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loggedIn()
        // Do any additional setup after loading the view.
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}