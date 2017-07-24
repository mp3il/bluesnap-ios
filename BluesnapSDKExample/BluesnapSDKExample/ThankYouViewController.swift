//
//  ThankYouViewController.swift
//  BluesnapSDKExample
//
//  Created by Shevie Chen on 24/07/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class ThankYouViewController: UIViewController {

    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var successLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func tryAgainClicked(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }

}
