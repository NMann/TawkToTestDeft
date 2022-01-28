//
//  CoreDataManager.swift
//  Loyalty
//
//  Created by IOS42 on 28/01/22.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager : NSObject {
    
    // MARK:- Context
    private class func getContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "TawkToApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container.viewContext
    }
    
    // MARK:- save User List Data
    class func saveUserListData(users: [UserListModel]) {
        
        let context = getContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: coreDataEntity.kUserListEntity)

        do {
            for user in users
            {
                let userId = user.id ?? kEmptyCount
                
            fetchRequest.predicate =  NSPredicate(format: "userid = %d", userId)
            let results = try? context.fetch(fetchRequest) as? [NSManagedObject]
            
            if !(results?.count ?? 0 > 0)
            {
                let newUser = NSEntityDescription.insertNewObject(forEntityName: coreDataEntity.kUserListEntity, into: context)
                newUser.setValue(user.id, forKey: coreDataKey.userid)
                newUser.setValue(user.login, forKey: coreDataKey.username)
                newUser.setValue(user.type, forKey: coreDataKey.usertype)
                
                if let url = user.avatar_url
                {
                    let imageData = self.stringToData(string: url)
                    newUser.setValue(imageData, forKey: coreDataKey.userimage)
                }
            }
            }

        do {
            try context.save()
           //debugPrint("saveUserListData Success")
        } catch {
           debugPrint("Error saving: \(error)")
        }
        }
        

    }
    //MARK: save Note For User with id
    
    class func saveNoteForUser(id: Int,notes:String) {

        let context = getContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: coreDataEntity.kUserNotesEntity)
        let userId = NSSortDescriptor(key:coreDataKey.userid, ascending:true)
        fetchRequest.sortDescriptors = [userId]
        fetchRequest.predicate =  NSPredicate(format: "userid = %d", id)
        //debugPrint("user id \(id) \(notes)")
        
        do {
            let results = try? context.fetch(fetchRequest) as? [NSManagedObject]
            
            if (results?.count ?? 0 > 0)
            {
        
                results?[0].setValue(notes, forKey: coreDataKey.usernotes)
            }
            else
            {
                let newUser = NSEntityDescription.insertNewObject(forEntityName: coreDataEntity.kUserNotesEntity, into: context)
                
                newUser.setValue(id, forKey: coreDataKey.userid)
                newUser.setValue(notes, forKey: coreDataKey.usernotes)
            }
    
        do {
            try context.save()
           //debugPrint("saveNoteForUser Success")
        } catch {
           debugPrint("Error saving: \(error)")
        }
        }
        
    }
    
    //MARK: Update Note For User id
    
    class func UpdateNoteForUser(id: Int,notes:String) {
        
        let context = getContext()

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: coreDataEntity.kUserListEntity)
        let userId = NSSortDescriptor(key:coreDataKey.userid, ascending:true)
        fetchRequest.sortDescriptors = [userId]
        fetchRequest.predicate =  NSPredicate(format: "userid = %d", id)

        do {
            let results = try? context.fetch(fetchRequest) as? [NSManagedObject]
            
            if (results?.count ?? 0 > 0)
            {
               // debugPrint("Notes found")
                results?[0].setValue(notes, forKey: coreDataKey.usernotes)
            }
            do {
                try context.save()
              // debugPrint("UpdateNoteForUser Success")
            } catch {
               debugPrint("Error saving: \(error)")
            }
        }
    
    }
    
    // MARK:- Retrive fetch User List
    class func fetchUserList() -> [UserListOffline] {
        var users:[UserListOffline] = []
        
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: coreDataEntity.kUserListEntity)
        let userId = NSSortDescriptor(key:coreDataKey.userid, ascending:true)
        
        fetchRequest.sortDescriptors = [userId]
        do {
            let results = try? context.fetch(fetchRequest) as? [NSManagedObject]
            
            
            for result in results!{
                let userid = result.value(forKey: coreDataKey.userid) as? Int ?? kEmptyCount
                let usertype = result.value(forKey: coreDataKey.usertype) as? String
                let username = result.value(forKey: coreDataKey.username) as? String
                let userimage = result.value(forKey: coreDataKey.userimage) as? Data ?? Data()
                let usernotes = result.value(forKey: coreDataKey.usernotes) as? String
                let user =  UserListOffline(userId: userid, userName: username, userType: usertype, userImage: userimage,userNotes: usernotes)
                users.append(user)
   
            }
            
            return users
        }
      
    }
    
    // MARK:- Retrive User Notes
    class func fetchUserNotes() -> [Int] {
        var users:[Int] = []
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: coreDataEntity.kUserNotesEntity)
        let userId = NSSortDescriptor(key:coreDataKey.userid, ascending:true)
        fetchRequest.sortDescriptors = [userId]
        do {
            let results = try? context.fetch(fetchRequest) as? [NSManagedObject]
            for result in results!{
                let userid = result.value(forKey: coreDataKey.userid) as? Int ?? kEmptyCount
                users.append(userid)
            }
            
            return users
        }

    }
    

// MARK:- Retrive User Note based on Id
    class func fetchUserNoteBasedOnId(userId:Int) -> String {
        var userNotes = ""
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: coreDataEntity.kUserNotesEntity)
        fetchRequest.predicate =  NSPredicate(format: "userid = %d", userId)
        let userId = NSSortDescriptor(key:coreDataKey.userid, ascending:true)
        
        fetchRequest.sortDescriptors = [userId]
        do {
            let results = try? context.fetch(fetchRequest) as? [NSManagedObject] ?? []
            if (results?.count ?? 0 > 0)
            {
                userNotes = results?[0].value(forKey: coreDataKey.usernotes) as? String ?? kEmptyString
            }

            return userNotes
        }
    
    }
    

    class func stringToData(string: String) -> Data {
        
        if string.isEmpty {
            return Data()
        }
        let url = URL(string: string)
        var data = Data()
       // DispatchQueue.main.async {
            if let imageData = try? Data(contentsOf: url ?? URL(fileURLWithPath: kEmptyString))
            {
                data = imageData
          }
        //}
        
        return data
    }
    
    
}
