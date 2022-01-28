//
//  UserListVC.swift
//  TawkToApp
//
//  Created by ios2 on 25/01/22.
//

import UIKit

class UserListVC: BaseVC {
    
    //MARK:- Outlets
    
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableViewUserList: UITableView!
    @IBOutlet weak var viewSearch: UIView!
    
    //MARK:- Variable
    
    let refreshControl = UIRefreshControl()
    var userList:[UserListModel] = []
    var filteredUserList:[UserListModel] = []
    var UserListOffline:[UserListOffline] = []
    var filteredOffline:[UserListOffline] = []
    var notesUserId:[Int] = []
    
    var searchActive : Bool = false
    var userOnline : Bool = false
    var page = 0
    var isLoadingPage=false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewSetup()
    
        setupUI()
        self.ShowData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            if self.userOnline
            {
                self.notesUserId.removeAll()
                self.notesUserId = CoreDataManager.fetchUserNotes()
            }
            else
            {
                self.UserListOffline.removeAll()
                self.notesUserId.removeAll()
                self.notesUserId = CoreDataManager.fetchUserNotes()
                self.UserListOffline = CoreDataManager.fetchUserList()
            }
            self.refreshControl.endRefreshing()
            self.tableViewUserList.reloadData()
        }
    }
    
    //MARK:- Setup UI
    func setupUI()
    {
        self.searchText.delegate = self
        self.hideKeyboardWhenTappedAround()
        self.viewLoader.isHidden=true
        
    }
    //MARK:- Refresh table
    
    @objc func refresh(_ sender: AnyObject) {
        if Reachability.isConnectedToNetwork()
        {
    
        self.ShowData(fromPullRefresh: true)
        }
        else
        {
            self.refreshControl.endRefreshing()
        }
        
    }
    
    //MARK:- Show table view data
    func ShowData(page:Int=0,fromPullRefresh:Bool=false)
    {
        if Reachability.isConnectedToNetwork()
        {
            self.userOnline=true
            if page == 0
            {
                self.userList.removeAll()
                self.filteredOffline.removeAll()
                self.filteredUserList.removeAll()
                if !fromPullRefresh{
                   
                    Indicator.sharedInstance.showIndicator()
                }
                else
                {
                    self.refreshControl.beginRefreshing()
                }
            }
            else
            {
                self.viewLoader.isHidden=false
            }
            
            UserListViewModel.shared.callApiUserList(page:page) { userList in
                
                self.page = self.page + 1
                if page == 0
                {
                    self.userList = userList
                    self.notesUserId = CoreDataManager.fetchUserNotes()
                    Indicator.sharedInstance.hideIndicator()
                }
                else
                {
                    for user in userList
                    {
                        self.userList.append(user)
                    }
                    
                }
                
                DispatchQueue.main.async {
                    self.viewLoader.isHidden=true
                    self.refreshControl.endRefreshing()
                    self.tableViewUserList.reloadData()
                }
                
                
            } ErorrCompletion: { error in
                self.refreshControl.endRefreshing()
                Indicator.sharedInstance.hideIndicator()
                UIAlertController.showSimpleAlertWithVC(kError, message: error, buttons: kOk, vc: self)
            }
            
            
            
        }
        else
        {
            self.refreshControl.endRefreshing()
            self.userOnline=false
            self.notesUserId = CoreDataManager.fetchUserNotes()
            self.UserListOffline = CoreDataManager.fetchUserList()
            DispatchQueue.main.async {
                self.tableViewUserList.reloadData()
            }
            if  self.UserListOffline.count == 0
            {
                UIAlertController.showSimpleAlertWithVC(kMessage, message: kOfflineMessage, buttons: kOk, vc: self)
            }
           // debugPrint("self.UserListOffline = \(self.UserListOffline)")
        }
    }
    
}

//MARK:- Table delegate and data source

extension UserListVC:UITableViewDelegate,UITableViewDataSource
{

    func tableViewSetup()
    {
        self.tableViewUserList.delegate=self
        self.tableViewUserList.dataSource=self
        
        self.tableViewUserList.rowHeight = UITableView.automaticDimension;
        self.tableViewUserList.estimatedRowHeight = 100.0
        self.tableViewUserList.registerXibCell(identifierName: tableViewCellName.userList)
        self.tableViewUserList.registerXibCell(identifierName: tableViewCellName.InvertedUserTableViewCell)
        
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableViewUserList.addSubview(refreshControl)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if !self.userOnline
        {
            
            if searchActive
            {
                return  self.filteredOffline.count
            }
            else
            {
                return  self.UserListOffline.count
            }
        }
        else
        {
            if searchActive
            {
                return  self.filteredUserList.count
            }
            else
            {
                return  self.userList.count
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if  (indexPath.row != 0 && indexPath.row % 3 == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellName.InvertedUserTableViewCell, for: indexPath) as! InvertedUserTableViewCell
            if !self.userOnline
            {
                
                var cellData:UserListOffline?
                
                if searchActive && self.filteredOffline.count>indexPath.row
                {
                    cellData = self.filteredOffline[indexPath.row]
                }
                else if self.UserListOffline.count>indexPath.row
                {
                    cellData = self.UserListOffline[indexPath.row]
                }
                cell.lableUserName.text = cellData?.userName ?? kEmptyString
                cell.lableDetail.text = kType + (cellData?.userType ?? kEmptyString)
                
                
                let userNotes = cellData?.userNotes ?? kEmptyString
                let userId = cellData?.userId ?? kEmptyCount
                if userNotes.count>0 || self.notesUserId.contains(userId)
                {
                    cell.imageNotes.isHidden=false
                }
                else
                {
                    cell.imageNotes.isHidden=true
                }
                let imageData = cellData?.userImage ?? Data()
                
                if !imageData.isEmpty
                {
                    cell.imageUser.image = self.dataToImage(data: imageData)
                }
                else{
                    
                    cell.imageUser.image = UIImage(named: "user")
                }
                cell.imageUser.image = cell.imageUser.image?.invertedImage()
                
                if self.isDarkModeOn()
                {
                
                    cell.imageNotes.image = cell.imageNotes.image?.withRenderingMode(.alwaysTemplate)
                    cell.imageNotes.tintColor = UIColor.white
                }
                else
                {
                    cell.imageNotes.image = cell.imageNotes.image?.withRenderingMode(.alwaysTemplate)
                    cell.imageNotes.tintColor = UIColor.black
                }
            }
            else
            {
                var cellData:UserListModel?
                
                if searchActive && self.filteredUserList.count>indexPath.row
                {
                    cellData = self.filteredUserList[indexPath.row]
                }
                else if self.userList.count>indexPath.row
                {
                    cellData = self.userList[indexPath.row]
                }
                
                let userId = cellData?.id ?? kEmptyCount
                
                if self.notesUserId.contains(userId)
                {
                    cell.imageNotes.isHidden=false
                }
                else
                {
                    cell.imageNotes.isHidden=true
                }
                
            
                
                cell.lableUserName.text = cellData?.login ?? kEmptyString
                cell.lableDetail.text = kType + (cellData?.type ?? kEmptyString)
                
                if let strUrl = cellData?.avatar_url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
                   let imgUrl = URL(string: strUrl)
                {
                    
                    cell.imageUser.loadImageWithUrl(imgUrl)
                }
                else{
                    
                    cell.imageUser.image = UIImage(named: "user")
                }
                
                cell.imageUser.image = cell.imageUser.image?.invertedImage()
              
                
            }
            
            cell.imageUser.borderColor = UIColor.clear
            cell.lableUserName.text =  cell.lableUserName.text?.capitalized
            if self.isDarkModeOn()
            {
            
                cell.imageNotes.image = cell.imageNotes.image?.withRenderingMode(.alwaysTemplate)
                cell.imageNotes.tintColor = UIColor.white
            }
            else
            {
                cell.imageNotes.image = cell.imageNotes.image?.withRenderingMode(.alwaysTemplate)
                cell.imageNotes.tintColor = UIColor.black
            }
            return cell
            
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellName.userList, for: indexPath) as! UserTableCell
            if !self.userOnline
            {
                
                var cellData:UserListOffline?
                
                if searchActive && self.filteredOffline.count>indexPath.row
                {
                    cellData = self.filteredOffline[indexPath.row]
                }
                else if self.UserListOffline.count>indexPath.row
                {
                    cellData = self.UserListOffline[indexPath.row]
                }
                cell.lableUserName.text = cellData?.userName ?? kEmptyString
                cell.lableDetail.text = kType + (cellData?.userType ?? kEmptyString)
                let userId = cellData?.userId ?? kEmptyCount
                
                let userNotes = cellData?.userNotes ?? kEmptyString
                if userNotes.count>0 || self.notesUserId.contains(userId)
                {
                    cell.imageNote.isHidden=false
                }
                else
                {
                    cell.imageNote.isHidden=true
                }
                
                let imageData = cellData?.userImage ?? Data()
                
                if !imageData.isEmpty
                {
                    cell.imageUser.image = self.dataToImage(data: imageData)
                }
                else{
                    
                    cell.imageUser.image = UIImage(named: "user")
                }
            }
            else
            {
                var cellData:UserListModel?
                
                if searchActive && self.filteredUserList.count>indexPath.row
                {
                    cellData = self.filteredUserList[indexPath.row]
                }
                else if self.userList.count>indexPath.row
                {
                    cellData = self.userList[indexPath.row]
                }
                cell.lableUserName.text = (cellData?.login ?? kEmptyString)
                cell.lableDetail.text = kType + (cellData?.type ?? kEmptyString)
                let userId = cellData?.id ?? kEmptyCount
                
                if self.notesUserId.contains(userId)
                {
                    cell.imageNote.isHidden=false
                }
                else
                {
                    cell.imageNote.isHidden=true
                }
                
                if let strUrl = cellData?.avatar_url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
                   let imgUrl = URL(string: strUrl)
                {
                    
                    cell.imageUser.loadImageWithUrl(imgUrl) // call this line for getting image to yourImageView
                }
                else{
                    
                    cell.imageUser.image = UIImage(named: "user")
                }
                
            }
            cell.lableUserName.text =  cell.lableUserName.text?.capitalized
            if self.isDarkModeOn()
            {
            
                cell.imageNote.image = cell.imageNote.image?.withRenderingMode(.alwaysTemplate)
                cell.imageNote.tintColor = UIColor.white
            }
            else
            {
                cell.imageNote.image = cell.imageNote.image?.withRenderingMode(.alwaysTemplate)
                cell.imageNote.tintColor = UIColor.black
            }
            
            return cell
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let vc = ProfileVC.instantiate(fromAppStoryboard: .Main)
        
        if !self.userOnline
        {
            
            var cellData:UserListOffline?
            if searchActive && self.filteredOffline.count>indexPath.row
            {
                cellData = self.filteredOffline[indexPath.row]
            }
            else if  self.UserListOffline.count>indexPath.row
            {
                cellData = self.UserListOffline[indexPath.row]
            }
            vc.userName = cellData?.userName ?? kEmptyString
            vc.userDetailOffline = cellData
            vc.userNotes = cellData?.userNotes ?? kEmptyString
        }
        else
        {
            var cellData:UserListModel?
            
            if searchActive && self.filteredUserList.count>indexPath.row
            {
                cellData = self.filteredUserList[indexPath.row]
            }
            else if  self.userList.count>indexPath.row
            {
                cellData = self.userList[indexPath.row]
            }
            vc.userName = cellData?.login ?? kEmptyString
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90 //UITableView.automaticDimension
    }
    
    
}

//MARK:- For Paggination

extension UserListVC
{
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((tableViewUserList.contentOffset.y + tableViewUserList.frame.size.height) >= tableViewUserList.contentSize.height-50)
        {
            self.ShowData(page: self.page)
            
        }
        
        
    }
}
//MARK:- search functionlity and delegate
extension UserListVC:UISearchBarDelegate
{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        
        searchBar.text = nil
        searchBar.resignFirstResponder()
        self.tableViewUserList.resignFirstResponder()
        self.searchText.showsCancelButton = false
        tableViewUserList.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.view.endEditing(true)
        
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        self.searchText.showsCancelButton = true
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if search.count == 0
        {
            self.searchActive = false;
            self.tableViewUserList.reloadData()
        }
        else
        {
            self.searchActive = true;
            self.ToSearchData(searchText: searchText)
        }
        
    }
    func ToSearchData(searchText:String)
    {
        DispatchQueue.main.async {
            
            if !self.userOnline
            {
                self.filteredOffline.removeAll()
                for  user in self.UserListOffline
                {
                    let userName = user.userName ?? kEmptyString
                    let userNotes = user.userNotes ?? kEmptyString
                    
                    if (userName+userNotes).lowercased().contains(searchText.lowercased())
                    {
                        
                        self.filteredOffline.append(user)
                    }
                }
            }
            else
            {
                self.filteredUserList.removeAll()
                for  user in self.userList
                {
                    let userName = user.login ?? kEmptyString
                    
                    if userName.lowercased().contains(searchText.lowercased())
                    {
                        self.filteredUserList.append(user)
                    }
                }
            }
            self.tableViewUserList.reloadData()
            
        }
    }
    
}

