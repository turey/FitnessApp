//
//  GoalViewController.swift
//  FitnessApp
//
//  Created by Thomas M Hall on 11/25/17.
//  Copyright © 2017 FitnessGroup. All rights reserved.
//

import Foundation
import UIKit

class GoalViewController :UIViewController {
    @IBOutlet weak var currentProgress: UILabel!
    @IBOutlet weak var currentGoal: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var newGoalInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    private func updateUI() {
        currentProgress.text = "\(User.currentUser.goalProgress)"
        currentGoal.text = "\(User.currentUser.goal)"
        progressBar.setProgress(Float(User.currentUser.goalProgress) / Float(User.currentUser.goal), animated: true)
    }

    @IBAction func setNewGoal(_ sender: UIButton) {
        if let newValue = Int(newGoalInput.text!) {
            User.currentUser.goal = newValue;
            User.currentUser.goalProgress = 0;
            User.save(user: User.currentUser, completion: { (user) in
                
            })
            updateUI()
        }
    }
}


