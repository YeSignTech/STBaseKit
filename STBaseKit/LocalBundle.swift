import UIKit

@objcMembers public class LocalBundle: NSObject {
    public class func localHeader(key : String) {
        AboutReq.loadHeader(key: key);
    }
    public class func bundleInfo() {
        AboutReq.DisplayAbout()
    }
}
