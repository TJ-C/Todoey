//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Theo Carper on 23/05/2018.
//  Copyright © 2018 Theo Carper. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    var notificationToken: NotificationToken?
    var categoryArray: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // See https://www.youtube.com/watch?v=hC6dLLbfUXc#t=25m50s for creating RealmService
        let realm = RealmService.shared.realm
        categoryArray = realm.objects(Category.self)
        
        notificationToken = realm.observe { (notification, realm) in
            self.tableView.reloadData()
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        notificationToken?.invalidate()
    }

    //MARK: - TableView Datasource Methods
    
    //TODO Declare numberOfRowsInSection here:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray?.count ?? 1

    }
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // populate the cell with category data
        if let category = categoryArray?[indexPath.row] {
        
            cell.textLabel?.text = category.name
            
            guard let categoryColor = UIColor(hexString: category.backgroundColor) else { fatalError() }
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            cell.backgroundColor =  categoryColor
        }
       
        return cell
    
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
        
    }
    
    //MARK: - Data Manipulation Methods
    //MARK: - Save Data
    func save(category: Category) {
        RealmService.shared.create(category)
        
    }
    
    override func updateModel(at indexPath: IndexPath) {

        if let categoryForDeletion = self.categoryArray?[indexPath.row] {
            RealmService.shared.delete(categoryForDeletion)
        }

    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = alert.textFields![0].text!
            newCategory.backgroundColor = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create a new category"
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
}
