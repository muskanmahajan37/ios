//
//  AudioPlayerViewController.swift
//  AmahiAnywhere
//
//  Created by Abhishek Sansanwal on 06/06/19.
//  Copyright © 2019 Amahi. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioPlayerViewController: UIViewController {
    
    public var player: AVPlayer!
    public var playerItems: [AVPlayerItem]!
    public var itemURLs: [URL]!
    
    let commandCenter = MPRemoteCommandCenter.shared()
    
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
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        player.pause()
        player = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if playPauseButton.currentImage == UIImage(named: "playIcon") {
            player.play()
            configurePlayButton()
        }
        else{
            player.pause()
            configurePlayButton()
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
       playNextSong()
    }
    
    func playSong(){
        player.play()
        setLockScreenMetadata()
    }
    
    func setLockScreenMetadata() {
        
        var track: String = ""
        var artist: String = ""
        
        let asset:AVAsset = AVAsset(url:itemURLs[playerItems.index(of: player.currentItem!) ?? 0])
        
        for metaDataItems in asset.commonMetadata {
            //getting the title of the song
            //getting the thumbnail image associated with file
            if metaDataItems.commonKey == AVMetadataKey.commonKeyArtist {
                track = metaDataItems.value as! String
            }
            if metaDataItems.commonKey == AVMetadataKey.commonKeyTitle {
                artist = metaDataItems.value as! String
            }
            
        }
        updateNowPlayingInfo(trackName: track, artistName: artist,img: musicArtImageView.image!)
    }
    
    func playNextSong(){
        player.pause()
        player.rate = 0
        configurePlayButton()
        player.seek(to: CMTime.zero)
        var index =  playerItems.index(of: player.currentItem!) ?? 0
        if index == playerItems.count - 1 {
            index = 0
        }
        else {
            index = index + 1
        }
        player.replaceCurrentItem(with: playerItems[index])
        playSong()
        setArtWork()
        setDurationLabel()
    }
    
    func playPrevSong(){
        player.pause()
        player.rate = 0
        configurePlayButton()
        player.seek(to: CMTime.zero)
        var index =  playerItems.index(of: player.currentItem!) ?? 0
        if index == 0 {
            index = playerItems.count - 1
        }
        else {
            index = index - 1
        }
        player.replaceCurrentItem(with: playerItems[index])
        playSong()
        setArtWork()
        setDurationLabel()
    }
    
    @IBAction func prevButtonPressed(_ sender: Any) {
        playPrevSong()
    }
    
    func setArtWork(){
        setButtonsVisibility()
        DispatchQueue.global(qos: .background).async {
            let image = AudioThumbnailGenerator().getThumbnail(self.itemURLs[self.playerItems.index(of: self.player.currentItem!) ?? 0])
            DispatchQueue.main.async {
                self.musicArtImageView.image = image
                self.setLockScreenMetadata()
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
                self.setLockScreenMetadata()
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
    
    var nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    var remoCommandCenter = MPRemoteCommandCenter.shared()
    
    func updateNowPlayingInfo(trackName:String,artistName:String,img:UIImage) {
        
        var art = MPMediaItemArtwork(image: img)
        if #available(iOS 10.0, *) {
            art = MPMediaItemArtwork(boundsSize: CGSize(width: 200, height: 200)) { (size) -> UIImage in
                return img
            }
        }
        nowPlayingInfoCenter.nowPlayingInfo = [MPMediaItemPropertyTitle: trackName,
                                               MPMediaItemPropertyArtist: artistName,
                                               MPMediaItemPropertyArtwork : art, MPMediaItemPropertyPlaybackDuration: "0:00",
                                            MPNowPlayingInfoPropertyPlaybackRate: 1.0]
        
        
        remoCommandCenter.seekForwardCommand.isEnabled = false
        remoCommandCenter.seekBackwardCommand.isEnabled = false
        remoCommandCenter.previousTrackCommand.isEnabled = false
        remoCommandCenter.nextTrackCommand.isEnabled = false
        remoCommandCenter.togglePlayPauseCommand.isEnabled = false

        UIApplication.shared.beginReceivingRemoteControlEvents()

        becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        
        setButtonsVisibility()
        timeSlider.isUserInteractionEnabled = true
        setDurationLabel()
        setArtWork()
        timeSlider.setThumbImage(UIImage(named: "sliderKnobIcon"), for: .normal)
        self.setLockScreenMetadata()
        listenForNotifications()
        
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(self, action: #selector(playandPause(_:)))
    }
    
    @objc private func playandPause(_ sender: Any) {
        AmahiLogger.log("playandPause was called ")
        
        if !(sender is UIButton) {
            self.player.timeControlStatus == .playing ? self.player.pause() : self.player.play()
        }
    }
    
    private func listenForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)),
                                               name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    @objc private func handleRouteChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let reasonRaw = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonRaw.uintValue)
            else { fatalError("Strange... could not get routeChange") }
        if reason == .oldDeviceUnavailable {
            DispatchQueue.main.async(execute: {
                self.player.timeControlStatus == .playing ? self.player.pause() : self.player.play()
                // Handle this event as if it is user-touch triggered
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        
        timeSlider!.minimumValue = 0
        
        let duration : CMTime = player.currentItem?.asset.duration ?? CMTime.zero
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        timeSlider!.maximumValue = Float(seconds)
        timeSlider!.isContinuous = false
        
        timeSlider?.addTarget(self, action: #selector(timeSliderValueChanged(_:)), for: .valueChanged)
        
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player?.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                self.timeSlider.value = Float ( time );
                self.setLabelText(self.timeElapsedLabel, Int(time))
                if self.timeElapsedLabel.text != "--:--" && self.timeElapsedLabel.text == self.durationLabel.text {
                    if self.nextButton.isEnabled == true {
                        self.playNextSong()
                    }
                }
                self.configurePlayButton()
            }
        }
    }
    
    func configurePlayButton(){
        
        if ((self.player.rate != 0) && (self.player.error == nil)) {
            self.playPauseButton.setImage(UIImage(named: "pauseIcon"), for: .normal)
        }
        else{
            self.playPauseButton.setImage(UIImage(named: "playIcon"), for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        if canBecomeFirstResponder {
            becomeFirstResponder()
        }
       /* commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget(self, action: Selector(("playPrevSong")))
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: Selector(("playNextSong")))
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: "playSong")
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: "pauseAudio")*/
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        
        guard let event = event else { return }
        
        if event.type == UIEvent.EventType.remoteControl {
            if event.subtype == .remoteControlPause || event.subtype == .remoteControlPlay {
                ///player.play()
                print("pressed!!!!!!!!")
            }
        }
    }
    
    @objc func timeSliderValueChanged(_ playbackSlider:UISlider)
    {
        
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player!.seek(to: targetTime)
        
        if player!.rate == 0
        {
            playSong()
        }
    }
    
}
