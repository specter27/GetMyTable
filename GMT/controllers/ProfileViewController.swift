//
//  ProfileViewController.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-22.
//

import UIKit

//import FirebaseStorage
import FirebaseStorage

// imports for Firestore
import FirebaseFirestore
import FirebaseFirestoreSwift




// 1. conform the class to the UIImagePickerControllerDelegate & UINavigationController Delegate

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Local Data source
    var localDB = DatabaseHelper.shared
    
    // MARK: Getting the Firestore DB
    let db = Firestore.firestore()
    
    // firebase storage service
    let storage = Storage.storage()
    
    // MARK: Variables
    var currentUser: User?
    let USER_COLLECTION = "users"


    // MARK: Outlets
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var updateImageButton: UIButton!
    @IBOutlet weak var totalBookingLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    // MARK: Lifecycle Functions
    // -------------------- Execution order: #1 --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ProfileViewController Loaded")
        
        // -Disable the updateImageButton
        self.updateImageButton.isEnabled = false
        
        // - Adding listener for the profileImage(UIImageView) for listening the tap on the image
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        profileImage.addGestureRecognizer(tapGR)
        profileImage.isUserInteractionEnabled = true
        
        // - Making the profile Image Radius round
        profileImage.makeRoundCorners(byRadius: 20)
        
        // - Setting the default profile image
        profileImage.image = UIImage(named:"profile-avtar")
        
        // MARK: programattically adding a navigation bar button for Logout
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
        
        
    }
    
    // -------------------- Execution order: #2 --------------------
    override func viewWillAppear(_ animated: Bool) {
        
        self.getUser()
    }
    
    @objc func logoutTapped(){
        
        // after user has successfully logged out
         
        //MARK: Switching the root view for resolving issue for using tab & navigation controller together
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        
    }
    
    // MARK: Actions
    
    @IBAction func updateProfilePressed(_ sender: Any) {
        
        // 1. Update the changes in the Firestore collection
        self.updateUserDetails()
        
        // 2. Refresh the Screen to get the User updated detsils
        viewWillAppear(true)
    }
    
    
    @IBAction func updateImagePressed(_ sender: Any) {
        
        if(self.currentUser?.profileImage != "userProfileImages/profile-avtar.jpg"){
            // 1. Delete the old profile_image from FirebaseStorage
            // Create a reference to the file to delete
            let docRef = self.storage.reference().child(self.currentUser!.profileImage)

            // Delete the file
            docRef.delete { error in
              if let error = error {
                  print("Error when deleting data")
                  print(error)
                
              } else {
                  // 2. Save the updated profile_image from FirebaseStorage & Update the User Object
                  self.savePhotoToCloud()
              }
            }
            
        }
            
        
        // 2. Save the updated profile_image from FirebaseStorage
        self.savePhotoToCloud()
        
        
        
    }
    
    
    // MARK: Cloud features
    
    // - Getting the profile image for the current user & setting the profileImage(UIImage) to the fetched image.
    
    private func getProfileImageFromCloud(name: String){
        // 1. specify the path to the file in the cloud storage
        let pathToImage = self.storage.reference(withPath: name)
        
        // 2. using a background task, asynchronously attempt to retrieve the photo from the cloud
       // 3. when downloading the photo, set the size of the photo (max size = 2MB)
        pathToImage.getData(maxSize: 10*1024*1024) {
            (photoData, error) in
            
            if let err = error {
                print("Ann error occurred while retrieving the photo")
                print(err)
            }
            else {
               // 4. do something with the photo
                let downloadedImage = UIImage(data:photoData!)
                self.profileImage.image = downloadedImage
                
            }
        }
    }
    
    private func savePhotoToCloud(){
        
        // specify the photo you want to save to the cloud
        guard let image = self.profileImage.image else {
            print("No image available")
            return
        }
        
        // send the photo to the cloud as a png
        if let image = image.pngData() {
            // send the photo to the cloud
            
            let profileImageUpdatedName: String = "userProfileImages/\(String(describing: currentUser!.id))profilePhoto.png"
            let ref = storage.reference().child(profileImageUpdatedName)
            ref.putData(image, metadata: nil) {
                (metadata, error) in
                
                if let err = error {
                    print("Error when uploading data")
                    print(err)
                }
                else {
                    print("Image uploaded")
                    // 3. update the user object
                    self.updateUserImage(updatedImageName: profileImageUpdatedName)
                }
            }
            
        }
        else {
            print("Error when getting PNG data from image")
       }
        
    }
    
    
    
    
    
    // MARK: Detect when did the user finish choosing a photo from the photo picker popup
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        // This function will execute when the user finishes choosing a photo (or) taking a photo with the camera
        print("User finished selecting a photo.")
        
        // close the picker popup
        picker.dismiss(animated: true, completion: nil)
        print("Closed the popup.")
        
        // get the photo the person selected
        guard let imageFromPicker = info[.originalImage] as? UIImage else {
            print("Error getting the photo")
            return
        }
        
        // do something with the photo here, for example, display it in an UIImageView outlet
        profileImage.image = imageFromPicker
        
        // Enable the updateImageButton
        self.updateImageButton.isEnabled = true

        
    }
    
    // MARK: Image Selector Popup
    // - Allow the user to select profile image from(gallary or camera) after tapping on the profile image view
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            print("UIImageView tapped")
            
            // create an image picker object
            // this object lets us choose the "source" of our photos (camera, photo gallery, etc)
            let imagePicker = UIImagePickerController()
           
            
            // choose a source for the photos
            // - if a camera is available, open the camera and wait for user to take a photo
            if (UIImagePickerController.isSourceTypeAvailable(.camera) == true) {
                // do the code to open the camera and get a photo
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                
                present(imagePicker, animated: true, completion:nil)
            }
            else {
                // do the code to open a photo gallery and get a photo
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                
                present(imagePicker, animated: true, completion:nil)
            }

            // - if no camera is available, then open the photo gallery and wait for user to select a photo
        }
    }
    
    // MARK: Helper Functions
    // getUser(): This function will get a spcific user from the firebase Collection
    private func getUser() {

        print("Getting User \(localDB.userID) from the Firestore")
        
        let docRef = db.collection(USER_COLLECTION).document(localDB.userID)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                do{
                    let dataDescription = try document.data(as: User.self)
                    // - populating the local reference for currentUser
                    self.currentUser = dataDescription
                    
                    // -Update the UI
                    // - Get & Set the profileImage for the currentUser.
                    self.getProfileImageFromCloud(name: dataDescription.profileImage)
                    print("-------Profile Image name: \(dataDescription.profileImage)\n\n\n")
                    
                    self.nameLabel.text = dataDescription.fullName
                    
                    // Create Date Formatter
                    let dateFormatter = DateFormatter()
                    
                    // Set Date Format
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .none

                    // Convert Date to String
                    self.creationDateLabel.text = "Member Since \(dateFormatter.string(from: dataDescription.createdOn))"
                    self.totalBookingLabel.text = String(dataDescription.totalBookings)
                    self.nameText.text = dataDescription.fullName
                    
                } catch {
                    print("Document does not exist")
                }
                
            } else {
                print("Document does not exist")
            }
    
        }
    }
    
    private func updateUserDetails() {
        
        print("Updating user Profile")
        
        // 1. Validating the current user
        guard var currentUser = currentUser else {
            print("The user is null, so we cannot proceed")
            return
        }
        
        // 2. Validating the Updated Name
        guard let updatedName = nameText.text, updatedName.isEmpty == false else{
            let errorMsg = "Please ensure that name field is not empty"
            self.statusLabel.text = errorMsg
            print("\(errorMsg)")
            return
        }
        
        currentUser.fullName = updatedName
        
        // 3. Do the update in the FireStore DB
        do {
            try db.collection(USER_COLLECTION).document(currentUser.id!).setData(from: currentUser)
            print("User Document updated")
        } catch {
            print("Error updating User document")
        }
           
    }
    
    private func updateUserImage(updatedImageName: String) {
        
        print("Updating user profile image")
        
        // 1. Validating the current user
        guard var currentUser = currentUser else {
            print("The user is null, so we cannot proceed")
            return
        }
        
        
        currentUser.profileImage = updatedImageName
        
        // 2. Do the update in the FireStore DB
        do {
            try db.collection(USER_COLLECTION).document(currentUser.id!).setData(from: currentUser)
            print("User Document updated for profile Image")
        } catch {
            print("Error updating User document")
        }
           
        
        
        
    }
    
    

}
