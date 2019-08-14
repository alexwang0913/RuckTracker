//
//  WorkoutSetViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 8/9/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit

class WorkoutSetViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var repCountLabel: UILabel!
    @IBOutlet weak var nextWorkoutLabel: UILabel!
    @IBOutlet weak var currentWorkoutLabel: UILabel!
    @IBOutlet weak var setLabel: UILabel!
    @IBOutlet weak var exerciseLabel: UILabel!
    @IBOutlet weak var finishButton: RoundButton!
    @IBOutlet weak var nextButton: RoundButton!
    @IBOutlet weak var stopButton: RoundButton!
    
    var workoutSet: WorkoutSet?
    var timer: Timer?
    var nextWorkoutSet: WorkoutSet?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        finishButton.isHidden = true
    }
    
    @IBAction func nextButtonClick(_ sender: Any) {
        GlobalManager.shared.currentWorkoutSetIndex += 1
        self.timer?.invalidate()
        
        if GlobalManager.shared.currentWorkoutSetIndex == GlobalManager.shared.workoutSetList.count {
            if GlobalManager.shared.workoutRepIndex == GlobalManager.shared.currentWorkout.setCount {
                
                let alert = UIAlertController(title: "Info", message: "You've finished all workout sets", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    // Save workout set
                    self.saveWorkoutHistory()
                }))
                self.present(alert, animated: true)
                return
            } else {
                GlobalManager.shared.workoutRepIndex += 1
                GlobalManager.shared.currentWorkoutSetIndex = 0
            }
        }
        
        if nextWorkoutSet?.mode == 1 {
            self.initData()
        } else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let trackViewController = storyBoard.instantiateViewController(withIdentifier: "trackView") as! TrackViewController
            self.navigationController?.pushViewController(trackViewController, animated: true)
        }
    }
    
    @IBAction func stopButtonClick(_ sender: Any) {
        GlobalTimer.sharedTimer.stopTimer()
        
        let alert = UIAlertController(title: "End exercise?", message: "Are you sure end exercise?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            GlobalTimer.sharedTimer.startTimer()
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            self.saveWorkoutHistory()
        }))
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true)
    }
    
    func saveWorkoutHistory() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let saveViewController = storyBoard.instantiateViewController(withIdentifier: "saveWorkoutView") as! SaveWorkoutViewController
        
        self.navigationController?.pushViewController(saveViewController, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.initData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func initData() {
        self.workoutSet = GlobalManager.shared.workoutSetList[GlobalManager.shared.currentWorkoutSetIndex]
        let workoutRepIndex = GlobalManager.shared.workoutRepIndex
        let workoutRepCount = GlobalManager.shared.currentWorkout.setCount
        let exerciseIndex = GlobalManager.shared.currentWorkoutSetIndex + 1
        let exerciseCount = GlobalManager.shared.workoutSetList.count
        
        
        currentWorkoutLabel.text = workoutSet!.name
        repCountLabel.text = "\(workoutSet!.repCount)"
        setLabel.text = "\(workoutRepIndex) / \(workoutRepCount)"
        exerciseLabel.text = "\(exerciseIndex) / \(exerciseCount)"
        
        if GlobalManager.shared.currentWorkoutSetIndex == GlobalManager.shared.workoutSetList.count - 1 {
            if GlobalManager.shared.workoutRepIndex == GlobalManager.shared.currentWorkout.setCount {
                nextWorkoutLabel.text = "--"
                
                nextButton.isHidden = true
                stopButton.isHidden = true
                finishButton.isHidden = false
            } else {
                self.nextWorkoutSet = GlobalManager.shared.workoutSetList[0]
                nextWorkoutLabel.text = self.nextWorkoutSet?.name
            }
        } else {
            self.nextWorkoutSet = GlobalManager.shared.workoutSetList[GlobalManager.shared.currentWorkoutSetIndex + 1]
            nextWorkoutLabel.text = self.nextWorkoutSet?.name
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimerAction), userInfo: nil, repeats: true)
        
        
    }
    
    @objc func fireTimerAction(sender: AnyObject?){
        timeLabel.text = FormatDisplay.time(GlobalManager.shared.workoutHistory.seconds)
    }
    
    @IBAction func finishButtonClick(_ sender: Any) {
        self.saveWorkoutHistory()
    }
    
}
