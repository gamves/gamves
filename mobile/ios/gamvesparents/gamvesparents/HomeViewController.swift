//
//  HomeViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 9/26/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit
import Foundation
import Parse
import NVActivityIndicatorView
import MapKit
import ParseLiveQuery


class HomeViewController: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate, 
    UICollectionViewDelegateFlowLayout {

    var userStatistics = [UserStatistics]()

	var metricsHome = [String:Int]()
    
    var tabBarViewController:TabBarViewController?
    
    private var sonSubscription: Subscription<PFObject>!
    
    let liveQueryClient: Client = ParseLiveQuery.Client(server: Global.localWs) // .remoteWs)
    
    private var approvalSubscription: Subscription<PFObject>!
    
    let liveQueryClientApproval: Client = ParseLiveQuery.Client(server: Global.localWs) // .remoteWs .localWs)

    var youSonChatId = Int()
    var youSpouseChatId = Int()
    var groupChatId = Int()
    
    var approvalViewController: ApprovalViewControlle = {
        let selector = ApprovalViewControlle()
        return selector
    }()
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.backgroundColor = UIColor.white
        return v
    }()
    

    var familyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        //label.backgroundColor = UIColor.white        
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.gray
        return label
    }()

    let photosContainerView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    let homeBackgroundView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.white
        return view
    }()
	
    lazy var sonPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "son_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSonPhotoImageView)))
        imageView.isUserInteractionEnabled = true        
        imageView.tag = 1
        return imageView
    }()   

    var checkLabelSon: UILabel = {
        let label = UILabel()
        return label
    }()

    lazy var spousePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "spouse_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSpousePhotoImageView)))        
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 2           
        return imageView
    }()

    var checkLabelSpouse: UILabel = {
        let label = UILabel()
        return label
    }()

    lazy var groupPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "your_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGroupPhotoImageView)))        
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 0           
        return imageView
    }()

    var checkLabelGroup: UILabel = {
        let label = UILabel()
        return label
    }()

    var sonLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        //label.backgroundColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()   
    

     lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    let footerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.backgroundColor = UIColor.red
        return v
    }()

    lazy var chatViewController: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()

    var activityIndicatorView:NVActivityIndicatorView?
    
    var cellId = String()
    
    var sonOnline = Bool()

    var _status = UserStatistics()
    var _location = UserStatistics()
    var _time = UserStatistics()
    var _approval = UserStatistics()
    var _activity = UserStatistics()
    var _history = UserStatistics()

    var photoCornerRadius = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

         tabBarController?.tabBar.isHidden = false
        
         self.cellId = "homeCellId"

         self.view.backgroundColor = UIColor.gamvesBackgoundColor
         self.collectionView.backgroundColor = UIColor.gamvesBackgoundColor

        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.familyLabel)
        self.scrollView.addSubview(self.photosContainerView)
        self.scrollView.addSubview(self.sonLabel)        
        self.scrollView.addSubview(self.collectionView)       
        self.scrollView.addSubview(self.footerView)

        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.scrollView)
        self.view.addConstraintsWithFormat("V:|[v0]-50-|", views: self.scrollView)
        
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.familyLabel)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.photosContainerView)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.sonLabel)
        self.scrollView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.collectionView)        
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.footerView)        
        
        let width:Int = Int(view.frame.size.width)
        
        let topPadding = 40
        let midPadding =  topPadding / 2
        let smallPadding =  midPadding / 2
        let photoSize = width / 5
        let padding = (width - (photoSize * 3))  / 4
        self.photoCornerRadius = photoSize / 2

        self.metricsHome["topPadding"]      = topPadding
        self.metricsHome["midPadding"]      = midPadding
        self.metricsHome["smallPadding"]    = smallPadding
        self.metricsHome["photoSize"]       = photoSize
        self.metricsHome["padding"]         = padding    

        self.scrollView.addConstraintsWithFormat(
         "V:|-midPadding-[v0(midPadding)]-midPadding-[v1(photoSize)]-50-[v2(midPadding)]-10-[v3(300)][v4(30)]|", views:
         self.familyLabel,
         self.photosContainerView,
         self.sonLabel,
         self.collectionView,        
         self.footerView,
         metrics: metricsHome)

        
        self.checkLabelSon =  Global.createCircularLabel(text: "2", size: 25, fontSize: 18.0, borderWidth: 0.0, color: UIColor.gamvesColor)
        self.checkLabelSpouse =  Global.createCircularLabel(text: "2", size: 25, fontSize: 18.0, borderWidth: 0.0, color: UIColor.gamvesColor)
        self.checkLabelGroup =  Global.createCircularLabel(text: "2", size: 25, fontSize: 18.0, borderWidth: 0.0, color: UIColor.gamvesColor)        

        self.photosContainerView.addSubview(self.sonPhotoImageView)
        self.photosContainerView.addSubview(self.checkLabelSon)

        self.photosContainerView.addSubview(self.spousePhotoImageView)
        self.photosContainerView.addSubview(self.checkLabelSpouse)

        self.photosContainerView.addSubview(self.groupPhotoImageView)
        self.photosContainerView.addSubview(self.checkLabelGroup)
        
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.sonPhotoImageView)
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.spousePhotoImageView)
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.groupPhotoImageView)

        var metricsVerBudge = [String:Int]()

        metricsVerBudge["verPadding"] = photoSize - 25 
        
        self.photosContainerView.addConstraintsWithFormat("V:|-verPadding-[v0(25)]", views: self.checkLabelSon, metrics: metricsVerBudge)    
        self.photosContainerView.addConstraintsWithFormat("V:|-verPadding-[v0(25)]", views: self.checkLabelSpouse, metrics: metricsVerBudge)
        self.photosContainerView.addConstraintsWithFormat("V:|-verPadding-[v0(25)]", views: self.checkLabelGroup, metrics: metricsVerBudge)
        
        self.photosContainerView.addConstraintsWithFormat(
            "H:|-padding-[v0(photoSize)]-padding-[v1(photoSize)]-padding-[v2(photoSize)]-padding-|", views:
            self.sonPhotoImageView,
            self.spousePhotoImageView,
            self.groupPhotoImageView,
            metrics: metricsHome)

        var metricsHorBudge = [String:Int]()

        let paddingBudge = (padding + photoSize) - 25

        metricsHorBudge["sonPadding"]      = paddingBudge 
        metricsHorBudge["spousePadding"]   = (paddingBudge * 2) + 25
        metricsHorBudge["groupPadding"]    = (paddingBudge * 3) + 50

        self.photosContainerView.addConstraintsWithFormat("H:|-sonPadding-[v0(25)]", views: self.checkLabelSon, metrics: metricsHorBudge)
        self.photosContainerView.addConstraintsWithFormat("H:|-spousePadding-[v0(25)]", views: self.checkLabelSpouse, metrics: metricsHorBudge)
        self.photosContainerView.addConstraintsWithFormat("H:|-groupPadding-[v0(25)]", views: self.checkLabelGroup, metrics: metricsHorBudge)
        
        NotificationCenter.default.addObserver(self, selector: #selector(familyLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(chatFeedLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyChatFeed), object: nil)
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)
        
        self.collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
        
        self.activityIndicatorView?.startAnimating()
        
        self.checkLabelSon.isHidden = true
        self.checkLabelSpouse.isHidden = true
        self.checkLabelGroup.isHidden = true
             
        _status.desc = "Offline"
        _status.icon = UIImage(named: "status_offline")!
        _status.id = 0
        self.userStatistics.append(_status)
        
        _location.desc = "Current location"
        _location.data = "5 Km"
        _location.id = 1
        _location.icon = UIImage(named: "map")!
        self.userStatistics.append(_location)

        _time.desc = "Week count"
        _time.data = "04:50 hs"
        _time.id = 2
        _time.icon = UIImage(named: "time")!
        self.userStatistics.append(_time)

        _approval.desc = "Approvals"
        _approval.id = 3
        _approval.icon = UIImage(named: "check_circle")!
        self.userStatistics.append(_approval)        

        _activity.desc = "Activity"
        _activity.id = 4
        _activity.icon = UIImage(named: "view_activity")!
        self.userStatistics.append(_activity)  

        _history.desc = "History"
        _history.id = 5
        _history.icon = UIImage(named: "history")!
        self.userStatistics.append(_history)        

    }
 

     func openMapForPlace() {

        let latitude: CLLocationDegrees = 37.2
        let longitude: CLLocationDegrees = 22.9

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Place Name"
        mapItem.openInMaps(launchOptions: options)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.tabBar.isHidden = false
    }
  
  
    
    func chatFeedLoaded()
    {
        let sonRegisterChatId:Int = Global.gamvesFamily.sonRegisterChatId
        if ChatFeedMethods.chatFeeds[sonRegisterChatId]! != nil
        {
            let sonBadge = ChatFeedMethods.chatFeeds[sonRegisterChatId]?.badgeNumber
            
            if sonBadge! > 0
            {
                self.checkLabelSon.isHidden = false
                
                let sob = "\(sonBadge!)"
                
                self.checkLabelSon.text = sob
            }
            
        }
        
        let spouseRegisterChatId:Int = Global.gamvesFamily.spouseRegisterChatId
        if ChatFeedMethods.chatFeeds[spouseRegisterChatId]! != nil
        {
            let spouseBadge = ChatFeedMethods.chatFeeds[spouseRegisterChatId]?.badgeNumber
            
            if spouseBadge! > 0
            {
                self.checkLabelSpouse.isHidden = false
                
                let spb = "\(spouseBadge!)"
               
                self.checkLabelSpouse.text = spb
            }
        }
        
        let groupChatId:Int = Global.gamvesFamily.familyChatId
        if ChatFeedMethods.chatFeeds[groupChatId]! != nil
        {
            let groupBadge = ChatFeedMethods.chatFeeds[groupChatId]?.badgeNumber       
            
            if groupBadge! > 0
            {
                self.checkLabelGroup.isHidden = false
                
                let grb = "\(groupBadge!)"
                
                self.checkLabelGroup.text = grb
            }
            
        }
        
        //self.familyLoaded()
    }
    
    func familyLoaded()
    {
        
        let familyId = Global.gamvesFamily.objectId
        
        Global.getApprovasByFamilyId(familyId: familyId, completionHandler: { ( count ) -> () in
            
            print(count)
            
            self._approval.approval = count as Int
            self.collectionView.reloadData()
            
        })
        
        self.familyLabel.text = Global.gamvesFamily.familyName

        if self.isKeyPresentInUserDefaults(key:"son_object_id")
        {
            let sonId = Global.defaults.object(forKey: "son_object_id") as! String
            if Global.userDictionary[sonId] != nil
            {
                self.sonLabel.text = Global.userDictionary[sonId]?.firstName
                self.sonPhotoImageView.image = Global.userDictionary[sonId]?.avatar
                Global.setRoundedImage(image: self.sonPhotoImageView, cornerRadius: self.photoCornerRadius, boderWidth: 2, boderColor: UIColor.gamvesColor)
            }
        }
        
        if self.isKeyPresentInUserDefaults(key:"spouse_object_id")
        {
            
            let spouseId = Global.defaults.object(forKey: "spouse_object_id") as! String
            if Global.userDictionary[spouseId] != nil
            {
                self.spousePhotoImageView.image = Global.userDictionary[spouseId]?.avatar
                Global.setRoundedImage(image: self.spousePhotoImageView, cornerRadius: self.photoCornerRadius, boderWidth: 2, boderColor: UIColor.gamvesColor)
            }
        }
        
        self.groupPhotoImageView.image = Global.gamvesFamily.familyImage //self.generateGroupImage() 
        Global.setRoundedImage(image: self.groupPhotoImageView, cornerRadius: self.photoCornerRadius, boderWidth: 2, boderColor: UIColor.gamvesColor)
        
        self.activityIndicatorView?.stopAnimating()
        
        self.initializeOnlineSubcritpion()
        
    }
    
   
    func isKeyPresentInUserDefaults(key: String) -> Bool
    {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    
    func generateGroupImage() -> UIImage
    {
        let LeftImage = self.sonPhotoImageView.image // 355 X 200
        let RightImage = self.spousePhotoImageView.image  // 355 X 60
        
        let size = CGSize(width: LeftImage!.size.width, height: LeftImage!.size.height)
        
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        LeftImage?.draw(in: CGRect(x: 0, y: 0, width:size.width, height: size.height))
        RightImage?.draw(in: CGRect(x: size.width/2, y: 0, width:size.width, height: size.height))
        
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }

    func handleSonPhotoImageView(sender: UITapGestureRecognizer)
    {
        
        let sonRegisterChatId:Int = Global.gamvesFamily.sonRegisterChatId
    
        if ChatFeedMethods.chatFeeds[sonRegisterChatId]! != nil
        {
            let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[sonRegisterChatId]!
            
            var users = [GamvesParseUser]()
            users.append(Global.gamvesFamily.sonsUsers[0])
            users.append(Global.gamvesFamily.youUser)

            self.chatViewController.chatId = sonRegisterChatId
            self.chatViewController.gamvesUsers = users
            self.chatViewController.room = chatfeed.room!            
            self.chatViewController.view.backgroundColor = UIColor.white
           
            navigationController?.pushViewController(self.chatViewController, animated: true)
    
        }
        
    }

    func handleSpousePhotoImageView(sender: UITapGestureRecognizer)
    {
        
        let spouseRegisterChatId:Int = Global.gamvesFamily.spouseRegisterChatId
        
        if ChatFeedMethods.chatFeeds[spouseRegisterChatId]! != nil
        {
            let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[spouseRegisterChatId]!
            
            var users = [GamvesParseUser]()
            users.append(Global.gamvesFamily.spouseUser)
            users.append(Global.gamvesFamily.youUser)
            
            self.chatViewController.chatId = spouseRegisterChatId
            self.chatViewController.gamvesUsers = users
            self.chatViewController.room = chatfeed.room!
            //self.chatViewController.isStandAlone = true
            self.chatViewController.view.backgroundColor = UIColor.white
            
            navigationController?.pushViewController(self.chatViewController, animated: true)
            
        }
    	
    }

    func handleGroupPhotoImageView(sender: UITapGestureRecognizer)
    {
        let familyChatId:Int = Global.gamvesFamily.familyChatId
        
        if ChatFeedMethods.chatFeeds[familyChatId]! != nil
        {
            let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[familyChatId]!
            
            var users = [GamvesParseUser]()
            users.append(Global.gamvesFamily.sonsUsers[0])
            users.append(Global.gamvesFamily.spouseUser)
            users.append(Global.gamvesFamily.youUser)
            
            self.chatViewController.chatId = familyChatId
            self.chatViewController.gamvesUsers = users
            self.chatViewController.room = chatfeed.room!
            //self.chatViewController.isStandAlone = true
            self.chatViewController.view.backgroundColor = UIColor.white
            
            navigationController?.pushViewController(self.chatViewController, animated: true)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    ////collectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userStatistics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeCollectionViewCell
        

        let id = indexPath.row
        
        var stats = self.userStatistics[id]
        
        cell.descLabel.text = stats.desc
        
        cell.dataLabel.text = stats.data
        
        print(stats.desc)
        print(stats.approval)
        
        if id == 0
        {
            if self.sonOnline
            {
                stats.icon = UIImage(named: "status_online")!
                cell.descLabel.text = "Online"
            } else
            {
                stats.icon = UIImage(named: "status_offline")!
                cell.descLabel.text = "Offline"
            }
            
            cell.dataLabel.isHidden = true
            
        }
        
        if stats.approval > 0 {
            
            stats.icon = UIImage(named: "check_circle_white")!
            
            cell.descLabel.textColor = UIColor.white
            cell.dataLabel.textColor = UIColor.white
            
            cell.dataLabel.text = String(stats.approval)
        
            cell.backgroundColor = UIColor.gamvesColor
            cell.layer.cornerRadius = 10
            
        }
        
        /*else {
            
            stats.icon = UIImage(named: "check_circle")!
            
            cell.descLabel.textColor = UIColor.darkGray
            cell.dataLabel.textColor = UIColor.lightGray
            
            cell.backgroundColor = UIColor.gamvesBackgoundColor
            cell.layer.cornerRadius = 0
            
        }*/
   
        cell.iconImageView.image = stats.icon
        
        if id > 0
        {
            cell.iconImageView.alpha = 0.4
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {    
        
        if indexPath.row == 0 {
            
        } else if indexPath.row == 1 {
            
        
        } else if indexPath.row == 2 {
            
            
        } else if indexPath.row == 3 {
        
            approvalViewController.homeViewController = self
            approvalViewController.view.backgroundColor = UIColor.white
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            navigationController?.pushViewController(approvalViewController, animated: true)
            tabBarController?.tabBar.isHidden = true
            
        }      
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let userStatistic = userStatistics[indexPath.row]

        /*if let description = userStatistic.description {
            
            let size = CGSize(width:250, height:1000)
            
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            return CGSize(width:self.frame.width, height:estimatedFrame.height + 20)
        }*/
        
        return CGSize(width:self.collectionView.frame.width, height:50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 0, 0)
    }
   
    
    func initializeOnlineSubcritpion()
    {
        let sonId = Global.defaults.object(forKey: "son_object_id") as! String
        if Global.userDictionary[sonId] != nil
        {
            let userId = Global.userDictionary[sonId]?.userId
            
            let onlineQuery = PFQuery(className: "UserOnline").whereKey("userId", equalTo: userId)
            
            self.sonSubscription = liveQueryClient.subscribe(onlineQuery).handle(Event.updated) { _, onlineMessage in
                
                self.changeSingleUserStatus(onlineMessage:onlineMessage)
                
            }
            
            let queryOnine = PFQuery(className:"UserOnline")
            queryOnine.whereKey("userId", equalTo: userId)
            queryOnine.findObjectsInBackground { (usersOnline, error) in
                
                if error != nil
                {
                    print("error")
                    
                } else {
                    
                    if (usersOnline?.count)!>0
                    {
                        for monline in usersOnline!
                        {
                            self.changeSingleUserStatus(onlineMessage:monline)
                        }
                    }
                }
            }
        }
        
        if Global.gamvesFamily != nil
        {
            
            let familyId = Global.gamvesFamily.objectId
            
            var approvalQuery = PFQuery(className: "Approvals").whereKey("familyId", equalTo: familyId)
            
            self.approvalSubscription = liveQueryClientApproval.subscribe(approvalQuery).handle(Event.updated) { _, approvals in
                
                Global.getApprovasByFamilyId(familyId: familyId, completionHandler: { ( count ) -> () in
                    
                        self._approval.approval = count as Int
                        
                })
                
                
            }
            
        }

        
    }
    
    func changeSingleUserStatus(onlineMessage:PFObject)
    {
        let isOnline = onlineMessage["isOnline"] as! Bool
        
        if isOnline
        {
            self.sonOnline = true
        } else
        {
            self.sonOnline = false
        }
        
        //self.collectionView.reloadData()
        
    }

    
}
