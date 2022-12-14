//
//  SearchImageCell.swift
//  gamves
//
//  Created by Jose Vigil on 12/29/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

public enum SearchActionType {
    case isDelete
    case isCheck
}

class SearchSingleImageCell: UITableViewCell {
    
    var checked = Bool()
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            
            //nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            //statusLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            
        }
    }
    
    let conteinerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()

    
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    public var checkLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        return label
    }()

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupViews()
    }
    
    var actionType:SearchActionType!
    
     var imageMetrics = [String:CGFloat]()
    
    var cw:CGFloat!
    var ch:CGFloat!
    
    var name = String()

    func setupViews()
    {
        self.addSubview(self.conteinerView)
    
        self.cw = self.frame.width
        self.ch = cw * 9 / 16
        
        let vp = 10 * ch / self.frame.width
        
        imageMetrics = ["cw":cw,"ch":ch,"vp":vp]
        
        // "H:|-cp-[v0(cs)]-cp-|"
        
        self.addConstraintsWithFormat("H:[v0(cw)]", views: conteinerView, metrics:imageMetrics )
        self.addConstraintsWithFormat("V:[v0(ch)]", views: conteinerView, metrics:imageMetrics)
        
        self.conteinerView.addSubview(self.thumbnailImageView)
        
        self.conteinerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: thumbnailImageView, metrics:imageMetrics )
        self.conteinerView.addConstraintsWithFormat("V:|-vp-[v0]-vp-|", views: thumbnailImageView, metrics:imageMetrics)
                
        self.conteinerView.addSubview(thumbnailImageView)
        
        checkLabel =  Global.createCircularLabel(text: "✓", size: 60, fontSize: 50.0, borderWidth: 3.0, color: UIColor.gamvesColor)
        
        addSubview(checkLabel)
        
        let pr = cw - 80
        let pt = ch - 80
        
        
        let paddingMetrics = ["pr":pr,"pt":pt]
        
        addConstraintsWithFormat("H:|-pr-[v0(60)]", views: checkLabel, metrics : paddingMetrics)
        addConstraintsWithFormat("V:|-pt-[v0(60)]", views: checkLabel, metrics : paddingMetrics)

        
    }
    
    func setChecked() {
        
        
    }
    
    /*override func layoutSubviews() {
        
        if self.actionType == SearchActionType.isCheck {
            
            checkLabel =  Global.createCircularLabel(text: "✓", size: 60, fontSize: 50.0, borderWidth: 3.0, color: UIColor.gamvesColor)
            
        } else if self.actionType == SearchActionType.isDelete {
            
            checkLabel =  Global.createCircularLabel(text: "x", size: 60, fontSize: 50.0, borderWidth: 3.0, color: UIColor.red)
            
        }
        
        if !checkLabel.isDescendant(of: self) {
            addSubview(checkLabel)
        }
        
        
        
        if self.actionType == SearchActionType.isDelete {
            
            print(checked)
            print(name)
        
            if self.checked {
                
                self.checkLabel.isHidden =  false
                
            } else {
                
                self.checkLabel.isHidden =  true
            }
        }
        
        
        if !self.checked {
           
            let pr = cw - 80
            let pt = ch - 80
            
            
            let paddingMetrics = ["pr":pr,"pt":pt]
            
            addConstraintsWithFormat("H:|-pr-[v0(60)]", views: checkLabel, metrics : paddingMetrics)
            addConstraintsWithFormat("V:|-pt-[v0(60)]", views: checkLabel, metrics : paddingMetrics)
            
        }
    }*/
    
}
