//
//  AppConstant.swift
//  TawkToApp
//
//  Created by ios2 on 25/01/22.
//

import Foundation

let kError = "Error"
let kMessage = "Message"
let kSucess = "Sucess"
let kOk = "Ok"
let kEmptyString = ""
let kEmptyCount = 0
let kFollower = "Follower"
let kFollowing = "Following"
let kType = "Type: "

let kUser = "User"

let kEmptyMessage = "Please enter notes."
let kOfflineMessage = "Please check internet connection and refresh page."
let kSavedMessage = "Notes saved."
struct APIUrl
{
    static let userList = "https://api.github.com/users?since=" 
    static let userListTale = "&per_page=10"
    static let userDetail = "https://api.github.com/users/"
}

struct tableViewCellName
{
    static let userList = "UserTableCell"
    static let InvertedUserTableViewCell = "InvertedUserTableViewCell"
    
}

struct coreDataEntity
{
    static let kUserListEntity = "UserList"
    static let kUserNotesEntity = "UserNotes"
    
}

struct coreDataKey
{
    static let userid = "userid"
    static let userimage = "userimage"
    static let username = "username"
    static let usertype = "usertype"
    static let usernotes = "usernotes"
    
}

