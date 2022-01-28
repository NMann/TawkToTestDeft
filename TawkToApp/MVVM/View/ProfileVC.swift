//
//  ProfileVC.swift
//  TawkToApp
//
//  Created by ios2 on 25/01/22.
//

import UIKit

class ProfileVC: BaseVC {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var labelFollowing: UILabel!
    @IBOutlet weak var labelFollower: UILabel!
    @IBOutlet weak var imageHeader: ImageLoader!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelCompany: UILabel!
    @IBOutlet weak var labelBlog: UILabel!
    @IBOutlet weak var textViewNote: UITextView!
    @IBOutlet weak var butonSave: UIButton!
    @IBOutlet weak var viewNotes: UIView!
    @IBOutlet weak var viewDetail: UIView!
    var userName = ""
    var userNotes = ""
    var userDetail:UserDetailModel?
    var userDetailOffline:UserListOffline?
    var userOnline : Bool = false
    var userId = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        if Reachability.isConnectedToNetwork()
        {
            self.userOnline=true
            Indicator.sharedInstance.showIndicator()
            UserListViewModel.shared.callApiUserDetails(url: APIUrl.userDetail+userName) { userDetail in
                self.userDetail = userDetail
                
                DispatchQueue.main.async {
                    self.setupDetail()
                }
                
                Indicator.sharedInstance.hideIndicator()
            } ErorrCompletion: { error in
                Indicator.sharedInstance.hideIndicator()
                UIAlertController.showSimpleAlertWithVC(kError, message: error, buttons: kOk, vc: self)
                
            }
        }
        else
        {
            self.userOnline=false
            DispatchQueue.main.async {
                self.setupDetail()
            }
        }
        setupUI()
    }
    
    //MARK:- Setup UI
    func setupUI()
    {
        self.setTitle(title: userName)
        self.hideKeyboardWhenTappedAround()
        
        self.textViewNote.delegate=self
        
        if self.isDarkModeOn()
        {
            self.viewNotes.borderColor = UIColor.white
            self.viewDetail.borderColor = UIColor.white
        }
        else {
    
            self.viewNotes.borderColor = UIColor.black
            self.viewDetail.borderColor = UIColor.black
        }
    }
    
    //MARK:- Show data from api or coredata
    
    func setupDetail()
    {
        
        
        if self.userOnline
        {
            userId = self.userDetail?.id ?? kEmptyCount
            self.labelName.text = self.userDetail?.login ?? kEmptyString
            self.labelCompany.text = self.userDetail?.company ?? kEmptyString
            
            self.labelBlog.text = self.userDetail?.blog ?? kEmptyString
            let followers = self.userDetail?.followers ?? kEmptyCount
            self.labelFollower.text = (followers>1 ? (kFollower+": ") + "\(followers) " : (kFollower+"s: "  + "\(followers) "))
            
            let following = self.userDetail?.following ?? kEmptyCount
            self.labelFollowing.text = kFollowing+": " + "\(following)"
            
            if let strUrl = self.userDetail?.avatar_url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
               let imgUrl = URL(string: strUrl) {
                self.imageHeader.loadImageWithUrl(imgUrl)
            }
            
        }
        else
        {
            userId = self.userDetailOffline?.userId ?? kEmptyCount
            self.labelName.text = self.userDetailOffline?.userName ?? kEmptyString
            self.labelCompany.text =  kEmptyString
            
            self.labelBlog.text =  kEmptyString
            
            let followers =  kEmptyCount
            self.labelFollower.text = (followers>1 ? (kFollower+": ") + "\(followers) " : (kFollower+"s: "  + "\(followers) "))
            
            let following =  kEmptyCount
            self.labelFollowing.text = kFollowing+": " + "\(following)"
            
            let imageData = self.userDetailOffline?.userImage ?? Data()
            
            if !imageData.isEmpty
            {
                self.imageHeader.image = self.dataToImage(data: imageData)
            }
            else{
                
                self.imageHeader.image = UIImage(named: "user")
            }
        }
        self.labelName.text =  self.labelName.text?.capitalized
        
        self.textViewNote.text = (self.userNotes.count != 0) ? (self.userNotes)  : (CoreDataManager.fetchUserNoteBasedOnId(userId: userId))
        
        
    }
    //MARK:- Save note action
    @IBAction func SaveButtonAction(_ sender: UIButton)
    {
        let noteText = self.textViewNote.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if noteText.count == 0
        {
            UIAlertController.showSimpleAlertWithVC(kError, message: kEmptyMessage, buttons: kOk, vc: self)
            
        }
        else
        {
     
            CoreDataManager.saveNoteForUser(id: self.userId,notes: noteText)
            CoreDataManager.UpdateNoteForUser(id: self.userId,notes: noteText)
           
            UIAlertController.showAlertWithVC(kSucess, message: kSavedMessage, buttons: [kOk], vc: self) { alert, index in
                self.textViewNote.text=kEmptyString
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
        
    }
    
}
extension ProfileVC:UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
