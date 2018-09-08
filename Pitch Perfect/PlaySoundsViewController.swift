//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Eric Winn on 3/21/15.
//  Copyright (c) 2018 Eric N. Winn. All rights reserved.
//

import UIKit
import AVFoundation

// NOTE: Full property sets and range checks are for future expansion
// NOTE: Renamed github remote repo from UDACITY to Pitch-Perfect

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var stopButton: UIButton!
    
    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stopButton.isEnabled = false
        
        audioPlayer = try? AVAudioPlayer(contentsOf: receivedAudio.filePathUrl as URL)
        audioPlayer.enableRate = true
        audioPlayer.prepareToPlay()
        
        audioEngine = AVAudioEngine()
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl as URL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudioSpeed(speed: 0.5)
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        playAudioSpeed(speed: 2.0)
    }
    
    @IBAction func stopAudioPlay(sender: UIButton) {
        stopAllAudio()
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(pitch: 1200, rate: 1.0, overlap: 8.0)
    }
    
    @IBAction func DarthVaderButton(sender: UIButton) {
        playAudioWithVariablePitch(pitch: -800, rate: 1.0, overlap: 8.0)
    }
    
    @IBAction func reverbButton(sender: UIButton) {
        playAudioWithReverb(preset: .cathedral, wetDryMix: 20.0)
    }
    
    @IBAction func echoButton(sender: UIButton) {
        playAudioWithEcho(delayTime: 1, feedback: 50.0, lowPassCutoff: 15000.0, wetDryMix: 20.0)
    }
    
    func playAudioSpeed (speed: Float) {
        setAudioSession()
        stopAllAudio()
        
        // Always start at the beginning of the track
        audioPlayer.currentTime = 0.0
        
        // Rate default is 1.0. Range is 0.5 to 2.0 (half to double)
        switch speed {
            case 0.5...2.0:
                audioPlayer.rate = speed
            default:
                audioPlayer.rate = 1.0
        }
        
        audioPlayer.delegate = self
        audioPlayer.isMeteringEnabled = true
        
        stopButton.isEnabled = true
        audioPlayer.play()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (flag) {
            stopButton.isEnabled = false
        }
    }
    
    func playAudioWithEcho(delayTime: TimeInterval, feedback: Float, lowPassCutoff: Float, wetDryMix: Float) {
        setAudioSession()
        stopAllAudio()
        
        let echoPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(echoPlayerNode)
        
        let changeEchoEffect = AVAudioUnitDelay()
        
        // Time taken by the delayed input to reach the output. Range is 0 to 2 seconds. Default is 1
        switch delayTime {
            case 0...2:
                changeEchoEffect.delayTime = delayTime
            default:
                changeEchoEffect.delayTime = 1
        }
        
        // Amount of output fed back into the delay line. Range is -100% to 100%. Default is 50%
        switch feedback {
            case -100.0...100.0:
                changeEchoEffect.feedback = feedback
            default:
                changeEchoEffect.feedback = 50.0
        }
        
        let sampleRate = Float(AVAudioSession.sharedInstance().sampleRate)
        let rangeBottom: Float = 10.0
        let rangeTop = (sampleRate / 2.0)
        
        // Cutoff frequency, in Hz, above which high frequency content is rolled off
        // Range is 10 Hz through (sampleRate/2). Default is 15000 Hz
        switch lowPassCutoff {
            case rangeBottom...rangeTop:
                changeEchoEffect.lowPassCutoff = lowPassCutoff
            default:
                changeEchoEffect.lowPassCutoff = 15000
        }
        
        // Blend of wet and dry. Range is 0% (all dry) to 100% (all wet). Default is 100%
        switch wetDryMix {
            case 0.0...100.0:
                changeEchoEffect.wetDryMix = wetDryMix
            default:
                changeEchoEffect.wetDryMix = 100.0
        }
        
        
        audioEngine.attach(changeEchoEffect)
        
        audioEngine.connect(echoPlayerNode, to: changeEchoEffect, format: nil)
        audioEngine.connect(changeEchoEffect, to: audioEngine.outputNode, format: nil)
        
        echoPlayerNode.scheduleFile(audioFile,
                                    at: nil,
            completionHandler: audioEngineCompletion)
        
        do {
            try audioEngine.start()
        } catch _ {
        }
        
        stopButton.isEnabled = true
        echoPlayerNode.play()
    }
    
    func playAudioWithReverb(preset: AVAudioUnitReverbPreset, wetDryMix: Float ) {
        setAudioSession()
        stopAllAudio()
        
        let reverbPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(reverbPlayerNode)
        
        let changeReverbEffect = AVAudioUnitReverb()
        changeReverbEffect.loadFactoryPreset(preset)
        
        // Blend of wet and dry. Range is 0% (all dry) to 100% (all wet). Default is 100%
        switch wetDryMix {
            case 0.0...100.0:
                changeReverbEffect.wetDryMix = wetDryMix
            default:
                changeReverbEffect.wetDryMix = 100.0
        }
        
        
        audioEngine.attach(changeReverbEffect)
        
        audioEngine.connect(reverbPlayerNode, to: changeReverbEffect, format: nil)
        audioEngine.connect(changeReverbEffect, to: audioEngine.outputNode, format: nil)
        
        reverbPlayerNode.scheduleFile(audioFile,
                                      at: nil,
            completionHandler: audioEngineCompletion)
        
        do {
            try audioEngine.start()
        } catch _ {
        }
        
        stopButton.isEnabled = true
        reverbPlayerNode.play()
        
    }
    
    func playAudioWithVariablePitch(pitch: Float, rate: Float, overlap: Float){
        setAudioSession()
        stopAllAudio()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        
        // Pitch is defined in cents. Default is 1.0. Range is -2400.0 to 2400.0 One octave is 1200 cents, one semitone is 100 cents
        switch pitch {
            case -2400.0...2400.0:
                changePitchEffect.pitch = pitch
            default:
                changePitchEffect.pitch = 1.0
        }
        
        // Rate default is 1.0. Range is 1/32 to 32.0
        switch rate {
            case 1/32...32/0:
                changePitchEffect.rate = rate
            default:
                changePitchEffect.rate = 1.0
        }
        
        //Higher value results in fewer artifacts in output signal. Default value is 8.0. Range is 3.0 to 32.0
        switch overlap {
            case 3.0...32.0:
                changePitchEffect.overlap = overlap
            default:
                changePitchEffect.overlap = 8.0
        }
        
        audioEngine.attach(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile,
                                     at: nil,
            completionHandler: audioEngineCompletion)
        
        do {
            try audioEngine.start()
        } catch _ {
        }
        
        stopButton.isEnabled = true
        audioPlayerNode.play()
        
    }
    
    func audioEngineCompletion() {
        // Adjust for latency
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.stopButton.isEnabled = false
        }
    }
    
    func stopAllAudio() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        stopButton.isEnabled = false
    }
    
    func setAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
    }
}

