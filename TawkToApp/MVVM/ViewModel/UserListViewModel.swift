//
//  UserListViewModel.swift
//  TawkToApp
//
//  Created by ios2 on 27/01/22.
//

import Foundation
class UserListViewModel
{
    static var shared = UserListViewModel()
    
    private init(){}
    
    func callApiUserList(page:Int=0,SucessCompletion:  @escaping ([UserListModel]) -> (),ErorrCompletion:  @escaping (String) -> ())
    {
        let fullApiUrl = APIUrl.userList+"\(page)"+APIUrl.userListTale
       // debugPrint("fullApiUrl = \(fullApiUrl)")
        
        APIManager.apiCallWithUrl(url: fullApiUrl) { data in
            do {
                
                let jsonDecoder = JSONDecoder()
                let userList = try jsonDecoder.decode([UserListModel].self, from: data)
                SucessCompletion(userList)
                DispatchQueue.background(delay: 0, completion:  {
            
              CoreDataManager.saveUserListData(users: userList)

                })
            } catch let error {
                
                ErorrCompletion(error.localizedDescription)
                
            }
            
        } ErorrCompletion: { error in
            ErorrCompletion(error)
        }
        
    }
    
    func callApiUserDetails(url:String,SucessCompletion:  @escaping (UserDetailModel) -> (),ErorrCompletion:  @escaping (String) -> ())
    {
        APIManager.apiCallWithUrl(url: url) { data in
            do {
                
                let jsonDecoder = JSONDecoder()
                let userDetail = try jsonDecoder.decode(UserDetailModel.self, from: data)
                SucessCompletion(userDetail)
            } catch let error {
                
                ErorrCompletion(error.localizedDescription)
                
            }
            
        } ErorrCompletion: { error in
            ErorrCompletion(error)
        }
        
    }
}
