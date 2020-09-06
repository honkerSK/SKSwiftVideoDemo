//
//  FilterListTableViewController.swift
//  GPUImage2FilterList
//
//  Created by sunke on 2020/9/6.
//  Copyright © 2020 KentSun. All rights reserved.
//

import UIKit

class FilterListTableViewController: UITableViewController {

    let reuseID = "cell"
    let filterModels = FilterModel.filterModels()
    var values: [[FilterModel]] {
        return Array(filterModels.values)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filter List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseID)
    }

    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return filterModels.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID)
        cell?.textLabel?.text = "       " + values[indexPath.section][indexPath.row].name
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "🔨 " + Array(filterModels.keys)[section]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let displayVC = DisplayViewController()
        displayVC.filterModel = values[indexPath.section][indexPath.row]
        navigationController?.pushViewController(displayVC, animated: true)
    }
}
