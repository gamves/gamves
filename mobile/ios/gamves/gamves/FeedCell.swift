

//
//  FeedCell.swift
//  youtube
//
//  Created by Brian Voong on 7/3/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery
import Floaty
import NVActivityIndicatorView
import PopupDialog

class FeedCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FeedDelegate {
    
    var activityView: NVActivityIndicatorView!
    
    var homeController: HomeController?    
    
    let liveQueryClientFeed: Client = ParseLiveQuery.Client(server: Global.remoteWs) // .localWs)
  
    private var subscription: Subscription<PFObject>!
    
    var queryChatFeed:PFQuery<PFObject>!
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let cellId = "cellId"
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .brown
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.delegateFeed = self
    
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        
        self.activityView = Global.setActivityIndicator(container: self, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)
        
        self.collectionView.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        self.registerLiveQuery()
        
        //Floaty.global.rtlMode = true
        
        let floaty = Floaty()
        floaty.addItem(title: "New Group", handler: { item in

            if self.homeController != nil
            {
                self.homeController?.selectContact(group: true)
            }
            
        })
        
        floaty.addItem(title: "Select Contact", handler: { item in
            
            if self.homeController != nil
            {
                self.homeController?.selectContact(group: false)
            }
        })
        self.addSubview(floaty)
        
        print(Global.chatVideos)
        
    }
    
    
    func registerLiveQuery()
    {
    
        queryChatFeed = PFQuery(className: "ChatFeed")
        
        if let userId = PFUser.current()?.objectId
        {
            queryChatFeed.whereKey("members", contains: userId)
        }
        
        self.subscription = liveQueryClientFeed.subscribe(queryChatFeed).handle(Event.created) { _, chatFeed in
            
            ChatFeedMethods.parseChatFeed(chatFeedObjs: [chatFeed], completionHandler: { ( restul:Int ) -> () in
                
                self.collectionView.reloadData()
                
            })           
        }
        
        self.subscription = liveQueryClientFeed.subscribe(queryChatFeed).handle(Event.updated) { _, chatFeed in
            
            ChatFeedMethods.parseChatFeed(chatFeedObjs: [chatFeed], completionHandler: { ( restul:Int ) -> () in
                
                self.collectionView.reloadData()
                
            })

        }
        
        //self.fetchFeed()
        
        self.collectionView.reloadData()
        
    }

    func fetchFeed()
    {
    
        self.activityView.startAnimating()
        
        queryChatFeed.findObjectsInBackground(block: { (chatfeeds, error) in
            
            if error == nil
            {
                
                let chatFeddsCount = chatfeeds?.count
                
                if chatFeddsCount! > 0
                {
                    let chatfeedsCount =  chatfeeds?.count
                    
                    ChatFeedMethods.parseChatFeed(chatFeedObjs: chatfeeds!, completionHandler: { ( restul:Int ) -> () in
                        
                        self.collectionView.reloadData()
                        self.activityView.stopAnimating()
                        
                    })
                    
                } else
                {
                    self.activityView.stopAnimating()
                }
                
            }
        })
    
    }
    
    
    func uploadData()
    {
        self.reloadCollectionView()
    }
    
    func reloadCollectionView()
    {
        ChatFeedMethods.sortFeedByDate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.collectionView.reloadData()
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        print(ChatFeedMethods.chatFeeds.count)
        return ChatFeedMethods.chatFeeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        let index = indexPath.item
        let key: Int = Array(ChatFeedMethods.chatFeeds)[index].key
        let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[key]!
        
        cell.nameLabel.text = chatfeed.room

        var message:String = chatfeed.text!

        let admin_delimitator = Global.admin_delimitator

        if message.range(of:admin_delimitator) != nil {
            if let range = message.range(of: admin_delimitator) {
            
                message.removeSubrange(range)
                
                if (message.contains("____"))
                {
                    let messageArr : [String] = message.components(separatedBy: "____")
                    
                    var audioId : String = messageArr[0]
                    var audioTime : String = messageArr[1]
                    
                    let attachment = NSTextAttachment()
                    attachment.image = UIImage(named: "rec_on")
                    let attachmentString = NSAttributedString(attachment: attachment)
                    let myString = NSMutableAttributedString(string: audioTime)
                    myString.append(attachmentString)
                    cell.messageLabel.attributedText = myString

                }
            }
        
        } else {
            
            cell.messageLabel.text = message
        }
        
        
        let audio_delimitator = Global.audio_delimitator
        
        if message.range(of:audio_delimitator) != nil {
        
            if let range = message.range(of: audio_delimitator) {
    
                //HERE SHOW AUDIO MESSAGE
                
            }
            
        }
        
        cell.profileImageView.image = chatfeed.chatThumbnail
        
        if chatfeed.lasPoster != nil
        {
            let userId = chatfeed.lasPoster!
            
            let gamvesUser = Global.userDictionary[userId]

            cell.hasReadImageView.image = gamvesUser?.avatar
        }
        
        var image = String()
        
        if (chatfeed.isVideoChat)!
        {
            image = "movie"
        } else
        {
            image = "group"
        }
        
        let imagetype = UIImage(named: image)
        cell.isImageView.image = imagetype
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let elapsedTimeInSeconds = Date().timeIntervalSince(chatfeed.date!)
        
        let secondInDays: TimeInterval = 60 * 60 * 24
        
        if elapsedTimeInSeconds > 7 * secondInDays {
            dateFormatter.dateFormat = "MM/dd/yy"
        } else if elapsedTimeInSeconds > secondInDays {
            dateFormatter.dateFormat = "EEE"
        }
        
        if chatfeed.badgeNumber != nil
        {
            if chatfeed.badgeNumber! > 0
            {
                let number = chatfeed.badgeNumber

                cell.badgeLabel.isHidden = false
                
                if let textNumber = number
                {
                    cell.badgeLabel.text = String (textNumber)
                }
            
            } else
            {
                cell.badgeLabel.text = ""
                //cell.badgeLabel.layer.backgroundColor = UIColor.gamvesLightGrayColor.cgColor
                cell.badgeLabel.isHidden = true
            }
        } else
        {
            cell.badgeLabel.isHidden = true
        }
        
        cell.timeLabel.text = dateFormatter.string(from: chatfeed.date!)
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: self.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let layout = UICollectionViewFlowLayout()
        
        let index = indexPath.item
        let key: Int = Array(ChatFeedMethods.chatFeeds)[index].key
        let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[key]!
    
        print(chatfeed.chatId)
        
        let isVideoChat:Bool = chatfeed.isVideoChat! as Bool
        
        if isVideoChat
        {
            
            let chatId = chatfeed.chatId! as Int
            print(chatId)
            var video = VideoGamves()
                
            video = Global.chatVideos[chatId]!
            
            print(video.ytb_videoId)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)
            
            let videoLauncher = VideoLauncher()
            videoLauncher.showVideoPlayer(videoGamves: video)
            
        } else
        {
            if self.homeController != nil
            {
                self.homeController?.openChat(room: chatfeed.room!, chatId: chatfeed.chatId!, users: chatfeed.users!)
            }
            
        }
        
    }
}


















