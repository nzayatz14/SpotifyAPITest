//
//  SongPlayerView.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/12/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import MarqueeLabel

class SongPlayerView: UIView {
    
    
    
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var lblSongTitle: MarqueeLabel!
    @IBOutlet weak var lblArtistName: MarqueeLabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSBundle.mainBundle().loadNibNamed("GameSettingsiPhoneSubview3", owner: self, options: nil)
        
        self.addSubview(self.view)
        
        setup()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSBundle.mainBundle().loadNibNamed("GameSettingsiPhoneSubview3", owner: self, options: nil)
        
        self.frame = frame
        self.view.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        self.addSubview(self.view)
        
        setup()
    }
    
    
    /**
     Setup function to set initialize properties of the view
     
     - parameter void:
     - returns: void
     */
    func setup(){

    }

}
