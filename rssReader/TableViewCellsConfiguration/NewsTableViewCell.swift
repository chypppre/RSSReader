//
//  NewTableViewCell.swift
//  rssReader
//
//  Created by Сава Волков on 01.03.2020.
//  Copyright © 2020 Savely Dudko. All rights reserved.
//

import UIKit

public class NewsTableViewCell: UITableViewCell {

  @IBOutlet weak var newsHead: UILabel!
  @IBOutlet weak var newsDate: UILabel!
  @IBOutlet weak var newsText: UILabel!
    
    var newsLink = URL(string: "")

}
