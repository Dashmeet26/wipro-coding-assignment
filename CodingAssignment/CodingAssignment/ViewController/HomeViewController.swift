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
    
    // ViewModel
    var viewModel = InfoViewModel()
    
    private let refreshControl = UIRefreshControl()
    
    override func loadView() {
        super.loadView()
        
        viewModel.navTitle = self.title ?? EMPTY_STRING
        viewModel.tableView = self.tableView
        viewModel.refreshControl = self.refreshControl
        
        // conforming to table view delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: FETCH_DATA, attributes: nil)
        
        // setup tableview
        setupTableView()
        
        // Api call
        self.apiCall()
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        
        self.apiCall()
    }
    
    func apiCall() {
        // Api call
        if (!viewModel.makeRequestForData()) {
            if NetworkManager.sharedHandler.isInternetAvailable {
                self.showError(alertTitle: ERROR , message: DATA_ERROR)
            } else {
                self.showError(alertTitle: NETWORK_ERROR , message: CHECK_INTERNET)
            }
        } else {
            self.title = viewModel.navTitle
        }
    }
    
    func setupTableView() {
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        // setting up for auto cell size
        tableView.estimatedRowHeight = CGFloat(ESTIMATE_ROW_HEIGHT)
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
    
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InfoTableViewCell
        
        cell.titleLabel.text = self.viewModel.tableData[indexPath.row].title ?? TITLE_EMPTY
        
        cell.logoImage.sd_setImage(with: URL(string: self.viewModel.tableData[indexPath.row].imageHref ?? ""), placeholderImage:nil, completed: { (image, error, cacheType, url) -> Void in
            if ((error) != nil) {
                // set the placeholder image
                cell.logoImage.image = UIImage.init(named: "no-image-available")
            } else {
                // success ... use the image
                cell.logoImage.image = image
            }
        })
        
        cell.descriptionLabel.text = self.viewModel.tableData[indexPath.row].description ?? DESCRIPTION_EMPTY
        
        self.title = viewModel.navTitle
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
}
