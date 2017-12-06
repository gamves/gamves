//
//  NewVideoController.swift
//  gamves
//
//  Created by Jose Vigil on 12/3/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import DownPicker
import Alamofire
import NVActivityIndicatorView
import SwiftyJSON
import UITextView_Placeholder

protocol SearchProtocol {
    func setResultOfsearch(videoId: String, title: String, description : String, image : UIImage)
}

class NewVideoController: UIViewController, SearchProtocol  {
    
    var homeController: HomeController?
    
    var category = CategoryGamves()

	let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesColor
        return v
    }()

	
    //-- CATEGORY     

    let categoriesContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    var categoryDownPicker: DownPicker!
    let categoryTypeTextField: UITextField = {
        let tf = UITextField()        
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let categoryTypeSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()  

    var fanpageDownPicker: DownPicker!
    let fanpageTextField: UITextField = {
        let tf = UITextField()        
        tf.translatesAutoresizingMaskIntoConstraints = false        
        return tf
    }()

    let fanpageSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var typeDownPicker: DownPicker!
    let typeTextField: UITextField = {
        let tf = UITextField()        
        tf.translatesAutoresizingMaskIntoConstraints = false        
        return tf
    }()

    //-- VIDEO

    let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    let inputVideoRowView: UIView = {
        let view = UIView()        
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()   

     let previewVideoRowView: UIView = {
        let view = UIView()        
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()

    //-- inputVideoRowView youtube

	let youtubeUrlTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Youtube url"
        tf.translatesAutoresizingMaskIntoConstraints = false
        //tf.text = "o7Kd6VVp6jE"        
        return tf
    }()

    let inputVideoSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()  

    lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor
        button.translatesAutoresizingMaskIntoConstraints = false          
        button.addTarget(self, action: #selector(handleSearch), for: .touchUpInside)  
        let imageIcon = UIImage(named: "search_icon")    
        imageIcon?.maskWithColor(color: UIColor.white)
        button.setImage(imageIcon, for: .normal)
        return button
    }()

    //-- inputVideoRowView local

    lazy var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
        button.setTitle("Record video", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)        
        button.addTarget(self, action: #selector(handleRecord), for: .touchUpInside)       
        button.layer.cornerRadius = 5 
        return button
    }()


	lazy var uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
        button.setTitle("Upload video", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)        
        button.addTarget(self, action: #selector(handleUpload), for: .touchUpInside)       
        button.layer.cornerRadius = 5 
        return button
    }()

	//-- previewVideoRowView 

	let thumbnailConteinerView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesBackgoundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var cameraView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "camera")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit        
        imageView.isUserInteractionEnabled = true          
        //imageView.backgroundColor = UIColor.gray
        imageView.tag = 0           
        return imageView
    }()

    let thumbnailSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


	let titleDescContainerView: UIView = {
        let view = UIView()        
        //view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Title"
        tf.translatesAutoresizingMaskIntoConstraints = false        
        return tf
    }()

    let titleDescSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let descriptionTextView: UITextView  = {
        let tf = UITextView()
        tf.placeholder = "Description"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false      
        return tf
    }()

    var thumbnailImage = UIImage()
    var thumbnail_url = String()
    var author_name = String()
    var videoTitle = String()
    var videoDescription = String()
    var videoId = String()

    //-- save

    var activityIndicatorView:NVActivityIndicatorView?

    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
        button.setTitle("Add video to Gamves", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)        
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)       
        button.layer.cornerRadius = 5 
        return button
    }()

    let bottomView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var searchController: SearchController = {
        let search = SearchController()
        search.newVideoController = self
        search.delegateSearch = self
        return search
    }()
    
    var metricsNew = [String:CGFloat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navItem = UINavigationItem()
        navItem.title = "Share your video"
        
        let buttonArrowBack: UIButton = UIButton (type: UIButtonType.custom)
        buttonArrowBack.setImage(UIImage(named: "arrow_back_white"), for: UIControlState.normal)
        buttonArrowBack.frame = CGRect(x:0, y:0, width:30, height:30)
        buttonArrowBack.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
        
        let arrowButton = UIBarButtonItem(customView: buttonArrowBack)
        
        navigationItem.leftBarButtonItem = arrowButton

		self.view.addSubview(self.scrollView)

		self.view.addConstraintsWithFormat("H:|[v0]|", views: self.scrollView) 
		self.view.addConstraintsWithFormat("V:|[v0]|", views: self.scrollView)
    
        self.scrollView.contentSize.width = self.view.frame.width

		self.scrollView.addSubview(self.categoriesContainerView)
        
        let cwidth:CGFloat = self.view.frame.width
        let cpadd:CGFloat = 12
        let csize:CGFloat = cwidth - (cpadd*2)
        
        print(cwidth)
        print(cpadd)
        print(csize)
        
        self.metricsNew["cpadd"]    =  cpadd
        self.metricsNew["csize"]    =  csize
        
        self.scrollView.addConstraintsWithFormat("H:|-cpadd-[v0(csize)]-cpadd-|", views: self.categoriesContainerView, metrics: metricsNew)
        
        self.scrollView.addSubview(self.videoContainerView)
		self.scrollView.addSubview(self.saveButton)
		self.scrollView.addSubview(self.bottomView)
        
        self.scrollView.addConstraintsWithFormat("H:|-cpadd-[v0(csize)]-cpadd-|", views: self.videoContainerView, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|-cpadd-[v0(csize)]-cpadd-|", views: self.saveButton, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|-cpadd-[v0(csize)]-cpadd-|", views: self.bottomView, metrics: metricsNew)

		self.scrollView.addConstraintsWithFormat(
            "V:|-cpadd-[v0(124)]-cpadd-[v1(160)]-cpadd-[v2(40)][v3]|", views:
            self.categoriesContainerView, 
            self.videoContainerView, 
            self.saveButton, 
            self.bottomView,
            metrics: metricsNew)

        //-- categoriesContainerView

        self.categoryTypeTextField.addTarget(self, action: #selector(self.categoryFieldDidChange(_:)), for: .editingChanged)

		self.categoriesContainerView.addSubview(self.categoryTypeTextField)
        self.categoriesContainerView.addSubview(self.categoryTypeSeparatorView)
        self.categoriesContainerView.addSubview(self.fanpageTextField)                
        self.categoriesContainerView.addSubview(self.fanpageSeparatorView)  
        self.categoriesContainerView.addSubview(self.typeTextField)    

        self.categoriesContainerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.categoryTypeTextField)
        self.categoriesContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.categoryTypeSeparatorView)        
        self.categoriesContainerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.fanpageTextField)
        self.categoriesContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.fanpageSeparatorView)       
        self.categoriesContainerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.typeTextField)                	

        self.categoriesContainerView.addConstraintsWithFormat(
            "V:|[v0(40)][v1(2)][v2(40)][v3(2)][v4(40)]|", 
            views: 
            self.categoryTypeTextField, 
            self.categoryTypeSeparatorView, 
            self.fanpageTextField,
            self.fanpageSeparatorView,            
            self.typeTextField) 
        
        var catArray = [String]()
        for cats in Global.categories_gamves {	
        	catArray.append(cats.name)
        }
        let categories: NSMutableArray = catArray as! NSMutableArray
        self.categoryDownPicker = DownPicker(textField: categoryTypeTextField, withData:categories as! [Any])
        self.categoryDownPicker.setPlaceholder("Tap to choose category...")

        self.categoryDownPicker.addTarget(self, action: #selector(selectedCategory), for: UIControlEvents.valueChanged )

        let types: NSMutableArray = ["Youtube", "Local"]		
        self.typeDownPicker = DownPicker(textField: typeTextField, withData:types as! [Any])
        self.typeDownPicker.setPlaceholder("Tap to choose type of video...")

        self.typeDownPicker.addTarget(self, action: #selector(selectedType), for: UIControlEvents.valueChanged )
        
        self.fanpageDownPicker = DownPicker(textField: fanpageTextField)

        self.fanpageDownPicker.isEnabled = false
        self.typeDownPicker.isEnabled = false

        //-- videoContainerView        

        self.videoContainerView.addSubview(self.inputVideoRowView)
		self.videoContainerView.addSubview(self.inputVideoSeparatorView)        
		self.videoContainerView.addSubview(self.previewVideoRowView)

		self.videoContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.inputVideoRowView)		
		self.videoContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.inputVideoSeparatorView)		
		self.videoContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.previewVideoRowView)
		
		self.videoContainerView.addConstraintsWithFormat("V:|[v0(40)][v1(2)][v2]|", views: 
			self.inputVideoRowView,
			self.inputVideoSeparatorView,
			self.previewVideoRowView)		

		//-- inputVideoRowView youtube

		self.inputVideoRowView.addSubview(self.youtubeUrlTextField)
		self.inputVideoRowView.addSubview(self.searchButton)		

		self.inputVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.youtubeUrlTextField)		
		self.inputVideoRowView.addConstraintsWithFormat("V:|[v0(40)]|", views: self.searchButton)	

		self.inputVideoRowView.addConstraintsWithFormat("H:|[v0][v1(40)]|", views: 
			self.youtubeUrlTextField,
			self.searchButton)		

		//-- inputVideoRowView local

		self.inputVideoRowView.addSubview(self.recordButton)
		self.inputVideoRowView.addSubview(self.uploadButton)		

		self.inputVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.recordButton)		
		self.inputVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.uploadButton)	

		self.inputVideoRowView.addConstraintsWithFormat("H:|[v0][v1]|", views: 
			self.recordButton,
			self.uploadButton)

		//-- previewVideoRowView 
	
		self.previewVideoRowView.addSubview(self.thumbnailConteinerView)
		self.previewVideoRowView.addSubview(self.thumbnailSeparatorView)	
		self.previewVideoRowView.addSubview(self.titleDescContainerView)			

		self.previewVideoRowView.addConstraintsWithFormat("V:|[v0(120)]|", views: self.thumbnailConteinerView)		
		self.previewVideoRowView.addConstraintsWithFormat("V:|[v0(120)]|", views: self.thumbnailSeparatorView)	
		self.previewVideoRowView.addConstraintsWithFormat("V:|[v0(120)]|", views: self.titleDescContainerView)			

		self.previewVideoRowView.addConstraintsWithFormat("H:|[v0(120)][v1(2)][v2]|", views: 
			self.thumbnailConteinerView,
			self.thumbnailSeparatorView,
			self.titleDescContainerView)

		self.thumbnailConteinerView.addSubview(self.cameraView)
		self.previewVideoRowView.addConstraintsWithFormat("H:|-15-[v0]-15-|", views: self.cameraView)		
		self.previewVideoRowView.addConstraintsWithFormat("V:|-15-[v0]-15-|", views: self.cameraView)		

		self.titleDescContainerView.addSubview(self.titleTextField)
		self.titleDescContainerView.addSubview(self.titleDescSeparatorView)		
		self.titleDescContainerView.addSubview(self.descriptionTextView)

		self.titleDescContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.titleTextField)	
		self.titleDescContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.titleDescSeparatorView)	
		self.titleDescContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.descriptionTextView)

		self.titleDescContainerView.addConstraintsWithFormat("V:|[v0(40)][v1(2)][v2]|", views:
			self.titleTextField,
			self.titleDescSeparatorView,
			self.descriptionTextView)	
		
		self.recordButton.isHidden = true
		self.uploadButton.isHidden = true

		//self.videoContainerView.isHidden = true
		//self.saveButton.isHidden = true
		//self.inputVideoRowView.isHidden = true
		//self.previewVideoRowView.isHidden = true

		self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)

		//self.handleSearch()*/ 
        
        //Looks for single or multiple taps.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

    }
    
    func backButtonPressed(sender: UIBarButtonItem)
    {
        //self.delegateFeed.uploadData()
        //self.navigationController?.popViewController(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    override func viewWillLayoutSubviews() {
        
        self.scrollView.contentSize.width = self.view.frame.width
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func selectedCategory(picker: DownPicker)
    {
        print("changed")
        
        self.fanpageDownPicker.isEnabled = true
        
        let value = picker.getTextField().text
        let fanpage = FanpageGamves()
        for cat in Global.categories_gamves {
            if cat.name == value
            {
                self.category = cat
            }
        }
        
        var fanArray = [String]()
        for fan in self.category.fanpages
        {
            fanArray.append(fan.name)
        }
        let fanpages = fanArray as! NSMutableArray
        self.fanpageDownPicker.setData(fanpages as! [Any])
        self.fanpageDownPicker.setPlaceholder("Tap to choose category...")

        self.fanpageDownPicker.addTarget(self, action: #selector(selectedFanpage), for: UIControlEvents.valueChanged )

        self.fanpageDownPicker.becomeFirstResponder()        
                
    }

    func selectedFanpage(picker: DownPicker)
    {

        let value = picker.getTextField().text
        print(value)
        
        self.typeDownPicker.isEnabled = true

        self.typeDownPicker.becomeFirstResponder()

    }


    func selectedType(picker: DownPicker)
    {

		self.videoContainerView.isHidden = false
		self.inputVideoRowView.isHidden = false
		self.previewVideoRowView.isHidden = false

    	let value = picker.getTextField().text

    	if value == "Youtube"
    	{

			self.youtubeUrlTextField.isHidden = false
			self.searchButton.isHidden = false

			self.recordButton.isHidden = true
			self.uploadButton.isHidden = true

    	} else if value == "Local"
    	{

			self.recordButton.isHidden = false
			self.uploadButton.isHidden = false

			self.youtubeUrlTextField.isHidden = true
			self.searchButton.isHidden = true
    	}
  
    }

     
    func getVideoDataUser(videoId: String, completionHandler : @escaping (_ resutl:Bool) -> ()){

    	let urlString = "\(Global.api_image_base)\(videoId)\(Global.api_image_format)"
        
        print(urlString)

        Alamofire.request(urlString, method: .get)
            .responseJSON { response in
                
                print("Success: \(response.result.isSuccess)")
                
                switch response.result {
                    case .success:
                        
                        if let json = response.result.value as? [String: Any]
                        {
                            let result = json["result"] ?? 0
                            self.thumbnail_url = (json["thumbnail_url"] as? String)!
                            self.author_name = (json["author_name"] as? String)!
                            self.videoTitle = (json["title"] as? String)!

                            print(self.thumbnail_url)
							print(self.author_name)
							print(self.videoTitle)                            

                            let coverURL = URL(string: self.thumbnail_url)!
                            let sessionCover = URLSession(configuration: .default)
                            
                            let downloadCover = sessionCover.dataTask(with: coverURL) {
                                (data, response, error) in
                                
                                guard error == nil else {
                                    print(error!)
                                    return
                                }
                                guard let data = data else {
                                    print("Data is empty")
                                    return
                                }
                                
                                if error == nil
                                {
                                    self.thumbnailImage = UIImage(data:data)!
                                    
                                    completionHandler(true)
                                    
                                }
                                
                            }
                            downloadCover.resume()
                            
                        }
                        
                        break
                    case .failure(let error):
                        print(error)
                }
           }
    }

    func getVideoDescription(videoId: String, completionHandlerDesc : @escaping (_ resutl:Bool) -> ()){

    	let urlString = "\(Global.api_desc_base)\(videoId)\(Global.api_desc_middle)\(Global.api_key)"
        
        print(urlString)

        Alamofire.request(urlString, method: .get)
            .responseJSON { response in
                
                print("Success: \(response.result.isSuccess)")
                
                switch response.result {
                    case .success:
                        
                        let jsonResponse = JSON(response.result.value!)
                            
                        var jsonArr:[JSON] = jsonResponse["items"].arrayValue
                        
                        var snptJson = jsonArr[0]["snippet"] as JSON
                        
                        self.videoDescription = snptJson["description"].stringValue
                        
                        print(self.videoDescription)
                        
                        
                        break
                    case .failure(let error):
                        print(error)
                }
           }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        
    }
    
    func categoryFieldDidChange(_ textField: UITextField) {

	}


	func handleSearch()
    {

        self.openSerarch()
        
		/*self.activityIndicatorView?.startAnimating()

    	self.getVideoDataUser(videoId: "C7i4SoN58Sk", completionHandler: { ( restul:Bool ) -> () in   		

    		self.cameraView.image = self.thumbnailImage
			self.titleTextField.text = self.videoTitle			

			self.getVideoDescription(videoId: "C7i4SoN58Sk", completionHandlerDesc: { ( restul:Bool ) -> () in

				self.descriptionTextView.text = self.videoDescription

				self.activityIndicatorView?.stopAnimating()

			})

		})*/

        
        
		/*if let keyWindow = UIApplication.shared.keyWindow 
		{

			var view:UIView!
			view = UIView(frame: keyWindow.frame)
            view.backgroundColor = UIColor.white 

            view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)           

            let searchFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)

			let searchView = SearchView(frame: searchFrame)  


			keyWindow.addSubview(searchView)    

			searchView.setViews()

			 UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                
                view.frame = keyWindow.frame
                
                }, completion: { (completedAnimation) in                   
                    
                    UIApplication.shared.setStatusBarHidden(true, with: .fade)
            })        

		}*/

    }


    
    
    func openSerarch()
    {
        //searchController.isGroup = group
        searchController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(searchController, animated: true)
    }

	func handleSave()
    {

    }
   
   	func handleRecord()
    {

    }

    func handleUpload()
    {

    }


    func setResultOfsearch(videoId: String, title: String, description : String, image : UIImage)
    {
    	self.videoId = videoId
    	self.videoTitle = title
    	self.videoDescription = description
    	self.thumbnailImage = image

    	self.titleTextField.text = title
    	self.descriptionTextView.text = description
    	self.cameraView.image = image    	
    }   

}

