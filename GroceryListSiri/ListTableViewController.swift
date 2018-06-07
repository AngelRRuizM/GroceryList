//
//  ListTableViewController.swift
//  GroceryListSiri
//
//  Created by Alumno on 06/06/18.
//  Copyright © 2018 Alumno. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    var dictionary: NSMutableDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPlist()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 75
        
    }
    
    func loadPlist(){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documenstDirectory = paths[0] as! NSString
        let path = documenstDirectory.appendingPathComponent("GroceriesLists.plist")
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: path){
            if let bundlePath = Bundle.main.path(forResource: "GroceriesLists", ofType: "plist") {
                do{
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                }
                catch{
                    print("Error: failed loading plist")
                }
            }
        }
        
        dictionary = NSMutableDictionary(contentsOfFile: path)!
        tableView.reloadData()
    }
    
    func savePlist(){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! NSString
        let path = documentsDirectory.appendingPathComponent("GroceriesLists.plist")
        
        dictionary?.write(toFile: path, atomically: false)
        self.loadPlist()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionary!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListsCell", for: indexPath) as! ListsTableViewCell
        let object = NSMutableArray(array: (dictionary?.allKeys)!)[indexPath.row] as! String
        cell.titleText.text = object
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let text = (tableView.cellForRow(at: indexPath) as! ListsTableViewCell).titleText.text
            dictionary?.removeObject(forKey: text!)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.savePlist()
        }
    }
   
    @IBAction func insertNewList(_ sender: Any) {
        print("lol")
        let alert = UIAlertController(title: "New List", message: "Whats the name of your new list?", preferredStyle: .alert)
        alert.addTextField{ textField -> Void in
            textField.placeholder = "I'm going to the groeceries in... "
        }
        let action = UIAlertAction(title: "Add", style: .default, handler: {
            (UIAlertAction) in
            if let listTitle = alert.textFields![0].text {
                print(listTitle)
                self.dictionary![listTitle] = []
                print(self.dictionary!)
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
                self.tableView.endUpdates()
                self.savePlist()
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toItemList", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toItemList" {
            (segue.destination as! ItemTableViewController).listTitle = (tableView.cellForRow(at: sender as! IndexPath) as! ListsTableViewCell).titleText.text
        }
    }
    
}
