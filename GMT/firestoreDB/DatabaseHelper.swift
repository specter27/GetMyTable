//
//  DatabaseHelper.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-22.
//

import Foundation

// imports
import FirebaseFirestore
import FirebaseFirestoreSwift

// - This class provides a Singleton
class DatabaseHelper{
    
    static let shared = DatabaseHelper()
    private init() {}
    
    // MARK: Variable
    var userID: String = ""
    var userObject: User?
    var restaurantList:[Restaurant] = []
    var bookingList:[Booking] = []
    
}
