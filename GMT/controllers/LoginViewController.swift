//
//  ViewController.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-15.
//

import UIKit

// imports
import FirebaseFirestore
import FirebaseFirestoreSwift

class LoginViewController: UIViewController {
    
    
    // MARK: Local Data source
    var localDB = DatabaseHelper.shared
    
    // MARK: Getting the Firestore DB
    let db = Firestore.firestore()
    
    //MARK: Variables
    // 1 -> Email does not exist
    // 2 -> Password Does not Match
    var userAuthorizationStatus : Int = 0
    
    let USER_COLLECTION = "users"
    var userList:[User] = []
    
    // MARK: Outlets
    @IBOutlet weak var loginScreenImg: UIImageView!

    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: Actions
    @IBAction func loginPressed(_ sender: Any) {
        
        print("Login Pressed")
        
        // 1a. Validating the userEmail
        guard let email = userEmail.text, email.isEmpty == false, email.isValidEmail else{
            let errorMsg = "Provide a valid email.\nHINT: Please ensure that email field is not empty"
            self.errorLabel.text = errorMsg
            print("\(errorMsg)")
            return
        }
        
        // 1b. Validating the userPassword
        guard let password = userPassword.text, password.isEmpty == false else{
            let errorMsg = "Provide a valid password.\nHINT: Please ensure that password field is not empty"
            self.errorLabel.text = errorMsg
            print("\(errorMsg)")
            return
        }
        
        // 2. Checking User Authorization Status
        if(checkAuthorization(email: email, password: password)){
            
            // MARK: Switching the root view for resolving issue for using tab & navigation controller together
            
            // after login is done, maybe put this in the login web service completion block
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                
            // This is to get the SceneDelegate object from your view controller
            // then call the change root view controller function to change to main tab bar
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
            // ------------------------------------------------------
            
            
            // 4. Programatically Navigating to Home(Restaurant_List) Screen
            navigateToHomeUpScreen()
            
            
        } else{
            // -Update the error label for different cases
            
            switch(userAuthorizationStatus){
                 
                case 1:
                   self.errorLabel.text = "Email doesn't exist!"
                case 2:
                   self.errorLabel.text = "Password Does not Match !!"
                default:
                   self.errorLabel.text = "Invalid Credentials!"
            }
            
            
        }
        // 3. Clear the text-boxes
        clearText()
        
        
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        print("Signup Pressed")
        navigateToSignUpScreen()
    }
    
    // MARK: Lifecycle Functions
    // -------------------- Execution order: #1 --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // -------------------- Execution order: #2 --------------------
    override func viewWillAppear(_ animated: Bool) {
        loginScreenImg.image = UIImage(named:"restaurant")
        self.getUserList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // 1. Resetting the error label
        self.errorLabel.text = ""
        
        // 2. Clear the text-boxes
        clearText()
    }
    
    // MARK: Helper Functions
    func clearText(){
        
        // 1a. Clearing the email field
        self.userEmail.text = ""

        // 1b. Clearing the password field
        self.userPassword.text = ""
    }
    
    func checkAuthorization(email: String, password: String) -> Bool{
        var authorizationStatus : Bool = false
        print("userList.count = \(userList.count)")
        
        if(userList.count>0){
            for user in userList{
                
                if(user.email == email.lowercased()){
                    print("User Name: \(user.fullName)")
                    
                    if(user.password == password){
                        authorizationStatus = true
                        // -Storing userID & user in the app local reference
                        self.localDB.userID = user.id!
                        self.localDB.userObject = user
                        break
                    } else{
                        self.userAuthorizationStatus = 2
                    }
                } else{
                    self.userAuthorizationStatus = 1
                }
            }
        } else{
            print("Unable to fetch userList from the FireStore")
        }
        
        return authorizationStatus
    }
    
    
    func navigateToSignUpScreen(){
        
        // 1. Programatically Navigating to Activity List Screen
        
        // a. Try to get a reference to the next screen
        guard let nextScreen = storyboard?.instantiateViewController(identifier: "SignupScreen") as? SignupViewController else {
            print("Cannot find next screen")
            return
        }
        
        // b. Navigate to the next screen
        self.navigationController?.pushViewController(nextScreen, animated: true)
    }
    
    func navigateToHomeUpScreen(){
        
        // 1. Programatically Navigating to Activity List Screen
        
        // a. Try to get a reference to the next screen
        guard let nextScreen = storyboard?.instantiateViewController(identifier: "HomeScreen") as? HomeViewController else {
            print("Cannot find next screen")
            return
        }
        
        // b. Navigate to the next screen
        self.navigationController?.pushViewController(nextScreen, animated: true)
    }
    
    
    // getUserList(): This function will get all the users from the firebase Collection
    private func getUserList() {

        print("Getting User List from the Firestore")
        
        // retrieve data from Firestore
        
        // this code connects to the specified collection and retrieves all the documents in the collection
 
        db.collection(USER_COLLECTION).getDocuments {
          
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
                        let userFromFirestore:User? = try document.data(as: User.self)
                                         
                        if let user = userFromFirestore {
                            // add user to userList array
                            self.userList.append(user)
                            print("  Document id: \(user.id ?? "abc123")")
                            print("  User name: \(user.fullName)")
                            print("  User Email Address: \(user.email)")
                            print("  User Password: \(user.password)")
                            print("  User Created On \(user.createdOn)")
                        }
                        else {
                                print("User is null")
                        }
                    } catch {
                        print("Error converting document to a User")
                    }
               }    // end for loop
           } // end else
        } // end getDocuments
        
    }
    
   
    

}

