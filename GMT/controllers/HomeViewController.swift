//
//  HomeViewController.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-22.
//

import UIKit

// imports
import FirebaseFirestore
import FirebaseFirestoreSwift

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: Outlets
    @IBOutlet weak var restaurantTableView: UITableView!
    
    
    
    // MARK: Local Data source
    var localDB = DatabaseHelper.shared
    
    // MARK: Getting the Firestore DB
    let db = Firestore.firestore()
    
    // MARK: Variables
    var currentUser: User?
    let RESTAURANT_COLLECTION = "restaurants"
    

    // MARK: Lifecycle Functions
    // -------------------- Execution order: #1 --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Home Screen Loaded")
        
        restaurantTableView.delegate = self
        restaurantTableView.dataSource = self
        
        // Programatically setting the row height in the table view
        restaurantTableView.rowHeight = 170
        
        // MARK: programattically adding a navigation bar button for Logout
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
        
        // ---------- Fetching the restaturants here as there is no feature to update restaurant list during the whole app lifecycle ------------------------
        // 1. Reset the restaurant list before fetching new values in it
        self.localDB.restaurantList = []
        
        // 2. Fetch the Restaurant list from the in FireStore DB collection(restaurant)
        self.getRestaurantList()
    }
    
    // -------------------- Execution order: #2 --------------------
    override func viewWillAppear(_ animated: Bool) {
        
       
    }
    
    @objc func logoutTapped(){
        
        // after user has successfully logged out
         
        //MARK: Switching the root view for resolving issue for using tab & navigation controller together
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        
    }
    
    // MARK: Helper function
    
    // getRestaurantList(): This function will get all the restaurants from the firebase Collection
    private func getRestaurantList() {

        print("Getting Restaurant List from the Firestore")
        
        // retrieve data from Firestore
        
        // this code connects to the specified collection and retrieves all the documents in the collection
 
        db.collection(RESTAURANT_COLLECTION).getDocuments {
          
           // If queryResults is NOT nil, then it will contain an array of your documents from Firestore
           // if error is NOT nil, then it will contain the error message
           (queryResults, error) in
          
           // error handling:  This if-statement will be executed if an error
           // occurred while retrieving data from Firestore
           if let err = error {
               // if an error was encountered, then output the error message to console and exit
               print("Error getting documents from collection")
               print(err)
               return
           }
          
           // this block of code will be executed if the app was successfully able to
           // retrieve data from Firestore
           if (queryResults!.count == 0) {
               // executed if the collection is empty
               print("No documents found in the collection")
           }
           else {
               // otherwise, documents were found
               print("I found results: \(queryResults!.count)")
               
               // loop through the array of results and output each document to the screen
            for document in queryResults!.documents {
                print("Doc ID: \(document.documentID)")
                
                
                do {
                    let restaurantFromFirestore:Restaurant? = try document.data(as: Restaurant.self)
                                        
                    if let restaurant = restaurantFromFirestore {
                        // MARK: Add user to userList array
                        self.localDB.restaurantList.append(restaurant)
                    }
                    else {
                            print("Restaurant document was null")
                    }
                } catch {
                    print("Error converting document to Restaurant")
                }
            }    // end for loop
               // MARK: Reload the TableView so that its cells are populated once we have the fetched restaurant list from the FireStore Collection(restaurants)
               self.restaurantTableView.reloadData()
           } // end else
        } // end getDocuments
        
    }
    
   
    

}

extension HomeViewController {
    
    // ------------------------------------
    // MARK: Mandatory table view functions
    // ------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 1. Set the number of items in the table view.
    
    // - Define the total number of rows you want to display in the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localDB.restaurantList.count
    }
    
    // 2. Populating the row cells in the restaurant list
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = restaurantTableView.dequeueReusableCell(withIdentifier: "restaurantCell", for:indexPath) as! RestaurantTableViewCell
        let currRestaurant:Restaurant = localDB.restaurantList[indexPath.row]
        // 3. Populate the current cell with the required values
        cell.populateRestaurantTableViewCell(currentRestaurant: currRestaurant)

        return cell
    }
    // OPTIONAL: Detects when a row is clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("restaurant row clicked")
        
        // 1. Programatically Navigating to Activity List Screen
        
        // a. Try to get a reference to the next screen
        guard let nextScreen = storyboard?.instantiateViewController(identifier: "RestaurantDetailScreen") as? RestaurantDetailVC else {
            print("Cannot find next screen")
            return
        }
        
        // b. setting variables values in the next screen
        nextScreen.currentRestaurant = self.localDB.restaurantList[indexPath.row] as Restaurant
        
        // c. Navigate to the next screen
        self.navigationController?.pushViewController(nextScreen, animated: true)
    }
        
}
