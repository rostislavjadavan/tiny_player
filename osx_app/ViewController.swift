//
//  ViewController.swift
//  osx_app
//
//  Created by Rostislav Jadavan on 17/06/2018.
//  Copyright © 2018 Rostislav Jadavan. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
    @IBOutlet weak var openButton: NSButton!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var labelField: NSTextField!
    @IBOutlet weak var timeField: NSTextField!
    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var volumeSlider: NSSlider!
    
    var filename: String!
    var player: AVPlayer!
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelField.stringValue = "";
        timeField.stringValue = "";
        slider.doubleValue = 0
        slider.isEnabled = false
        volumeSlider.minValue = 0;
        volumeSlider.maxValue = 1;
        volumeSlider.floatValue = 0.66;
    }
    
    override var representedObject: Any? {
        didSet {
        }
    }
    
    @IBAction func playButton(_ sender: Any) {
        player.play()
    }
    
    @IBAction func openButton(_ sender: Any) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        //dialog.allowedFileTypes        = ["aac","adts","ac3","aif","aiff","aifc","caf","mp3","mp4","m4a","snd","au","sd2","wav"]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            
            if (result == nil) {
                labelField.stringValue = "Unable to open " + (dialog.url?.path)!
                return;
            }
            
            player = AVPlayer(url: result!)
            player.volume = volumeSlider.floatValue
            player.play()
            
            if (player.status == AVPlayerStatus.failed) {
                labelField.stringValue = (player.error?.localizedDescription)!
                return
            }
            
            if (player.currentItem?.status == AVPlayerItemStatus.failed) {
                labelField.stringValue = (player.currentItem?.error?.localizedDescription)!
                return
            }
            
            filename = result!.path
            labelField.stringValue = (result?.lastPathComponent)!
            
            slider.floatValue = 0
            slider.isEnabled = true
            slider.maxValue = CMTimeGetSeconds(player.currentItem!.asset.duration)
            
            player!.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 10), queue: DispatchQueue.main, using: { [weak self] time in
                let currentTime = Float(CMTimeGetSeconds((self?.player!.currentTime())!))
                let totalTime = Float(CMTimeGetSeconds((self?.player.currentItem!.asset.duration)!))
                self?.slider.floatValue = currentTime
                self?.timeField.stringValue = (self?.formatTime(currentTime))! + " / " + (self?.formatTime(totalTime))!
            })
        }
    }
    
    @IBAction func stopButton(_ sender: Any) {
        player.pause()
    }
    
    @IBAction func sliderAction(_ sender: Any) {
        let ft: Float = self.slider.floatValue;
        let timeTo: CMTime = CMTimeMake(Int64(ft * 1000), 1000);
        self.player.seek(to: timeTo);
    }
    @IBAction func volumeAction(_ sender: Any) {
        self.player.volume = self.volumeSlider.floatValue
    }
    
    private func formatTime(_ time: Float) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}

