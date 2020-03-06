//
//  WebKitVC.swift
//  rssReader
//
//  Created by Сава Волков on 04.03.2020.
//  Copyright © 2020 Savely Dudko. All rights reserved.
//

import UIKit
import WebKit

class WebKitVC: UIViewController {

    
    @IBOutlet weak var webKit: WKWebView!
    
    var link = URL(string: "")
    var titleWebKit = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Reachability.isConnectedToNetwork() {
            navigationController?.title = titleWebKit
            let urlRequest = URLRequest(url: link!)
            webKit.load(urlRequest)
        } else {
            let ac = UIAlertController(title: "Lost Network", message: "Your network if lost", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default)
            ac.addAction(ok)
            present(ac, animated: true)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
