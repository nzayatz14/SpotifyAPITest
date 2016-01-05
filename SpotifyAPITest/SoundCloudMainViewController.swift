//
//  SoundCloudMainViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/5/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import Soundcloud
import AVKit
import AVFoundation

class SoundCloudMainViewController: UIViewController, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var audioPlayer: AVAudioPlayer?
    
    
    @IBOutlet weak var tblSongList: UITableView!
    var songs = [Track]()
    var songDatas = [String : NSData]()
    
    var size = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblSongList.dataSource = self
        tblSongList.delegate = self
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let session = Soundcloud.session
        session?.me({result in
            //print("\(result)")
            result.response.result?.favorites({ tracklist in
                print("Tracklist count: \(tracklist.response.result?.count)")
                
                self.songs = (tracklist.response.result?.filter({$0.streamable == true}))!
                //self.songDatas = [String : NSData]
                self.tblSongList.reloadData()
                
                Track.relatedTracks(self.songs[0].identifier, completion: { result in
                    print("\(self.songs[0]) \n\n \(result)")
                })
                
                /*var streamable = false
                var i = 0
                while(!streamable){
                if(tracklist.response.result![i].streamable){
                print("Track \(i): \(tracklist.response.result![i].streamURL)")
                streamable = true
                }else{
                i++
                }
                }*/
                
                /*let songData = NSData(contentsOfURL: tracklist.response.result![i].streamURL!)
                
                do {
                print("do play")
                self.audioPlayer = try AVAudioPlayer(data: songData!)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.prepareToPlay()
                } catch let error1 as NSError {
                self.audioPlayer = nil
                print("\(error1)")
                }catch{
                self.audioPlayer = nil
                print("other error")
                }*/
                
            })
        })
    }
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true{
            print("done")
        }else{
            print("did not finish properly")
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SoundcloudTableCell", forIndexPath: indexPath) as! SoundCloudTableCell
        
        cell.lblSongTitle.text = songs[indexPath.row].title
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var songData: NSData!
        
        if songDatas["\(songs[indexPath.row].identifier)"] == nil {
            songData = NSData(contentsOfURL: songs[indexPath.row].streamURL!)
            songDatas["\(songs[indexPath.row].identifier)"] = songData
        }else{
            songData = songDatas["\(songs[indexPath.row].identifier)"]
        }
        
        do {
            print("do play")
            self.audioPlayer = try AVAudioPlayer(data: songData!)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch let error1 as NSError {
            self.audioPlayer = nil
            print("\(error1)")
        }catch{
            self.audioPlayer = nil
            print("other error")
        }
    }
}
