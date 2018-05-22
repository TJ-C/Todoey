//
//  ViewController.swift
//  Todoey
//
//  Created by Theo Carper on 21/05/2018.
//  Copyright © 2018 Theo Carper. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

//    var itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon"]
    var itemArray = [Item(title: "Find Mike"), Item(title: "Buy Eggs"), Item(title: "Destroy Demogorgon")]
//    ,Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon"),Item(title: "Destroy Demogorgon")]

    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
            itemArray = items
        }
        
    }
    
    // MARK: - Tableview Datasource Methods
    
   
    //TODO Declare numberOfRowsInSection here:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //TODO: Declare cellForRowAtIndexPath here:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("How many times")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        // populate the cell with item data
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Set the cell checkmark if item done equals true.
        

        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            itemArray[indexPath.row].done = false
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            itemArray[indexPath.row].done = true

        }
        tableView.deselectRow(at: indexPath, animated: true)
        print(itemArray[indexPath.row].done)
        
    }
    
    
    //MARK - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            self.itemArray.append(Item(title: alert.textFields![0].text!))
            
//            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        

    }
    

}

