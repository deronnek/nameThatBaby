//
//  TableViewController.swift
//  NameThatBaby
//
//  Created by Kevin DeRonne on 8/26/17.
//  Copyright © 2017 Kevin DeRonne. All rights reserved.
//

import Foundation

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var textField: UITextField!
    @IBOutlet var tableView: UITableView!
    var taskArray : NSMutableArray! = NSMutableArray() //Could be a non-NS as well
    var model = Model(useRandomNames: false, names: [])
    
    @IBAction func addTask(sender: AnyObject) {
        //Print to alert we entered method
        print("task submitted")
        //Get input from text field
        let input = textField.text
        //Add object to array, reload table
        self.taskArray.add(input!)
        self.tableView.reloadData()
        textField.text = ""
        
        self.model.addName(name: input!)
        
    }//addTask
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //print("application finished loading")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskArray.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        cell.textLabel?.text = self.taskArray.object(at: indexPath.row) as? String
        cell.textLabel?.textAlignment = .center
        return cell
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // remove the item from the data model
            // This is probably more properly done with observers
            self.taskArray.removeObject(at: indexPath.row)
            self.model.removeName(withId: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "startRank" {
            if let toViewController = segue.destination as? ViewController {
                toViewController.model = self.model
            }
        }
    }
}
