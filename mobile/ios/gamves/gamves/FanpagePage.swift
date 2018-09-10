//
//  FanpageTableViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 6/19/17.
//

import UIKit
import Parse
import NVActivityIndicatorView
import KenBurns
import SKPhotoBrowser
//import CampcotCollectionViewpo

struct AlbumSectionData {
    var isExpanded = Bool()
    var title = String()   
}

class FanpagePage: UIViewController,
    //UICollectionViewDataSource, 
    //UICollectionViewDelegate, 
    //UICollectionViewDelegateFlowLayout,
    UITableViewDataSource, 
    UITableViewDelegate,
    CustomHeaderViewDelegate
{  

    //- All page view

    let coverContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red 
        return view
    }()

    //- Header background image

    var coverImageView: KenBurnsImageView = {
        let imageView = KenBurnsImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()    

    //- Go back button

    lazy var arrowBackButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "arrow_back_white")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white   
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)        
        return button
    }()

    //- Fanpge avatar

    var avatarImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill 
        image.clipsToBounds = true
        image.backgroundColor = UIColor.gamvesColor
        image.layer.cornerRadius = 30
        image.borderWidth = 3
        image.borderColor = UIColor.black
        return image
    }()

     let separatorButtonsView: UIView = {
        let view = UIView()        
        return view
    }()

    //- Separetor Label

    let separatorCenterView: UIView = {
        let view = UIView()               
        return view
    }()        

    var fanpageName: UILabel = {
        let label = UILabel()        
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.white
        return label
    }()

    //- Favorite button

    lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "favorite")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white   
        button.addTarget(self, action: #selector(handleFavoriteButton), for: .touchUpInside)        
        return button
    }()

    //- Images Collection

    //var collectionView = CampcotCollectionView()
    //let interitemSpacing: CGFloat = 10
    //let lineSpacing: CGFloat = 10
    //let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)  
   
    //- Bottom line 

    let bottomLineContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black 
        return view
    }()   

    // TableView

    lazy var tableView: UITableView = {
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let tv = UITableView(frame: rect)
        //tv.backgroundColor = UIColor.white
        tv.alwaysBounceVertical = false
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    var homeController:HomeController!

    //- VARIABLES & OBJCETS    

    var fanpageGamves  = GamvesFanpage()
    var videosGamves  = [GamvesVideo]()
    
    var groupAlbums = [[GamvesAlbum]]()
    var albumSections = [AlbumSectionData]()

    weak var delegate:CellDelegate?       
    
    var activityVideoView: NVActivityIndicatorView!
    
    var timer:Timer? = nil

    //var gallery:SwiftPhotoGallery?

     var isFavorite = Bool()

    var favorite:PFObject!
    
    let cellFanpageTableId = "cellFanpageTableId"
    let cellVideoTableId = "cellVideoTableId"

    let sectionHeaderId = "fanpgageSectionHeader"

    var categoryName = String()   

    var posterId = String()  
    
    var isFortnite = Bool() 

    var customView: UILabel?

    var videosSection = "Videos"

    var storedOffsets = [Int: CGFloat]()    
    
    override func viewDidLoad() {

        super.viewDidLoad()        

        self.view.addSubview(self.coverContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.coverContainerView)
        
        self.coverContainerView.addSubview(self.coverImageView)
        self.coverContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.coverImageView)
        self.coverContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.coverImageView)
    
        self.coverContainerView.addSubview(self.arrowBackButton)
        self.coverContainerView.addSubview(self.avatarImageView)
        self.coverContainerView.addSubview(self.separatorButtonsView)
        self.coverContainerView.addSubview(self.favoriteButton)
        
        //horizontal constraints
        self.coverContainerView.addConstraintsWithFormat("H:|[v0(60)][v1(60)]-10-[v2][v3(60)]|", views: arrowBackButton, avatarImageView, separatorButtonsView, favoriteButton)
        
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.arrowBackButton)
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.avatarImageView)
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.separatorButtonsView)       
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.favoriteButton)       
    
        self.coverContainerView.addSubview(self.separatorCenterView)        
        self.coverContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.separatorCenterView)           
        self.coverContainerView.addConstraintsWithFormat("V:|-60-[v0(50)]|", views: self.separatorCenterView)   

        self.coverContainerView.addSubview(self.bottomLineContainerView)
        self.coverContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.bottomLineContainerView)
        self.coverContainerView.addConstraintsWithFormat("V:|-77-[v0(3)]|", views: self.bottomLineContainerView)                               

        self.separatorButtonsView.addSubview(self.fanpageName)
        self.separatorButtonsView.addConstraintsWithFormat("H:|[v0]|", views: self.fanpageName)
        self.separatorButtonsView.addConstraintsWithFormat("V:|[v0]|", views: self.fanpageName)           

        self.view.addSubview(self.tableView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.tableView)
        self.view.addConstraintsWithFormat("V:|[v0(80)][v1]|", views:
            self.coverContainerView,
            self.tableView)       
        self.tableView.backgroundColor = UIColor.gamvesBlackColor
        
        self.tableView.register(FanpageTableCell.self, forCellReuseIdentifier: self.cellFanpageTableId)        
        self.tableView.register(FanpageVideoTableCell.self, forCellReuseIdentifier: self.cellVideoTableId)
        self.tableView.register(FanpageSectionHeader.self, forCellReuseIdentifier: self.sectionHeaderId)
        
        //self.collectionView.toggle(to: 0, animated: true)

        self.activityVideoView = Global.setActivityIndicator(container: self.tableView, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)
           
        //self.activityVideoView.startAnimating()                  
    }    
       

    override func viewWillAppear(_ animated: Bool) {
        self.view.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.favoriteButton.tintColor = UIColor.white
    }

    func setFanpageGamvesData(data: GamvesFanpage) {        
        
        self.checkFavorite()    

        self.fanpageGamves = data as GamvesFanpage

        self.categoryName = self.fanpageGamves.categoryName             

        if self.categoryName == "PERSONAL" {

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(tapGestureRecognizer:)))
            self.avatarImageView.isUserInteractionEnabled = true
            self.avatarImageView.addGestureRecognizer(tapGestureRecognizer)

        }
        
        self.fanpageName.text = self.fanpageGamves.name
        
        let fanpageId = data.fanpageObj?["fanpageId"] as! Int
        
        let name = data.fanpageObj?["pageName"] as! String
        
        self.newKenBurnsImageView(image: self.fanpageGamves.cover_image)
        
        self.avatarImageView.image = self.fanpageGamves.icon_image
        
        if Downloader.fanpageImagesDictionary[fanpageId] != nil {

            let allAbums =  Downloader.fanpageImagesDictionary[fanpageId] as! [GamvesAlbum]

            let groupDictionary = Dictionary(grouping: allAbums) { (album) -> String in
                return album.type
            }
            
            let keys = groupDictionary.keys.sorted()
            keys.forEach{ (key) in
                print(key)
                var albumSection = AlbumSectionData()
                albumSection.title = key
                albumSection.isExpanded = false
                self.albumSections.append(albumSection)
                self.groupAlbums.append(groupDictionary[key]!)
            }
            
            self.groupAlbums.forEach({
                $0.forEach({print($0)})
                print("-----------------------")
            }) 

            var albumSection = AlbumSectionData()
            albumSection.title = self.videosSection
            albumSection.isExpanded = false
            self.albumSections.append(albumSection)            
                            
            //self.tableView.reloadData()

            var expandeds = ["Images", "News", "Videos"]

            //for var albumSection in self.albumSections {

            for i in 0...self.albumSections.count - 1 {

                for expanded in expandeds {

                    if self.albumSections[i].title.contains(expanded) {
                        self.albumSections[i].isExpanded = true                    
                    }
                }
            }
        }
        
        if self.coverContainerView.tag != 1 {
            self.setupGradientLayer()
        }
        
        self.view.isHidden = false
    }

    @objc func avatarTapped(tapGestureRecognizer: UITapGestureRecognizer) {

        self.posterId = self.fanpageGamves.posterId

        if Global.userDictionary[posterId] != nil {

            let gamvesUserPoster = Global.userDictionary[posterId] as! GamvesUser

            let userDataDict:[String: GamvesUser] = ["gamvesUser": gamvesUserPoster]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Global.notificationKeyShowProfile), object: nil, userInfo: userDataDict)       
        }
            
    }

   
    func checkFavorite() {


        let queryFavorite = PFQuery(className:"Favorites")

        if let userId = PFUser.current()?.objectId {
        
            queryFavorite.whereKey("userId", equalTo: userId)

        }

        if let fanpageId = self.fanpageGamves.fanpageObj?.objectId {

            queryFavorite.whereKey("referenceId", equalTo: fanpageId)

        }
        
        queryFavorite.findObjectsInBackground { (favoritePF, error) in
         
             if error == nil {
                
                var count = Int()
                
                count = (favoritePF?.count)!

                if count > 0 {

                    self.isFavorite = true               
                    
                    self.favoriteButton.tintColor = UIColor.red

                    self.favorite = favoritePF![0]

                } else {

                    self.unMarkFavorite()
                }

            } else {

                self.unMarkFavorite()
            }          
        }
    }

    func unMarkFavorite() {

        self.isFavorite = false

        self.favoriteButton.tintColor = UIColor.white

    }

    @objc func handleFavoriteButton() {

        if !self.isFavorite {

            let favoritesPF: PFObject = PFObject(className: "Favorites")

            if let fanpageId = self.fanpageGamves.fanpageObj?.objectId {

                favoritesPF["referenceId"] = fanpageId

            }
            
            if let userId = PFUser.current()?.objectId {
            
                favoritesPF["userId"] = userId
                
            }
            
            favoritesPF["type"] = 1
            
            favoritesPF.saveInBackground(block: { (resutl, error) in
                
                if error == nil {
                
                    self.favoriteButton.tintColor = UIColor.red

                    self.isFavorite = true

                    self.favorite = favoritesPF
                }

            })            
            
        } else {

            self.favorite.deleteEventually()

            self.favoriteButton.tintColor = UIColor.white

            self.isFavorite = false
        }
        
    }


    @objc func handleBackButton()  {
        
        if ( delegate != nil ) {

            if self.timer != nil {
                self.timer?.invalidate()
            }
            
            delegate?.setCurrentPage(current: 0, direction: -1, data: nil)
        }
    }
    
    func newKenBurnsImageView(image: UIImage) {
        self.coverImageView.setImage(image)
        self.coverImageView.zoomIntensity = 1.5
        self.coverImageView.setDuration(min: 5, max: 13)
        self.coverImageView.startAnimating()
    }

    fileprivate func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.coverContainerView.frame
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.gamvesBlackColor.cgColor]
        gradientLayer.locations = [0.2, 1.2]
        self.coverContainerView.tag = 1
        self.coverContainerView.layer.addSublayer(gradientLayer)
        self.coverContainerView.bringSubview(toFront: self.separatorButtonsView)
        self.coverContainerView.bringSubview(toFront: self.arrowBackButton)
        self.coverContainerView.bringSubview(toFront: self.favoriteButton)    
        self.coverContainerView.bringSubview(toFront: self.favoriteButton)
    }  
    

    func setFanpageData() {   

        self.videosGamves = [GamvesVideo]()                
        self.getFanpageVideos(fan: fanpageGamves)
    }

    @objc func autoScrollImageSlider() {

     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func getFanpageVideos(fan:GamvesFanpage)
    {

        self.activityVideoView.startAnimating()

        let countVideosLoaded = 0
        
        let videoRel:PFRelation = fan.fanpageObj!.relation(forKey: "videos")
        let queryvideos:PFQuery = videoRel.query()
        
        //queryvideos.whereKey("approved", equalTo: true)
        
        let filterTarget = [
            Global.schoolShort,
            Global.levelDescription.lowercased(),
            Global.userId] as [String]
        
        queryvideos.whereKey("target", containedIn: filterTarget)
        
        if !Global.hasDateChanged()
        {
            queryvideos.cachePolicy = .cacheThenNetwork
        }

        queryvideos.findObjectsInBackground(block: { (videoObjects, error) in
            
            if error != nil
            {
                print("error")
                
            } else {
                
                let countVideosLoaded = Int()
                
                var countVideos = videoObjects?.count
                var count = 0
                
                //print(countVideos)
                
                if countVideos! > 0
                {
                    if let videoArray = videoObjects
                    {
                        for qvideoinfo in videoArray
                        {
                            
                            let video = GamvesVideo()
                            
                            var videothum = qvideoinfo["thumbnail"] as! PFFile
                            
                            video.authorized                = qvideoinfo["authorized"] as! Bool

                            if video.authorized 
                            {

                                video.title                     = qvideoinfo["title"] as! String
                                video.description               = qvideoinfo["description"] as! String
                                video.thumbnail                 = videothum
                                video.categoryName              = qvideoinfo["categoryName"] as! String
                                video.videoId                   = qvideoinfo["videoId"] as! Int
                                video.s3_source                 = qvideoinfo["s3_source"] as! String
                                video.ytb_thumbnail_source      = qvideoinfo["ytb_thumbnail_source"] as! String
                                video.ytb_videoId               = qvideoinfo["ytb_videoId"] as! String
                                
                                let dateStr = qvideoinfo["ytb_upload_date"] as! String
                                let dateDouble = Double(dateStr)
                                let date = NSDate(timeIntervalSince1970: dateDouble!)
                                
                                video.ytb_upload_date           = date as Date
                                video.ytb_view_count            = qvideoinfo["ytb_view_count"] as! Int
                                video.ytb_tags                  = qvideoinfo["ytb_tags"] as! [String]
                                
                                let durStr = qvideoinfo["ytb_upload_date"] as! String
                                let durDouble = Double(durStr)
                                video.ytb_duration              = durDouble!
                                
                                video.ytb_categories            = qvideoinfo["ytb_categories"] as! [String]
                                //video.ytb_like_count            = qvideoinfo["ytb_like_count"] as! Int
                                video.order                     = qvideoinfo["order"] as! Int
                                video.fanpageId                 = qvideoinfo["fanpageId"] as! Int
                                
                                video.posterId                  = qvideoinfo["posterId"] as! String
                                
                                print(video.posterId)
                                
                                if Global.userDictionary[video.posterId] == nil && video.posterId != Global.gamves_official_id {
                                
                                    let userQuery = PFQuery(className:"_User")
                                    userQuery.whereKey("objectId", notEqualTo: video.posterId)
                                    userQuery.findObjectsInBackground(block: { (users, error) in
                                        
                                        if error == nil
                                        {
                                            let usersCount =  users?.count
                                            var count = 0
                                            
                                            //print(usersCount)
                                            
                                            for user in users!
                                            {
                                                Global.addUserToDictionary(user: user as! PFUser, isFamily: false, completionHandler: { ( gamvesUser ) -> () in                                           
                                                                                                        
                                                    //self.tableView.reloadData()
                                                })
                                            }
                                        }
                                    })
                                }
                                
                                video.posterName = qvideoinfo["poster_name"] as! String
                                
                                video.published = qvideoinfo.createdAt! as Date                                
                                video.videoObj = qvideoinfo
                                
                                videothum.getDataInBackground(block: { (data, error) in
                                    
                                    if error == nil{
                                        
                                        video.image = UIImage(data: data!)!
                                        
                                        self.videosGamves.append(video)
                                        
                                        print("***********")
                                        print("countVideos: \(countVideos!)")
                                        print("countVideosLoaded: \(countVideosLoaded)")
                                        
                                        if ( (countVideos!-1) == count)
                                        {                                            
                                            self.activityVideoView.stopAnimating()
                                            self.tableView.reloadData()
                                            
                                        }
                                        count = count + 1
                                    }
                                })

                            } else {

                                if countVideos! > 1 {
                                    
                                    if ( (countVideos!-1) == count)
                                    {                                        
                                        self.activityVideoView.stopAnimating()
                                    }
                                    count = count + 1
                                    
                                } else {
                                    self.showEmptyMessage()
                                }
                            }
                        }
                    }
            
                } else {
                   
                    self.showEmptyMessage()
                }
            }
        })
    } 

    func showEmptyMessage() {
        self.activityVideoView.stopAnimating()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        var count = Int()
        count = self.albumSections.count
        return count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if !self.albumSections[section].isExpanded {
            return 0
        }
        
        return 1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {     
       
        var reuseHeaderView: UICollectionReusableView? = nil            

        let sectionHeaderView = tableView.dequeueReusableCell(withIdentifier: self.sectionHeaderId) as! FanpageSectionHeader

        sectionHeaderView.delegate = self

        sectionHeaderView.section = section       
    
        let albumSelection = self.albumSections[section]

        if albumSelection.isExpanded {

            let image = UIImage(named: "expand_more_white")
            sectionHeaderView.expandImageView.image = image           

        } else {

            let image = UIImage(named: "expand_less_white")
            sectionHeaderView.expandImageView.image = image           

        }
        
        sectionHeaderView.nameLabel.text = albumSelection.title
        sectionHeaderView.backgroundColor = UIColor.black                                 

        return sectionHeaderView     
    
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        
        /*let section = self.albumSections[indexPath.section]
        let row = indexPath.section    

        if section == self.videosSection {

            guard var verTableViewCell = cell as? FanpageVideoTableCell else
            {
                return
            }            
            
            verTableViewCell.selectionStyle = .none            
            verTableViewCell.setCollectionViewDataSourceDelegate(self, forRow: row)
            verTableViewCell.collectionViewOffset = storedOffsets[row] ?? 0   

        } else {

            guard let horTableViewCell = cell as? FanpageTableCell else
            {
                return
            }            
            
            horTableViewCell.selectionStyle = .none            
            horTableViewCell.setCollectionViewDataSourceDelegate(self, forRow: row)
            horTableViewCell.collectionViewOffset = storedOffsets[row] ?? 0   

        }*/
        
    }    
  

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 40
    }    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {     
       
        let cell:UITableViewCell!
        
        let albumSelection = self.albumSections[indexPath.section]
        
        print(albumSelection.title)
        
        if albumSelection.title == self.videosSection {

            let cellV = tableView.dequeueReusableCell(withIdentifier: self.cellVideoTableId, for: indexPath) as! FanpageVideoTableCell
            
            cellV.videosGamves = self.videosGamves
            cellV.setupViews()
            cellV.videoCollectionView.reloadData()
            return cellV

        } else {

            let cellI = tableView.dequeueReusableCell(withIdentifier: self.cellFanpageTableId, for: indexPath) as! FanpageTableCell
            
            let albums = self.groupAlbums[indexPath.section] 
            cellI.albums = albums
            cellI.albumCollectionView.reloadData()
            return cellI
        }
        
        return cell
    }
    

    @objc func handleViewProfile(recognizer:UITapGestureRecognizer) {
        
        let v = recognizer.view!
        let index = v.tag
               
        let indexPath = IndexPath(item: index, section: 1)
        
        let posterId = self.videosGamves[indexPath.item].posterId
        
        print(posterId)
        
        let gamvesUserPoster = Global.userDictionary[posterId] as! GamvesUser

        if let userId = PFUser.current()?.objectId {

            //Not open my user
            
            if gamvesUserPoster.userId != userId {

                if gamvesUserPoster.userName == "gamvesadmin" {

                    var chatId = Int()

                    if gamvesUserPoster.chatId > 0 {

                        chatId = gamvesUserPoster.chatId
                    } else {
                        chatId = Global.getRandomInt()
                    }

                    let userDataDict:[String: AnyObject] = ["gamvesUser": gamvesUserPoster, "chatId": chatId as AnyObject]
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Global.notificationOpenChatFromUser), object: nil, userInfo: userDataDict) 

                } else  {

                    let profileLauncher = PublicProfileLauncher()
                    profileLauncher.showProfileView(gamvesUser: gamvesUserPoster)

                }

            }
        }     
    }    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = CGFloat()

        if self.albumSections[indexPath.section].title == self.videosSection {

            height = (view.frame.width - 16 - 16) * 9 / 16
            
            height = height + 16 + 88

        } else {

            height = 100        

        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
                
        let selectedAlbums = self.groupAlbums[indexPath.section] as [GamvesAlbum]
        
        var images = [SKPhoto]()
        
        for album in selectedAlbums {
            
            let image = SKPhoto.photoWithImage(album.cover_image)
            image.caption = album.name
            
            images.append(image)
        }
        
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(0)
        present(browser, animated: true, completion: {})       
        
    }

    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {

         var size = CGSize()

         let albumSelection = self.albumSections[indexPath.section]

        if albumSelection.title == self.videosSection {

            let height = (view.frame.width - 16 - 16) * 9 / 16
            
            size = CGSize(width: view.frame.width, height: height + 16 + 88)
        
        } else {

            let module = view.frame.width / 5
            
            size = CGSize(width: module, height: module)            
        }       
        
        return size

    }*/

    func selectSection(section: Int) {   
        
        let isExpanded = self.albumSections[section].isExpanded
        self.albumSections[section].isExpanded = !isExpanded
        
        self.tableView.reloadData()       
       

    }  
    
    
  
}



