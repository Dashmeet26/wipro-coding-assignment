//
//  InfoViewModel.swift
//  CodingAssignment
//
//  Created by FT User on 15/10/20.
//  Copyright © 2020 FT User. All rights reserved.
//

import UIKit

class InfoViewModel: NSObject {
    
    // array to store table data
    var tableData = [DescriptionData]()
    
    // View components
    var navTitle = EMPTY_STRING
    var tableView = UITableView()
    var refreshControl = UIRefreshControl()
    
    var result = true
    
    
    func makeRequestForData() -> Bool {
        
        NetworkManager.sharedHandler.makeGetRequestFor(url: INFO_URL) { (res, error, data) in
            
            if let _ = error {
                self.result = false
            }
            else if let response = data {
                
                do {
                    let responseData = try JSONDecoder().decode(HeaderData.self, from: response)
                    
                    DispatchQueue.main.async {
                        self.navTitle = responseData.title ?? EMPTY_STRING
                        self.tableData = responseData.rows
                        
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                    self.result = true
                }
                catch {
                    self.refreshControl.endRefreshing()
                    self.result = false
                }
            }
        }
        self.refreshControl.endRefreshing()
        
        return self.result
    }
    
}

extension UIViewController {
    // shows an UIAlertController alert with error title and message
    func showError(alertTitle title: String, message: String? = nil) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = UIWindow.appearance().tintColor
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        
        alertWindow.makeKeyAndVisible()
        
        DispatchQueue.main.async {
            alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
    }
    
}
