//
//  ImageDetailFooterView.swift
//  memory
//
//  Created by yang on 2018/5/30.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit
import Kingfisher

public class ImageDetailFooterView: UIView {
    
    public var commentClickBlock: ((_ image: Image)-> Void)?
    
    private var contentView: UIView!
    
    private var avatarImage: UIImageView!
    private var usernameLabel: UILabel!
    private var timeLabel:  UILabel!
    private var descriptionLabel: UILabel!
    private var likeBtn: UIButton!
    private var commentBtn: UIButton!
    
    private var image: Image?
    private var storyboard: UIStoryboard?
    private var vc: UIViewController?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        //contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        avatarImage = contentView.viewWithTag(1) as! UIImageView
        avatarImage.clipsToBounds = true
        avatarImage.layer.cornerRadius = avatarImage.frame.width / 2
        
        usernameLabel = contentView.viewWithTag(2) as! UILabel
        timeLabel = contentView.viewWithTag(3) as! UILabel
        descriptionLabel = contentView.viewWithTag(5) as! UILabel
        likeBtn = contentView.viewWithTag(6) as! UIButton
        likeBtn.addTarget(self, action: #selector(likeClick), for: .touchUpInside)
        commentBtn = contentView.viewWithTag(7) as! UIButton
        commentBtn.addTarget(self, action: #selector(commentClick), for: .touchUpInside)
        
        // use bounds not frame or it'll be offset
        contentView.frame = bounds
        
        // Make the view stretch with containing view
        contentView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView)
    }
    
    @objc private func likeClick(_ button: UIButton) {
        
    }
    
    @objc private func commentClick() {
        print("commentClick")
        commentClickBlock?(self.image!)
        print(self.storyboard)
       
        if let vcc = self.storyboard?.instantiateViewController(withIdentifier: "commentNavViewController") as? UINavigationController {
            self.vc?.dismiss(animated: true, completion: {
                print(vcc.childViewControllers[0])
                let cvc = vcc.childViewControllers[0] as! CommentViewController
                cvc.image = self.image
                self.vc?.present(cvc, animated: true, completion: nil)
            })
            
        }
    }
    
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    public func updateData(image: Image, pvc: UIViewController?, storyboard: UIStoryboard?) {
        print("update image footer view")
        self.image = image
        self.vc = pvc
        self.storyboard = storyboard
        
        if let avatar = image.creater?.avatar {
            avatarImage.kf.setImage(with: URL(string:  avatar), placeholder: #imageLiteral(resourceName: "image_placeholder"))
        } else {
            avatarImage.image = #imageLiteral(resourceName: "image_placeholder")
        }
        
        usernameLabel.text = image.creater?.name ?? "Unknown"
        timeLabel.text = image.created
        descriptionLabel.text = image.description
        
        likeBtn.setTitle(" \(image.likes)", for: .normal)
        commentBtn.setTitle(" \(image.comments)", for: .normal)
    }

}
