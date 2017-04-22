//
//  ViewController.swift
//  eliteDecoder
//
//  Created by Jon Gilbert on 2/9/16.
//  Copyright © 2016 Jon Gilbert. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
        if(self.candidatesTable.isHidden) {
            self.candidates = [];
        }
    }
    
    func csvOutput320x320x80() {
        var csv:String = ""
        
        for y in 0...330 where y % 10 == 0 {
            for z in 0...330 where z % 10 == 0 {
                for x in 0...330 where z % 10 == 0 {
                    let coords = "\(x),\(z),\(y),A"
                    csv.append("@\(coords): \(Decoder.parse_finder(coords)),")
                }
            }
            csv.append("\n")
        }
        
        print(csv)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        candidatesTable.isHidden = true
        self.setDoneButton()
        self.doneButton.isEnabled = true
        self.doneButton.alpha = 1.0
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField as? LeetTextField
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /* perform validation on the input fields :D */
        if(textField == ewCoord || textField == udCoord || textField == nsCoord) {
            let validator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[0-9]{1,4}")
            if(validator.evaluate(with: string) /* i.e. backspace */) {
                self.find(textField, withNewData: string)
                return true
            }
            else {
                return false
            }
        }
        else if(textField == letterCode) {
            let validator:NSPredicate = NSPredicate(format:"SELF MATCHES %@","[A-Za-z]{1,1}")
            if(validator.evaluate(with: string) /* i.e. backspace */) {
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
                if(textField.text?.characters.count > 5 && candidatesTable.isHidden) {
                    textField.keyboardType = UIKeyboardType.numbersAndPunctuation
                    textField.resignFirstResponder()
                    textField.becomeFirstResponder()
                }
                else if(candidatesTable.isHidden) {
                    textField.keyboardType = UIKeyboardType.default
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
            
            func lookup(_ name:String)->Bool {
                let original = self.reverseResult.text!
                self.reverse(name)
                var decoded:String = self.reverseResult.text!
                if(numberValidator.evaluate(with: decoded[0])) {
                    if(name[6] != "0") {
                        textField.text? = name
                    }
                    self.reverseResult.text = decoded
                    return true
                }
                else if(decoded == "out of bounds for 1280 LY cube") {
                    self.reverse("\(name + "-")")
                    decoded = self.reverseResult.text!
                    if(numberValidator.evaluate(with: decoded[0])) {
                        textField.text = name + "-"
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
                    switch starType.uppercased() {
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
                    for i in 0 ..< factor {
                        let test = "\(original)\(string)\(i)-"
                        if(lookup(test)) {
                            self.candidates.insert(textField.text!, at: 0)
                        }
                    }
                    if(self.candidates.count == 1) {
                        setKeyboard()
                        return false
                    }
                    else if(candidates.count > 1) {
                        self.tableTitle = "Autocomplete Results"
                        candidatesTable.isHidden = false
                        candidatesTable.reloadData()
                        
                        textField.resignFirstResponder()
                        textField.text = original
                        textField.text?.append(string)
                        reverse()
                        return false
                    }
                    else {
                        return false
                    }
                }
                else {
                    textField.text?.append(string)
                    self.reverse(textField.text!)
                    setKeyboard()
                    return false
                }
            }
            
            func delete(_ size:Int) {
                let start = range.location - size
                let end = (textField.text?.characters.count)!
                let rangeToRemove = (textField.text?.characters.index((textField.text?.startIndex)!, offsetBy: start))! ..< (textField.text?.characters.index((textField.text?.startIndex)!, offsetBy: end))!
                textField.text?.removeSubrange(rangeToRemove)
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
                    if(efStarValidator.evaluate(with: starType)) {
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
                if(letterValidator.evaluate(with: string)) {
                    return true
                }
                return false
            case 1:
                if(letterValidator.evaluate(with: string)) {
                    textField.text?.append(string + "-")
                }
                return false
            case 3:
                if(letterValidator.evaluate(with: string)) {
                    textField.text?.append(string + " ")
                }
                return false
            case 5:
                if(letterValidator.evaluate(with: string)) {
                    textField.text?.append(string)
                    reverse()
                }
                return false
            case 6:
                if(numberValidator.evaluate(with: string)) {
                    textField.text?.append(string)
                    reverse()
                }
                return false
            case 7:
                let starType:String = ssName.text![5]
                let firstDigit:Int = Int(ssName.text![6])!
                if(string == "-" && !(ghStarValidator.evaluate(with: starType)
                                      || (starType.uppercased() == "E" && firstDigit > 6)
                                      || (starType.uppercased() == "F" && firstDigit > 2))) {
                    textField.text?.append(string)
                    reverse()
                }
                else if(numberValidator.evaluate(with: string)) {
                    textField.text?.append(string)
                    reverse()
                }
                return false
            default:
                reverse()
                return false
            }
        }
    }
    
    func find(_ textField: UITextField, withNewData newData:String) {
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
        if(self.numberValidator.evaluate(with: reverseResult.text![0]) && ssName.text!.characters.count > 5) {
            let starType:String = ssName.text![5]
            if(self.abcValidator.evaluate(with: starType)) {
                self.doneButton.setTitle("       Nearby Zones", for: UIControlState());
            }
            else {
                self.doneButton.setTitle("                           Done", for: UIControlState());
            }
        }
        else {
            self.doneButton.setTitle("                           Done", for: UIControlState());
        }
    }
    
    func reverse(_ text:String) {
        reverseResult.text = Decoder.parse_reverse(text)
        self.setDoneButton()
    }
    
    func findNearbys() {
        let starType:String = ssName.text![5]
        if(!self.abcValidator.evaluate(with: starType)) {
            return; //kinda pointless to lookup nearbys for stars with big zones
        }
        let possibleStarTypes:String = "ABCDEFGH"
        self.candidates = [String]()
        for aStarType:Character in possibleStarTypes.characters {
            let myStarType:String = String.init(aStarType)
            if(myStarType == starType.uppercased()) {
                continue
            }
            let coords:String = self.reverseResult.text!
            let rangesArray:[String] = coords.components(separatedBy: CharacterSet.init(charactersIn: ","))
            var lookupCoords = [String]()
            for range:String in rangesArray {
                let myRanges:[String] = range.components(separatedBy: CharacterSet.init(charactersIn: "-"))
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
        if(self.candidates.count > 0) {
            self.tableTitle = "Nearby Zones"
            candidatesTable.isHidden = false
            candidatesTable.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.doneButton.isEnabled = false
        self.doneButton.alpha = 0.0
        return true;
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        if(self.activeTextField != nil) {
            self.activeTextField?.resignFirstResponder()
            self.activeTextField = nil
        }
        self.doneButton.isEnabled = false
        self.doneButton.alpha = 0.0
        if(self.doneButton.titleLabel!.text!.contains("Nearby Zones")) {
            self.findNearbys()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "whee")
        if(cell == nil) {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier:"whee")
        }
        
        cell!.textLabel!.text = self.candidates[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let selection:String = self.candidates[indexPath.row]
        self.textField(ssName, shouldChangeCharactersIn:NSRange.init(location: 0, length: self.ssName.text!.characters.count), replacementString: selection)
        //self.reverse(selection)
        self.candidatesTable.isHidden = true
        self.ssName.becomeFirstResponder()
        return(indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return self.candidates.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableTitle
    }
}

class LeetTextField: UITextField {
    
    override func deleteBackward() {
        super.deleteBackward()
    }
}

