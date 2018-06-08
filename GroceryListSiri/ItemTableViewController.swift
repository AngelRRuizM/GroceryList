//
//  ItemTableViewController.swift
//  GroceryListSiri
//
//  Created by Alumno on 06/06/18.
//  Copyright © 2018 Alumno. All rights reserved.
//

import UIKit
import Speech

class ItemTableViewController: UITableViewController, SFSpeechRecognizerDelegate{
    
    var dictionary: NSMutableDictionary?
    var items: NSMutableArray?
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    var request: SFSpeechAudioBufferRecognitionRequest?
    var task: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    var canSiri: Bool?
    var timer: Timer!
    var listTitle: String?{
        didSet{
            self.configureView()
        }
    }
    var newItem: String!
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
        
        newItem = ""
        
        canSiri = false
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization{
            (authorizationStatus) in
            switch authorizationStatus {
                case .authorized:
                    OperationQueue.main.addOperation {
                            self.canSiri = true
                    }
                    print("User granted access to speech recognition")
                    break
                case .notDetermined:
                    print("User denied access to speech recognition")
                    break
                case .denied:
                    print("Speech recognition is restricted for this device")
                    break
                case .restricted:
                    print("Speech recognition has not been authorized yet")
                    break
            }
        }
        
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
        
        let object1 = items![indexPath.row] as! String
        
        cell.itemName.text = object1
        
        let object = object1.lowercased()
        
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
    
    @IBAction func addItem(_ sender: Any) {
        let alert = UIAlertController(title: "New item", message: "What item do you want to add to the list?", preferredStyle: .alert)
        alert.addTextField{
            textField -> Void in
            textField.placeholder = "I need to buy some..."
        }
        let addAction = UIAlertAction(title: "Add", style: .default, handler:{
            (UIAlertAction) in
            if let item = alert.textFields![0].text {
                if !item.isEmpty{
                    self.items?.insert(item as Any, at: 0)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
                    self.tableView.endUpdates()
                    self.savePlist()
                }
            }
        })
        let siriAction = UIAlertAction(title: "Say it", style: .default, handler:{
            (UIAlertAction) in
            if self.canSiri! {
                self.startRecording()
                self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.stopRecording), userInfo: nil, repeats: false)
                
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(siriAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            items?.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.savePlist()
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            canSiri = true
        }
        else{
            canSiri = false
        }
    }
    
    func record() {
        if task != nil{
            task?.cancel()
            task = nil
        }
        
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSessionCategoryRecord)
            try session.setMode(AVAudioSessionModeMeasurement)
            try session.setActive(true, with: .notifyOthersOnDeactivation)
        } catch{
            print("Error: Setting audioSession properties.")
        }
        
        request = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        guard request != nil else{
            fatalError("Error: Couldn't create a request object")
        }
        request?.shouldReportPartialResults = true
        task = speechRecognizer?.recognitionTask(with: request!, resultHandler: {(result, error) in
            if result != nil {
                let text = result?.bestTranscription.formattedString
                
                self.newItem = text!
            }
            if error != nil{
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.request = nil
                self.task = nil
                self.canSiri = true
            }
        })
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, when) in
            self.request?.append(buffer)
        }
        audioEngine.prepare()
        do{
            try audioEngine.start()
        } catch{
            print("Error: starting audioengine")
        }
        
    }
    
    func startRecording(){
        if audioEngine.isRunning {
            audioEngine.stop()
            //audioEngine.inputNode.removeTap(onBus: 0)
            request?.endAudio()
            canSiri = false
        }
        else{
            record()
        }
    }
    
    @objc func stopRecording(){
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            request?.endAudio()
            canSiri = true
            if newItem != ""{                self.items?.add(self.newItem)
                self.savePlist()
            }
        }
    }
}
