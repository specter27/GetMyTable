//
//  LocationReviewDetailVC.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-23.
//

import UIKit

import CoreLocation
import MapKit

class LocationReviewDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Geocoder Variables
    let geocoder = CLGeocoder()

    // MARK: Variables
    var address:String=""
    var reviewList:[Review]=[]
    var currentRestaurantMenuURL: String = ""
    
    
    // MARK: Outlets
    @IBOutlet weak var restaurantLocationMapView: MKMapView!
    @IBOutlet weak var reviewListTableVIew: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("LocationReviewDetailVC Screen Loaded")
        print(self.address)
        print(self.reviewList)
        
        self.reviewListTableVIew.dataSource = self
        self.reviewListTableVIew.delegate = self
        
        // Programatically setting the row height in the table view
        self.reviewListTableVIew.rowHeight = 80
        
        self.getLocationOnMap()
        
    }
    
    // MARK: Helper Function
    private func getLocationOnMap() {
        
        // 1. Perform geocoding
        print("Attemping to find coordinates for \(self.address)")
        self.geocoder.geocodeAddressString(self.address) {
            (resultsList, error) in
            if let err = error {
                print("An error occured during forward geocoding")
                print(err)
            } else {
                // we found some results
                print("Number of results found: \(resultsList!.count)")
                // extract the first result from the array
                // output it to the screen
                let locationResult:CLPlacemark = resultsList!.first!
                
                let lat = locationResult.location?.coordinate.latitude
                let lng = locationResult.location?.coordinate.longitude
                              
                // 2. Construct the map marker
                let markerToAdd = MKPointAnnotation()
                
                // 2a. use the lat lng to make the marker
                markerToAdd.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                
                // 3. Add to the map
                self.restaurantLocationMapView.addAnnotation(markerToAdd)
                
                print("Marker added.")
                
                // 3. configure the mapview
                // - center of the map: specifies the lat,lng coordinate of the center of the map
                let centerOfMapCoordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                      
                // - span: specifies the zoom level (zoom in by choosing a smaller number, zoom out by choosing a larger number)
                let zoomLevel = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                      
                // - region: object that represents the area of the map that should be displayed
                let visibleRegion = MKCoordinateRegion(center: centerOfMapCoordinate , span: zoomLevel)
                      
                // configure the map with these settings
                self.restaurantLocationMapView.setRegion(visibleRegion, animated: true)
            }
        }
    }
    // MARK: Actions
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        //Get a reference to the next screen
        guard let nextScreen = storyboard?.instantiateViewController(identifier: "RestaurantMenuScreen") as? RestaurantMenuViewController else {
            print("Cannot find next screen")
            return
        }
        nextScreen.webUrl = currentRestaurantMenuURL
        
        //Navigate to the next screen
        self.navigationController?.pushViewController(nextScreen, animated: true)
    }
    
    // ------------------------------------
    // MARK: Mandatory table view functions
    // ------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reviewList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reviewListTableVIew.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath)
        cell.textLabel?.text = "NAME: \(self.reviewList[indexPath.row].name)"
        cell.detailTextLabel?.text = self.reviewList[indexPath.row].body
        return cell
    }

    
    

}
