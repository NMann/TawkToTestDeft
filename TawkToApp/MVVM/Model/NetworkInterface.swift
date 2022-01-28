//
//  NetworkInterface.swift
//  TawkToApp
//
//  Created by ios2 on 27/01/22.
//

import Foundation
import UIKit

class APIManager {
    
    //MARK: Call API with URL
    
    class func apiCallWithUrl(url:String,SucessCompletion:  @escaping (Data) -> (),ErorrCompletion:  @escaping (String) -> ())
    {
        let url = URL(string: url)
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error == nil && data != nil
            {
                SucessCompletion(data!)
            }
            else
            {
                ErorrCompletion(error?.localizedDescription ?? "")
            }
            
        })
        task.resume()
    }

}
