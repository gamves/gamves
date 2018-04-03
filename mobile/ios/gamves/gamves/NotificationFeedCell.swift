//
//  MessageCell.swift
//  gamves
//
//  Created by Jose Vigil on 10/11/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//


import UIKit
import PulsingHalo

class NotificationFeedCell: BaseCell {
    
    var checked = Bool()
    
    let thumbnailImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let rowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let userProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let labelsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let notificationName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let notficationDatePublish: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsetsMake(0, -4, 0, 0)
        textView.textColor = UIColor.lightGray
        return textView
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var checkView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    var titleLabelHeightConstraint: NSLayoutConstraint?
    
    override func setupViews()
    {
        
        addSubview(thumbnailImageView)
        addSubview(rowView)
        addSubview(separatorView)
        
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: thumbnailImageView)
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: rowView)
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: separatorView)
        
        addConstraintsWithFormat("V:|-16-[v0]-8-[v1(50)]-10-[v2(1)]|",
                                 views: thumbnailImageView, rowView, separatorView)
        
        rowView.addSubview(userProfileImageView)
        rowView.addSubview(labelsView)
        
        rowView.addConstraintsWithFormat("H:|[v0(50)]|", views: userProfileImageView)
        rowView.addConstraintsWithFormat("V:|[v0(50)]|", views: userProfileImageView)
        
        rowView.addConstraintsWithFormat("H:|-50-[v0]|", views: labelsView)
        rowView.addConstraintsWithFormat("V:|[v0(50)]|", views: labelsView)
        
        labelsView.addSubview(notificationName)
        labelsView.addSubview(notficationDatePublish)
        
        labelsView.addConstraintsWithFormat("H:|-10-[v0]|", views: notificationName)
        labelsView.addConstraintsWithFormat("V:|[v0(25)]|", views: notificationName)
        
        labelsView.addConstraintsWithFormat("H:|-10-[v0]|", views: notficationDatePublish)
        labelsView.addConstraintsWithFormat("V:|-25-[v0(25)]|", views: notficationDatePublish)
        
        self.separatorView.backgroundColor = UIColor.lightGray
        
        self.checkView = UIView()
        
        var checkLabel = UILabel()
        
        checkLabel =  Global.createCircularLabel(text: "New", size: 60, fontSize: 20.0, borderWidth: 3.0, color: UIColor.red)
        
        let haloCheck = PulsingHaloLayer()
        haloCheck.position.x = checkLabel.center.x
        haloCheck.position.y = checkLabel.center.y
        haloCheck.haloLayerNumber = 5
        haloCheck.backgroundColor = UIColor.white.cgColor
        haloCheck.radius = 100
        haloCheck.start()
        
        self.checkView.layer.addSublayer(haloCheck)
        
        let cw = self.frame.width
        let ch = cw * 9 / 16
        
        let pr = cw - 100
        let pt = ch - 80
        
        let paddingMetrics = ["pr":pr,"pt":pt]
        
        self.addSubview(self.checkView)
        self.addConstraintsWithFormat("H:|-pr-[v0(30)]", views: self.checkView, metrics : paddingMetrics)
        self.addConstraintsWithFormat("V:|-pt-[v0(30)]", views: self.checkView, metrics : paddingMetrics)
        
        self.checkView.addSubview(checkLabel)
        self.checkView.addConstraintsWithFormat("H:|[v0(60)]|", views: checkLabel)
        self.checkView.addConstraintsWithFormat("V:|[v0(60)]|", views: checkLabel)
        
        
    }
    
}