//
//  ViewController.swift
//  SampleTableView
//
//  Created by Darshan on 19/05/18.
//  Copyright © 2018 XYZ. All rights reserved.
//

import UIKit
import SwiftyJSON
import AlamofireImage

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var googleModel = ModelGooglePlaces(json: JSON.null)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        callAPI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func callAPI() {
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?radius=500&key=AIzaSyBVaKLybZJP-YqjvS7l6lvyMET7erlLVMs&location=23.1030749,72.573718"
        
        WSManager.POST(urlString, param: nil, success: { (responseJSON) in
            // Success
            self.googleModel = ModelGooglePlaces(json: responseJSON)
            self.tableView.reloadData()
        }) { (error, isTimeOut) in
            // Failure
        }
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GoogleCell
        cell.placeNameLbl.text = googleModel.results?[indexPath.row].name
        if let urlString = googleModel.results?[indexPath.row].icon {
            cell.placeImageView.af_setImage(withURL: URL(string: urlString)!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return googleModel.results?.count ?? 0
    }
}

extension ViewController: UITableViewDelegate {
    
}

