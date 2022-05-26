//
//  Extensions.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-22.
//

import Foundation

import UIKit
extension String {
   var isValidEmail: Bool {
      let regexForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let email = NSPredicate(format:"SELF MATCHES %@", regexForEmail)
      return email.evaluate(with: self)
   }
}

extension UIImageView {
   func makeRoundCorners(byRadius rad: CGFloat) {
      self.layer.cornerRadius = rad
      self.clipsToBounds = true
   }
}
extension Double {
    var priceFormat:String {
        return String(format:"%.2f", self)
    }
}
