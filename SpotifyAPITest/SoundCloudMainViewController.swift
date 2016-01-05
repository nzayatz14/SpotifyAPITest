//
//  SoundCloudMainViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/5/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import Soundcloud

class SoundCloudMainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let session = Soundcloud.session
        session?.me({result in
            //print("\(result)")
            result.response.result?.favorites({ tracklist in
                print("\(tracklist)")
            })
        })
    }
}
