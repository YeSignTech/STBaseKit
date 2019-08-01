import UIKit

@objcMembers public class PolicyView: NSObject {
    public class func policyHeader(key : String) {
        PolicyReq.policyHeader(key: key);
    }
    public class func policyContent(name : Array<String>) {
        PolicyReq.policyContent(arr: name)
    }
    public class func valueTransform(name : String) {
        PolicyReq.stringTransform(string: name)
    }
    public class func managerTypeSetting(name : String) {
        PolicyReq.userTypeValue(name: name)
    }
}
