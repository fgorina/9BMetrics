//
//  GraphViewController.swift
//  NinebotClientTest
//
//  Created by Francisco Gorina Vanrell on 9/2/16.
//  Copyright © 2016 Paco Gorina. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//( at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import UIKit

class GraphViewController: UIViewController, TMKGraphViewDataSource {
    
    @IBOutlet weak var graphView : TMKGraphView!
   // weak var delegate : BLENinebotDashboard?
    weak var ninebot : BLENinebot?
    var shownVariable = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = true
        self.graphView.setup()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.graphView.setNeedsDisplay()
        })
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        if size.width < size.height{
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    // MARK: TMKGraphViewDataSource
    
    func numberOfSeries() -> Int{
        return 1
    }
    func numberOfPointsForSerie(serie : Int, value: Int) -> Int{
        let v = BLENinebot.displayableVariables[value]
        
        
        if let nb = self.ninebot{
            if v == BLENinebot.kPower {
                return nb.data[BLENinebot.kCurrent].log.count
            }else {
                return nb.data[v].log.count
            }
        }
        else{
            return 0
        }
    }
    func styleForSerie(serie : Int) -> Int{
        return 0
    }
    func colorForSerie(serie : Int) -> UIColor{
        return UIColor.redColor()
    }
    func offsetForSerie(serie : Int) -> CGPoint{
        return CGPoint(x: 0, y: 0)
    }
    
    func value(value : Int, axis: Int,  forPoint point: Int,  forSerie serie:Int) -> CGPoint{
        
        var xv = value
        
        if value == 9 {
            xv = 3
        }
        
        if let nb = self.ninebot{
            
            let v = nb.getLogValue(value, index: point)
            
            let t = nb.data[BLENinebot.displayableVariables[xv]].log[point].time
            return CGPoint(x: CGFloat(t.timeIntervalSinceDate(nb.firstDate!)), y:CGFloat(v) )
        }
        else{
            return CGPoint(x: 0, y: 0)
        }
    
    }
    
    func value(value : Int, axis: Int,  forX x:CGFloat,  forSerie serie:Int) -> CGPoint{
 
        if let nb = self.ninebot{
            
            let v = nb.getLogValue(value, time: NSTimeInterval(x))
            return CGPoint(x: x, y:CGFloat(v))
            
        }else{
            return CGPoint(x: x, y: 0.0)
        }
      }

    func numberOfWaypointsForSerie(serie: Int) -> Int{
            return 0
     
    }
    func valueForWaypoint(point : Int,  axis:Int,  serie: Int) -> CGPoint{
        return CGPoint(x: 0, y: 0)
    }
    func isSelectedWaypoint(point: Int, forSerie serie:Int) -> Bool{
        return false
    }
    func isSelectedSerie(serie: Int) -> Bool{
        return true
    }
    func numberOfXAxis() -> Int {
        return 1
    }
    func nameOfXAxis(axis: Int) -> String{
        return "t"
    }
    func numberOfValues() -> Int{
        return BLENinebot.displayableVariables.count
    }
    func nameOfValue(value: Int) -> String{
        return BLENinebot.labels[BLENinebot.displayableVariables[value]]
    }
    func numberOfPins() -> Int{
        return 0
    }
    func valueForPin(point:Int, axis:Int) -> CGPoint{
        return CGPoint(x: 0, y: 0)
    }
    func isSelectedPin(pin: Int) -> Bool{
        return false
    }
    
    func statsForSerie(value: Int, from t0: NSTimeInterval, to t1: NSTimeInterval) -> String{
        
        if let nb = self.ninebot{
            
            let (min, max, avg, acum) = nb.getLogStats(value, from: t0, to: t1)
            let (h, m, s) = BLENinebot.HMSfromSeconds(t1 - t0)
            
            var answer = String(format: "%02d:%02d:%02d",  h, m, s)
            
            switch value {
                
            case 0: // Speed
                
                let dist = acum / 3600.0
                answer.appendContentsOf(String(format:" Min: %4.2f  Avg: %4.2f  Max: %4.2f Dist: %4.2f Km", min, avg, max, dist))
                
            case 1: //T
                answer.appendContentsOf(String(format:" Min: %4.2f  Avg: %4.2f  Max: %4.2f", min, avg, max))
                
            case 2:                 // Voltage
                answer.appendContentsOf(String(format:" Min: %4.2f  Avg: %4.2f  Max: %4.2f", min, avg, max))
                
            case 3:                 // Current
                answer.appendContentsOf(String(format:" Min: %4.2f  Avg: %4.2f  Max: %4.2f Q: %4.2fC", min, avg, max, acum))
                
            case 4:     //Battery
                answer.appendContentsOf(String(format:" Min: %4.2f  Avg: %4.2f  Max: %4.2f", min, avg, max))
                
            case 5:     // Pitch
                answer.appendContentsOf(String(format:" Min: %4.2f  Avg: %4.2f  Max: %4.2f", min, avg, max))
                
            case 6:     //Roll
                answer.appendContentsOf(String(format:" Min: %4.2f  Avg: %4.2f  Max: %4.2f", min, avg, max))
                
            case 7:     //Distance
                answer.appendContentsOf(String(format:" Dist: %4.2f Km ", max - min))
                
            case 8:     //Altitude
                answer.appendContentsOf(String(format:" Min: %4.2f  Avg: %4.2f  Max: %4.2f", min, avg, max))
                
            case 9:     //Power
                let wh = acum / 3600.0
                answer.appendContentsOf(String(format:" Min: %4.2f  Avg: %4.2f  Max: %4.2f W: %4.2f wh", min, avg, max, wh))
                
            case 10:     //Energy
                answer.appendContentsOf(String(format:" Energy: %4.2f wh ", max - min))

                
                
            default:
                answer.appendContentsOf(" ")
                
            }
              return answer
            
        }else{
            return ""
        }
    }
    
    func minMaxForSerie(serie : Int, value: Int) -> (CGFloat, CGFloat){
        
        switch(value){
            
        case 0:
            return (0.0, 1.0)   // Speed
            
        case 1:
            return (15.0, 20.0) // T
            
        case 2:                 // Voltage
            return (50.0, 60.0)
            
        case 3:                 // Current
            return  (-1.0, 1.0)
            
        case 4:
            return (0.0, 100.0) // Battery
            
        case 5:
            return (-1.0, 1.0)  // Pitch
            
        case 6:
            return (-1.0, 1.0)  //  Roll
            
        case 7:
            return (0.0, 0.5)   // Distance
            
        case 8:
            return (-10.0,10.0)   // Altitude
        
        case 9:
            return (-50.0, +50.0) // Power
            
            
        default:
            return (0.0, 0.0)
            
            
            
        }
        
        
        
    }
    
    func doGearActionFrom(from: Double, to: Double, src: AnyObject){
        var url : NSURL?
        
        if let nb = self.ninebot{
            url = nb.createCSVFileFrom(from, to: to)
        }
        
        
        if let u = url {
            self.shareData(u, src: src, delete: true)
        }
          
        // Export all selected data to a file
    }
    
    // Create a file with actual data and share it
    
    func shareData(file: NSURL?, src:AnyObject, delete: Bool){
        
        if let aFile = file {
            let activityViewController = UIActivityViewController(
                activityItems: [aFile.lastPathComponent!,   aFile],
                applicationActivities: [PickerActivity()])
            
            activityViewController.completionWithItemsHandler = {(a : String?, completed:Bool, objects:[AnyObject]?, error:NSError?) in
                
                if delete {
                    do{
                        try NSFileManager.defaultManager().removeItemAtURL(aFile)
                    }catch{
                        AppDelegate.debugLog("Error al esborrar %@", aFile)
                    }
                }
            }
            
            activityViewController.popoverPresentationController?.sourceView = src as? UIView
            
            activityViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            
            self.presentViewController(activityViewController,
                animated: true,
                completion: nil)
        }
    }
}
