//
//  SettingLauncher.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 17/9/20.
//  Copyright © 2020 Monash University. All rights reserved.

// Ref: https://www.youtube.com/watch?v=2kwCfFG5fDA and https://www.youtube.com/watch?v=5-uLbwNgHng&ab_channel=LetCreateAnApp
// For demonstrating setting up the background style and the elements for the popup menu

import UIKit

class SortLauncher: NSObject{
    
    weak var sortItemDelegate: SortDelegate?

    let backgroundView = UIView()
    let tableView = UITableView()
    
    let CELL_SORT = "cellSort"
    
    let sortMenuItems = ["Sort Ascending", "Sort Decending", "Cancel"]
    let sortMenuImage = [UIImage(named: "sort-ascending"), UIImage(named: "sort-descending"), UIImage(systemName: "xmark")]
    
    @objc func showSortMenu(){
        if let window = UIApplication.shared.windows.first{
            
            // Set the background to a transparent darkened view
            backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissScreen)))
            
            // Add the subviews to the primary window and set the view to cover the whole window
            window.addSubview(backgroundView)
            
            
            let viewHeight: CGFloat = 200
            let y = window.frame.height - viewHeight
            window.addSubview(tableView)
            tableView.frame = CGRect(x: 0,y: window.frame.height, width: window.frame.width, height: viewHeight)
            
            
            backgroundView.frame = window.frame
            backgroundView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.backgroundView.alpha = 1
                
                self.tableView.frame = CGRect(x: 0, y: y, width: self.tableView.frame.width, height: self.tableView.frame.height)
                
            }, completion: nil)
            
        }
        
    }
    
    
    @objc func dismissScreen(){
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundView.alpha = 0
            
            if let window = UIApplication.shared.windows.first{
                self.tableView.frame = CGRect(x: 0, y: window.frame.height, width: self.tableView.frame.width, height: self.tableView.frame.height)
            }
        })
    }
    
    override init() {
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SortTableViewCell.self, forCellReuseIdentifier: CELL_SORT)
    }
}

extension SortLauncher: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_SORT, for: indexPath) as! SortTableViewCell
        
        cell.customImageView.image = sortMenuImage[indexPath.row]
        cell.customImageView.tintColor = .black
        cell.nameLabel.text = sortMenuItems[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            sortItemDelegate?.sortExhibitionDelegate(actionCode: indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
            dismissScreen()
        case 1:
            sortItemDelegate?.sortExhibitionDelegate(actionCode: indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
            dismissScreen()
        case 2:
            tableView.deselectRow(at: indexPath, animated: true)
            dismissScreen()
        default:
            dismissScreen()
        }
    }
}
