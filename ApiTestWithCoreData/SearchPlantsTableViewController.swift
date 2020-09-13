//
//  SearchPlantsTableViewController.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 12/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class SearchPlantsTableViewController: UITableViewController, UISearchBarDelegate {


    let PLANT_CELL = "plantCell"
    let API_KEY = "FYTiGTebvmXvhD_V4n4C8T8W0N_OnI2tA2bRlia0N-A"
    let REQUEST_STRING = "https://trefle.io/api/v1/plants/search?token="
    
    var indicator = UIActivityIndicatorView()
    var newPlants = [PlantData]()
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for plant"

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.tableView.center
        self.view.addSubview(indicator)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newPlants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PLANT_CELL,for: indexPath)
        let plant = newPlants[indexPath.row]

        cell.textLabel?.text = plant.commonName
        cell.detailTextLabel?.text = plant.scienceName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let plant = newPlants[indexPath.row]
        let _ = databaseController?.addPlant(plantData: plant)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Search Bar Delegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    // If there is no text end immediately
        guard let searchText = searchBar.text, searchText.count > 0 else {
            return;
        }

        indicator.startAnimating()
        indicator.backgroundColor = UIColor.clear

        newPlants.removeAll()
        tableView.reloadData()
        
        requestPlants(plantName: searchText)
    }

    // MARK: - Web Request

    func requestPlants(plantName: String) {
        let processedPlantName = plantName.replacingOccurrences(of: " ", with: "%20")
        let searchString = REQUEST_STRING + API_KEY + "&q=" + processedPlantName
        let jsonURL = URL(string: searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        

        let task = URLSession.shared.dataTask(with: jsonURL!) {(data, response, error) in
        // Regardless of response end the loading icon from the main thread
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }

        if let error = error {
            print(error)
            return
        }

        do {
            let decoder = JSONDecoder()
            let searchResult = try decoder.decode(SearchResultData.self, from: data!)
            if let plants = searchResult.plants {
                self.newPlants.append(contentsOf: plants)

        DispatchQueue.main.async {
            self.tableView.reloadData()
                }
            }
        } catch let err {
            print(err)
            }
        }
        task.resume()
    }
}
