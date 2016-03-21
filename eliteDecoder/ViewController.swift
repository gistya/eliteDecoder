//
//  ViewController.swift
//  eliteDecoder
//
//  Created by Jon Gilbert on 2/9/16.
//  Copyright © 2016 Jon Gilbert. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var ewCoord: LeetTextField!
    @IBOutlet var udCoord: LeetTextField!
    @IBOutlet var nsCoord: LeetTextField!
    @IBOutlet var letterCode: LeetTextField!
    @IBOutlet var ssName: LeetTextField!
    @IBOutlet var finderResult: UILabel!
    @IBOutlet var reverseResult: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var candidatesTable: UITableView!
    @IBOutlet var infoView: UIView!
    var candidates:[String] = []
    
    var activeTextField: LeetTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ewCoord.delegate = self;
        udCoord.delegate = self;
        nsCoord.delegate = self;
        ssName.delegate = self;
        letterCode.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func csvOutput320x320x80() {
        var csv:String = ""
        
        for(var y = 0; y < 330; y+=10) {
            for(var z = 0; z < 330; z+=10) {
                for(var x = 0; x < 330; x+=10) {
                    let coords = "\(x),\(z),\(y),A"
                    csv.appendContentsOf("@\(coords): \(Decoder.parse_finder(coords)),")
                }
            }
            csv.appendContentsOf("\n")
        }
        
        print(csv)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.doneButton.enabled = true
        self.doneButton.alpha = 1.0
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextField = textField as? LeetTextField
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        /* perform validation on the input fields :D */
        if(textField == ewCoord || textField == udCoord || textField == nsCoord) {
            let validator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[0-9]{1,4}")
            if(validator.evaluateWithObject(string) /* i.e. backspace */) {
                self.find(textField, withNewData: string)
                return true
            }
            else {
                return false
            }
        }
        else if(textField == letterCode) {
            let validator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[A-Za-z]{1,1}")
            if(validator.evaluateWithObject(string) /* i.e. backspace */) {
                self.find(textField, withNewData: string)
                return true
            }
            else {
                return false
            }
        }
        /* for the reverse function... */
        else {
            
            let letterValidator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[A-Za-z]")
            let starValidator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[A-Ha-h]")
            let bigStarValidator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[E-He-h]")
            let efStarValidator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[E-Fe-f]")
            let ghStarValidator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[G-Hg-h]")
            let numberValidator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[0-9]")
            
            func reverse() {
                if(textField.text?.characters.count > 6) {
                    self.reverse(textField.text!)
                    if(self.reverseResult.text == "out of bounds for 1280 LY cube") {
                        if(textField.text?.characters.count == 7 && string == "") {
                            textField.text = textField.text?[0...5]
                            reverse()
                        }
                    }
                }
                else {
                    self.reverseResult.text = "please enter a sector name"
                }
                if(textField.text?.characters.count > 5 && candidatesTable.hidden) {
                    textField.keyboardType = UIKeyboardType.NumbersAndPunctuation
                    textField.resignFirstResponder()
                    textField.becomeFirstResponder()
                }
                else if(candidatesTable.hidden) {
                    textField.keyboardType = UIKeyboardType.Default
                    textField.resignFirstResponder()
                    textField.becomeFirstResponder()
                }
            }
            
            func lookup(name:String)->Bool {
                var decoded:String = Decoder.parse_reverse(name);
                if(numberValidator.evaluateWithObject(decoded[0])) {
                    if(name[6] != "0") {
                        textField.text? = name
                    }
                    self.reverseResult.text = decoded
                    return true
                }
                else if(decoded == "out of bounds for 1280 LY cube") {
                    decoded = Decoder.parse_reverse("\(name.stringByAppendingString("-"))");
                    if(numberValidator.evaluateWithObject(decoded[0])) {
                        textField.text = name.stringByAppendingString("-")
                        self.reverseResult.text = decoded
                        return true
                    }
                }
                return false
            }
            
            if(textField.text?.characters.count == 5 && string != "") {
                if !(lookup("\(textField.text!)\(string)0")) {
                    let starType:String = string
                    var factor = 128
                    switch starType.uppercaseString {
                    case "B":
                        factor = factor / 2
                        break
                    case "C":
                        factor = factor / 4
                        break
                    case "D":
                        factor = factor / 8
                        break
                    case "E":
                        factor = factor / 16
                        break
                    case "F":
                        factor = factor / 32
                        break
                    case "G":
                        factor = factor / 64
                        break
                    case "H":
                        factor = 1
                        break
                    default:
                        break
                    }
                    let original = textField.text!
                    self.candidates = []
                    for(var i = 0; i < factor; i++) {
                        let test = "\(original)\(string)\(i)-"
                        if(lookup(test)) {
                            self.candidates.insert(textField.text!, atIndex: 0)
                        }
                    }
                    if(self.candidates.count == 1) {
                        return false
                    }
                    else if(candidates.count > 1) {
                        candidatesTable.hidden = false
                        candidatesTable.reloadData()
                        textField.resignFirstResponder()
                        textField.text = original
                    }
                    else {
                        return false
                    }
                }
                else {
                    textField.text?.appendContentsOf(string)
                    return false
                }
            }
            
            if(textField.text?.characters.count > 5 && string != "") {
                if lookup("\(textField.text!)\(string)") {
                    return false
                }
            }
            
            func delete(size:Int) {
                let start:String.CharacterView.Index.Distance = range.location - size
                let end:String.CharacterView.Index.Distance = (textField.text?.characters.count)!
                let rangeToRemove = (textField.text?.startIndex.advancedBy(start))! ..< (textField.text?.startIndex.advancedBy(end))!
                textField.text?.removeRange(rangeToRemove)
            }
            
            /* if the user pressed backspace delete the text after the insertion point */
            if(string == "") {
                switch range.location {
                case 2,4,8:
                    delete(1)
                    reverse()
                    return false
                case 7:
                    let starType:String = ssName.text![5]
                    if(efStarValidator.evaluateWithObject(starType)) {
                        delete(0)
                        reverse()
                    }
                    else {
                        delete(1)
                        reverse()
                    }
                    return false
                default:
                    delete(0)
                    reverse()
                    return false
                }
            }
            
            /* if the user pasted in a value then ignore it (fix this later) */
            if(string.characters.count > 1) {
                return false;
            }
            
            switch range.location {
            case 0:
                if(letterValidator.evaluateWithObject(string)) {
                    return true
                }
                return false
            case 1:
                if(letterValidator.evaluateWithObject(string)) {
                    textField.text?.appendContentsOf(string + "-")
                }
                return false
            case 3:
                if(letterValidator.evaluateWithObject(string)) {
                    textField.text?.appendContentsOf(string + " ")
                }
                return false
            case 5:
                if(letterValidator.evaluateWithObject(string)) {
                    textField.text?.appendContentsOf(string)
                    reverse()
                }
                return false
            case 6:
                if(numberValidator.evaluateWithObject(string)) {
                    textField.text?.appendContentsOf(string)
                    reverse()
                }
                return false
////            case 6:
////                let starType:String = ssName.text![5]
////                /* for mass E and F, there are only single digit sectors */
////                if(starType.uppercaseString == "F") {
////                    if(numberValidator.evaluateWithObject(string)) {
////                        if(Int(string) > 2) {
////                            textField.text?.appendContentsOf("-" + string)
////                        }
////                        else {
////                            textField.text?.appendContentsOf(string)
////                        }
////                        reverse()
////                    }
////                }
////                else if(starType.uppercaseString == "E") {
////                    if(numberValidator.evaluateWithObject(string)) {
////                        if(Int(string) > 6) {
////                            textField.text?.appendContentsOf("-" + string)
////                        }
////                        else {
////                            textField.text?.appendContentsOf(string)
////                        }
////                        reverse()
////                    }
////                }
////                else if(numberValidator.evaluateWithObject(string)) {
////                    textField.text?.appendContentsOf(string)
////                    reverse()
////                }
////                return false
            case 7:
                let starType:String = ssName.text![5]
                let firstDigit:Int = Int(ssName.text![6])!
                if(string == "-" && !(ghStarValidator.evaluateWithObject(starType)
                                      || (starType.uppercaseString == "E" && firstDigit > 6)
                                      || (starType.uppercaseString == "F" && firstDigit > 2))) {
                    textField.text?.appendContentsOf(string)
                    reverse()
                }
                else if(numberValidator.evaluateWithObject(string)) {
                    textField.text?.appendContentsOf(string)
                    reverse()
                }
                return false
//            case 8:
//                let starType:String = ssName.text![5]
//                let firstDigit:Int = Int(ssName.text![6])!
//                if(string == "-" && !(starType.uppercaseString == "D" && firstDigit > 1) && !(bigStarValidator.evaluateWithObject(starType))) {
//                    textField.text?.appendContentsOf(string)
//                    reverse()
//                }
//                return false
            default:
                reverse()
                return false
            }
        }
    }
    
    func find(textField: UITextField, withNewData newData:String) {
        let ew = textField == ewCoord ? newData : ewCoord.text!
        let ud = textField == udCoord ? newData : udCoord.text!
        let ns = textField == nsCoord ? newData : nsCoord.text!
        let lc = textField == letterCode ? newData : letterCode.text!
        
        if(ew == "" || ud == "" || ns == "" || lc == "") {
            finderResult.text = "please enter some coordinates"
        }
        else if let find:String = "\(ew),\(ud),\(ns),\(lc)" {
            print("finding: \(find)")
            finderResult.text = Decoder.parse_finder(find)
        }
    }
    
    func reverse(text:String) {
        reverseResult.text = Decoder.parse_reverse(text)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.doneButton.enabled = false
        self.doneButton.alpha = 0.0
        return true;
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        if(self.activeTextField != nil) {
            self.activeTextField?.resignFirstResponder()
            self.activeTextField = nil
        }
        self.doneButton.enabled = false
        self.doneButton.alpha = 0.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("whee")
        if(cell == nil) {
            cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier:"whee")
        }
        
        cell!.textLabel!.text = self.candidates[indexPath.row]
        return cell!
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let selection:String = self.candidates[indexPath.row]
        self.ssName.text = selection
        self.reverse(selection)
        self.candidatesTable.hidden = true
        self.ssName.becomeFirstResponder()
        return(indexPath)
    }
    
//    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return self.candidates.count
        }
        else {
            return 0
        }
    }
}

class LeetTextField: UITextField {
    
    override func deleteBackward() {
        super.deleteBackward()
    }
}
