//
//  ActivitiesNavigationController.swift
//  FitnessApp
//
//  Created by Bishal Wagle on 11/23/17.
//  Copyright © 2017 FitnessGroup. All rights reserved.
//

import UIKit

class ActivitiesNavigationController: UINavigationController {
    
    override var prefersStatusBarHidden: Bool{
        get{
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.navigationBar.barTintColor = UIColor.clear
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

