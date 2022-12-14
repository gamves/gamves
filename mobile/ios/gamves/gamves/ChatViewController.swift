//
//  ChatViewController.swift
//  gamves
//
//  Created by Jose Vigil on 10/13/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ChatViewController: UIViewController, NavBarDelegate, KeyboardDelegate {
    
    var chatView:ChatView!
    var chatId = Int()
    
    let avatar:UIImageView! = nil
    
    var homeController: HomeController?
    
    var gamvesUsers = [GamvesUser]()
    
    var params = [String: Any]()

    var loaded = Bool()
    
    var buttonAvatar: UIButton!
    
    var room = String()
    
    var delegateFeed:FeedDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageUser:UIImage!
        
        if gamvesUsers.count > 2 {
            
            imageUser = UIImage(named: "community")
        } else {
            
            imageUser = gamvesUsers[0].avatar
        }
    
        print(gamvesUsers[0].name)
        
        let buttonArrowBack: UIButton = UIButton (type: UIButtonType.custom)
        buttonArrowBack.setImage(UIImage(named: "arrow_back_white"), for: UIControlState.normal)
        buttonArrowBack.frame = CGRect(x:0, y:0, width:40, height:40)
        buttonArrowBack.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
        
        buttonAvatar = UIButton (type: UIButtonType.custom)
        
        buttonAvatar.setImage(imageUser, for: UIControlState.normal)
        buttonAvatar.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
        
        buttonAvatar.frame = CGRect(x:0, y:0, width:40, height:40)
        buttonAvatar.layer.cornerRadius = 20
        buttonAvatar.clipsToBounds = true
        
        if #available(iOS 9.0, *) {
            buttonAvatar.widthAnchor.constraint(equalToConstant: 40).isActive = true
            buttonAvatar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        let avatarButton = UIBarButtonItem(customView: buttonAvatar)
        let arrowButton = UIBarButtonItem(customView: buttonArrowBack)
        
        let negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15
        
        self.navigationItem.leftBarButtonItems = [negativeSpacer, arrowButton, avatarButton]
        
        var widthLeft = CGFloat()
        widthLeft = self.view.frame.width - (arrowButton.width + avatarButton.width)
        
        
    }
    
    @objc func backButtonPressed(sender: UIBarButtonItem)
    {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyReloadPageFanpage), object: self)

        if self.delegateFeed != nil {
            self.delegateFeed.uploadData()
        }
        
        //self.navigationController?.popViewController(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if loaded
        {
            self.loadChatView()
            
            let imageUser:UIImage!

            if gamvesUsers.count>2
            {
                imageUser = UIImage(named: "community")
            } else
            {
                imageUser = gamvesUsers[0].avatar
            }
            
            self.buttonAvatar.setImage(imageUser, for: UIControlState.normal)
        }
    
    }
    
    override func viewDidLayoutSubviews()
    {
        if !loaded
        {
            self.loadChatView()
            loaded = true
        }

    }
    
    func loadChatView()
    {
        var subtitle = "                "
        
        var userArray =  [String]()
        
        if self.gamvesUsers.count > 1
        {
            let subTitle = String()
            for guser in self.gamvesUsers
            {
                //subtitle = "\(subtitle) \(guser.name),"
                userArray.append(guser.firstName)
            }
            
            subtitle = userArray.description
            subtitle = subtitle.replacingOccurrences(of: "[", with: "")
            subtitle = subtitle.replacingOccurrences(of: "]", with: "")
            subtitle = subtitle.replacingOccurrences(of: "\"", with: "")
        }
        
        self.navigationItem.titleView = Global.setTitle(title: self.room, subtitle: subtitle)
        
        let chatFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        chatView = ChatView(parent: ChatViewType.ChatViewController, frame: chatFrame, isVideo: false)  
        
        params = ["chatId": chatId, "isVideoChat": false, "gamvesUsers": gamvesUsers, "navBarProtocol": self, "delegate": self] as [String : Any]
        
        chatView.setParams(parameters: params)
        
        UIView.transition(with: self.view, duration: 0.5, options: UIViewAnimationOptions.showHideTransitionViews, animations: {
        
            self.view.addSubview(self.chatView)

        }, completion: { (finished: Bool) -> () in
            
            if finished {
                self.chatView.loadChatFeed()
            }
            
        })

       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func updateTitle(latelText:String)
    {
        
    }
    
    func updateSubTitle(latelText:String)
    {
        print(latelText)
        let subTitleLabel = self.navigationItem.titleView?.subviews[1] as! UILabel
        subTitleLabel.text = latelText
    
    }
    
    func keyboardOpened(keybordHeight keybordEditHeight: CGFloat) {
        
        if Global.device.lowercased().range(of:"ipad") != nil {
        
            let diffHeight = keybordEditHeight + self.chatView.messageContainerView.frame.height + (self.navigationController?.navigationBar.frame.height)!
            
            let collectionHeight = self.view.frame.height - diffHeight
            
            
            if self.chatView.collectionView.contentSize.height >= collectionHeight/2   {
                
                self.setChatMinY(keybordHeight: keybordEditHeight)
                
            } else {
            
                let chatHeight = self.view.frame.height - keybordEditHeight
                self.chatView.frame.size.height = chatHeight                
                
            }
           
        
        } else if Global.device.lowercased().range(of:"ipod") != nil {
            
        
            self.setChatMinY(keybordHeight: keybordEditHeight)
            
        }
        
        self.chatView.animateKeyboard()
        
    }
    
    func setChatMinY(keybordHeight keybordEditHeight: CGFloat) {
        
        let chatY = self.chatView.bounds.minY - keybordEditHeight
        
        let chatViewRect = CGRect(x: 0, y: chatY, width:  self.chatView.frame.width, height: self.chatView.frame.height)
        
        self.chatView.frame = chatViewRect
        
    }
    
    func setChatYBack() {
        
        let chatY = self.view.bounds.minY
        
        let chatViewRect = CGRect(x: 0, y: chatY, width:  self.chatView.frame.width, height: self.chatView.frame.height)
        
        self.chatView.frame = chatViewRect
        
    }
    
    func keyboardclosed() {
        
        if Global.device.lowercased().range(of:"ipad") != nil {
       
            self.setChatYBack()
            
        } else if Global.device.lowercased().range(of:"ipod") != nil {
            
            self.setChatYBack()
        }
        
        self.chatView.frame.size.height = self.view.frame.height
        
        self.chatView.animateKeyboard()
    }

}


