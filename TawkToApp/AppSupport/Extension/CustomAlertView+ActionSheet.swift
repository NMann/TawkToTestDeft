//
//  CustomAlertView+ActionSheet.swift
//  Utility
//
//  Created by ios2 on 22/12/21.
//

import Foundation
import UIKit

extension UIAlertController {
    
    class func showAlertWithVC(_ title: String, message: String, buttons: [String],vc:UIViewController, completion: ((UIAlertController, Int) -> Void)?) {
           let alertView: UIAlertController? = self.init(title: title, message: message, preferredStyle: .alert)
           for i in 0..<buttons.count {
               alertView?.addAction(UIAlertAction(title: buttons[i], style: .default, handler: {(_ action: UIAlertAction) -> Void in
                   if completion != nil {
                       completion!(alertView!, i)
                   }
               }))
           }
           vc.present(alertView!, animated: true, completion: nil)
       }
    
    class func showSimpleAlertWithVC(_ title: String, message: String, buttons: String,vc:UIViewController) {
           let alertView: UIAlertController? = self.init(title: title, message: message, preferredStyle: .alert)
   
            alertView?.addAction(UIAlertAction(title: buttons, style: .default, handler: nil))
           
           vc.present(alertView!, animated: true, completion: nil)
       }
}
