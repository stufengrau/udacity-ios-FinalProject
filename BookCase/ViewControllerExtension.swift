//
//  ViewControllerExtension.swift
//  BookCase
//
//  Created by heike on 28.03.17.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(title: String?, message errormessage: String) {
        let alertController = UIAlertController(title: title, message: errormessage, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
