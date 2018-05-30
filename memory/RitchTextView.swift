//
//  RitchTextView.swift
//  SmileyView
//
//  Created by yang on 2017/12/21.
//  Copyright © 2017年 yang. All rights reserved.
//

import UIKit

class RitchTextView: UITextView {

    lazy var placeholderLabel: UILabel = UILabel()
    public weak var context: UIViewController?
    
    public var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    override var text: String! {
        didSet {
            textChnage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("RitchTextView")
        setUpPlaceholder()
    }
    
    private func setUpPlaceholder() {
        placeholderLabel.font = font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame = CGRect(x: 5, y: 8, width: 100, height: 15)
        
        addSubview(placeholderLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChnage), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.frame = CGRect(x: 5, y: 8, width: frame.width - 10, height: 15)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    @objc func textChnage(_ notification: Notification? = nil) {
        placeholderLabel.isHidden = hasText || (self.result?.count ?? 0) > 0
    }
    
    // 获得纯文本，图片 表情 已经转化为字符串
    public var result: String? {
        guard let attrStr = attributedText else { return nil }
        
        var result = String()
        attrStr.enumerateAttributes(in: NSRange(location: 0, length: attrStr.length), options: []) { (dict, range, _) in
            if let attach = dict[NSAttributedStringKey.attachment] as? ImageAttachment {
                if let v = attach.value {
                    result += v
                }
            }else {
                result += (attrStr.string as NSString).substring(with: range)
            }
        }
        return result
    }
    
    // 插入image属性文本
    func insertImageText(imageText: NSAttributedString) {
        let range = selectedRange
        
        let attrString = NSMutableAttributedString(attributedString: attributedText)
        attrString.replaceCharacters(in: range, with: imageText)
        attributedText = attrString
        
        //重新设置光标的位置
        selectedRange = NSRange(location: range.location + 1, length: 0)
        
        //手冻执行代理
        delegate?.textViewDidChange?(self)
        self.textChnage()
    }
}
