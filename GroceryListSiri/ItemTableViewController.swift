//
//  ItemTableViewController.swift
//  GroceryListSiri
//
//  Created by Alumno on 06/06/18.
//  Copyright © 2018 Alumno. All rights reserved.
//

import UIKit

class ItemTableViewController: UITableViewController{
    
    var dictionary: NSMutableDictionary?
    var items: NSMutableArray?
    
    var listTitle: String?{
        didSet{
            self.configureView()
        }
    }
    
    func configureView(){
        if let sel = self.listTitle{
            self.title = sel
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadPlist()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 75
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        if let list = self.listTitle{
            items = NSMutableArray(array: dictionary?.object(forKey: list) as! [Any])
            self.navigationItem.title = list
        }
        tableView.reloadData()
    }
    
    func savePlist(){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! NSString
        let path = documentsDirectory.appendingPathComponent("GroceriesLists.plist")
        
        if let list = self.listTitle{
            dictionary?.setObject(items!, forKey: list as NSCopying)
            dictionary?.write(toFile: path, atomically: false)
            self.navigationItem.title = list
            
            self.loadPlist()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath ) as! ItemTableViewCell
        
        let object = items![indexPath.row] as! String
        
        cell.itemName.text = object
        
        if object.contains("bread"){
            cell.gIcon.image = #imageLiteral(resourceName: "bread")
        } else if object.contains("broom"){
            cell.gIcon.image = #imageLiteral(resourceName: "broom")
        } else if object.contains("coffee"){
            cell.gIcon.image = #imageLiteral(resourceName: "coffee")
        } else if object.contains("fruit"){
            cell.gIcon.image = #imageLiteral(resourceName: "fruit")
        } else if object.contains("juice"){
            cell.gIcon.image = #imageLiteral(resourceName: "juice")
        } else if object.contains("meat"){
            cell.gIcon.image = #imageLiteral(resourceName: "meat")
        } else if object.contains("milk"){
            cell.gIcon.image = #imageLiteral(resourceName: "milk")
        } else if object.contains("soap"){
            cell.gIcon.image = #imageLiteral(resourceName: "soap")
        } else{
            cell.gIcon.image = #imageLiteral(resourceName: "groceries")
        }
        
        return cell
    }
    
}
