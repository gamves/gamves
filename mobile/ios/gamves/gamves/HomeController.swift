///
//  ViewController.swift
//  youtube
//
//  Created by Jose Vigil on 12/12/17.
//

import UIKit
import Parse
import PopupDialog

class HomeController: UICollectionViewController, 
UICollectionViewDelegateFlowLayout, 
CLLocationManagerDelegate {

    //-  UI & COMPONENTS    

    //- Controllers

    lazy var chatViewController: ChatViewController = {
        let launcher = ChatViewController()
        launcher.homeController = self
        return launcher
    }()        

    lazy var newGroupNameViewController: NewGroupNameViewController = {
        let groupName = NewGroupNameViewController()
        groupName.homeController = self
        return groupName
    }()

    lazy var selectContactViewController: SelectContactViewController = {
        let selector = SelectContactViewController()
        selector.homeController = self
        return selector
    }()

    lazy var friendNewController: FriendNewController = {
        let newFriend = FriendNewController()
        newFriend.homeController = self
        return newFriend
    }()    

    lazy var newVideoController: NewVideoController = {
        let newvideo = NewVideoController()
        newvideo.homeController = self
        return newvideo
    }()
    
    lazy var newFanpageController: NewFanpageController = {
        let newFanpage = NewFanpageController()
        newFanpage.homeController = self
        return newFanpage
    }()

    lazy var friendsViewController: FriendsViewController = {
        let friendsController = FriendsViewController()
        friendsController.homeController = self
        return friendsController
    }()

    lazy var friendApprovalViewController: FriendApprovalViewController = {
        let friendsApproval = FriendApprovalViewController()
        friendsApproval.homeController = self
        return friendsApproval
    }()

    lazy var giftViewController: GiftViewController = {
        let giftController = GiftViewController()
        giftController.homeController = self
        return giftController
    }()

    lazy var welcomeViewController: WelcomeViewController = {
        let welcomeController = WelcomeViewController()
        welcomeController.homeController = self
        return welcomeController
    }()

    //- Launchers

    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.homeController = self
        return launcher
    }()    

    lazy var puplicProfileLauncher: PublicProfileLauncher = {
        let launcher = PublicProfileLauncher()
        launcher.homeController = self
        return launcher
    }()

    lazy var bugListViewController: BugListViewController = {
        let bugList = BugListViewController()
        return bugList
    }()
    
    lazy var bugViewController: BugViewController = {
        let bug = BugViewController()
        return bug
    }()

    lazy var petSelectorViewController: PetSelectorViewController = {
        let petSelector = PetSelectorViewController()
        return petSelector
    }()
  
    //- MenuBar

    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.homeController = self
        return mb
    }()


    //- VARIABLES & OBJCETS    
    
    var popup:PopupDialog! = nil
    
    let homeCellId          = "homeCellId"
    let feedCellId          = "feedCellId"
    let notificationCellId  = "notificationCellId"
    let profileCellId       = "profileCellId"   
    
    let titles = ["Home", "Activity", "Notifications", "Profile"]
    
    var cellFree:FeedCell!
    var cellHome:HomeCell!
    var notificationCell:NotificationCell!
    //var profileHome:ProfileCell!
    
    var locationManager : CLLocationManager = CLLocationManager()
    
    var didFindLocation = Bool()  

    var pet:GamvesPet!
    var userPets:PFObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.green

        navigationController?.navigationBar.isTranslucent = false
        
        locationManager.delegate = self      
        locationManager.requestAlwaysAuthorization()                
        //locationManager.requestWhenInUseAuthorization()       
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest 
            locationManager.startUpdatingLocation()
            didFindLocation = false
        }
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        titleLabel.text = "  Home"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = titleLabel
        
        self.setupCollectionView()
        self.setupMenuBar()
        self.setupNavBarButtons()
       
        NotificationCenter.default.addObserver(self, selector: #selector(openChatFromUser), name: NSNotification.Name(rawValue: Global.notificationOpenChatFromUser), object: nil)        

        NotificationCenter.default.addObserver(self, selector: #selector(familyLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: nil)     

        NotificationCenter.default.addObserver(self, selector: #selector(showProfileController), name: NSNotification.Name(rawValue: Global.notificationKeyShowProfile), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loggedOut), name: NSNotification.Name(rawValue: Global.notificationKeyLogOut), object: nil)   

        ///Global.appGroupDefaults.addObserver(self, forKeyPath: "extensionUrl", options: .new, context: nil)
        //Global.appGroupDefaults.set(value: arrayDataToPasstoTodayExtension, forKey: "arrayDatatoDisplayInToday")

        self.getPets(completionHandler: { ( resutl ) -> () in
            
            if resutl {

                self.getUserPets()
            }

        })     
        
        
    }

    
    /*override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
            if keyPath == Global.groupShare {
                //gatherReceivedNotifications()
                print(change)
            }
        
    }*/
    
    @objc private func loggedOut() {
        
        self.showLoginController(registered: true)
    }
    
    func showLoginController(registered: Bool) {
        
        UserDefaults.standard.setIsRegistered(value: registered)
        
        let loginController = LoginController()
        
        //loginController.isRegistered = registered
        //loginController.tabBarViewController = self
        
        //self.tutorialController.dismiss(animated: true)
        
        present(loginController, animated: true, completion: {
            //perhaps we'll do something here later
            //self.blurVisualEffectView?.removeFromSuperview()
        })
        
    }

    @objc func familyLoaded() {

      if let userId = PFUser.current()?.objectId {            

            let profileUser = Global.userDictionary[userId] as! GamvesUser               

            Global.setProfileUser(user: profileUser)
        }
    }
    
   
    @objc func openChatFromUser(_ notification: NSNotification) {

        if let user = notification.userInfo?["gamvesUser"] as? GamvesUser {    

            if let chatId = notification.userInfo?["chatId"] as? Int {
            
                self.openChat(room: user.name, chatId: chatId, users: [user])
            }
        }        
    }

    
    func setupCollectionView() {
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(HomeCell.self, forCellWithReuseIdentifier: homeCellId)
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: feedCellId)
        collectionView?.register(NotificationCell.self, forCellWithReuseIdentifier: notificationCellId)
        collectionView?.register(ProfileCell.self, forCellWithReuseIdentifier: profileCellId)
    
        collectionView?.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)
        
        collectionView?.isPagingEnabled = true       
       
    }
    
    func setupNavBarButtons() {        
 
        var dogImage = UIImage(named: "dog")?.withRenderingMode(.alwaysOriginal)
      
        let dogButtonItem = UIBarButtonItem(image: dogImage, style: .plain, target: self, action: #selector(handlePet))

        let searchImage = UIImage(named: "search_icon")?.withRenderingMode(.alwaysOriginal)

        let searchBarButtonItem = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(handleSearch))
        
        let moreButton = UIBarButtonItem(image: UIImage(named: "nav_more_icon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMore))
        
        navigationItem.rightBarButtonItems = [moreButton, searchBarButtonItem, dogButtonItem]
    }
    
    
    @objc func handleMore() {
        //show menu
        settingsLauncher.showSettings()
    }
    
    func showControllerForSetting(_ setting: Setting) {
        let dummySettingsViewController = UIViewController()
        dummySettingsViewController.view.backgroundColor = UIColor.white
        dummySettingsViewController.navigationItem.title = setting.name.rawValue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }

    func openSearch(params:[String : Any]) {
        let media = MediaController()
        media.delegate = params["targer"] as! MediaDelegate
        media.isImageMultiSelection = params["isImageMultiSelection"] as! Bool
        media.setType(type: params["type"] as! MediaType)
        media.termToSearch = params["termToSearch"] as! String
        media.searchType = params["searchType"] as! SearchType
        media.searchSize = params["searchSize"] as! SearchSize
        navigationController?.pushViewController(media, animated: true)
    } 

    @objc func showProfileController(_ notification: NSNotification) {
        
        if let user = notification.userInfo?["gamvesUser"] as? GamvesUser {  

            self.puplicProfileLauncher.showProfileView(gamvesUser: user)
        }         
    }


    func getHomeCell() -> HomeCell 
    {
        let identifier: String       
        identifier = homeCellId
        
        let indexPath = IndexPath(item: 0, section: 0)
        
        let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        cellHome = cell as! HomeCell
        
        return cellHome
    }
    
    @objc func handleSearch() {
        scrollToMenuIndex(2)
    }

    @objc func handlePet() {                 

        if self.pet == nil {

            self.showPetController()

        } else {

            let petLauncher = PetLauncher()            
            petLauncher.showPet(petGamves: self.pet)

        }
        
    }

    func showPetController() {

        petSelectorViewController.homeController = self         
        petSelectorViewController.view.backgroundColor = UIColor.gamvesPetBackgroundColor        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(petSelectorViewController, animated: true)

    }
    
    func scrollToMenuIndex(_ menuIndex: Int) {
    
        print(menuIndex)
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
        setTitleForIndex(menuIndex)
        self.reloadFeed(index: menuIndex)
    }
    
    func switchToMenuIndex(index: Int) {

        self.scrollToMenuIndex(index)

        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        
        self.setTitleForIndex(Int(index))
       self.reloadFeed(index: Int(index))
    }

    fileprivate func setTitleForIndex(_ index: Int) {
        if let titleLabel = navigationItem.titleView as? UILabel {
            titleLabel.text = "  \(titles[index])"
        }


    }  
   
    
    fileprivate func setupMenuBar() {        
       
        view.addSubview(menuBar)
        view.addConstraintsWithFormat("H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormat("V:[v0(50)]", views: menuBar)
        
        menuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 4
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = targetContentOffset.pointee.x / view.frame.width
        
        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        
        self.setTitleForIndex(Int(index))
        self.reloadFeed(index: Int(index))
    }
    
    func reloadFeed(index : Int) {
        if cellFree != nil && index == 1 {
            cellFree.reloadCollectionView()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier: String
        if indexPath.item == 0
        {
            identifier = homeCellId
        } else if indexPath.item == 1
        {
            identifier = feedCellId
        } else if indexPath.item == 2
        {
            identifier = notificationCellId
        } else
        {
            identifier = profileCellId
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if indexPath.item == 0 {
            
            cellHome = cell as! HomeCell
            cellHome.homeController = self
            cellHome.setFanpageHomeController(homeController: self)
            
        } else if indexPath.item == 1 {
            
            cellFree = cell as! FeedCell
            cellFree.homeController = self
            
        }  else if indexPath.item == 2 {
            
            notificationCell = cell as! NotificationCell
            notificationCell.homeController = self
            
        } else if indexPath.item == 3 {
            
            let profileHome = cell as! ProfileCell
            //profileHome.profileSaveType = ProfileSaveType.profile
            profileHome.homeController = self            
            profileHome.setProfileType(type: ProfileSaveType.profile)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 50)
    }
    
    func openChat(room: String, chatId:Int, users:[GamvesUser]) {
        
        self.chatViewController.modalPresentationStyle = .overCurrentContext
        self.chatViewController.chatId = chatId
        self.chatViewController.gamvesUsers = users
        self.chatViewController.delegateFeed = cellFree
        self.chatViewController.room = room
        chatViewController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(self.chatViewController, animated: true)
    }    
    
    func selectContact(group: Bool) {
        selectContactViewController.isGroup = group
        selectContactViewController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(selectContactViewController, animated: true)
    }  

    func addFriend() {        
        friendNewController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(friendNewController, animated: true)
    }  
    
    
    func addNewVideo() {        
        newVideoController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(newVideoController, animated: true)
    }

    func showFriends() {        
        friendsViewController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(friendsViewController, animated: true)
    }  

     func showFriendApproval() {        
        friendApprovalViewController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(friendApprovalViewController, animated: true)
    }   

    func showBugList() {
    
        bugListViewController.homeController = self
        bugListViewController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(bugListViewController, animated: true)
    }
    
    func showBugViewControllerForSetting(_ setting: Setting?, image: UIImage?, bug:GamvesBug?) {
        
        
        bugViewController.homeController = self
        
        if bug != nil {
            
            bugViewController.pictureImageView.image = bug?.screenshot
            bugViewController.navigationItem.title = bug?.title
            
            bugViewController.titleTextField.text = bug?.title
            bugViewController.descTextView.text = bug?.description

            bugViewController.isEdit = true
            
        } else  {
            
            bugViewController.pictureImageView.image = image
            bugViewController.navigationItem.title = setting!.name.rawValue

            bugViewController.isEdit = false
        }
        
        bugViewController.view.backgroundColor = UIColor.gamvesColor        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(bugViewController, animated: true)
    }
    
    func addNewFanpage(edit:Bool) {
        if edit {
            newFanpageController.isEdit = true
        } else {
            newFanpageController.isEdit = false
        }
        newFanpageController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(newFanpageController, animated: true)
        
    }

    func showGiftViewcontroller() {               
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(giftViewController, animated: true)
    }

     func showWelcomeViewcontroller() {               
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(welcomeViewController, animated: true)
    }    

    func clearNewFanpage() {
        self.newFanpageController = NewFanpageController()
        newFanpageController.homeController = self
    }
    
    func clearNewVideo() {
        self.newVideoController = NewVideoController()
        newVideoController.homeController = self
    }
    
    func selectGroupName(users: [GamvesUser]) {
        self.newGroupNameViewController.view.backgroundColor = UIColor.white
        self.newGroupNameViewController.gamvesUsers = users
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        self.navigationController?.pushViewController(newGroupNameViewController, animated: true)
    }

    /*func showAXPhotoViewer(photosViewController:AXPhotosViewController) {
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.white] as [NSAttributedStringKey : Any]
        navigationController?.pushViewController(photosViewController, animated: true)
    }*/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first
        {
            if !didFindLocation
            {
                didFindLocation = true
                
                print(location.coordinate)
                
                var lat = Double(location.coordinate.latitude)
                var lng = Double(location.coordinate.longitude)                
                
                self.getLastLocation(completionHandler: { ( point:PFGeoPoint, has:Bool ) -> () in
                    
                    var newLocation = Bool()
                    
                    if has
                    {
                        
                        let current = PFGeoPoint(latitude: lat, longitude: lng)
                        let distance = current.distanceInKilometers(to: point as! PFGeoPoint)
                    
                        if distance > 0.2
                        {
                            newLocation = true
                        }
                    
                    } else
                    {
                        newLocation = true
                    }
                    
                    if newLocation
                    {
                        let userLocation = PFObject(className: "Location")
                    
                        if let userId = PFUser.current()?.objectId
                        {
                            userLocation["userId"] = userId
                        }
                    
                        let geoPoint = PFGeoPoint(latitude: lat, longitude: lng)
                        userLocation["geolocation"] = geoPoint
                    
                        userLocation.saveInBackground(block: { (resutl, error) in
                    
                            if error != nil
                            {
                                print(error)
                            } else
                            {
                                print(resutl)
                            }
                    
                        })
                    }
                })
            }
        }
    }
    
    
    func getLastLocation(completionHandler : @escaping (_ point:PFGeoPoint, _ has:Bool) -> ()?)
    {
        let locationQuery = PFQuery(className:"Location")
        
        if let userId = PFUser.current()?.objectId
        {
            locationQuery.whereKey("userId", equalTo: userId)
        }
        locationQuery.order(byDescending: "createdAt")
        
        locationQuery.getFirstObjectInBackground { (location, error) in
            
            var point = PFGeoPoint()
            
            if error != nil
            {
                print("error: \(error)")
            }
            
            if location != nil
            {
                point = location?["geolocation"] as! PFGeoPoint
                
                completionHandler(point, true)
                
            } else
            {                
                completionHandler(point, false)

            }
        }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp()
    {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "In order to deliver pizza we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
        }

        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }


    func setCurrentPage(current: Int, direction: Int, data: GamvesFanpage) {

        let homeCell = getHomeCell()
        
        homeCell.setCurrentPage(current: current, direction: direction, data: data)        
    }   


    func getPets(completionHandler : @escaping (_ resutl:Bool) -> ()) {

        let petQuery = PFQuery(className:"Pets")    

        petQuery.findObjectsInBackground(block: { (petsPF, error) in
            
            if error == nil
            {
                if let petsPF = petsPF
                {
                    var countPets = petsPF.count
                    var count = 0

                    var pets = [GamvesPet]()
                    
                    for petPF in petsPF
                    {
                        
                        var gamvesPet = GamvesPet()

                        gamvesPet.objectId = petPF.objectId!
                        gamvesPet.name = petPF["name"] as! String

                        let thumnail = petPF["thumbnail"] as! PFFileObject
                        
                        thumnail.getDataInBackground(block: { (data_thumbnail, error) in
                                            
                            if error == nil {
                                
                                let thumb_pet = UIImage(data: data_thumbnail!)

                                gamvesPet.thumbnail = thumb_pet 

                                Global.pets[gamvesPet.objectId] = gamvesPet

                                if count == (countPets - 1)
                                {
                                    completionHandler(true)
                                }
                                count = count + 1
                            }
                        })        
                    }
                }
            }
        })
    }

     func getUserPets() {

        let userPetQuery = PFQuery(className:"UserPets")
        
        if let userId = PFUser.current()?.objectId
        {
            userPetQuery.whereKey("userId", equalTo: userId)
        }       
        
        userPetQuery.getFirstObjectInBackground { (userPetsPF, error) in                       
            
            if error != nil
            {
                print("error: \(error)")
                
                print(self.pet)
                
                self.pet = nil
            
            } else {                

                let petsId = userPetsPF!["petsId"] as! String

                if Global.pets[petsId] != nil {

                    self.pet = Global.pets[petsId]               
                }

                self.userPets = userPetsPF
                 
            }            
        }
    }
}






