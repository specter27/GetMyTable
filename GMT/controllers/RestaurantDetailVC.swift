//
//  RestaurantDetailViewController.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-23.
//

import UIKit

//import FirebaseStorage
import FirebaseStorage

import FirebaseFirestore
import FirebaseFirestoreSwift

class RestaurantDetailVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Outlets
    @IBOutlet weak var txtrestaurantName: UILabel!
    @IBOutlet weak var txtDiningStyle: UILabel!
    @IBOutlet weak var txtBookingStatus: UILabel!
    @IBOutlet weak var imageRestaurant: UIImageView!
    @IBOutlet weak var txtDescriptionAddress: UILabel!
    @IBOutlet weak var txtPrice: UILabel!
    
    @IBOutlet weak var txtCuisines: UILabel!
    @IBOutlet weak var pvNumberOfTickets: UIPickerView!
    @IBOutlet weak var dpDate: UIDatePicker!
    
    // MARK: Getting the Firestore DB
    let db = Firestore.firestore()
    
    // MARK: Local Data source
    var localDB = DatabaseHelper.shared
    
    // MARK: Variables
    var currentRestaurant: Restaurant?
    var currentBooking: Booking?
    var reviewList:[Review]=[]
    
    // Firebase storage service
    let storage = Storage.storage()
    
    var dataForPickerView:[Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    let API_URL = "https://jsonplaceholder.typicode.com/comments"
    let USER_COLLECTION = "users"
    let BOOKING_COLLECTION = "bookings"


    
    // MARK: Lifecycle Functions
    // -------------------- Execution order: #1 --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Restaurant Detail Screen Loaded")
        print("current Restaurant Details: \(currentRestaurant!)")
        
        
        // -Picker view
        self.pvNumberOfTickets.delegate = self
        self.pvNumberOfTickets.dataSource = self
        
        // Setting date picker minimum date
        var dayComponent = DateComponents()
        dayComponent.day = 1
        let theCalendar = Calendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: Date())
        dpDate.minimumDate =  nextDate
        
        // Setting the UI values
        self.setValuesForUI()
        

        // Do any additional setup after loading the view.
    }
    // -------------------- Execution order: #2 --------------------
    override func viewWillAppear(_ animated: Bool) {
        
        // 1. Reset the restaurant list before fetching new values in it
        self.reviewList = []
        
        // 2. Fetch the Review list from the Third-Party API
        self.getReviewsList()
        
    }
    
    // - Picker View Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataForPickerView.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // As picker view contain data of type Int
        return "\(dataForPickerView[row])"
    }
    

    // MARK: Actions
    
    @IBAction func reserveSeatsPressed(_ sender: Any) {
        
        // 1. Get the Data for Bookings from the UI Elements
        
        // a. Get selected value from the PickerView
        let index = pvNumberOfTickets.selectedRow(inComponent: 0)
        let totalPeople: Int = dataForPickerView[index]
        print("totalPeople are: \(totalPeople)")
        
        // b. Get selected date with format from DatePickerView
        let dateFormatter = DateFormatter()
        // Set Date Format
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .long
        let selectedDate = dateFormatter.string(from: dpDate.date)
        print(selectedDate)
        
        // c. Calculate the totalBookingCost
        let calculatedBookingCost:Double = currentRestaurant!.pricePerPerson * Double(totalPeople)
        print("calculatedBookingCost: \(calculatedBookingCost)")
        
        
        // 2a. Create a Booking Object
        let bookingToAdd: Booking = Booking(totalGuest: totalPeople, bookedFor: selectedDate, bookedBy: self.localDB.userID, totalBookingCost: calculatedBookingCost, restaurantImage: currentRestaurant!.image, restaurantName: currentRestaurant!.name)
        
        // 2b. Save that in FireStore Collection(bookings)
        
        do {
            try db.collection(BOOKING_COLLECTION).addDocument(from: bookingToAdd)
            // 3. Update the User Object
            self.updateUserDetails()
            let successMsg = "Reservation Booked Successfully!!"
            print("\(successMsg)")
        } catch {
            print("Error while adding document in the collection")
        }
        //- Show Alert box to show total cost
        let alertBox = UIAlertController(title: "Reservation Details", message: "Cost for Reservation: CAN$\(calculatedBookingCost.priceFormat)", preferredStyle: .alert)
        alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertBox, animated: true)
        
        
        
    }
    
    @IBAction func moreInfoPressed(_ sender: Any) {
        // 1. Programatically Navigating to Activity List Screen
        
        // a. Try to get a reference to the next screen
        guard let nextScreen = storyboard?.instantiateViewController(identifier: "MoreInfoScreen") as? LocationReviewDetailVC else {
            print("Cannot find next screen")
            return
        }
        
        // b. setting variables values in the next screen
        nextScreen.address = (self.currentRestaurant?.address)!
        nextScreen.reviewList = self.reviewList
    
        nextScreen.currentRestaurantMenuURL = self.currentRestaurant!.menu
        
        // c. Navigate to the next screen
        self.navigationController?.pushViewController(nextScreen, animated: true)
    }
    
    //MARK: Helper Functions
    
    private func updateUserDetails() {
        
        print("Updating user Object")
        
        // # Fetch the Current User from the FireStore using the userID in our local reference(DatabaseHelper)
        let docRef = db.collection(USER_COLLECTION).document(localDB.userID)

                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        
                        do{
                            var fetchedUser = try document.data(as: User.self)
                           
                            // 1. Update the Current user in local reference & Firebase collection for the booking removal change
                            print("Updating User Object for removing the booking from the bookings list")
                            
                            // 1a. Decrement the totalBookings for current User
                            print("--------- currentUser.totalBookings value BEFORE DECREMENT \(fetchedUser.totalBookings)---------------\n\n")
                            fetchedUser.totalBookings = fetchedUser.totalBookings+1
                            print("--------- currentUser.totalBookings value AFTER DECREMENT \(fetchedUser.totalBookings)---------------\n\n")
                            
                            // 1b. Do the update in the FireStore DB for User changes
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
    
    func setValuesForUI(){
        
        // 1. Setting values of the UI elements on the Restaurant Detail Screen
        self.txtrestaurantName.text = currentRestaurant?.name ?? "NA"
        self.txtDiningStyle.text = currentRestaurant?.diningStyle ?? "NA"
        self.txtCuisines.text = currentRestaurant?.cuisines ?? "NA"
        self.txtDescriptionAddress.text = currentRestaurant?.about ?? "Not Available"
        
        if(currentRestaurant?.bookingOpen ?? false){
            self.txtBookingStatus.text = "OPEN"
            self.txtBookingStatus.textColor = .systemGreen
        } else {
            self.txtBookingStatus.text = "CLOSED"
            self.txtBookingStatus.textColor = .red
        }
        
        self.txtPrice.text = "CAN$\(currentRestaurant?.pricePerPerson.priceFormat ?? "0.00") per person"
        
        // 2. Updating the UIImageView with the restaurant image from the Firebase Storage
        self.getProfileImageFromCloud(name: currentRestaurant!.image)
        
        
    }
    
    private func getReviewsList(){
        
        URLSession.shared.dataTask(with: URL(string: API_URL)!, completionHandler:
        {
            data, response, error in
            guard let data = data , error == nil else
            {
                print("something went wrong")
                return
            }
            var result: [Review]?
            do
            {
                result = try JSONDecoder().decode([Review].self, from: data)
            }
            catch
            {
                print("Failed to convert the Review-List Data")
            }
            
            
            guard let json = result else
            {
                return
            }
            
            var count = 1
            for review in json
            {
                if(count<=8)
                {
                    self.reviewList.append(review)
                    count=count+1
                }
                //print(review.body)
            }
        }).resume()
        
    }
    
    // MARK:  Cloud features
    
    // - Getting the profile image for the current user & setting the profileImage(UIImage) to the fetched image.
    private func getProfileImageFromCloud(name: String){
        // 1. specify the path to the file in the cloud storage
        let pathToImage = self.storage.reference(withPath: name)
        
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
                self.imageRestaurant.image = downloadedImage
                
            }
        }
    }
    
}
