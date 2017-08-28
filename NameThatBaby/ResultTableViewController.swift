//
//  ResultTableViewController.swift
//  NameThatBaby
//
//  Created by Kevin DeRonne on 8/28/17.
//  Copyright © 2017 Kevin DeRonne. All rights reserved.
//

import Foundation

import UIKit

class ResultTableViewController: UITableViewController {
    var taskArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        self.tableView.delegate = self
        self.tableView.dataSource = self
 */
        //print("application finished loading")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskArray.count
    }
    
    internal override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "resultCell") as UITableViewCell!
        cell.textLabel?.text = self.taskArray[indexPath.row]
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // remove the item from the data model
            // This is probably more properly done with observers
            self.taskArray.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
    

}
