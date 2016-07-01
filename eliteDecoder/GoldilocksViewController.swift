//
//  GoldilocksViewController.swift
//  eliteDecoder
//
//  Created by Jon Gilbert on 6/1/16.
//  Copyright © 2016 Jon Gilbert. All rights reserved.
//

import UIKit

class GoldilocksViewController: UIViewController {

    @IBOutlet var radiusLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!

    @IBOutlet var radiusSlider: UISlider!
    @IBOutlet var tempSlider: UISlider!
    
    @IBOutlet var minLS: UILabel!
    @IBOutlet var maxLS: UILabel!
    
    @IBOutlet var minAU: UILabel!
    @IBOutlet var maxAU: UILabel!
    
    @IBOutlet var starClassPicker: UISegmentedControl!

    var radius:Double = 1.0
    var temp:Double = 5780
    var lums:Double = 1.0
    var lum:Double = 1.0
    var maxTemp:Double = 3200.0
    var minTemp:Double = 2500.0
    var maxRadius:Double = 0.3
    var minRadius:Double = 0.05
    
    var radiusSliderLastValue:Float = -1.0
    var tempSliderLastValue:Float = -1.0
    var radiusSliderTimeLastUpdated:Double = -1.0
    var tempSliderTimeLastUpdated:Double = -1.0
    
    /* constants */
    let Sr:Double = 6.955000E+08
    let SB:Double = 5.670367E-08
    let AU:Double = 1.495979E+11
    
    let tempCutoffs:[Double] = [3700.0,5200.0,6000.0,7500.0,11000.0,32000.0,120000.0]
    
    let radiusCutoffs:[Double] = [0.699,1.01,1.24,1.7,2.0,6.0,20.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStarClass(0)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recalculate()
        // Dispose of any resources that can be recreated.
    }
    
    func min(median:Double) -> Double {
        return 450.16 * pow(lums,0.4599)
    }
    
    func max(median:Double) -> Double {
        return median * 1.46
    }
    
    func recalculate() {
        radiusLabel.text = String(format: "%.4f", radius)
        tempLabel.text = String(format: "%.2f", temp)

        lum = SB * pow(temp,4.0) * 4.0 * M_PI * pow(radius * Sr,2.0)
        lums = pow(radius,2.0) * pow(temp/5780.0,4.0)
        
        let medianAU = sqrt(0.25 * ((lum/M_PI)/1367.0))/AU
        let medianLS = medianAU * 499.0

        maxAU.text = String(format:"%.2f AU",max(medianAU))
        minAU.text = String(format:"%.2f AU",min(medianLS)/499.0)
        
        maxLS.text = String(format:"%.0f LS",max(medianLS))
        minLS.text = String(format:"%.0f LS",min(medianLS))
    }
    
    func radiusSliLog(sliderValue:Double) -> Double {
    // Input will be between min and max
        let min:Double = 1.0
        let max:Double = 15000.0
    
    // Output will be between minv and maxv
        let minv:Double = log(minRadius)
        let maxv:Double = log(maxRadius)
    
    // Adjustment factor
        let scale:Double = (maxv - minv) / (max - min)
    
        return exp(minv + (scale * (sliderValue - min)));
    }
    
    func tempSliLog(sliderValue:Double) -> Double {
        // Input will be between min and max
        let min:Double = 1.0
        let max:Double = 150000.0
        
        // Output will be between minv and maxv
        let minv:Double = log(minTemp)
        let maxv:Double = log(maxTemp)
        
        // Adjustment factor
        let scale:Double = (maxv - minv) / (max - min)
        
        return exp(minv + (scale * (sliderValue - min)));
    }
    
    func setStarClass(classification:Int) {
        maxTemp = tempCutoffs[classification]
        maxRadius = radiusCutoffs[classification]
        minRadius = 0.2
        minTemp = 1540.0
        if(classification != 0) {
            minTemp = tempCutoffs[classification - 1]
            let radiusOffset:Int = classification > 1 ? 2 : 1
            minRadius = radiusCutoffs[classification - radiusOffset]
        }
    }
    
    @IBAction func radiusSliderChanged(sender: UISlider) {
        if(radiusSliderTimeLastUpdated < -0.1) {
            radiusSliderTimeLastUpdated = NSDate().timeIntervalSince1970
        }
        else {
            let now:Double = NSDate().timeIntervalSince1970
            let delta:Double = now - radiusSliderTimeLastUpdated
            if(delta > 1.0) {
                //radiusSliderLocked = true
                radiusSlider.value = radiusSliderLastValue
                return
            }
        }
        if(radiusSliderLastValue == sender.value) {
            return;
        }
        radiusSliderLastValue = sender.value
        radiusSliderTimeLastUpdated = NSDate().timeIntervalSince1970
        let sliderValue:Double = Double(sender.value)
        radius = radiusSliLog(sliderValue)
        recalculate()
    }
    
    @IBAction func tempSliderChanged(sender: UISlider) {
        if(tempSliderTimeLastUpdated < -0.1) {
            tempSliderTimeLastUpdated = NSDate().timeIntervalSince1970
        }
        else {
            let now:Double = NSDate().timeIntervalSince1970
            let delta:Double = now - tempSliderTimeLastUpdated
            if(delta > 1.0) {
                //radiusSliderLocked = true
                tempSlider.value = tempSliderLastValue
                return
            }
        }
        if(tempSliderLastValue == sender.value) {
            return;
        }
        tempSliderLastValue = sender.value
        tempSliderTimeLastUpdated = NSDate().timeIntervalSince1970
        let sliderValue:Double = Double(sender.value)
        temp = tempSliLog(sliderValue)
        recalculate()
    }
    
    @IBAction func incrementTemp(sender: UIButton) {
        temp += 1.0
        recalculate()
    }
    
    @IBAction func decrementTemp(sender: UIButton) {
        temp -= 1.0
        recalculate()
    }
    
    @IBAction func incrementRadius(sender: UIButton) {
        radius += 0.0001
        recalculate()
    }
    
    @IBAction func decrementRadius(sender: UIButton) {
        radius -= 0.0001
        recalculate()
    }
    
    @IBAction func radiusSliderTouchUpInside(sender: UISlider) {
        radiusSliderTimeLastUpdated = -1.0
    }
    
    @IBAction func radiusSliderTouchUpOutside(sender: UISlider) {
        radiusSliderTimeLastUpdated = -1.0
    }
    
    @IBAction func tempSliderTouchUpInside(sender: UISlider) {
        tempSliderTimeLastUpdated = -1.0
    }
    
    @IBAction func tempSliderTouchUpOutside(sender: UISlider) {
        tempSliderTimeLastUpdated = -1.0
    }
    
    @IBAction func starClassChanged(sender: UISegmentedControl) {
        setStarClass(sender.selectedSegmentIndex)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
