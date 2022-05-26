//
//  BookingViewController.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-22.
//

import UIKit

import FirebaseFirestore
import FirebaseFirestoreSwift

//import FirebaseStorage
import FirebaseStorage

class BookingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Local Data source
    var localDB = DatabaseHelper.shared
    
    // MARK: Getting the Firestore DB
    let db = Firestore.firestore()
    
    // Firebase storage service
    let storage = Storage.storage()
    
    // MARK: Variables
    let BOOKING_COLLECTION = "bookings"
    let USER_COLLECTION = "users"
    
    // MARK: Outlets
    
    @IBOutlet weak var bookingTableView: UITableView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: Lifecycle Functions
    // -------------------- Execution order: #1 --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("BookingViewController Loaded")
        
        self.bookingTableView.delegate = self
        self.bookingTableView.dataSource = self

//        self.bookingTableView.register(BookingTableViewCell.self, forCellReuseIdentifier: "bookingCell")
        
        // Programatically setting the row height in the table view
        self.bookingTableView.rowHeight = 220
        
        // MARK: programattically adding a navigation bar button for Logout
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
        
    }
    
    // -------------------- Execution order: #2 --------------------
    override func viewWillAppear(_ animated: Bool) {
        print("Executing \(#function) for \(#file)")
        // 1. Reset the bookings list before fetching new values in it
        self.localDB.bookingList = []
        
        // 2. Fetch the Bookings list from the in FireStore DB collection(bookings) for current user
        self.getUserBookings()
        
    }
    
    //-------------------- Execution order: #3 --------------------
    override func viewDidAppear(_ animated: Bool) {
        
    
    }
    
    @objc func logoutTapped(){
        
        // after user has successfully logged out
         
        //MARK: Switching the root view for resolving issue for using tab & navigation controller together
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        
    }
    
    // MARK: Helper functions
    
    private func getUserBookings(){
        
        print("Fetching User specific booking document from Firestore collection(bookings)")
    
        // This code connects to the specified collection(bookings) and retrieves only those documents WHERE bookedBy == self.localDB.userID
 
        db.collection(BOOKING_COLLECTION).whereField("bookedBy", isEqualTo: self.localDB.userID)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if(querySnapshot!.documents.count == 0){
                        self.statusLabel.text = "No Bookings Yet"
                    }
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        do {
                            let bookingFromFirestore:Booking? = try document.data(as: Booking.self)
                                                
                            if let booking = bookingFromFirestore {
                                // MARK: Add booking to bookingList array
                                self.localDB.bookingList.append(booking)
                            }
                            else {
                                    print("Booking document was null")
                            }
                        } catch {
                            print("Error converting document to Booking")
                        }
                    }
                    // MARK: Reload the TableView so that its cells are populated once we have the fetched restaurant list from the FireStore Collection(restaurants)
                    self.bookingTableView.reloadData()
                }
        }
    }
        
        
}

extension BookingViewController {
    
    
    
    // ------------------------------------
    // MARK: Mandatory table view functions
    // ------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 1. Set the number of items in the table view.
    
    // - Define the total number of rows you want to display in the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Trying creating the table view numberOfRowsInSection = \(self.localDB.bookingList.count)")
        return self.localDB.bookingList.count
//        return 1
        
    }
    
    // 2. Populating the row cells in the restaurant list
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = bookingTableView.dequeueReusableCell(withIdentifier: "bookingCell", for:indexPath) as! BookingTableViewCell
        let currBooking:Booking = self.localDB.bookingList[indexPath.row]
        // 3. Populate the current cell with the required values
        

        print("currBooking: \(currBooking)")
        
        cell.restaurantName?.text = currBooking.restaurantName
        cell.bookingDate?.text = currBooking.bookedFor
        cell.totalGuest?.text = String(currBooking.totalGuest)
        
        if(currBooking.confirmed){
            cell.bookingStatus?.text = "Yes"
            cell.bookingStatus?.textColor = .systemGreen
        } else {
            cell.bookingStatus?.text = "No"
            cell.bookingStatus?.textColor = .red
        }
        
        // - Getting the profile image for the current user & setting the profileImage(UIImage) to the fetched image.

        // 1. specify the path to the file in the cloud storage
        let pathToImage = self.storage.reference(withPath: currBooking.restaurantImage)
        
        // 2. using a background task, asynchronously attempt to retrieve the photo from the cloud
       // 3. when downloading the photo, set the size of the photo (max size = 2MB)
        pathToImage.getData(maxSize: 2*1024*1024) {
            (photoData, error) in
            
            if let err = error {
                print("Ann error occurred while retrieving the photo")
                print(err)
            }
            else {
               // 4. do something with the photo
                let downloadedImage = UIImage(data:photoData!)
                cell.restaurantImage?.image = downloadedImage
                
            }
        }
        
        //        cell.populateBookingTableViewCell(currentBooking: currBooking)

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
    
    // MARK: Deleting a row (with swipe action)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // 1. Before we delete the booking, we need its id
            let bookingToDelete = self.localDB.bookingList[indexPath.row]
            let idToDelete = bookingToDelete.id!
       
            // 2. Delete the booking from the local reference bookings(array)
            self.localDB.bookingList.remove(at: indexPath.row)
            
            
            // 3. Delete the corresponding row from the tableview
            tableView.deleteRows(at: [indexPath], with: .fade)
           
            // 4. Delete it from firestore bookings(collection)
            db.collection(BOOKING_COLLECTION).document(idToDelete).delete() {
               (err) in
               if let err = err {
                   print("Error removing document")
                   print(err)
               }
               else {
                   print("Document deleted from Firestore")
                   self.viewWillAppear(true)
               }
           }
            // 5. Fetch the Current User from the FireStore using the userID in our local reference(DatabaseHelper)
            let docRef = db.collection(USER_COLLECTION).document(localDB.userID)

                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            
                            do{
                                var fetchedUser = try document.data(as: User.self)
                               
                                // 6. Update the Current user in local reference & Firebase collection for the booking removal change
                                print("Updating User Object for removing the booking from the bookings list")
                                
                                // 6a. Decrement the totalBookings for current User
                                print("--------- currentUser.totalBookings value BEFORE DECREMENT \(fetchedUser.totalBookings)---------------\n\n")
                                fetchedUser.totalBookings = fetchedUser.totalBookings-1
                                print("--------- currentUser.totalBookings value AFTER DECREMENT \(fetchedUser.totalBookings)---------------\n\n")
                                
                                // 6b. Do the update in the FireStore DB for User changes
                                do {
                                    try self.db.collection(self.USER_COLLECTION).document(fetchedUser.id!).setData(from: fetchedUser)
                                    print("User Document updated")
                                } catch {
                                    print("Error updating User document")
                                }
                                
                            } catch {
                                print("Document does not exist")
                            }
                            
                        } else {
                            print("Document does not exist")
                        }
                
                    }
            
            
            
               
        }
    }


        
}
