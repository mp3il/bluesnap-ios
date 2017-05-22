//
//  BSInputLine.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 17/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

@IBDesignable
class BSInputLine: BSBaseInputControl {

    // MARK: Additional Configurable properties

    @IBInspectable var labelText: String! = "Label" {
        didSet {
            label.text = labelText
        }
    }

    @IBInspectable var labelTextColor: UIColor = UIColor.darkGray
    @IBInspectable var labelBkdColor: UIColor = UIColor.white

    // MARK: Additional UI elements
    
    internal var label : UILabel! = UILabel()
    
    // MARK: private properties

    internal let labelWidth : CGFloat = 100
    internal let labelHeight : CGFloat = 17
    internal let labelFontSize : CGFloat = 14
    
    override func buildElements() {
        super.buildElements()
        self.addSubview(label)
    }
    
    override func setElementAttributes() {
        
        super.setElementAttributes()
        
        label.backgroundColor = self.labelBkdColor
        label.shadowColor = UIColor.clear
        label.shadowOffset = CGSize.zero
        label.layer.shadowRadius = 0
        label.layer.shadowColor = UIColor.clear.cgColor
        label.textColor = self.labelTextColor
    }

    override func resizeElements() {
        
        super.resizeElements()
        
        if let labelFont : UIFont = UIFont(name: self.fontName, size: labelFontSize*vRatio) {
            label.font = labelFont
        }
        
        label.frame = CGRect(x: leftMargin*hRatio, y: (totalHeight-labelHeight)/2*vRatio, width: labelWidth*hRatio, height: labelHeight*vRatio)
    }
    
    override func getFieldWidth() -> CGFloat {
        
        let actualFieldWidth : CGFloat = (totalWidth - labelWidth - (image != nil ? imageWidth : 0) - leftMargin - rightMargin - middleMargin*2) * hRatio
        return actualFieldWidth
    }
    
    override func getFieldX() -> CGFloat {
        
        let fieldX = (leftMargin + labelWidth + middleMargin) * hRatio
        return fieldX
    }


}
