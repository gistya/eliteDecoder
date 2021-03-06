//
//  Decoder.swift
//  eliteDecoder
//
//  Created by Jon Gilbert on 2/9/16.
//  Copyright © 2016 Jon Gilbert. All rights reserved.
//

import UIKit

let alphabet:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

infix operator **
func ** (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

extension String {
    
//    subscript (i: Int) -> Character {
//        return self[self.characters.index(self.startIndex, offsetBy: i)]
//    }
    
    subscript (i: Int) -> String {
        if(self.characters.count <= i) {
            return ""
        }
        let s = self[self.characters.index(self.startIndex, offsetBy: i)]
        return String([s])
    }
    
    subscript (r: CountableClosedRange<Int>) -> String {
        let start = characters.index(startIndex, offsetBy: r.lowerBound)
        let end = characters.index(start, offsetBy: r.upperBound - r.lowerBound)
        return self[(start ..< end)]
    }
}

let divisor = alphabet.characters.count
let middle = divisor**2
let biggest = divisor**3


let rowlength = 128
let sidelength = rowlength**2

open class Decoder: NSObject {
    
    static func finder(_ column:Int,stack:Int,row:Int,lettercode:String) -> String {
        var column = column, stack = stack, row = row, lettercode = lettercode
        var cubeside:Int = 0
        var first:String
        var second:String
        var third:String
        var number_second:Int
        var number_third:Int
        var number:Int
        var working:Int
        var position:Int
        var text:String
        lettercode = lettercode.uppercased();
        
        if lettercode == "H" {
            return "AA-A H#"
        }
        else if lettercode == "G" {
            cubeside = 640
        }
        else if lettercode == "F" {
            cubeside = 320
        }
        else if lettercode == "E" {
            cubeside = 160
        }
        else if lettercode == "D" {
            cubeside = 80
        }
        else if lettercode == "C" {
            cubeside = 40
        }
        else if lettercode == "B" {
            cubeside = 20
        }
        else if lettercode == "A" {
            cubeside = 10
        }
        
        if row >= cubeside {
            row = row - (row % cubeside)
        }
        else { row = 0 }
        
        row = (row / cubeside)
        
        if stack >= cubeside {
            stack = stack - (stack % cubeside)
        }
        else { stack = 0 }
        
        stack = stack/cubeside
        
        if column >= cubeside {
            column = column - (column % cubeside)
        }
        else { column = 0 }
        column = (column / cubeside)
        
        position = 0
        position += row * sidelength
        position += stack * rowlength
        position += column
        
        number = position / biggest
        working = position - (number * biggest)
        
        number_third = working / middle
        third = alphabet[number_third]
        working = working - (number_third * middle)
        
        number_second = working / divisor
        second = alphabet[number_second]
        working = working - (number_second * divisor)
        
        first = alphabet[working]
        
        
        if number != 0 {
            text = "\(first)\(second)-\(third) \(lettercode)\(number)-"
        }
        else {
            text = "\(first)\(second)-\(third) \(lettercode)"
        }
        return text
//        return "System name for these coordinates: [Sector Name] \(text)"
    }
    
    static func reverse(_ first:String,second:String,third:String,lettercode:String,first_number:Int) -> String {
        
        //print("\(first)\(second)-\(third) \(lettercode)\(first_number)-#")
        
        var position:Int
        var working:Int
        var row:Int
        var stack:Int
        var column:Int
        var cubeside:Int = 0
        var approx_x:Int
        var approx_y:Int
        var approx_z:Int
        
        position = 0
        position += first_number * biggest
        
        for letter in 0...(divisor-1) {
            if alphabet[letter] == third {
                position += letter * middle
            }
        }
        
        for letter in 0...(divisor-1) {
            if alphabet[letter] == second {
                position += letter * divisor
            }
        }
        
        for letter in 0...(divisor-1) {
            if alphabet[letter] == first {
                position += letter
            }
        }
        
        working = position
        
        row = working / sidelength
        working = working - (row * sidelength)
        
        stack = working / rowlength
        working = working - (stack * rowlength)
        
        column = working
        
        if lettercode == "H" {
            cubeside = 1280
        }
        else if lettercode == "G" {
            cubeside = 640
        }
        else if lettercode == "F" {
            cubeside = 320
        }
        else if lettercode == "E" {
            cubeside = 160
        }
        else if lettercode == "D" {
            cubeside = 80
        }
        else if lettercode == "C" {
            cubeside = 40
        }
        else if lettercode == "B" {
            cubeside = 20
        }
        else if lettercode == "A" {
            cubeside = 10
        }
        
        approx_x = (column * cubeside)
        approx_y = (row * cubeside)
        approx_z = (stack * cubeside)
        
        if(approx_x+cubeside > 1280 || approx_y+cubeside > 1280 || approx_z+cubeside > 1280) {
            return "out of bounds for 1280 LY cube"
        }
        
        return "\(approx_x)-\(approx_x+cubeside),\(approx_z)-\(approx_z+cubeside),\(approx_y)-\(approx_y+cubeside)"
        
    }
    
    public static func parse_reverse(_ input:String) -> String {
        var input = input
        
        //FIXME: This returns out of bounds until a hyphen is on the end for ones that need a hyphen; how about checking first to see if a hyphen would fix it and if so assume it's there?
        input.remove(at: input.characters.index(input.startIndex, offsetBy: 2)) //remove first hyphen
        input = input.replacingOccurrences(of: " ", with: "")
        if input.characters.count < 4 {
            return "error: invalid input"
        }
        if(input.contains("-")) { //ignore stuff after second hyphen
            let array = input.components(separatedBy: CharacterSet.init(charactersIn: "-"))
            input = array[0]
        }
        else {
            input = "\(input[0...3])0"
        }
        input = input.uppercased()
        let first = input[0] as String
        let second = input[1] as String
        let third = input[2] as String
        let lettercode = input[3] as String
        let first_number:Int? = Int(input.substring(from: input.characters.index(input.startIndex, offsetBy: 4)))
        if(first_number != nil) {
            return reverse(first, second: second, third: third, lettercode: lettercode, first_number: first_number!)
        }
        else {
            return "error: wrong format"
        }
    }
    
    public static func parse_finder(_ input:String) -> String {
        var input = input
        input = input.replacingOccurrences(of: " ", with: "")
        let coords = input.components(separatedBy: ",")
        if coords.count < 4 {
            return "error: invalid input"
        }
        return finder(Int(coords[0])!, stack: Int(coords[1])!, row: Int(coords[2])!, lettercode: coords[3])
    }

}
