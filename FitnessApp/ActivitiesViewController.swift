//
//  ActivitiesViewController.swift
//  FitnessApp
//
//  Created by Bishal Wagle on 11/23/17.
//  Copyright © 2017 FitnessGroup. All rights reserved.
//

import Foundation
import UIKit

class ActivitiesViewController: UIViewController{
    @IBOutlet weak var TableView: UITableView!
    
    var activities: [Activity] = [Activity](){
        didSet{
            TableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = User.currentUser{
            self.activities = User.currentUser.activities
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.delegate = self
        TableView.dataSource = self
        TableView.rowHeight = 75;
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ActivitiesViewController: UITableViewDelegate{
    
}

extension ActivitiesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activities.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = ActivityDetailViewController()
        detail.activity = self.activities[indexPath.row]
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivitiesTableViewCell") as! ActivitiesTableViewCell
        
        cell.myActivity = self.activities[indexPath.row]
        //        cell
        
        return cell
    }
}

