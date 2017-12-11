//
//  NewVideoController.swift
//  gamves
//
//  Created by Jose Vigil on 12/3/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import DownPicker
import Alamofire
import NVActivityIndicatorView
import SwiftyJSON
import UITextView_Placeholder
import AVFoundation
import MobileCoreServices


protocol VideoProtocol {
    func selectedVideo(videoUrl: String, title: String, description : String, image : UIImage)
}


protocol SearchProtocol {
    func setResultOfsearch(videoId: String, title: String, description : String, image : UIImage)
}

class NewVideoController: UIViewController, SearchProtocol, TakePicturesDelegate {
    
    var homeController: HomeController?
    
    var category = CategoryGamves()

	let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesColor
        return v
    }()

	//-- TITTLE
    
    let welcome: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Select category, fanpage and type"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
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
    
    let categorySeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //-- VIDEO

    let youtubeVideoRowView: UIView = {
        let view = UIView()        
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.cornerRadius = 5        
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white
        return view
    }()   

    let localVideoRowView: UIView = {
        let view = UIView()        
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.gamvesColor
        return view
    }() 

     let previewVideoRowView: UIView = {
        let view = UIView()        
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5   
        return view
    }()
    
    let previewVideoSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //-- youtubeVideoRowView youtube

	let youtubeUrlTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Youtube url"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.layer.cornerRadius = 5
        tf.backgroundColor = UIColor.white
        //tf.text = "o7Kd6VVp6jE"        
        return tf
    }()     

    lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor
        button.translatesAutoresizingMaskIntoConstraints = false          
        button.addTarget(self, action: #selector(handleSearch), for: .touchUpInside)  
        let imageIcon = UIImage(named: "search_icon")    
        imageIcon?.maskWithColor(color: UIColor.white)
        button.setImage(imageIcon, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()

    let youtubeVideoSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }() 

    //-- localVideoRowView local

    lazy var videoButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
        button.setTitle("Record video", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)        
        button.addTarget(self, action: #selector(handleVideo), for: .touchUpInside)       
        button.layer.cornerRadius = 5 
        return button
    }()	

    let localVideoSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

	//-- previewVideoRowView 

	let thumbnailConteinerView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesBackgoundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var cameraButton: UIButton = {
        let cameraButton = UIButton()
        let image = UIImage(named: "camera")
        cameraButton.setImage(image, for: .normal)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.contentMode = .scaleAspectFit
        cameraButton.isUserInteractionEnabled = true
        cameraButton.addTarget(self, action: #selector(handleCameraImage), for: .touchUpInside)
        cameraButton.tag = 0
        return cameraButton
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
        tf.backgroundColor = UIColor.white
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
    
    var videoSelLocalUrl:URL?
    var videoSelData = Data()
    var videoSelThumbnail = UIImage()
    
    var newVideoId = String()
    
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
        
        //-- categoriesContainerView
        
        self.categoryTypeTextField.addTarget(self, action: #selector(self.categoryFieldDidChange(_:)), for: .editingChanged)

		self.view.addConstraintsWithFormat("H:|[v0]|", views: self.scrollView) 
		self.view.addConstraintsWithFormat("V:|[v0]|", views: self.scrollView)
    
        self.scrollView.contentSize.width = self.view.frame.width

        self.scrollView.addSubview(self.welcome)
		self.scrollView.addSubview(self.categoriesContainerView)
        self.scrollView.addSubview(self.categorySeparatorView)        
        self.scrollView.addSubview(self.localVideoRowView)
        self.scrollView.addSubview(self.localVideoSeparatorView)
        self.scrollView.addSubview(self.youtubeVideoRowView)
        self.scrollView.addSubview(self.youtubeVideoSeparatorView)
        self.scrollView.addSubview(self.previewVideoRowView)
        self.scrollView.addSubview(self.previewVideoSeparatorView)
        self.scrollView.addSubview(self.saveButton)
        self.scrollView.addSubview(self.bottomView)
        
        let cwidth:CGFloat = self.view.frame.width
        let cp:CGFloat = 12
        let cs:CGFloat = cwidth - (cp*2)
        
        print(cwidth)
        print(cp)
        print(cs)
        
        self.metricsNew["cp"]    =  cp
        self.metricsNew["cs"]    =  cs

        self.scrollView.addConstraintsWithFormat(
            "V:|[v0(40)][v1(124)][v2(cp)][v3(40)][v4(cp)][v5(40)][v6(cp)][v7(120)][v8(cp)][v9(60)][v10]|", views:
            self.welcome,
            self.categoriesContainerView,
            self.categorySeparatorView,            
            self.localVideoRowView,
            self.localVideoSeparatorView,
            self.youtubeVideoRowView,
            self.youtubeVideoSeparatorView,
            self.previewVideoRowView,
            self.previewVideoSeparatorView,
            self.saveButton,
            self.bottomView,
            metrics: metricsNew)
        
        self.scrollView.addConstraintsWithFormat("H:|[v0(cs)]|", views: self.welcome, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.categoriesContainerView, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.categorySeparatorView, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.youtubeVideoRowView, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.youtubeVideoSeparatorView, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.localVideoRowView, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.localVideoSeparatorView, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.previewVideoRowView, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.saveButton, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.bottomView, metrics: metricsNew)
        
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

        self.categoryTypeTextField.becomeFirstResponder()

        var catArray = [String]()
        
        let ids = Array(Global.categories_gamves.keys)
        
        for i in ids {
            catArray.append((Global.categories_gamves[i]?.name)!)
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

		//-- youtubeVideoRowView youtube

		self.youtubeVideoRowView.addSubview(self.youtubeUrlTextField)
		self.youtubeVideoRowView.addSubview(self.searchButton)		

		self.youtubeVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.youtubeUrlTextField)		
		self.youtubeVideoRowView.addConstraintsWithFormat("V:|[v0(40)]|", views: self.searchButton)	

		self.youtubeVideoRowView.addConstraintsWithFormat("H:|[v0][v1(40)]|", views: 
			self.youtubeUrlTextField,
			self.searchButton)		

		//-- youtubeVideoRowView local

		self.localVideoRowView.addSubview(self.videoButton)
				

		self.localVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.videoButton)
        self.localVideoRowView.addConstraintsWithFormat("H:|[v0]|", views:
			self.videoButton)

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

		self.thumbnailConteinerView.addSubview(self.cameraButton)
		self.previewVideoRowView.addConstraintsWithFormat("H:|[v0]|", views: self.cameraButton)
		self.previewVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.cameraButton)

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
		
		//self.videoButton.isHidden = true
		//self.uploadButton.isHidden = true

		//self.youtubeUrlTextField.isHidden = true
		//self.searchButton.isHidden = true

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
        
        let ids = Array(Global.categories_gamves.keys)
        
        for i in ids {
            let cat = Global.categories_gamves[i]
            if cat?.name == value
            {
                self.category = cat!
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

        self.typeTextField.becomeFirstResponder()

    }


    func selectedType(picker: DownPicker)
    {

		self.titleDescContainerView.isHidden = false
		self.youtubeVideoRowView.isHidden = false
		self.previewVideoRowView.isHidden = false

    	let value = picker.getTextField().text

    	if value == "Youtube"
    	{
            
			//self.youtubeUrlTextField.alpha = 1
			//self.searchButton.alpha = 1
            //self.youtubeVideoRowView.alpha = 1

			//self.videoButton.alpha = 0.25
			//self.uploadButton.alpha = 0.25
            
            self.youtubeUrlTextField.isUserInteractionEnabled = true
            self.searchButton.isUserInteractionEnabled = true
            
            self.videoButton.isUserInteractionEnabled = false
            

    	} else if value == "Local"
    	{

            self.videoButton.isUserInteractionEnabled = true

            self.youtubeUrlTextField.isUserInteractionEnabled = false
            self.searchButton.isUserInteractionEnabled = false
            
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

        //searchController.isGroup = group
        searchController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(searchController, animated: true)
    }

  
    func handleCameraImage() {
        print("handleCameraImage")
        
        //let mediaPickerController = MediaPickerController(type: MediaPickerControllerType.imageOnly, presentingViewController: self )
        //mediaPickerController.show()
        
        let takePictures = TakePictures()
        takePictures.setType(type: TakePictureType.selectImage)
        navigationController?.pushViewController(takePictures, animated: true)
    }
    
    func didPickImage(_ image: UIImage){
        self.cameraButton.setImage(image, for: .normal)
        self.videoSelThumbnail = image
    }
    func didPickVideo(url: URL, data: Data, thumbnail: UIImage){
        self.videoSelLocalUrl = url
        self.videoSelData = data
    }

   	func handleVideo() {
        print("handleUpload")
        let takePictures = TakePictures()
        takePictures.setType(type: TakePictureType.selectVideo)
        navigationController?.pushViewController(takePictures, animated: true)
    }
    
    func setResultOfsearch(videoId: String, title: String, description : String, image : UIImage)
    {
    	self.videoId = videoId
    	self.videoTitle = title
    	self.videoDescription = description
    	self.thumbnailImage = image

    	self.titleTextField.text = title
    	self.descriptionTextView.text = description
    	self.cameraButton.setImage(image, for: .normal)
    }
    
    func handleSave() {
        
        if !checErrors()
        {
        
            print("hanhandleSavedleRecord")
            
            let videoPF: PFObject = PFObject(className: "VideoNew")
            
            videoPF["title"] = titleTextField.text
            
            videoPF["description"] = descriptionTextView.text
            
            let videoId = Global.getRandomInt()
            
            videoPF["videoId"] = videoId
        
            //let videoFile = PFFile(data: self.videoSelData)
            
            let thumbFile = PFFile(data: UIImageJPEGRepresentation(self.videoSelThumbnail, 1.0)!)
            
            videoPF.saveInBackground { (resutl, error) in
                
                if error != nil
                {
                    self.newVideoId = videoPF.objectId!
                    
                    
                }
            
                
                
            }
        }
        
    }
    
    func checErrors() -> Bool
    {
        var errors = false
        let title = "Error"
        var message = ""
        
        if self.videoSelThumbnail == nil
        {
            errors = true
            message += "Thumbnail image is empty please add a new video"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)
            
        } else if self.videoSelData == nil
        {
            errors = true
            message += "Please choose a video"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)
            
        } else if (self.categoryTypeTextField.text?.isEmpty)!
        {
            errors = true
            message += "Catgory is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.categoryTypeTextField)
            
        } else if (self.fanpageTextField.text?.isEmpty)!
        {
            errors = true
            message += "Fanpage is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.fanpageTextField)
            
        } else if ((self.typeDownPicker.getTextField().text == "Youtube") && (self.youtubeUrlTextField.text?.isEmpty)!)
        {
            errors = true
            message += "Youtube video is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.youtubeUrlTextField)
            
        }
        else if (self.titleTextField.text?.characters.count)! < 8
        {
            errors = true
            message += "The title of the video is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.titleTextField)
        }
        else if (self.descriptionTextView.text?.isEmpty)!
        {
            errors = true
            message += "The description of the video is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)
        }
        return errors
    }

    
    

}


