//
//  ViewController.swift
//  keyBoardPopUp
//
//  Created by Huangjunwei on 15/8/14.
//  Copyright (c) 2015年 Huangjunwei. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var keyBaordView: UIView!
    @IBOutlet weak var textFeild: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFeild.delegate = self
        textFeild.placeholder = "输入消息内容"
        textFeild.returnKeyType = UIReturnKeyType.Send
        textFeild.enablesReturnKeyAutomatically  = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:"handleTouches:")
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyBoardWillShow:", name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyBoardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func keyBoardWillShow(note:NSNotification)
    {
        
        
        let userInfo  = note.userInfo as! NSDictionary
        var  keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        var keyBoardBoundsRect = self.view.convertRect(keyBoardBounds, toView:nil)
        
        var keyBaoardViewFrame = keyBaordView.frame
        var deltaY = keyBoardBounds.size.height
        
        let animations:(() -> Void) = {
            
            self.keyBaordView.transform = CGAffineTransformMakeTranslation(0,-deltaY)
        }
        
        if duration > 0 {
            let options = UIViewAnimationOptions(UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
            
            
        }else{
            
            animations()
        }
        
        
    }
    
    func keyBoardWillHide(note:NSNotification)
    {
        
        let userInfo  = note.userInfo as! NSDictionary
        
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        
        let animations:(() -> Void) = {
            
            self.keyBaordView.transform = CGAffineTransformIdentity
            
        }
        
        if duration > 0 {
            let options = UIViewAnimationOptions(UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
            
            
        }else{
            
            animations()
        }
        
        
        
        
    }
    
    func handleTouches(sender:UITapGestureRecognizer){
        
        if sender.locationInView(self.view).y < self.view.bounds.height - 250{
            textFeild.resignFirstResponder()
     
            
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

