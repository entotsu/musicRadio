//
//  HomeViewController.swift
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/09/11.
//  Copyright (c) 2014 Takuya Okamoto. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //-------------------------------------------------
    
    func initViews() {
        
        let MAX_W:CGFloat = self.view.frame.size.width
        let MAX_H:CGFloat = self.view.frame.size.height
        
        
        // ----------- background ------------
        let bgView = UIView()
        bgView.frame = CGRectMake(0, 0, MAX_W, MAX_H)
        bgView.backgroundColor = UIColor(red: 0.209553, green: 0.209553, blue: 0.209553, alpha: 1.0)
        self.view.addSubview(bgView)
        
        
        // ----------- serch field ------------
        let TEXT_FIELD_H:CGFloat = 40
        let TEXT_FIELD_M:CGFloat = 80
        let placeholderColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        let placeholderAttrStr = NSAttributedString(string: "Search Artist", attributes: [NSForegroundColorAttributeName:placeholderColor])
        let clearBtn: UIButton = UIButton.buttonWithType(.Custom) as UIButton
        clearBtn.setImage(UIImage(named: "cancelButton_30_alpha70"), forState: .Normal)
        clearBtn.frame = CGRectMake(0, 0, 15, 15)
        let searchField = UITextField()
        searchField.frame = CGRectMake(0, 0, MAX_W - TEXT_FIELD_M, TEXT_FIELD_H)
        searchField.center = CGPointMake(MAX_W/2, MAX_H/2)
        searchField.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        searchField.attributedPlaceholder = placeholderAttrStr
        searchField.clearButtonMode = .WhileEditing
        searchField.rightView = clearBtn
        searchField.rightViewMode = .WhileEditing
        searchField.delegate = self
        self.view.addSubview(searchField)
        
        let underLine = UIView()
        underLine.frame = CGRectMake(0, 0, searchField.frame.size.width, 1)
        underLine.center = CGPointMake(searchField.center.x, searchField.center.y + TEXT_FIELD_H/2)
        underLine.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        self.view.addSubview(underLine)
        
    }
    
    
}

