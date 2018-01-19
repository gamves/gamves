//
//  LoginViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 11/2/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit
import Parse
import DownPicker
import BEMCheckBox
import NVActivityIndicatorView

class LoginViewController: UIViewController
{
    var tabBarViewController:TabBarViewController?
    
    var okLogin = Bool()
    
    var isRegistered = Bool()

    var activityIndicatorView:NVActivityIndicatorView?
    
    let explainLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please provide your fullname, emall and password for your new account"
        label.textColor = UIColor.white
        //label.font = UIFont.boldSystemFont(ofSize: 15)
        label.font = UIFont(name: label.font.fontName, size: 13)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 3
        return label
    }()
    
    let backView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.gamvesColor
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    let registerLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.text = "Please ask your parents for registration credentials and come back. They should register first in order to give you access."
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 5
        return label
    }()

    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full name"
        tf.text = "Jose Vigil"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.tag = 0
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.text = "josemanuelvigil@gmail.com"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.tag = 1
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        tf.text = "JoseVigil2016"
        tf.tag = 2
        return tf
    }()
    
    //var checkBoxView: CheckBoxView!

    let userTypeSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var userTypeDownPicker: DownPicker!
    let userTypeTextField: UITextField = {
        let tf = UITextField()        
        tf.translatesAutoresizingMaskIntoConstraints = false        
        tf.tag = -1
        return tf
    }()

    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor
        button.setTitle("Register", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()

    var isMessage = Bool()
    var message = String()
    var containerViewHeight = CGFloat()
    
    var containerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    var userTypeTextFieldHeightAnchor: NSLayoutConstraint?
    var registerLabelHeightAnchor: NSLayoutConstraint?
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let mTop:CGFloat        = 30
    let expHeight:CGFloat   = 50
    let scHeight:CGFloat    = 36
    let icHeight:CGFloat    = 160
    let icHeightLogin:CGFloat    = 160
    let cbHeight:CGFloat    = 70
    let lrbHeight:CGFloat   = 60
    
    var metricsDict:[String:Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gamvesColor
        
        self.view.addSubview(self.backView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.backView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.backView)
        
        self.backView.backgroundColor = UIColor.gamvesColor
        
        self.backView.addSubview(explainLabel)
        self.backView.addSubview(loginRegisterSegmentedControl)
        self.backView.addSubview(containerView)
        self.backView.addSubview(registerLabel)
        self.backView.addSubview(loginRegisterButton)
        self.backView.addSubview(bottomView)
        
        containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -24).isActive = true
        
        containerViewHeightAnchor = containerView.heightAnchor.constraint(equalToConstant: icHeight)
        containerViewHeightAnchor?.isActive = true
        
        self.metricsDict = [String:Any]()
        
        self.metricsDict["mTop" ] = mTop
        self.metricsDict["expHeight" ] = expHeight
        self.metricsDict["scHeight" ] = scHeight
        self.metricsDict["icHeight" ] = icHeight
        self.metricsDict["lrbHeight" ] = lrbHeight

        backView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.explainLabel)
        backView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.loginRegisterSegmentedControl)
        
        backView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.loginRegisterButton)
        backView.addConstraintsWithFormat("H:|[v0]|", views: self.bottomView)
        
        self.backView.addConstraintsWithFormat(
            "V:|-mTop-[v0(expHeight)]-10-[v1(scHeight)]-10-[v2(icHeight)]-10-[v3(lrbHeight)][v4]|", 
            views: self.explainLabel, 
            self.loginRegisterSegmentedControl, 
            self.containerView,
            self.loginRegisterButton, 
            self.bottomView,
            metrics: metricsDict)
        
        containerView.addSubview(nameTextField)
        containerView.addSubview(nameSeparatorView)
        containerView.addSubview(emailTextField)
        containerView.addSubview(emailSeparatorView)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(userTypeSeparatorView)
        containerView.addSubview(userTypeTextField)
        
        //Name
        nameTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        nameTextFieldHeightAnchor?.isActive = true
        
        //Name Separator
        nameSeparatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Email
        emailTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        emailTextFieldHeightAnchor?.isActive = true
        
        //Email Separator
        emailSeparatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Password
        passwordTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        passwordTextFieldHeightAnchor?.isActive = true  

        //need x, y, width, height constraints
        userTypeSeparatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        userTypeSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        userTypeSeparatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        userTypeSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
      
        //need x, y, width, height constraints
        userTypeTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        userTypeTextField.topAnchor.constraint(equalTo: userTypeSeparatorView.bottomAnchor).isActive = true        
        userTypeTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        userTypeTextFieldHeightAnchor = userTypeTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        userTypeTextFieldHeightAnchor?.isActive = true
  
        let parents: NSMutableArray = ["Father", "Mother"]
        self.userTypeDownPicker = DownPicker(textField: userTypeTextField, withData:parents as! [Any])
        
        userTypeTextFieldHeightAnchor = userTypeTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/4)
        
        userTypeDownPicker.setPlaceholder("Tap to choose relationship...")          
        
        //Register Message
        registerLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        registerLabel.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        registerLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        registerLabelHeightAnchor = registerLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        registerLabel.backgroundColor = UIColor.gambesDarkColor
        registerLabel.frame.size.width = registerLabel.intrinsicContentSize.width - 40
        registerLabel.textAlignment = .center
        registerLabel.isHidden = true
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        self.prepTextFields(inView: self.view)
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)
        
        //let deadlineTime = DispatchTime.now() + 2
        //DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
        //    self.firstTFBecomeFirstResponder(view: self.view)
        //}
        
        if self.isRegistered {
            self.loginRegisterSegmentedControl.selectedSegmentIndex = 0
            self.handleLoginRegisterChange()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        //logoImageView.isHidden = true
    }
    
    
    @objc func keyBoardWillHide(notification: NSNotification) {
        //logoImageView.isHidden = false
    }
    
    @objc func handleLoginRegisterChange()
    {
        
        if Reachability.isConnectedToNetwork() == true
        {
            if (!isMessage)
            {
                
                let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
                loginRegisterButton.setTitle(title, for: UIControlState())
                
                if (loginRegisterSegmentedControl.selectedSegmentIndex == 0)
                {
                    
                   
                    self.hideNameAndRelationship()
                    
                    emailTextFieldHeightAnchor?.isActive = false
                    emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
                    emailTextFieldHeightAnchor?.isActive = true
                    emailTextField.isHidden = false
                    
                    passwordTextFieldHeightAnchor?.isActive = false
                    passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
                    passwordTextFieldHeightAnchor?.isActive = true
                    passwordTextField.isHidden = false
                    
                    // Fucking self.containerView is not changing height
                    
                    //userTypeTextField.isHidden = true
                    
                    /*containerViewHeight = (containerViewHeightAnchor?.constant)!
                    print(containerViewHeight)
                    
                    containerViewHeightAnchor?.isActive = false
                    containerViewHeightAnchor?.constant = containerViewHeight / 2
                    containerViewHeightAnchor?.isActive = true
                    
                    self.containerView.layoutIfNeeded()
                    self.containerView.layoutSubviews()
                    
                    containerViewHeight = (containerViewHeightAnchor?.constant)!
                    print(containerViewHeight)*/
                    
                    let rect = CGRect(x: self.containerView.frame.minX, y: self.containerView.frame.minY, width: self.containerView.frame.width, height: 80)
                    
                    self.containerView.frame = rect
                    
                } else if (loginRegisterSegmentedControl.selectedSegmentIndex == 1)
                {
                    containerViewHeightAnchor?.constant = containerViewHeight
                    
                    nameTextFieldHeightAnchor?.isActive = false
                    nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
                    nameTextFieldHeightAnchor?.isActive = true
                    nameTextField.isHidden = false
                    
                    emailTextFieldHeightAnchor?.isActive = false
                    emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
                    emailTextFieldHeightAnchor?.isActive = true
                    emailTextField.isHidden = false
                    
                    passwordTextFieldHeightAnchor?.isActive = false
                    passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
                    passwordTextFieldHeightAnchor?.isActive = true
                    passwordTextField.isHidden = false
                    
                }
                
                registerLabelHeightAnchor?.isActive = false
                registerLabelHeightAnchor = registerLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0)
                registerLabelHeightAnchor?.isActive = true
                registerLabel.isHidden = true
                
            } else
            {
                
                self.hideNameAndRelationship()
                self.hideShowMessage(bol:true)
                self.isMessage = false
                
            }
            
        } else {
            
            let title = "Check connection"
            let message = "You are not connected to the Internet, please connect and try again"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)
            
            print("Internet connection FAILED")
        }
    }
    
    @objc func handleLoginRegister()
    {
        if !okLogin
        {
            
            if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
                handleLogin()
            } else {
                handleRegister()
            }
            
        } else
        {
            
            self.loginRegisterSegmentedControl.selectedSegmentIndex = 0
            self.handleLoginRegisterChange()
            
            self.okLogin = false
            
        }
    }
    
    func handleRegister()
    {
        
        if !checkForErrors()
        {

            self.activityIndicatorView?.startAnimating()

            var email = emailTextField.text
            let name = nameTextField.text
            var password = passwordTextField.text
            let relationship = userTypeTextField.text
            
            // Defining the user object
            let user = PFUser()
            user.username = email
            user.password = password
            user.email = email
            user["Name"] = name
            user["isRegister"] = true

            let full_name = name?.components(separatedBy: " ")

            user["firstName"] = full_name?[0]
            user["lastName"] = full_name?[1]
            
            //let userTypeRel:PFRelation = user.relation(forKey: "userType")
            
            var type = Int()            
            
            if relationship == "Father" {
                type = Global.REGISTER_FATHER
            } else if relationship == "Mother" {
                type = Global.REGISTER_MOTHER
            }
            
            user["iDUserType"] = type
        
            user.signUpInBackground {
                (success, error) -> Void in
                
                if let error = error as NSError?
                {
                    
                    let errorString = error.userInfo["error"] as? NSString
                    // In case something went wrong...
                    self.message = errorString as! String

                    self.activityIndicatorView?.stopAnimating()
                    
                } else {
                    
                    // Everything went ok
                    //user["userType"] = type
                    
                    self.activityIndicatorView?.stopAnimating()
                    
                    self.message="An email has been sent to your inbox. Please confirm, once then press the Login."
                    
                    self.okLogin = true
                    self.loginRegisterButton.setTitle("Ok", for: UIControlState())
                    
                    Global.defaults.set(email, forKey: "your_email")
                    Global.defaults.set(password, forKey: "your_password")
                    
                    Global.defaults.synchronize()
                    
                    Global.registerInstallationAndRole(completionHandlerRole: { ( resutl ) -> () in
                        
                        if resutl {

                             self.saveNewProfile(completionHandler: { (profile) in
                                
                                let relation:PFRelation = user.relation(forKey: "userType")
                                relation.add((Global.userTypes[type]?.userTypeObj)!)
                                
                                let profileRel:PFRelation = user.relation(forKey: "profile")
                                profileRel.add(profile)
                                
                                user.saveInBackground(block: { (resutl, error) in
                                    
                                    if error == nil
                                    {
                                        
                                        PFUser.logOut()
                                        
                                    } else
                                    {
                                        print(error)
                                    }
                                    
                                })
                                
                             })
                        }
                    })
                }
                
                self.isMessage=true
                self.handleLoginRegisterChange()
            }
        }
    }
    
    func saveNewProfile(completionHandler : @escaping (_ profile:PFObject) -> ())
    {
        
        let profilePF: PFObject = PFObject(className: "Profile")
        
        let backImage = UIImage(named: "universe")
        
        var backimagePF = PFFile(name: "background.png", data: UIImageJPEGRepresentation(backImage!, 1.0)!)
        profilePF.setObject(backimagePF, forKey: "pictureBackground")
        
        if let userId = PFUser.current()?.objectId {
            profilePF["userId"] = userId
        }
        
        profilePF["backgroundColor"] = [228, 239, 245]
        
        profilePF.saveInBackground { (resutl, error) in
            
            if error == nil {
                
                 completionHandler(profilePF)
            }
            
        }
        
    }
    
    func handleLogin() {
     
        self.activityIndicatorView?.startAnimating()   
        
        let email = emailTextField.text        
        let password = passwordTextField.text
        
        print("________________")
        print(email)
        print(password)
        print("________________")
        
        if (email?.isEmpty)!
        {
            return
        }       
        
        if (password?.isEmpty)!
        {
            return
        }
        
        // Defining the user object
        PFUser.logInWithUsername(inBackground: email!, password: password!, block: {(user, error) -> Void in
            
            if let error = error as NSError?
            {
                
                let errorString = error.userInfo["error"] as? NSString
                // Something went wrong
                self.message="Error \(errorString), please try again."
                self.isMessage=true
                self.handleLoginRegisterChange()
                
            } else {
                
                let emailVerified = user?["emailVerified"]
                
                if emailVerified as! Bool == true {
                    
                    UserDefaults.standard.setIsLoggedIn(value: true)
                    
                    if self.isRegistered {                    
                    
                        Global.getFamilyData(completionHandler: { ( result:Bool ) -> () in
                            
                            UserDefaults.standard.setIsLoggedIn(value: true)                            
                            UserDefaults.standard.setIsRegistered(value: true)
                            
                            ChatFeedMethods.queryFeed(chatId: nil, completionHandlerChatId: { ( chatId:Int ) -> () in })
                            
                            //FAMILY
                            
                            Global.defaults.set(true, forKey: "profile_completed")
                            Global.defaults.set(true, forKey: "family_exist")
                            Global.defaults.set(true, forKey: "son_exist")
                            
                            let your_family_name = Global.gamvesFamily.familyName
                            Global.defaults.set(your_family_name, forKey: "your_family_name")
                            
                            //YOU

                            let email = Global.gamvesFamily.youUser.email
                            Global.defaults.set(email, forKey: "your_email")
                            
                            let password = Global.gamvesFamily.youUser.email
                            Global.defaults.set(password, forKey: "your_password")
                            
                            let your_username = Global.gamvesFamily.youUser.userName
                            Global.defaults.set(your_username, forKey: "your_username")
                            
                            let youImage:UIImage = Global.gamvesFamily.youUser.avatar
                            
                            Global.storeImgeLocally(imagePath: Global.youImageName, imageToStore:                  youImage)
                            
                            let youImageLow = youImage.lowestQualityJPEGNSData as Data
                            var youSmallImage = UIImage(data: youImageLow)
                            
                            Global.storeImgeLocally(imagePath: Global.youImageNameSmall, imageToStore: youSmallImage!)
                            
                            //SPOUSE
                            
                            let spouse_username = Global.gamvesFamily.spouseUser.userName
                            Global.defaults.set(spouse_username, forKey: "spouse_username")
                            
                            let spouse_email = Global.gamvesFamily.spouseUser.email
                            Global.defaults.set(spouse_email, forKey: "spouse_email")
                          
                            let spouseImage:UIImage = Global.gamvesFamily.spouseUser.avatar
                            
                            Global.storeImgeLocally(imagePath: Global.spouseImageName, imageToStore: spouseImage)
                            
                            let spouseImageLow = spouseImage.lowestQualityJPEGNSData as Data
                            var spouseSmallImage = UIImage(data: spouseImageLow)
                            
                            Global.storeImgeLocally(imagePath: Global.spouseImageNameSmall, imageToStore: spouseSmallImage!)
                            
                            //SON
                            
                            let sonUser:GamvesParseUser = Global.gamvesFamily.sonsUsers[0]
                            
                            let son_name = sonUser.name
                            Global.defaults.set(son_name, forKey: "son_name")
                            
                            let son_username = sonUser.userName
                            Global.defaults.set(son_username, forKey: "son_username")
                            
                            let son_type = sonUser.typeNumber
                            Global.defaults.set(son_type, forKey: "son_type")
                            
                            let son_school = Global.gamvesFamily.school.schoolName
                            Global.defaults.set(son_school, forKey: "son_school")
                            
                            if let son_userId = sonUser.userObj.objectId {
                                Global.defaults.set(son_userId, forKey: "son_userId")
                                Global.defaults.set(son_userId, forKey: "son_object_id")
                            }
                            
                            let sonImage:UIImage = Global.gamvesFamily.sonsUsers[0].avatar
                            
                            Global.storeImgeLocally(imagePath: Global.sonImageName, imageToStore: sonImage)
                            
                            let sonImageLow = sonImage.lowestQualityJPEGNSData as Data
                            var sonSmallImage = UIImage(data: sonImageLow)
                            
                            Global.storeImgeLocally(imagePath: Global.sonImageNameSmall, imageToStore: sonSmallImage!)             
                            
                            self.tabBarViewController?.profileViewController.loadFamilyDataGromGlobal()
                            
                            self.tabBarViewController?.selectedIndex = 0 //Home
                            
                            self.activityIndicatorView?.stopAnimating()   
                            self.dismiss(animated: true, completion: nil)
                            
                        })
                        
                    } else {
                        
                        self.activityIndicatorView?.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
                else
                {
                    PFUser.logOut()
                }
            }
        })
    }

    
    func hideShowMessage(bol:Bool)
    {
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0)
        emailTextFieldHeightAnchor?.isActive = true
        emailTextField.isHidden = bol
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0)
        passwordTextFieldHeightAnchor?.isActive = true
        passwordTextField.isHidden = bol

        userTypeTextFieldHeightAnchor?.isActive = false
        userTypeTextFieldHeightAnchor = userTypeTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0)
        userTypeTextFieldHeightAnchor?.isActive = true
        userTypeTextField.isHidden = bol
        
        registerLabelHeightAnchor?.isActive = false
        registerLabelHeightAnchor = registerLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1)
        registerLabelHeightAnchor?.isActive = true
        registerLabel.isHidden = !bol
        registerLabel.text = message
    }
    
    func checkForErrors() -> Bool
    {
        var errors = false
        let title = "Validation error"
        var message = ""

        if (self.nameTextField.text?.isEmpty)! {

            errors = true
            message += "Complete name is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.nameTextField)
            
        }
        else if (emailTextField.text?.isEmpty)!
        {
            errors = true
            message += "Email is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.emailTextField)
            
            self.emailTextField.becomeFirstResponder()
        }
        else if !Global.isValidEmail(test: self.emailTextField.text!)
        {
            errors = true
            message += "Invalid Email Address"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.emailTextField)
            
        }
        else if (self.passwordTextField.text?.isEmpty)!
        {
            errors = true
            message += "Password is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.passwordTextField)
            
        }
        else if (self.passwordTextField.text?.characters.count)! < 8
        {
            errors = true
            message += "Password must be at least 8 characters"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.passwordTextField)
        
        }
        else if (userTypeTextField.text?.isEmpty)!
        {
            errors = true
            message += "Tap to choose a relationship..."
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.userTypeTextField)
            
            self.emailTextField.becomeFirstResponder()
        }
        
        return errors
    }
    

    func hideNameAndRelationship()
    {
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextField.isHidden = true
        
        userTypeTextFieldHeightAnchor?.isActive = false
        userTypeTextFieldHeightAnchor = userTypeTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0)
        userTypeTextFieldHeightAnchor?.isActive = true
        userTypeTextField.isHidden = true
            
    }
    
    func handleSelectProfileImageView()
    {
        
    }
    
}
