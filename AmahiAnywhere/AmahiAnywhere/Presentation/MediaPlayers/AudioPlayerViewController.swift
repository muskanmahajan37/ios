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
    
    public var player: AVQueuePlayer!
    
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
        print("Done Button Pressed")
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        print("Play/Pause Button Pressed")
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        print("Next Button Pressed")
    }
    
    @IBAction func prevButtonPressed(_ sender: Any) {
        print("Prev Button Pressed")
    }
    
    override func viewDidLoad() {
        print("View Did Load")
    }
}
