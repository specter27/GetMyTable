//
//  Review.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-23.
//

import Foundation

struct Review:Codable {
    
    // add properties for Reviews(Fetched from the third party API) here
    let name:String
    let email:String
    let body:String
}
