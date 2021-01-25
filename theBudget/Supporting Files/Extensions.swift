//
//  Extensions.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 24/01/2021.
//

import UIKit

//MARK: Hides the keypad/keyboard when tapped outside
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}

public extension UIView {
    
    //MARK: Vibrate when needed
    func vibrate() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    //MARK: Shake the UI Element which requires entry from user
    func shake(count : Float = 2,for duration : TimeInterval = 0.5,withTranslation translation : Float = 2) {

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.speed = 4
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
        
        
    }
    
    func addDoneButtonOnKeyboard(textViewDescription: UITextField){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(UIView.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        textViewDescription.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        resignFirstResponder()
    }
    
    

}
