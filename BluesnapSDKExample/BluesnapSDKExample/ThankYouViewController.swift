//
//  ThankYouViewController.swift
//  BluesnapSDKExample
//
//  Created by Shevie Chen on 24/07/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class ThankYouViewController: UIViewController {

    var errorText : String?
    
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var errorTextView: UITextView!
    @IBOutlet weak var somethingWentWrongLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let errorText = errorText {
            checkmarkImageView.image = #imageLiteral(resourceName: "Sadface")
            successLabel.text = "Oops!"
            somethingWentWrongLabel.isHidden = false
            errorTextView.text = errorText
        } else {
            checkmarkImageView.image = #imageLiteral(resourceName: "Checkmark")
            successLabel.text = "Success!"
            somethingWentWrongLabel.isHidden = true
            errorTextView.text = ""
        }
    }

    @IBAction func tryAgainClicked(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }

}
