//
//  MessageCell.swift
//  gamves
//
//  Created by Jose Vigil on 10/11/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//


import UIKit

class MessageCell: BaseCell {
    
    /*override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            timeLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            messageLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }*/

    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark Zuckerberg"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Your friend's message and something else..."
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "12:05 pm"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .right
        return label
    }()
    
    var hasReadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var isImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var badgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()

    var audioIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "rec_on")
        imageView.isHidden = true
        return imageView
    }()
    
    var pictureIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "camera_black")
        imageView.isHidden = true
        return imageView
    }()    
     
    override func setupViews() {        
      
        addSubview(profileImageView)
        addSubview(dividerLineView)
        
        setupContainerView()
        
        addConstraintsWithFormat("H:|-12-[v0(68)]", views: profileImageView)
        addConstraintsWithFormat("V:[v0(68)]", views: profileImageView)
        
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat("V:[v0(1)]|", views: dividerLineView)   

        let clear = UIColor(white: 1, alpha: 0).cgColor
        let gamvesBackgoundColor = UIColor.gamvesBackgoundColor.cgColor
        
    }
    
    fileprivate func setupContainerView() {
        
        let containerView = UIView()
        addSubview(containerView)
        
        addConstraintsWithFormat("H:|-90-[v0]|", views: containerView)
        addConstraintsWithFormat("V:[v0(50)]", views: containerView)
        
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        badgeLabel =  Global.createCircularLabel(text: "✓", size: 25, fontSize: 13.0, borderWidth: 0.0, color: UIColor.gamvesColor)
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(isImageView)
        containerView.addSubview(hasReadImageView)
        containerView.addSubview(badgeLabel)
        containerView.addSubview(audioIconView)
        containerView.addSubview(pictureIconView)

        containerView.addConstraintsWithFormat("H:|[v0][v1(110)]-12-|", views: nameLabel, timeLabel)
        
        containerView.addConstraintsWithFormat("V:|[v0][v1(24)]|", views: nameLabel, messageLabel)
        
        containerView.addConstraintsWithFormat("H:|[v0]-8-[v1(20)]-8-[v2(20)]-8-[v3(25)]-12-|", views: messageLabel, isImageView, hasReadImageView, badgeLabel)
        
        containerView.addConstraintsWithFormat("V:|[v0(24)]", views: timeLabel)
        
        containerView.addConstraintsWithFormat("V:[v0(20)]|", views: isImageView)
        
        containerView.addConstraintsWithFormat("V:[v0(20)]|", views: hasReadImageView)
        
        containerView.addConstraintsWithFormat("V:[v0(25)]|", views: badgeLabel)
        
        containerView.addConstraintsWithFormat("H:|[v0(20)]|", views: self.audioIconView)
        containerView.addConstraintsWithFormat("V:|-28-[v0(20)]|", views: self.audioIconView)
        
        containerView.addConstraintsWithFormat("H:|[v0(20)]|", views: self.pictureIconView)
        containerView.addConstraintsWithFormat("V:|-28-[v0(20)]|", views: self.pictureIconView)

    }
    
}
