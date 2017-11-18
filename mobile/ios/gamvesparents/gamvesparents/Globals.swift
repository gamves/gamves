//
//  Objects.swift
//  gamvescommunity
//
//  Created by Jose Vigil on 5/30/17.
//  Copyright © 2017 Jose Vigil. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView
import PopupDialog

class Global: NSObject
{
    
    static var defaults = UserDefaults.standard
    
    static var keySpouse = "spousePhotoImage"
    static var keyYour = "yourPhotoImage"
    static var keySon = "sonPhotoImage"


    static var key_you_spouse_chat_id = "you_spouse_chat_id"
    static var key_you_son_chat_id = "you_son_chat_id"
    static var key_you_spouse_son_chat_id = "you_spouse_son_chat_id"

    
    static var keySpouseSmall   = String() //"\(Global.keySpouse)Small"
    static var keyYourSmall     = String() //"\(Global.keyYour)Small"
    static var keySonSmall      = String() //"\(Global.keySon)Small"
    
    //Notifications
    static var notificationKeyFamilyLoaded  = "com.gamves.gamvesparent.familyLoaded"
    static var notificationKeyChatFeed      = "com.gamves.gamvesparent.chatfeed"
    
    static var badgeNumber = Bool()
    
    static var userDictionary = Dictionary<String, GamvesParseUser>()
    
    static var gamvesFamily = GamvesFamily()
    
    static var chatVideos = Dictionary<Int64, VideoGamves>()
    
    static var hasNewFeed = Bool()
    
    static func addUserToDictionary(user: PFUser, isFamily:Bool, completionHandler : @escaping (_ resutl:GamvesParseUser) -> ())
    {
        var userId = user.objectId!
        
        if self.userDictionary[userId] == nil
        {
            
            let gamvesUser = GamvesParseUser()
            
            gamvesUser.name = user["Name"] as! String
            gamvesUser.userId = user.objectId!
            
            gamvesUser.firstName = user["firstName"] as! String
            gamvesUser.lastName = user["lastName"] as! String
            
            gamvesUser.userName = user["username"] as! String
            
            if user["status"] != nil
            {
                gamvesUser.status = user["status"] as! String
            }
            
            if PFUser.current()?.objectId == userId
            {
                gamvesUser.isSender = true
            }
            
            gamvesUser.gamvesUser = user
            
            let levelRelation = user.relation(forKey: "level") as PFRelation
            
            let queryLevel = levelRelation.query()
            
            queryLevel.findObjectsInBackground(block: { (levels, error) in
                
                if error == nil
                {
                    let countLevels = levels?.count
                    var count = 0
                    
                    for level in levels!
                    {
                        gamvesUser.levelNumber = level["grade"] as! Int
                        gamvesUser.levelDescription = level["description"] as! String
                    
                        if user["pictureSmall"] != nil
                        {
                        
                            let picture = user["pictureSmall"] as! PFFile
                            
                            picture.getDataInBackground(block: { (data, error) in
                                
                                if (error != nil)
                                {
                                    print(error)
                                } else
                                {
                                
                                    let image = UIImage(data: data!)
                                    gamvesUser.avatar = image!
                                    gamvesUser.isAvatarDownloaded = true
                                    gamvesUser.isAvatarQuened = false
                                    
                                    var typeNumber = user["userType"] as! Int
                                    
                                    print(gamvesUser.firstName)
                                    
                                    gamvesUser.typeNumber = typeNumber
                                    
                                    print(gamvesUser.typeNumber)
                                    
                                    //No me interesa
                                    //gamvesUser.typeDescription = user["description"] as! String
                                    
                                    if isFamily
                                    {
                                        var gender = GamvesGender()
                                        
                                        if typeNumber == 0 || typeNumber == 4
                                        {
                                            if typeNumber == 0
                                            {
                                                gender.female = true
                                            } else if typeNumber == 4
                                            {
                                                gender.male = true
                                            }
                                            gamvesUser.gender = gender
                                            
                                            Global.gamvesFamily.youUser = gamvesUser
                                            
                                        } else if typeNumber == 1 || typeNumber == 5
                                        {
                                            if typeNumber == 1
                                            {
                                                gender.female = true
                                            } else if typeNumber == 5
                                            {
                                                gender.male = true
                                            }
                                            
                                            gamvesUser.gender = gender
                                            
                                            Global.gamvesFamily.spouseUser = gamvesUser
                                            
                                        } else if typeNumber == 2 || typeNumber == 3
                                        {
                                            
                                            if typeNumber == 2
                                            {
                                                gender.male = true
                                            } else if typeNumber == 3
                                            {
                                                gender.male = false
                                            }
                                            gamvesUser.gender = gender
                                            
                                            Global.gamvesFamily.sonsUsers.append(gamvesUser)
                                        }
                                    }
                                    
                                    if count == (countLevels!-1)
                                    {
                                        
                                        self.userDictionary[userId] = gamvesUser
                                        
                                        completionHandler(gamvesUser)
                                        
                                    }
                                    
                                    count = count + 1
                                    
                                }
                                
                            })
                        }
                    }
                }
            })
            
        } else {
            
            completionHandler(self.userDictionary[userId]!)
        }
    }
    
    static func getImageVideo(videothumburl: String, video:VideoGamves, completionHandler : (_ video:VideoGamves) -> Void)
    {
        
        if let vurl = URL(string: videothumburl)
        {
            
            if let data = try? Data(contentsOf: vurl)
            {
                video.thum_image = UIImage(data: data)!
                
                completionHandler(video)
            }
        }
    }
    
    static func setTitle(title:String, subtitle:String) -> UIView
    {
        let titleLabel = UILabel(frame: CGRect(x:0, y:-2, width:0, height:0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        titleLabel.tag = 0
        
        let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width:0, height:0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        subtitleLabel.tag = 1
        
        let titleView = UIView(frame: CGRect(x:0, y:0, width:max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height:30))
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        
        return titleView
    }
    
    static func parseUsersStringToArray(separated: String) -> [String]
    {
        var feed = separated
        
        feed = feed.replacingOccurrences(of: "[", with: "")
        feed = feed.replacingOccurrences(of: "]", with: "")
        feed = feed.replacingOccurrences(of: "\\", with: "")
        feed = feed.replacingOccurrences(of: "\"", with: "")
        feed = feed.replacingOccurrences(of: " ", with: "")
        
        return feed.components(separatedBy:",")
    }
    
    static func addChannels(userIds:[String], channel:String, completionHandlerChannel : @escaping (_ resutl:Bool) -> ())
    {
        
        var method = String()
        
        let users:AnyObject
        
        if userIds.count > 1
        {
            method = "subscribeUsersToChannel"
            users = userIds as AnyObject
        } else
        {
            method = "subscribeUserToChannel"
            users = userIds[0] as String as AnyObject
        }
        
        let params = ["userIds":users, "channel":channel] as [String : Any]
        
        PFCloud.callFunction(inBackground: method, withParameters: params) { (resutls, error) in
            
            if error != nil
            {
                
                UIAlertController(title:"Error", message:
                    error as? String, preferredStyle: .actionSheet)
                
                
                completionHandlerChannel(false)
                
            } else
            {
                completionHandlerChannel(true)
            }
        }
    }
    
    static func registerInstallationAndRole(completionHandlerRole : @escaping (_ resutl:Bool) -> ())
    {
        if let user = PFUser.current()
        {
            
            let installation = PFInstallation.current()
            installation?["user"] = PFUser.current()
            installation?.saveInBackground(block: { (resutl, error) in
                
                PFPush.subscribeToChannel(inBackground: "GamvesChannel")
                
                var queryRole = PFRole.query() // You need to get role object
                queryRole?.whereKey("name", equalTo:"admin")
                
                queryRole?.getFirstObjectInBackground(block: { (role, error) in
                    
                    
                    if error == nil
                    {
                        
                        let roleQuery = PFRole.query()
                        
                        roleQuery?.whereKey("name", equalTo: "admin")
                        
                        roleQuery?.getFirstObjectInBackground(block: { (role, error) in
                            
                            if error == nil
                            {
                                let admin = role as! PFRole
                                
                                let acl = PFACL(user: PFUser.current()!)
                                
                                acl.setWriteAccess(true, for: admin)
                                acl.setReadAccess(true, for: admin)
                                
                                admin.users.add(PFUser.current()!)
                                
                                admin.saveInBackground(block: { (resutl, error) in
                                    
                                    print("")
                                    
                                    if error != nil
                                    {
                                        completionHandlerRole(false)
                                    } else {
                                        completionHandlerRole(true)
                                    }
                                    
                                })
                            }
                        })
                    }
                })
            })
        }
    }
    
    
    static func setActivityIndicator(container: UIView, type: Int, color:UIColor) -> NVActivityIndicatorView
    {
        
        var aiView:NVActivityIndicatorView?
        
        if aiView == nil
        {
            aiView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60.0, height: 60.0), type: NVActivityIndicatorType(rawValue: type), color: color, padding: 0.0)
            
            // add subview
            container.addSubview(aiView!)
            // autoresizing mask
            aiView?.translatesAutoresizingMaskIntoConstraints = false
            // constraints
            container.addConstraint(NSLayoutConstraint(item: aiView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
            container.addConstraint(NSLayoutConstraint(item: aiView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        }
        
        return aiView!
    }
    
    static func buildPopup(viewController: UIViewController, params: [String:Any] ) -> PopupDialog
    {
        
        // Prepare the popup assets
        let title = params["title"] //"THIS IS THE DIALOG TITLE"
        let message = params["message"] //"This is the message section of the popup dialog default view"
        
        var image = UIImage()
        
        if params["image"] != nil
        {
            image = UIImage(named: params["image"] as! String)!
        }
        
        // Create the dialog
        let popup = PopupDialog(title: title as! String, message: message as! String, image: image)
        
        if params["buttons"] != nil
        {
            let buttons = params["buttons"] as! [DefaultButton]
            
            for button in buttons
            {
                popup.addButton(button)
            }
        }
        
        // Create buttons
        /*let buttonOne = CancelButton(title: "CANCEL")
         {
         print("You canceled the car dialog.")
         }
         
         let buttonTwo = DefaultButton(title: "ADMIRE CAR")
         {
         print("What a beauty!")
         }
         
         let buttonThree = DefaultButton(title: "BUY CAR", height: 60)
         {
         print("Ah, maybe next time :)")
         }
         
         // Add buttons to dialog
         // Alternatively, you can use popup.addButton(buttonOne)
         // to add a single button
         popup.addButtons([buttonOne, buttonTwo, buttonThree])*/
        
        // Present dialog
        viewController.present(popup, animated: true, completion: nil)
        
        return popup
        
    }
    
    
    static func createCircularLabel(text: String, size: CGFloat, fontSize: CGFloat, borderWidth: CGFloat, color: UIColor) -> UILabel
    {
        let mSize:CGFloat = size
        
        let countLabel = UILabel(frame: CGRect(x : 0.0,y : 0.0, width : mSize, height :  mSize))
        countLabel.text = text
        countLabel.textColor = UIColor.white
        countLabel.textAlignment = .center
        
        countLabel.font = UIFont.systemFont(ofSize: fontSize)
        countLabel.layer.cornerRadius = size / 2
        countLabel.layer.borderWidth = borderWidth //3.0
        countLabel.layer.masksToBounds = true
        countLabel.layer.backgroundColor = color.cgColor //UIColor.orange.cgColor
        countLabel.layer.borderColor = UIColor.white.cgColor
        
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return countLabel
    }
    
    static func setRoundedImage(image: UIImageView, cornerRadius : Int, boderWidth: CGFloat, boderColor: UIColor)
    {
        image.layer.borderWidth = boderWidth
        image.layer.masksToBounds = false
        image.layer.borderColor = boderColor.cgColor        
        image.layer.cornerRadius = CGFloat(cornerRadius)
        image.clipsToBounds = true
    }
    
    static func loadBargesNumberForUser(completionHandler : @escaping (_ resutl:Int) -> ())
    {
        
        let queryBadges = PFQuery(className:"Badges")
        
        if let userId = PFUser.current()?.objectId
        {
            queryBadges.whereKey("userId", equalTo: userId)
        }
        queryBadges.findObjectsInBackground { (badges, error) in
            
            if error != nil
            {
                print("error")
                
            } else {
                
                if let badges = badges
                {
                    
                    let badgesAmount = badges.count
                    
                    if badgesAmount > 0
                    {
                        
                        var count = Int()
                        
                        for badge in badges
                        {
                            
                            let amount = badge["amount"] as! Int
                            
                            count = count + amount
                        }
                        
                        completionHandler(count)
                        
                    } else
                    {
                        completionHandler(0)
                    }
                    
                }
            }
        }
    }

    static func getRandomInt64() -> Int64 {
        var randomNumber: Int64 = 0
        withUnsafeMutablePointer(to: &randomNumber, { (randomNumberPointer) -> Void in
            _ = randomNumberPointer.withMemoryRebound(to: UInt8.self, capacity: 8, { SecRandomCopyBytes(kSecRandomDefault, 8, $0) })
        })
        return abs(randomNumber)
    }    
   
    
    
    
    static func getBadges(chatId:Int64, completionHandler : @escaping (_ resutl:Int) -> ())
    {
        
        let badgesQuery = PFQuery(className:"Badges")
        
        if let userId = PFUser.current()?.objectId
        {
            badgesQuery.whereKey("userId", equalTo: userId)
        }
        badgesQuery.whereKey("chatId", equalTo: chatId)
        badgesQuery.findObjectsInBackground(block: { (badges, error) in
            
            if error == nil
            {
                
                let badgesUsers = badges?.count
                
                var counter = Int()
                
                for badge in badges!
                {
                    let amount = badge["amount"] as! Int
                    counter = counter + amount
                }
                
                completionHandler(counter)
                
            }
        })
        
    }

    static func alertWithTitle(viewController: UIViewController, title: String!, message: String, toFocus:UITextField?) 
    {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
            
            if toFocus != nil
            {
                toFocus?.becomeFirstResponder()
            }

        });
        alert.addAction(action)
        viewController.present(alert, animated: true, completion:nil)
    }

    static func isValidEmail (test:String) ->Bool
    {
        // your email validation here...
        return true
    }
    
    
    static func getFamilyData()
    {
        
        self.keySpouseSmall   = "\(self.keySpouse)Small"
        self.keyYourSmall     = "\(self.keyYour)Small"
        self.keySonSmall      = "\(self.keySon)Small"
        
        DispatchQueue.global().async {
            
            let familyQuery = PFQuery(className:"Family")
            familyQuery.whereKey("members", equalTo: PFUser.current())
            familyQuery.cachePolicy = .cacheElseNetwork
            familyQuery.findObjectsInBackground(block: { (families, error) in
                
                if error == nil
                {
                    
                    for family in families!
                    {
                        
                        self.gamvesFamily.familyName = family["description"] as! String
                        
                        self.gamvesFamily.familyChatId = family["familyChatId"] as! Int64
                        self.gamvesFamily.sonChatId = family["sonChatId"] as! Int64
                        self.gamvesFamily.spouseChatId = family["spouseChatId"] as! Int64
                        
                        let membersRelation = family.relation(forKey: "members") as PFRelation
                        
                        let queryMembers = membersRelation.query()
                        
                        queryMembers.findObjectsInBackground(block: { (members, error) in
                            
                            if error == nil
                            {
                                
                                var memberCount = members?.count
                                var count = 0
                                
                                for member in members!
                                {
                                    
                                    DispatchQueue.main.async
                                        {
                                            
                                            self.addUserToDictionary(user: member as! PFUser, isFamily: true, completionHandler: { ( gamvesUser ) -> () in
                                                
                                                print(gamvesUser.userName)
                                                
                                                self.userDictionary[gamvesUser.userId] = gamvesUser
                                                
                                                if count == (memberCount!-1)
                                                {
                                                    NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: self)
                                                }
                                                count = count + 1
                                            })
                                    }
                                }
                            }
                        })
                        
                        let schoolRelation = family.relation(forKey: "school") as PFRelation
                        
                        let querySchool = schoolRelation.query()
                        
                        querySchool.findObjectsInBackground(block: { (schools, error) in
                            
                            if error == nil
                            {
                                for school in schools!
                                {
                                    self.gamvesFamily.school = school["name"] as! String
                                }
                            }
                        })
                    }
                }
            })
        }
    }
    
    
    

}





