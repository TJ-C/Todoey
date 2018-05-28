//
//  ViewController.swift
//  Todoey
//
//  Created by Theo Carper on 21/05/2018.
//  Copyright © 2018 Theo Carper. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {

    var notificationToken: NotificationToken?
    var todoItems: Results<Item>?
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
  
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let realm = RealmServices.shared.realm

        // Can't use this untill we can isolate delete notification due to Swipe also deleting the item in the todoItems list - which causes a Fatel error!
//        notificationToken = realm.observe { (notification, realm) in
//            self.tableView.reloadData()
//        }
        
        RealmService.shared.ObserveRealmErrors(in: self) { (error) in
            // Handle errors here.
            print(error ?? "No error detected")
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        guard let colourHex = selectedCategory?.backgroundColor else { fatalError() }
        updateNavBar(withhexCode: colourHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        notificationToken?.invalidate()
        RealmService.shared.stopObservingErrors(in: self)
        
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        
        updateNavBar(withhexCode: "1D98F6")
   
    }
    
    
    //MARK: - Load items into the tableview datasource
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    //MARK: - Nav bar setup methods
    
    func updateNavBar(withhexCode colourHexCode: String ) {
        
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist")}

        guard let navBarColour = UIColor(hexString: colourHexCode) else { fatalError() }
        navBar.barTintColor = navBarColour
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
        searchBar.barTintColor = navBarColour
    
    }
    
    //MARK: - Tableview Datasource Methods
    
    //TODO Declare numberOfRowsInSection here:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("todoItems count: \(String(describing: todoItems?.count))")
        return todoItems!.count
    
    }
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // populate the cell with item data
        
        print(CGFloat(indexPath.row) / CGFloat(todoItems!.count))
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory!.backgroundColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.tintColor = ContrastColorOf(color, returnFlat: true)
            }
        
        } else {
            cell.textLabel?.text = "no Items Added"
        }
        
        return cell
    
    }
    
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let item = todoItems?[indexPath.row] else { fatalError() }
        let done = !item.done
        RealmService.shared.update(item, with: ["done": done])
        self.tableView.reloadData()

    }
    
    
    //MARK - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in

            guard let currentCategory = self.selectedCategory else { fatalError() }
            let newItem = Item()
            newItem.title = alert.textFields![0].text!
            RealmService.shared.appendToList(currentCategory.items, newItem)
            self.tableView.reloadData()

        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)

    }
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        guard let itemForDeletion = self.todoItems?[indexPath.row] else { fatalError() }
        RealmService.shared.delete(itemForDeletion)
//        tableView.reloadData() // Don't do this as Swipe is also doing this

    }

}

//MARK: - Search bar methods

extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!)

        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        } else {
            
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        
            tableView.reloadData()
            
        }
    }
}

