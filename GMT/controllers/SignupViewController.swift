//
//  SignupViewController.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-22.
//

import UIKit

// imports
import FirebaseFirestore
import FirebaseFirestoreSwift

class SignupViewController: UIViewController {
    
    // MARK: Getting the Firestore DB
    let db = Firestore.firestore()
    
    let USER_COLLECTION = "users"

    //MARK: Outlets
    @IBOutlet weak var userFullName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: Lifecycle Functions
    // -------------------- Execution order: #1 --------------------
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // 1. Resetting the error label
        self.statusLabel.text = ""
        
        // 2. Clear the text-boxes
        clearText()
    }
    
    // MARK: Actions
    
    @IBAction func signUpPressed(_ sender: Any) {
        
        print("SignUp Pressed")
        
        // 1a. Validating the userFullName
        guard let name = userFullName.text, name.isEmpty == false else{
            let errorMsg = "HINT: Please ensure that name field is not empty"
            self.statusLabel.text = errorMsg
            print("\(errorMsg)")
            return
        }
        
        
        // 1b. Validating the userEmail
        guard let email = userEmail.text, email.isEmpty == false, email.isValidEmail else{
            let errorMsg = "Provide a valid email.\nHINT: Please ensure that email field is not empty"
            self.statusLabel.text = errorMsg
            print("\(errorMsg)")
            return
        }
        
        // 1c. Validating the userPassword
        guard let password = userPassword.text, password.isEmpty == false else{
            let errorMsg = "Provide a valid password.\nHINT: Please ensure that password field is not empty"
            self.statusLabel.text = errorMsg
            print("\(errorMsg)")
            return
        }
        
        // 2. Adding the user in the "users" collection of Firestore DB
        self.addUser(name: name, email: email, password: password)
        
        // 3. Clear the text boxs
        clearText()
        
    }
    
    // MARK: Helper Functions
    func clearText(){
        
        // 1a. Clearing the name field
        self.userFullName.text = ""
        
        // 1b. Clearing the email field
        self.userEmail.text = ""

        // 1c. Clearing the password field
        self.userPassword.text = ""
    }
    
    private func addUser(name: String, email: String, password: String) {
        
        // 1. Create a user object using the data from the user interface
        let userToAdd:User = User(fullName: name, email: email, password: password)
        
        // 2. Insert the document into firestore
        do {
            try db.collection(USER_COLLECTION).addDocument(from: userToAdd)
            let successMsg = "Account Created Successfully!!\nGo Back & Login"
            self.statusLabel.text = successMsg
            print("\(successMsg)")
        } catch {
            print("Error while adding document in the collection")
        }
        
    }
    
    

}
