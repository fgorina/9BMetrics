//
//  AppDelegate.swift
//  NinebotClientTest
//
//  Created by Francisco Gorina Vanrell on 2/2/16.
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var debugging = true
    
    static let applicationShortcutUserInfoIconKey = "applicationShortcutUserInfoIconKey"
    
    /// Saved shortcut item used as a result of an app launch, used later when app is activated.
    var launchedShortcutItem: UIApplicationShortcutItem?

    var window: UIWindow?
    
    var ubiquityUrl : NSURL?
    
    weak var mainController : ViewController?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        var shouldPerformAdditionalDelegateHandling = true
      
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            
            launchedShortcutItem = shortcutItem
            
            // This will block "performActionForShortcutItem:completionHandler" from being called.
            shouldPerformAdditionalDelegateHandling = false
        }
        
        self.setShortcutItems(false)
        
        return shouldPerformAdditionalDelegateHandling
    }
    
    
    func setShortcutItems(recording : Bool){
        
        var item : UIMutableApplicationShortcutItem?
        
        if recording {
            item = UIMutableApplicationShortcutItem(type: "es.gorina.9BMetrics.Stop", localizedTitle: "Stop", localizedSubtitle: "Stop recording data", icon: UIApplicationShortcutIcon(type: .Pause), userInfo: [
                AppDelegate.applicationShortcutUserInfoIconKey: UIApplicationShortcutIconType.Pause.rawValue
                ]
            )
        }
        else{
            item = UIMutableApplicationShortcutItem(type: "es.gorina.9BMetrics.Record", localizedTitle: "Record", localizedSubtitle: "Start recording data", icon: UIApplicationShortcutIcon(type: .Play), userInfo: [
                AppDelegate.applicationShortcutUserInfoIconKey: UIApplicationShortcutIconType.Play.rawValue
            ]
            )
        }
        
        
        if let it = item {
            UIApplication.sharedApplication().shortcutItems = [it]
        }
        
        
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if url.fileURL{
            
            
            guard let name = url.lastPathComponent else {return false}
            
            guard var newUrl =  self.applicationDocumentsDirectory()?.URLByAppendingPathComponent(name) else {return false}
            
            let mgr = NSFileManager.defaultManager()
            
            // Check if file exists
            
            var ct = 1
            guard var path = newUrl.path else {return false}
            
            while mgr.fileExistsAtPath(path){
                
                let newName = String(format: "%@(%d)", name, ct)
                let aUrl = self.applicationDocumentsDirectory()?.URLByAppendingPathComponent(newName)
                if let url = aUrl{
                    path = url.path!
                    newUrl = url
                    ct++
                }
                else{
                    return false
                    
                }
            }
            
            do {
                try mgr.moveItemAtURL(url, toURL: newUrl)
                
                if let wc = self.mainController{
                    wc.reloadFiles()
                    wc.openUrl(newUrl)
                }
                
            }catch {
                AppDelegate.debugLog("ERROR al copiar url %@ a %@", url, newUrl)
                return false
                
            }
            
            return true
            
        }
        return false
    }
    
  
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK : Shortcuts
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        let handledShortCutItem = handleShortCutItem(shortcutItem)
        
        completionHandler(handledShortCutItem)
    }
    
    func handleShortCutItem(shortcut : UIApplicationShortcutItem) -> Bool{

        AppDelegate.debugLog("Handle Sort Cut Item")
        launchedShortcutItem = nil // Clear it
     
        if shortcut.type == "es.gorina.9BMetrics.Record"{
            
            guard  let nav : UINavigationController = window?.rootViewController  as? UINavigationController else {return false}
            
            guard let wc = nav.topViewController as? ViewController   else {return false}
            
            wc.performSegueWithIdentifier("dashboardSegue", sender: wc)
            
        }else if shortcut.type == "es.gorina.9BMetrics.Stop"{
            guard  let nav : UINavigationController = window?.rootViewController  as? UINavigationController else {return false}
            
            guard let ds = nav.topViewController as? BLENinebotDashboard   else {return false}
            //guard let ds = wc.dashboard else {return false}
            
            ds.stop(self)
            
        }
        
        
        return true
    }
    
    // Missatges de Debug
    
    static func debugLog(format: String, _ args: CVarArgType...) {
        
        if AppDelegate.debugging {
            withVaList(args){
                NSLogv(format, $0)
            }
        }
        
    }
    
    //MARK : Directory Management
    
    func localApplicationDocumentsDirectory() -> NSURL?
    {
        let docs = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last
        
        return docs
        
    }
    
    
    func applicationDocumentsDirectory() -> NSURL?{
        
        if let url = self.ubiquityUrl{
            return url.URLByAppendingPathComponent("Documents")
        }
        else{
            return self.localApplicationDocumentsDirectory()
        }
    }
    
}

