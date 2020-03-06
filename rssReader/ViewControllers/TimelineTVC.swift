//
//  TimelineTVC.swift
//  rssReader
//
//  Created by Сава Волков on 29.02.2020.
//  Copyright © 2020 Savely Dudko. All rights reserved.
//

import UIKit
import CoreData
import SystemConfiguration

class TimelineTVC: UITableViewController, XMLParserDelegate, UIGestureRecognizerDelegate {
    
    var newsXML = [NewXML]()
    var elementName = String()
    var newsXMLTitle = String()
    var newsXMLLink = String()
    var newsXMLDescription = String()
    var newsXMLDate = Date()
    
    var selectNewRow = Int()
    var numberOfTimeline = Int()
    var newsList = [Timeline]()
    var linkOfTimeline = String()
    var news = [New]()
    let context = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!
    
    var refreshNews: UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest: NSFetchRequest<New> = New.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timeline =%@", newsList[numberOfTimeline])
        do {
            news = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if Reachability.isConnectedToNetwork() {
            contentUpdate()
        } else {
            let ac = UIAlertController(title: "Lost Network", message: "Your network if lost", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default)
            ac.addAction(ok)
            present(ac, animated: true)
        }
        
        tableView.refreshControl = refreshNews
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard Reachability.isConnectedToNetwork() else { return }
        deleteData(timeline: newsList[numberOfTimeline])
        saveData()
        tableView.reloadData()
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        if Reachability.isConnectedToNetwork() {
            contentUpdate()
            deleteData(timeline: newsList[numberOfTimeline])
            saveData()
            self.tableView.reloadData()
        } else {
            let ac = UIAlertController(title: "Lost Network", message: "Your network if lost", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default)
            ac.addAction(ok)
            present(ac, animated: true)
        }
        sender.endRefreshing()
    }
    
    func saveData() {
        for item in newsXML {
            let new = New(context: context)
            new.title = item.newsXMLTitle
            new.link = URL(string: item.newsXMLLink)
            new.text = item.newsXMLDescription
            new.date = item.newsXMLDate
            new.timeline = newsList[numberOfTimeline]
            
            do {
                try context.save()
                news.append(new)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func deleteData(timeline: Timeline) {
        let fetchRequest: NSFetchRequest<New> = New.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timeline =%@", timeline)
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object)
                try context.save()
                news.removeAll()
            }
        } catch let error as NSError {
        print("Delete all data error : \(error) \(error.userInfo)")
        }
    }
    
    func contentUpdate() {
        guard let url = URL(string: linkOfTimeline) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print(error ?? "Unknown error")
                return
            }

            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "News", for: indexPath) as! NewsTableViewCell
        let new = news[indexPath.row]
        
        cell.newsHead.text = new.title
        cell.newsText.text = new.text!
        
        guard let date = new.date else { return cell }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yy HH:mm"
        cell.newsDate.text = dateFormatter.string(from: date)
        
        guard let url = new.link else { return cell }
        cell.newsLink = url

        return cell
    }

 
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        selectNewRow = self.tableView.indexPathForSelectedRow!.row
        let vc = segue.destination as! WebKitVC
        if let link = news[selectNewRow].link {
            print(selectNewRow)
            print(link)
            vc.link = link
        }
        if let titleWebKit = news[selectNewRow].title {
        vc.titleWebKit = titleWebKit
        }
    }

    // MARK: - Parse
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "item" {
            newsXMLTitle = String()
            newsXMLDescription = String()
            newsXMLLink = String()
        }
        self.elementName = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let item = NewXML(newsXMLTitle: newsXMLTitle, newsXMLLink: newsXMLLink, newsXMLDescription: newsXMLDescription, newsXMLDate: newsXMLDate)
            newsXML.append(item)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if (!data.isEmpty) {
            if self.elementName == "title" {
                newsXMLTitle += data
            } else if self.elementName == "description" {
                newsXMLDescription += data
            } else if self.elementName == "link" {
                newsXMLLink += data
            } else if self.elementName == "pubDate" {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss z"
                
                if let date = dateFormatter.date(from: data) {
                    newsXMLDate = date
                } else {
                    dateFormatter.dateFormat = "d MMM yyyy HH:mm:ss z"
                    guard let date = dateFormatter.date(from: data) else { return }
                    newsXMLDate = date
                }
            }
        }
    }
}
 
