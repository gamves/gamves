//
//  AccountViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 24/01/2018.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit
import Parse

class AccountViewController: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate, 
    UICollectionViewDelegateFlowLayout {
    
    var homeViewController:HomeViewController?
    
    var tabBarViewController:TabBarViewController?

    var accountButton = [AccountButton]()

    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.backgroundColor = UIColor.white
        return v
    }()

    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gamvesBackgoundColor
        return view
    }()

     var backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill //.scaleFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let photosContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()

     var yourLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()

      let lineView: UIView = {
         let v = UIView()
         v.translatesAutoresizingMaskIntoConstraints = false
         v.backgroundColor = UIColor.gray
         return v
    }()

    let buttonLeftView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()

    let buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()

    let buttonRightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()

    lazy var sonPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "son_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSonPhotoImageView)))
        imageView.isUserInteractionEnabled = true        
        imageView.tag = 1
        return imageView
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()


    var photoCornerRadius = Int()

    var cellId = String()

    var _profile = AccountButton()
    var _payment = AccountButton()
    var _school = AccountButton()
    var _admin = AccountButton()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.cellId = "accountCellId"

        self.view.addSubview(self.scrollView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.scrollView)
        self.view.addConstraintsWithFormat("V:|[v0]-50-|", views: self.scrollView)

        self.scrollView.addSubview(self.headerView)
        self.scrollView.addSubview(self.lineView)
        self.scrollView.addSubview(self.buttonsView)
        
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.headerView)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)  
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.buttonsView)  

        let height:Int = Int(view.frame.size.height)
        let width:Int = Int(view.frame.size.width)

        let componentsHeight = height - 221

        var metricsComponents = [String:Int]()
        metricsComponents["componentsHeight"] = componentsHeight

        self.scrollView.addConstraintsWithFormat(
            "V:|[v0(220)][v1(1)][v2(componentsHeight)]|", views:
            self.headerView,
            self.lineView,
            self.buttonsView,
            metrics: metricsComponents)

        self.headerView.addSubview(self.backImageView)
        self.headerView.addSubview(self.photosContainerView)
        self.headerView.addSubview(self.yourLabel)

        self.headerView.addConstraintsWithFormat("H:|[v0]|", views: self.backImageView)
        self.headerView.addConstraintsWithFormat("V:|[v0(100)]|", views: self.backImageView)

        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.photosContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.yourLabel)

        var metricsHeader = [String:Int]()
        let photoSize = width / 3
        let padding = (width - photoSize) / 2

        metricsHeader["photoSize"] = photoSize
        metricsHeader["padding"] = padding

         self.headerView.addConstraintsWithFormat(
            "V:|-40-[v0(photoSize)][v1]|", views:
            self.photosContainerView,
            self.yourLabel,
            metrics: metricsHeader)
        
        self.backImageView.image = Global.yourAccountBackImage
        self.sonPhotoImageView.image = Global.gamvesFamily.youUser.avatar

        self.photosContainerView.addSubview(self.sonPhotoImageView)
        
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.sonPhotoImageView)
        
        var metricsVerBudge = [String:Int]()
        
        metricsVerBudge["verPadding"] = photoSize - 25     
        
        self.photosContainerView.addConstraintsWithFormat(
            "H:|-padding-[v0(photoSize)]-padding-|", views:
            self.sonPhotoImageView,
            metrics: metricsHeader)
        
        self.photoCornerRadius = photoSize / 2

        Global.setRoundedImage(image: self.sonPhotoImageView, cornerRadius: self.photoCornerRadius, boderWidth: 5, boderColor: UIColor.gamvesBackgoundColor)              
       
        self.collectionView.register(AccountCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)

        _profile.desc = "Profile"
        _profile.icon = UIImage(named: "identity")!
        _profile.id = 0
        self.accountButton.append(_profile)

        _payment.desc = "Payments"
        _payment.icon = UIImage(named: "payment")!
        _payment.id = 1
        self.accountButton.append(_payment)

        _school.desc = "School"
        _school.icon = UIImage(named: "school")!
        _school.id = 2
        self.accountButton.append(_school)

        _admin.desc = "Administrator"
        _admin.icon = UIImage(named: "admin")!
        _admin.id = 3
        self.accountButton.append(_admin)

        self.buttonsView.addSubview(self.buttonLeftView)
        self.buttonsView.addSubview(self.collectionView)        
        self.buttonsView.addSubview(self.buttonRightView)

        self.buttonsView.addConstraintsWithFormat("V:|-20-[v0]|", views: self.collectionView)
        self.buttonsView.addConstraintsWithFormat("V:|-20-[v0]|", views: self.buttonLeftView)
        self.buttonsView.addConstraintsWithFormat("V:|-20-[v0]|", views: self.buttonRightView)

        self.buttonsView.addConstraintsWithFormat("H:|[v0(20)][v1][v2(20)]|", views: 
            self.buttonLeftView, 
            self.collectionView, 
            self.buttonRightView)              

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AccountCollectionViewCell
        let id = indexPath.row        
        var accountButon = self.accountButton[id]
        cell.descLabel.text = accountButon.desc        
        cell.iconImageView.image = accountButon.icon
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.accountButton.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat =  10
        let collectionViewSize = collectionView.frame.size.width - padding
        
        let size = CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
        
        return size
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()     
    }
    
    

}
