//
//  ImagePickerViewController.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-05-20.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit
import RSKImageCropper
import NVActivityIndicatorView

protocol ImagesPickerProtocol {
   func didpickImage(type:ProfileImagesTypes) 
   func saveYouImageAndPhone(phone:String)
   func closeImagesPicker()
}

enum ProfileImagesTypes {
    case Son
    case Family
    case You
    case Partner
}

class ImagePickerViewController: UIViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
RSKImageCropViewControllerDelegate,
UITextFieldDelegate  {

    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesColor
        return v
    }()

    var activityIndicatorView:NVActivityIndicatorView?
    
    var imageCropVC = RSKImageCropViewController()
    
    var type:ProfileImagesTypes!

    var imagesPickerProtocol:ImagesPickerProtocol!

    let topView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.yellow
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false        
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center        
        return label
    }()

     let photoContainerView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()

     lazy var pictureImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.image = UIImage(named: "son_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))        
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 0           
        return imageView
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false        
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()

    let phoneLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false        
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 3
        //label.backgroundColor = UIColor.brown
        return label
    }()

    let schoolLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false        
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 3        
        return label
    }()

    var sonSchoolDownPicker: DownPicker!
    let sonSchoolTextField: UITextField = {
        let tf = UITextField()        
        tf.backgroundColor = UIColor.white
        tf.translatesAutoresizingMaskIntoConstraints = false        
        return tf
    }()

    let phoneTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "    Cellphone number"
        tf.translatesAutoresizingMaskIntoConstraints = false  
        tf.backgroundColor = UIColor.white 
        tf.font = UIFont.boldSystemFont(ofSize: 20)     
        tf.layer.cornerRadius = 10.0
        tf.tag = 0
        tf.text = "155 181 2085"
        tf.keyboardType = UIKeyboardType.decimalPad
        return tf
    }()
    
    lazy var finishButton: UIButton = {
        let button = UIButton(type: .system)
        //let image = UIImage(named: "add_image")
        //button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gambesDarkColor
        button.tintColor = .white
        button.layer.cornerRadius = 5        
        button.titleLabel!.font =  UIFont.boldSystemFont(ofSize: 18)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleFinish), for: .touchUpInside)
        return button
    }()

    let bottomView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.yellow
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()

    let imagePicker = UIImagePickerController()

    var smallImage = UIImage()

    var croppedImage = UIImage()   

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imagePicker.delegate = self

        self.view.addSubview(self.scrollView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.scrollView)        
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.scrollView)     

        self.view.backgroundColor = UIColor.gamvesColor

        self.scrollView.addSubview(self.topView)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.topView)        
        
        self.scrollView.addSubview(self.photoContainerView)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.photoContainerView)

        self.scrollView.addSubview(self.messageLabel)
        self.scrollView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.messageLabel)
        
        self.scrollView.addSubview(self.schoolLabel)
        self.scrollView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.schoolLabel)

        self.scrollView.addSubview(self.sonSchoolTextField)
        self.scrollView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.sonSchoolTextField)  

        self.scrollView.addSubview(self.phoneLabel)
        self.scrollView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.phoneLabel)

        self.scrollView.addSubview(self.phoneTextField)
        self.scrollView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.phoneTextField)  

        self.scrollView.addSubview(self.finishButton)
        self.scrollView.addConstraintsWithFormat("H:|-60-[v0]-60-|", views: self.finishButton)       

        self.scrollView.addSubview(self.bottomView)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.bottomView)

        var metricsPicker = [String:Int]()

        let width:Int = Int(self.view.frame.size.width)
        let height:Int = Int(self.view.frame.size.height)
        let photoSize = width / 3        

        metricsPicker["photoSize"] = photoSize  

        if (self.type == .You) {
            metricsPicker["phoneHeight"] = 40
            metricsPicker["phoneGap"] = 30
        } else {
            metricsPicker["phoneHeight"] = 0
            metricsPicker["phoneGap"] = 10
        }           

        self.scrollView.addConstraintsWithFormat(
            "V:|-10-[v0(100)]-10-[v1(photoSize)][v2(40)][v3(phoneHeight)]-5-[v4(phoneHeight)]-5-[v5(phoneHeight)]-5-[v6(phoneHeight)]-phoneGap-[v7(60)][v8]|", views: 
            self.topView,
            self.photoContainerView,
            self.messageLabel,
            self.schoolLabel,            
            self.sonSchoolTextField,
            self.phoneLabel,
            self.phoneTextField,
            self.finishButton,
            self.bottomView,
            metrics: metricsPicker)

        photoContainerView.addSubview(self.pictureImageView)
        photoContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.pictureImageView)
        photoContainerView.addConstraintsWithFormat("H:|-photoSize-[v0(photoSize)]-photoSize-|", views: 
            self.pictureImageView, 
            metrics: metricsPicker)                      

        self.topView.addSubview(self.titleLabel)        
        self.topView.addConstraintsWithFormat("H:|[v0]|", views: self.titleLabel)
        self.topView.addConstraintsWithFormat("V:|-40-[v0(80)]|", views: 
            self.titleLabel)      

        self.setScreenByType()        

        // Do any additional setup after loading the view.

        if self.type == .You {

            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)

            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            self.scrollView.addGestureRecognizer(tap)
        }

        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)

        Global.loadSchools(completionHandler: { ( user, schoolsArray ) -> () in           

            self.sonSchoolDownPicker = DownPicker(textField: self.sonSchoolTextField, withData:schoolsArray as! [Any])
            self.sonSchoolDownPicker.setPlaceholder("Tap to choose school...")                        
            self.sonSchoolDownPicker.addTarget(self, action: #selector(self.handleSchoolPickerChange), for: .valueChanged)

        })

        self.setNavBar()
    }

    func setNavBar()
    {            

        var title = String()

        if self.type == .You {

            title = "Personal Information"            

            let buttonIcon = UIImage(named: "arrow_back_white")        
            let leftBarButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(cancelButton(sender:)))
            leftBarButton.image = buttonIcon        

            self.navigationItem.leftBarButtonItem = leftBarButton         

        
        } else {

            title = "Add family"

            let rightBarButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.done, target: self, action: #selector(cancelButton(sender:)))
        
            self.navigationItem.rightBarButtonItem = rightBarButton   

        }

        self.navigationItem.title = title   
       
    }

    @objc func cancelButton(sender: UIButton) {

        self.imagesPickerProtocol.closeImagesPicker()
    }

    @objc func handleSchoolPickerChange() {

        let sKeys = Array(Global.schools.keys)
        
        for s in sKeys {

            let schoolId = Global.schools[s]!.objectId

            if self.sonSchoolTextField.text! == Global.schools[schoolId]?.schoolName {

                Global.schoolShort = Global.schools[schoolId]!.short

                Global.schoolId = schoolId

                print(Global.schoolShort)
            }            
        }                       
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        print("fuck dismiss")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let currentDateTime = Date()
        print(currentDateTime)
        print("fuck viewWillDisappear")
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


    @objc func keyboardWillShow(notification:NSNotification) {

        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 100
        self.scrollView.contentInset = contentInset

        
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                 target: self, action: #selector(doneButton_Clicked))

         toolbarDone.items = [barBtnDone] 

         toolbarDone.sizeToFit()

        DispatchQueue.main.async
        {
            self.phoneTextField.inputAccessoryView = toolbarDone
        }
    }

    @objc func doneButton_Clicked() {

        print("clicked")        

        self.view.endEditing(true)
    }

    @objc func keyboardWillHide(notification:NSNotification) {

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }

    func setScreenByType() {        

        self.activityIndicatorView?.stopAnimating()

        var title = String()
        var message = String()
        var buttonTitle = String()        
        var imageName = String()

        switch self.type {
             
            case .You?:

                    title = "Your Image"
                    message = "Choose your image"
                    buttonTitle = "  Select Your Image"
                    buttonTitle = "  Save image phone"
                    imageName = "your_photo" 

                    let phoneTitle = "  Your phone number"    
                    self.phoneLabel.text = phoneTitle            

                    let schoolTitle = "  Choose your school"    
                    self.schoolLabel.text = schoolTitle            

                    break

            case .Son?: 

                    title = "Child Image"
                    message = "Pick up an image for your son by touching the (+) add image"
                    buttonTitle = " Next family image"
                    imageName = "son_photo"
                    
                    break
                
            case .Family?:

                    title = "Family Image"
                    message = "Choose a family image where the three of you are present"
                    buttonTitle = " Next partner Image"
                    imageName = "family_photo"

                    break           

            case .Partner?:

                    title = "Partner Image"
                    message = "Choose your partner image"
                    buttonTitle = " Next complete forms"
                    imageName = "partner_photo"

                    break    
                
                default: break
            
        }

        self.titleLabel.text = title
        self.pictureImageView.image = UIImage(named: imageName)
        self.messageLabel.text = message
        self.finishButton.setTitle(buttonTitle, for: .normal)
        self.finishButton.isEnabled = false

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        
    }

    @objc func handleFinish(sender: UIButton) {

        self.activityIndicatorView?.startAnimating()

        sender.isUserInteractionEnabled = false         
        
        print(self.type)
        print(self.croppedImage)
        print(self.smallImage)
        print(self.imagesPickerProtocol)

        switch self.type {                

            case .You?:                            

                Global.yourPhotoImage                = self.croppedImage
                Global.yourPhotoImageSmall           = self.smallImage        
                
                self.imagesPickerProtocol.didpickImage(type: self.type)
                
                let phoneNumber = phoneTextField.text
                self.imagesPickerProtocol.saveYouImageAndPhone(phone: phoneNumber!)

                self.navigationController?.popViewController(animated: true)
               
                break
                
            case .Son?: 

                //sender.isUserInteractionEnabled = true                             

                self.type = ProfileImagesTypes.Family       

                Global.sonPhotoImage              = self.croppedImage
                Global.sonPhotoImageSmall         = self.smallImage        

                self.setScreenByType()

                break
                
            case .Family?:                
                

                self.type = ProfileImagesTypes.Partner                

                self.setScreenByType()

                Global.familyPhotoImage             = self.croppedImage
                Global.familyPhotoImageSmall        = self.smallImage

                self.setScreenByType()                    
                
                break       

            case .Partner?:                
                    
                Global.partnerPhotoImage              = self.croppedImage
                Global.partnerPhotoImageSmall         = self.smallImage

                self.imagesPickerProtocol.didpickImage(type: self.type)

                //self.navigationController?.popViewController(animated: true)

                //self.dismiss(animated:true)

                self.activityIndicatorView?.startAnimating()
                
                break    
                
            default: break                
        }
        
    }
    
    func setType(type:ProfileImagesTypes){
        self.type = type        
    }

    @objc func handlePhotoImageView(sender: UITapGestureRecognizer)
    {    
        let actionSheet = UIAlertController(title: "Select Input", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        actionSheet.addAction(cancelAction)
         
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (UIAlertAction) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
             
        }))
         
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (UIAlertAction) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
             
        }))        
         
        let popover = actionSheet.popoverPresentationController        
        popover?.permittedArrowDirections = UIPopoverArrowDirection.any


        // iPad spport
        if Global.device.lowercased().range(of:"ipad") != nil {
            
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = self.view.frame

        }
         
        present(actionSheet, animated: true, completion: nil)

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage 
        {            
            self.imageCropVC = RSKImageCropViewController(image: image, cropMode: .circle)
            self.imageCropVC.delegate = self
            self.navigationController?.pushViewController(imageCropVC, animated: true)         
        }

        picker.dismiss(animated: true, completion: nil);
        
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        let imageLow = croppedImage.lowestQualityJPEGNSData as Data
        
        self.smallImage = UIImage(data: imageLow)!
        
        self.croppedImage = croppedImage

        self.pictureImageView.image = croppedImage

        self.makeRounded(imageView:self.pictureImageView)

        self.finishButton.isEnabled = true

        self.finishButton.isUserInteractionEnabled = true  
        
        navigationController?.popViewController(animated: true)
    }
    

    @objc func dismissKeyboard() {
        self.scrollView.endEditing(true)
    }

    func makeRounded(imageView:UIImageView)
    {
        imageView.contentMode = UIViewContentMode.scaleToFill
        imageView.layer.cornerRadius = imageView.frame.size.width / 2            
        imageView.clipsToBounds = true         
        imageView.layer.borderColor = UIColor.gamvesBlackColor.cgColor
        imageView.layer.borderWidth = 3
    }


}
