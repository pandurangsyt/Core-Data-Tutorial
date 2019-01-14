//
//  ViewController.swift
//  Core Data Tutorial
//
//  Created by Pandu on 1/13/19.
//  Copyright © 2019 123 Apps Studio LLC. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var names = [NSManagedObject]()

    @IBOutlet var listTableView: UITableView!
    @IBAction func addNewItem(_ sender: Any) {
        let alert = UIAlertController(title: "New Name", message: "Add new a name", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            self.saveToCoreData(addName: nameToSave)
            self.listTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFromCoreData()
    }
    
    // Mark - Save data to core data
    func saveToCoreData(addName: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Names", in: managedContext)!
        let name = NSManagedObject(entity: entity, insertInto: managedContext)
        
        name.setValue(addName, forKey: "name")
        
        do {
            try managedContext.save()
            names.append(name)
        } catch {
            print("Save Error")
        }
    }
    
    // Mark - Fetch and display the data
    func fetchFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Names")
        
        do {
            names = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            print("Fetch Error")
        }
    }
    
    // Mark - Delete the data from core data
    func deleteFromCoreData(deleteNameIndex: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(names[deleteNameIndex])
        do {
            try managedContext.save()
            names.remove(at: deleteNameIndex)
        } catch {
            print("Delete Error")
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    // Mark - TableView : Display cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let name = names[indexPath.row]
        cell.textLabel?.text = name.value(forKey: "name") as? String
        return cell
    }
    
    // Mark - TableView : Delete action
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteFromCoreData(deleteNameIndex: indexPath.row)
            listTableView.reloadData()
        }
    }
}

