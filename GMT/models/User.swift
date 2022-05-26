//
//  User.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-22.
//

import Foundation

import FirebaseFirestoreSwift
 
struct User:Codable {
    
    // add properties of a user here
    
    @DocumentID var id:String?
    var fullName: String = ""
    var email: String = ""
    var password: String = ""
    var profileImage: String = "userProfileImages/profile-avtar.jpg"
    var totalBookings: Int = 0
    var reservationBookingsList: [String] = []
    var createdOn: Date = Date()
    var lastUpdated: Date = Date()
}
