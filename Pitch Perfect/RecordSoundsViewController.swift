//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Eric Winn on 3/15/15.
//  Copyright (c) 2018 Eric N. Winn. All rights reserved.
//

// NOTE: Renamed github remote repo from UDACITY to Pitch-Perfect

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordLabel.text = "Tap to Record"
        stopButton.isHidden = true
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        recordLabel.text = "recording..."
        stopButton.isHidden = false
        recordButton.isEnabled = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let currentDateTime = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        
        let recordingName = formatter.string(from: currentDateTime as Date) + ".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURL(withPathComponents: pathArray)
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryRecord)
        } catch _ {
        }
        
//        audioRecorder = try? AVAudioRecorder(URL: filePath!, settings: nil)
        audioRecorder = try? AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        
    }
    
    // NOTE: The delegate calls this function
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag) {
            // Step 1 - Save the recorded audio
            recordedAudio = RecordedAudio(filePathUrl: recorder.url as NSURL, title: recorder.url.lastPathComponent)
            
            // Step 2 - perform segue
            self.performSegue(withIdentifier: "stopRecording", sender: recordedAudio) }
        else {
            recordButton.isEnabled = true
            recordLabel.text = "Tap to Record"
            stopButton.isHidden = true
        }
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC: PlaySoundsViewController = segue.destination as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func stopButton(sender: UIButton) {
        recordLabel.text = "Tap to Record"
        stopButton.isHidden = true
        recordButton.isEnabled = true
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch _ {
        }
    }
    
}

