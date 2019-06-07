//
//  AudioPlayerViewController.swift
//  AmahiAnywhere
//
//  Created by Abhishek Sansanwal on 06/06/19.
//  Copyright © 2019 Amahi. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerViewController: UIViewController {
    
    public var player: AVPlayer!
    public var playerItems: [AVPlayerItem]!
    public var itemURLs: [URL]!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var musicArtImageView: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var audioControlsView: UIView!
    
    @IBAction func timeSliderDidChange(_ sender: Any) {
        print("Time Slider Did Change")
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        player.pause()
        player = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        print("Play/Pause Button Pressed")
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        player.pause()
        player.seek(to: CMTime.zero)
        var index =  playerItems.index(of: player.currentItem!) ?? 0
        if index == playerItems.count - 1 {
            index = 0
        }
        else {
            index = index + 1
        }
        player.replaceCurrentItem(with: playerItems[index])
        player.play()
        setArtWork()
        setDurationLabel()
    }
    
    @IBAction func prevButtonPressed(_ sender: Any) {
        player.pause()
        player.seek(to: CMTime.zero)
        var index =  playerItems.index(of: player.currentItem!) ?? 0
        if index == 0 {
            index = playerItems.count - 1
        }
        else {
            index = index - 1
        }
        player.replaceCurrentItem(with: playerItems[index])
        player.play()
        setArtWork()
        setDurationLabel()
    }
    
    func setArtWork(){
        setButtonsVisibility()
        DispatchQueue.global(qos: .background).async {
            let image = AudioThumbnailGenerator().getThumbnail(self.itemURLs[self.playerItems.index(of: self.player.currentItem!) ?? 0])
            DispatchQueue.main.async {
                self.musicArtImageView.image = image
            }
        }
    }
    
    func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
        return (seconds / 60, (seconds % 60) % 60)
    }
    
    func setLabelText(_ sender: UILabel!,_ duration: Int){
        let (m,s) = self.secondsToMinutesSeconds(seconds: Int(duration))
        if m/10 < 1 && s/10 < 1 {
            sender.text = "0\(m):0\(s)"
        }
        else if m/10 < 1 && s/10 >= 1 {
            sender.text = "0\(m):\(s)"
        }
        else if m/10 >= 1 && s/10 < 1 {
            sender.text = "\(m):0\(s)"
        }
        else{
            sender.text = "\(m):\(s)"
        }
    }
    
    func setDurationLabel(){
        self.timeSlider.value = 0.0
        self.durationLabel.text = "--:--"
        self.timeElapsedLabel.text = "--:--"
        DispatchQueue.global(qos: .background).async {
            let duration = CMTimeGetSeconds(self.player.currentItem?.asset.duration ?? CMTime.zero)
            DispatchQueue.main.async {
                self.setLabelText(self.durationLabel, Int(duration))
            }
        }
    }
    
    func setButtonsVisibility(){
        let index =  playerItems.index(of: player.currentItem!) ?? 0
        if index == 0 {
            prevButton.isEnabled = false
        }
        else {
            prevButton.isEnabled = true
        }
        if index == playerItems.count - 1 {
            nextButton.isEnabled = false
        }
        else {
            nextButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        setButtonsVisibility()
        timeSlider.isUserInteractionEnabled = true
        setDurationLabel()
        setArtWork()
        timeSlider.setThumbImage(UIImage(named: "sliderKnobIcon"), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        timeSlider!.minimumValue = 0
        
        let duration : CMTime = player.currentItem?.asset.duration ?? CMTime.zero
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        timeSlider!.maximumValue = Float(seconds)
        timeSlider!.isContinuous = false
        
        timeSlider?.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player?.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                self.timeSlider.value = Float ( time );
                self.setLabelText(self.timeElapsedLabel, Int(time))
            }
        }
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player!.seek(to: targetTime)
        
        if player!.rate == 0
        {
            player?.play()
        }
    }
    
}
