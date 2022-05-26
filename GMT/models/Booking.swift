//
//  Booking.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-23.
//

import Foundation

import FirebaseFirestoreSwift
 
struct Booking:Codable {
    
    // add properties for Restaurant-Booking here
    
    @DocumentID var id:String?
    var totalGuest: Int = 0
    var bookedFor: String = ""
    var confirmed: Bool = true
    var bookedBy: String = ""
    var totalBookingCost: Double = 0
    var restaurantImage: String = ""
    var restaurantName: String = ""
    
}
