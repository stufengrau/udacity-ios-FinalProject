//
//  UIColorExtension.swift
//  BookCase
//
//  Created by heike on 04.04.17.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

// MARK: - Extension: Intialize UIColor with HEX Color Values

// The code for the two convenience initializers is from:
// https://medium.com/ios-os-x-development/ios-extend-uicolor-with-custom-colors-93366ae148e6
// See also http://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values-in-swift-ios

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

// MARK: - Extension: Custom App UIColors
extension UIColor {
    struct BookCaseColors{
        static let darkBlueForTranslucentItems = UIColor(netHex: 0x20405D)
        static let darkBlue = UIColor(netHex: 0x38536D)
        static let lightBlue = UIColor(netHex: 0x8F9FAE)
    }
}
