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
    var tableTitle:String = ""
    var candidates:[String] = []
    let numberValidator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[0-9]")
    let abcValidator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[A-Ca-c]")
    
    var activeTextField: LeetTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        if(self.candidatesTable.hidden) {
            self.candidates = [];
        }
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
        candidatesTable.hidden = true
        self.setDoneButton()
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
            let efStarValidator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[E-Fe-f]")
            let ghStarValidator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[G-Hg-h]")
            
            func setKeyboard() {
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
                setKeyboard()
            }
            
            func lookup(name:String)->Bool {
                let original = self.reverseResult.text!
                self.reverse(name)
                var decoded:String = self.reverseResult.text!
                if(numberValidator.evaluateWithObject(decoded[0])) {
                    if(name[6] != "0") {
                        textField.text? = name
                    }
                    self.reverseResult.text = decoded
                    return true
                }
                else if(decoded == "out of bounds for 1280 LY cube") {
                    self.reverse("\(name.stringByAppendingString("-"))")
                    decoded = self.reverseResult.text!
                    if(numberValidator.evaluateWithObject(decoded[0])) {
                        textField.text = name.stringByAppendingString("-")
                        self.reverse(name)
                        return true
                    }
                }
                self.reverseResult.text = original
                return false
            }
            
            func autocomplete() -> Bool {
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
                        setKeyboard()
                        return false
                    }
                    else if(candidates.count > 1) {
                        self.tableTitle = "Autocomplete Results"
                        candidatesTable.hidden = false
                        candidatesTable.reloadData()
                        
                        textField.resignFirstResponder()
                        textField.text = original
                        textField.text?.appendContentsOf(string)
                        reverse()
                        return false
                    }
                    else {
                        return false
                    }
                }
                else {
                    textField.text?.appendContentsOf(string)
                    self.reverse(textField.text!)
                    setKeyboard()
                    return false
                }
            }
            
            func delete(size:Int) {
                let start:String.CharacterView.Index.Distance = range.location - size
                let end:String.CharacterView.Index.Distance = (textField.text?.characters.count)!
                let rangeToRemove = (textField.text?.startIndex.advancedBy(start))! ..< (textField.text?.startIndex.advancedBy(end))!
                textField.text?.removeRange(rangeToRemove)
            }
            
            /* do some coool autocomplete :D */
            if(textField.text?.characters.count == 5 && string != "") {
                return autocomplete()
            }
            
            if(textField.text?.characters.count > 5 && string != "") {
                if(string.characters.count > 5) {
                    if lookup(string) {
                        return false
                    }
                }
                if lookup("\(textField.text!)\(string)") {
                    return false
                }
            }
            
            /* if the user pressed backspace delete the text after the insertion point */
            if(string == "") {
                switch range.location {
                case 2,4,8:
                    delete(1)
                    reverse()
                    return false
                case 6:
                    delete(0)
                    return autocomplete()
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
    
    func setDoneButton() {
        if(self.numberValidator.evaluateWithObject(reverseResult.text![0]) && ssName.text!.characters.count > 5) {
            let starType:String = ssName.text![5]
            if(self.abcValidator.evaluateWithObject(starType)) {
                self.doneButton.setTitle("       Nearby Zones", forState: UIControlState.Normal);
            }
            else {
                self.doneButton.setTitle("                           Done", forState: UIControlState.Normal);
            }
        }
        else {
            self.doneButton.setTitle("                           Done", forState: UIControlState.Normal);
        }
    }
    
    func reverse(text:String) {
        reverseResult.text = Decoder.parse_reverse(text)
        self.setDoneButton()
    }
    
    func findNearbys() {
        let starType:String = ssName.text![5]
        if(!self.abcValidator.evaluateWithObject(starType)) {
            return; //kinda pointless to lookup nearbys for stars with big zones
        }
        let possibleStarTypes:String = "ABCDEFGH"
        self.candidates = [String]()
        for aStarType:Character in possibleStarTypes.characters {
            let myStarType:String = String.init(aStarType)
            if(myStarType == starType.uppercaseString) {
                continue
            }
            let coords:String = self.reverseResult.text!
            let rangesArray:[String] = coords.componentsSeparatedByCharactersInSet(NSCharacterSet.init(charactersInString: ","))
            var lookupCoords = [String]()
            for range:String in rangesArray {
                let myRanges:[String] = range.componentsSeparatedByCharactersInSet(NSCharacterSet.init(charactersInString: "-"))
                let lowRange:Int = Int(myRanges[0])!
                let hiRange:Int  = Int(myRanges[1])!
                var diff:Int = hiRange - lowRange
                diff = diff/2
                lookupCoords.append("\(lowRange+diff)")
            }
            let ew = lookupCoords[0]
            let ud = lookupCoords[1]
            let ns = lookupCoords[2]
            let lc = myStarType
            
            let find = "\(ew),\(ud),\(ns),\(lc)"
            let candidate = Decoder.parse_finder(find)
            candidates.append(candidate)
        }
        if(Bool(self.candidates.count)) {
            self.tableTitle = "Nearby Zones"
            candidatesTable.hidden = false
            candidatesTable.reloadData()
        }
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
        if(self.doneButton.titleLabel!.text!.containsString("Nearby Zones")) {
            self.findNearbys()
        }
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
        self.textField(ssName, shouldChangeCharactersInRange:NSRange.init(location: 0, length: self.ssName.text!.characters.count), replacementString: selection)
        //self.reverse(selection)
        self.candidatesTable.hidden = true
        self.ssName.becomeFirstResponder()
        return(indexPath)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return self.candidates.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableTitle
    }
}

class LeetTextField: UITextField {
    
    override func deleteBackward() {
        super.deleteBackward()
    }
}

