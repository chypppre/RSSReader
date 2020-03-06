//
//  MainTVC.swift
//  rssReader
//
//  Created by Сава Волков on 29.02.2020.
//  Copyright © 2020 Savely Dudko. All rights reserved.
//

import UIKit
import CoreData

class MainTVC: UITableViewController {
    
    let context = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!
    var timelines: [Timeline] = []
    var selectTimelineRow = Int()
    var indexPathForEdit: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest: NSFetchRequest<Timeline> = Timeline.fetchRequest()
        do {
            timelines = try context.fetch(fetchRequest)
        } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addTimeline(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "New timeline", message: "", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) {
            action in
            let nameNewTimeline = ac.textFields![0].text
            let urlNewTimeline = ac.textFields![1].text
            self.saveTimeline(name: nameNewTimeline!, link: urlNewTimeline!)
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addTextField(configurationHandler: {
            textField in
            textField.placeholder = "Name"
        })
        ac.addTextField(configurationHandler: {
            textField in
            textField.placeholder = "URL"
        })
        
        ac.addAction(ok)
        ac.addAction(cancel)
        present(ac, animated: true)
    }
   
    @IBAction func editTimeline(_ sender: UITextField) {
        let sender = sender
        let cell = sender.superview!.superview! as! TimelinesTableViewCell
        indexPathForEdit = tableView.indexPath(for: cell)
        let select = timelines[indexPathForEdit!.row]
        
        let ac = UIAlertController(title: "Edit timeline", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) {
                action in
                let newName = ac.textFields![0].text!
                let newLink = ac.textFields![1].text!
                self.updateTimeline(name: newName, link: newLink, select: self.indexPathForEdit!.row)
                self.tableView.reloadData()
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
            ac.addTextField(configurationHandler: {
                textField in
                textField.text = select.name
            })
            ac.addTextField(configurationHandler: {
                textField in
                textField.text! = String(describing: select.link!)
            })
            
            ac.addAction(ok)
            ac.addAction(cancel)
            present(ac, animated: true)
        }
    
    func updateTimeline(name: String, link: String, select: Int) {
        timelines[select].name = name
        timelines[select].link! = NSURL(string: link)! as URL
        do {
            try context.save()
        } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveTimeline(name: String, link: String) {
        let timeline = Timeline(context: context)
        
        timeline.name = name
        timeline.link = NSURL(string: link) as URL?
        
        do {
            try context.save()
            timelines.append(timeline)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
        
    // MARK: - Table view data source

       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return timelines.count
       }

       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TimelinesTableViewCell
        
           let timeline = timelines[indexPath.row]
           cell.name.text = timeline.name
           cell.link.text! = String(describing: timeline.link!)
           return cell
       }

       override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           return true
       }

       override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
            
               context.delete(timelines[indexPath.row])
               timelines.remove(at: indexPath.row)
               
               do {
                   try context.save()
                   tableView.deleteRows(at: [indexPath], with: .fade)
               } catch let error as NSError {
                   print("Could not fetch. \(error), \(error.userInfo)")
               }
           }
       }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! TimelineTVC
        selectTimelineRow = self.tableView.indexPathForSelectedRow!.row
        vc.title = timelines[selectTimelineRow].name
        vc.newsList = timelines
        vc.numberOfTimeline = selectTimelineRow
        
        guard let linkOfTimeline = timelines[selectTimelineRow].link else { return }
        vc.linkOfTimeline = "\(linkOfTimeline)"
    }
}
