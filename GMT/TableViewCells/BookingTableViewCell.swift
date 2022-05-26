//
//  BookingTableViewCell.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-24.
//

import UIKit

//import FirebaseStorage
import FirebaseStorage
class BookingTableViewCell: UITableViewCell {
    
    // Firebase storage service
    let storage = Storage.storage()
    
    // MARK: Outlets
    
    @IBOutlet weak var restaurantImage: UIImageView!
    
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var totalGuest: UILabel!
    @IBOutlet weak var bookingDate: UILabel!
    
    @IBOutlet weak var bookingStatus: UILabel!
    // MARK: Helper function
    // 1. Setting the values of the UI elements inside the custom Table View Cell
    func populateBookingTableViewCell(currentBooking: Booking){
        
        // Setting values of the UI elements inside the custom row or cell
        // 1. Updating the UIImageView with the restaurant image from the Firebase Storage
        self.getProfileImageFromCloud(name: currentBooking.restaurantImage)

        self.restaurantName.text = currentBooking.restaurantName
        self.bookingDate.text = currentBooking.bookedFor
        self.totalGuest.text = String(currentBooking.totalGuest)
        
        if(currentBooking.confirmed){
            self.bookingStatus.text = "Yes"
            self.bookingStatus.textColor = .systemGreen
        } else {
            self.bookingStatus.text = "No"
            self.bookingStatus.textColor = .red
        }
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
                self.restaurantImage.image = downloadedImage
                
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
