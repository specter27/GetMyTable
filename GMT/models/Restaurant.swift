//
//  Restaurant.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-23.
//

import Foundation

import FirebaseFirestoreSwift
 
struct Restaurant:Codable {
    
    // add properties of a user here
    
    @DocumentID var id:String?
    var name: String = ""
    var about: String = ""
    var address: String = ""
    var bookingOpen: Bool = true
    var pricePerPerson: Double = 0
    var image: String = ""
    var diningStyle: String = ""
    var cuisines: String = ""
    var menu: String = ""
}
