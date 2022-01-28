//
//  UITableView+Extension.swift
//  TawkToApp
//
//  Created by ios2 on 25/01/22.
//

import Foundation
import UIKit

extension UITableView
{
    func registerXibCell(identifierName:String)
    {
        self.register(UINib(nibName: identifierName, bundle: nil), forCellReuseIdentifier: identifierName)
        
    }
}
