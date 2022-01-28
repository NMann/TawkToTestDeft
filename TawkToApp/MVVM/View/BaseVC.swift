//
//  BaseVC.swift
//  TawkToApp
//
//  Created by ios2 on 25/01/22.
//

import UIKit

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setTitle(title: String, showBack: Bool = true, isLight: Bool = false, titleColor:UIColor? = nil, showGradient: Bool = false) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isHidden = false
   
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        // self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.layoutIfNeeded()
        // self.navigationController?.navigationBar.transparentNavigationBar()
        self.navigationController?.view.backgroundColor = .clear
            let foregroundColor = titleColor == nil ? (isLight ? UIColor.black: UIColor.black) : titleColor!
            self.navigationController?.navigationBar.titleTextAttributes =
                [NSAttributedString.Key.foregroundColor: foregroundColor,
                 NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
       
        if let parent = self.parent, parent.isKind(of: UITabBarController.self) {
            self.parent?.title = title
        }
        else {
            self.title = title
        }
        if showBack {
            self.setBackButton()
        }
        else {
            if self.parent!.isKind(of: UITabBarController.self) {
                self.parent!.navigationItem.leftBarButtonItem = nil
                self.parent!.navigationItem.leftBarButtonItems = nil
                self.parent!.navigationItem.hidesBackButton = true
            }
            else {
                self.navigationItem.leftBarButtonItem = nil
                self.navigationItem.leftBarButtonItems = nil
                self.navigationItem.hidesBackButton = true
            }
        }
    }
    
    //MARK: Back Button
    func setBackButton(image: UIImage =  #imageLiteral(resourceName: "backImage")){
        
        //Button Item
        let backButton = UIButton() //Custom back Button
        backButton.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        backButton.contentHorizontalAlignment = .left
        backButton.setImage(image, for: .normal)
        if self.isDarkModeOn()
        {
        
    
            backButton.setImage(backButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
            backButton.image(for: .normal)?.withTintColor(UIColor.white)
        }
        else
        {
            backButton.setImage(backButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
            backButton.image(for: .normal)?.withTintColor(UIColor.black)
        }
        
        backButton.addTarget(self, action: #selector(self.backButtonAction), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = backButton
        self.navigationItem.leftBarButtonItem = leftBarButton
        if let parent = self.parent, parent.isKind(of: UITabBarController.self) {
            self.parent!.navigationItem.setLeftBarButtonItems([leftBarButton], animated: false)
        }
        else {
            self.navigationItem.setLeftBarButtonItems([leftBarButton], animated: false)
        }
        
        //Touch Button
        let backButtonTouch = UIButton() //Custom back Button
        backButtonTouch.frame = CGRect(x: 0, y: 0, width: 100, height: 64)
        backButtonTouch.backgroundColor = UIColor.clear
        
        backButtonTouch.addTarget(self, action: #selector(self.backButtonAction), for: .touchUpInside)
        self.navigationController?.navigationBar.addSubview(backButtonTouch)
    }

    @objc func backButtonAction() {
        let navObj = self.navigationController?.popViewController(animated: true)
        if navObj == nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    func dataToImage(data: Data) -> UIImage {
        var image: UIImage?
        image = UIImage(data: data)
        return image ?? UIImage()
    }
    
    
    func isDarkModeOn() -> Bool
    {
        if self.traitCollection.userInterfaceStyle == .dark
        {
          return true
        }
        else {
            return false
        }

    }
}
