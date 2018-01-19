//
//  ViewController.swift
//  sleepTimer
//
//  Created by Dorothy Fu on 2018-01-15.
//  Copyright © 2018 Dorothy. All rights reserved.
//

import UIKit
import MediaPlayer

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}

extension UIApplication {
    var isKeyboardPresented: Bool {
        if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"), self.windows.contains(where: { $0.isKind(of: keyboardWindowClass) }) {
            return true
        } else {
            return false
        }
    }
}

// MARK: - UIViewController Properties
class ViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var editBox: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    let button = UIButton(type: UIButtonType.custom)
    let limitLength = 10
    
    var seconds = 0
    var timer = Timer()
    
    var isTimerRunning = false
    var resumeTapped = false

    

    // MARK: - IBActions
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = editBox.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= limitLength
    }
    
    func stringToInt() {
        let totalSeconds:Int? = Int(editBox.text!)
        
        guard let text = editBox.text, !text.isEmpty else {
            seconds = 0
            return
        }
        seconds = totalSeconds! * 60
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        stringToInt()
        if seconds == 0 {
            timerLabel.text = "Please enter a number greater than 0"
        } else if isTimerRunning == false {
//            if seconds > 86400 {
//                seconds = 86400
//            }
            
            runTimer()
            self.startButton.isEnabled = false
            editBox.resignFirstResponder()
            editBox.text = ""
        }
    }
    
    @objc func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
        pauseButton.isEnabled = true
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        if self.resumeTapped == false {
            timer.invalidate()
            isTimerRunning = false
            self.resumeTapped = true
            self.pauseButton.setTitle("Resume", for: .normal)
        } else {
            if isTimerRunning == false {
                runTimer()
            }
            self.resumeTapped = false
            isTimerRunning = true
            self.pauseButton.setTitle("Pause", for: .normal)
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        timer.invalidate()
        seconds = 0
        timerLabel.text = timeString(time: TimeInterval(seconds))
        isTimerRunning = false
        pauseButton.isEnabled = false
        startButton.isEnabled = true
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate() // send alert for time's up
            timerLabel.text = "Turning music off ..."
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
            try? AVAudioSession.sharedInstance().setActive(true)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+3.0) {
                self.seconds = 0
                self.timerLabel.text = self.timeString(time: (TimeInterval(self.seconds)))
            }
            
            isTimerRunning = false
            pauseButton.isEnabled = false
            startButton.isEnabled = true
            
        } else {
            timerLabel.text = timeString(time: TimeInterval(seconds))
            seconds -= 1
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        
    }
    
    // Return button
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewController.dismissKeyboard))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.editBox.inputAccessoryView = doneToolbar
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pauseButton.isEnabled = false
        self.view.backgroundColor = UIColor.black
        
        // Return button
        self.addDoneButtonOnKeyboard()
        
        editBox.delegate = self
        
        startButton.setTitleColor(UIColor(red:0.12, green:0.30, blue:0.57, alpha:1.0), for: .disabled)
        
        pauseButton.setTitleColor(UIColor(red:0.12, green:0.30, blue:0.57, alpha:1.0), for: .disabled)
        
        resetButton.setTitleColor(UIColor(red:0.20, green:0.47, blue:0.88, alpha:1.0), for: .disabled)
        
            timerLabel.textColor = .white
    
    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
}

