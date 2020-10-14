//
//  ViewController.swift
//  CodingAssignment
//
//  Created by FT User on 14/10/20.
//  Copyright © 2020 FT User. All rights reserved.
//

import UIKit

import SDWebImage

class HomeViewController: UIViewController {
    
    let tableView = UITableView()
    var safeArea: UILayoutGuide!
    
    var tableData = [DescriptionData]()
    
    
    override func loadView() {
        super.loadView()
        
        // conforming to table view delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        setupTableView()
        
        // Api call
        makeRequestForData()
    }
    
    func setupTableView() {
        
        // setting up for auto cell size
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        
        // setting up table footerview
        tableView.tableFooterView = UIView()
        
        safeArea = view.layoutMarginsGuide
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        // register table with the cell class
        tableView.register(InfoTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func makeRequestForData() {
        
        let infoUrl = "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"
        
        NetworkManager.sharedHandler.makeGetRequestFor(url: infoUrl) { (res, error, data) in
            
            if let err = error {
                self.showError(alertTitle: "Error" , message: err.localizedDescription)
            }
            else if let response = data {
                
                do {
                    let responseData = try JSONDecoder().decode(HeaderData.self, from: response)
                    
                    DispatchQueue.main.async {
                        self.title = responseData.title
                        self.tableData = responseData.rows
                        
                        self.tableView.reloadData()
                    }
                    
                }
                catch {
                    
                }
                
            }
            
        }
        
    }
    
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InfoTableViewCell
       
        cell.titleLabel.text = self.tableData[indexPath.row].title ?? "Title not available"
       
        cell.logoImage.sd_setImage(with: URL(string: self.tableData[indexPath.row].imageHref ?? ""), placeholderImage:nil, completed: { (image, error, cacheType, url) -> Void in
            if ((error) != nil) {
                // set the placeholder image
                cell.logoImage.image = UIImage.init(named: "no-image-available")
            } else {
                // success ... use the image
                cell.logoImage.image = image
            }
        })
        
        cell.descriptionLabel.text = self.tableData[indexPath.row].description ?? "Description not available"
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // shows an UIAlertController alert with error title and message
    func showError(alertTitle title: String, message: String? = nil) {
        if !Thread.current.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.showError(alertTitle: title, message: message)
            }
            return
        }
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.view.tintColor = UIWindow.appearance().tintColor
        controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}
