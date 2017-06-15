//
//  BSInputLine.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 17/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

@IBDesignable
class BSInputLine: BSBaseTextInput {

    // MARK: Additional Configurable properties

    @IBInspectable var labelText: String = "Label" {
        didSet {
            label.text = labelText
        }
    }

    @IBInspectable var labelTextColor: UIColor = UIColor.darkGray
    @IBInspectable var labelBkdColor: UIColor = UIColor.white
    @IBInspectable var labelWidth : CGFloat = 104
    @IBInspectable var labelHeight : CGFloat = 17
    @IBInspectable var labelFontSize : CGFloat = 14

    // MARK: private properties
    
    internal var label : UILabel = UILabel()
    var actualLabelWidth : CGFloat = 104
    var actualLabelHeight : CGFloat = 17
    var actualLabelFontSize : CGFloat = 14
    
    // Override functions
    
    override func buildElements() {
        super.buildElements()
        self.addSubview(label)
    }
    
    override func initRatios() -> (hRatio: CGFloat, vRatio: CGFloat) {
        
        let ratios = super.initRatios()
        
        actualLabelFontSize = (labelFontSize * ratios.vRatio).rounded()
        actualLabelWidth = (labelWidth * ratios.hRatio).rounded()
        actualLabelHeight = (labelHeight * ratios.vRatio).rounded()
        
        return ratios
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
        
        if let labelFont : UIFont = UIFont(name: self.fontName, size: actualLabelFontSize) {
            label.font = labelFont
        }
        
        label.frame = CGRect(x: actualLeftMargin, y: (self.frame.height-actualLabelHeight)/2, width: actualLabelWidth, height: actualLabelHeight)
    }
    
    override func getFieldWidth() -> CGFloat {
        
        let actualFieldWidth : CGFloat = self.frame.width - actualLabelWidth - (image != nil ? actualImageWidth : 0) - actualLeftMargin - actualRightMargin - actualMiddleMargin*2
        return actualFieldWidth
    }
    
    override func getFieldX() -> CGFloat {
        
        let fieldX = actualLeftMargin + actualLabelWidth + actualMiddleMargin
        return fieldX
    }


}
