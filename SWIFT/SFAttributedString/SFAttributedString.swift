//
//  SFAttributedString.swift
//  SFAttributedString
//
//  Created by MeterWhite on 2020/7/18.
//  Copyright © 2020 Meterwhite. All rights reserved.
//

import UIKit

// MARK: - Extension for String
public extension String {
    var sf_evalString : NSAttributedString? {
        return SFAtStringCore.eval(script: self)
    }
    var sf_unformattedString : String? {
        return SFAtStringCore.unformatted(string: self)
    }
}

// MARK: - SFAtStringCore
public struct SFAtStringCore {
    public static func registerAttributes(_ adic: [NSAttributedString.Key : Any], forLabel lb:String) {
        cached_lb_adic["[\(lb)]"] = adic
    }
    
    public static func eval(script string:String) -> NSAttributedString? {
        var rts = rgx.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        guard rts.count > 0 else {
            return nil
        }
        let ret = NSMutableAttributedString()
        var iRangeTxt = NSRange()
        guard rts.first!.range.location == 0 && nil != cached_lb_adic[String(string[Range.init(rts.first!.range, in: string)!])] else {
            assert(false, "The first attribute label is missing!")
            return nil
        }
        rts = rts.filter { (rt) -> Bool in
            return (cached_lb_adic[String(string[Range.init(rt.range, in: string)!])] != nil)
        }
        guard rts.count > 0 else {
            assert(false, "Missing attribute label!")
            return nil
        }
        for i in 0..<rts.count {
            let curr = rts[i]
            iRangeTxt.location = curr.range.location + curr.range.length
            if i == rts.count - 1 {
                guard iRangeTxt.location < string.count else {
                    assert(false, "Missing text at the end of the string!")
                    return nil
                }
                iRangeTxt.length = string.count - iRangeTxt.location
            } else {
                let next = rts[i + 1]
                iRangeTxt.length = next.range.location - iRangeTxt.location
            }
            let iTxt = string[Range.init(iRangeTxt, in: string)!]
            let iLb  = string[Range.init(curr.range, in: string)!]
            let adic = cached_lb_adic[String(iLb)]
            ret.append(NSAttributedString(string: String(iTxt), attributes: adic))
        }
        return (ret.copy() as? NSAttributedString)
    }
    
    public static func unformatted(string txt: String) -> String {
        var ret = txt
        var rts = rgx.matches(in: txt, options: [], range: NSRange(location: 0, length: txt.count))
        assert(rts.first?.range.location == 0 &&
            nil != cached_lb_adic[String(txt[Range.init(rts.first!.range, in: txt)!])],
               "The first attribute label is missing!")
        rts = rts.filter { (rt) -> Bool in
            return (cached_lb_adic[String(txt[Range.init(rt.range, in: txt)!])] != nil)
        }
        for item in rts.reversed() {
            ret.removeSubrange(Range.init(item.range, in: txt)!)
        }
        return ret
    }
    // MARK: private
    private static var cached_lb_adic = Dictionary<String, [NSAttributedString.Key : Any]>()
    fileprivate static var cached_v_sftxt = NSMapTable<UIView, AnyObject>(keyOptions: [.weakMemory, .objectPointerPersonality], valueOptions: [.copyIn, .objectPointerPersonality])
    private static var rgx = try! NSRegularExpression(pattern: "\\[\\w+\\]", options: [])
}

// MARK: - IB Inspectable supported
public extension UITextField {
   @IBInspectable override var sf_text : String? {
        get {
            super.sf_text
        }
        set {
            super.sf_text = newValue
            self.attributedText = newValue?.sf_evalString
        }
    }
}

public extension UITextView {
   @IBInspectable override var sf_text : String? {
        get {
            super.sf_text
        }
        set {
            super.sf_text = newValue
            self.attributedText = newValue?.sf_evalString
        }
    }
}

public extension UIButton {
    @IBInspectable var sf_title_default : String? {
        get {
            if let userInfo = SFAtStringCore.cached_v_sftxt.object(forKey: self) as? [UInt : String] {
                return userInfo[UIControl.State.normal.rawValue]
            }
            return nil
        }
        set {
            let userInfo = SFAtStringCore.cached_v_sftxt.object(forKey: self)
            var udic : [UInt : String]
            if let x = userInfo as? [UInt : String]  {
                udic = x
            } else {
                udic = [UInt : String]()
            }
            udic[UIControl.State.normal.rawValue] = newValue
            SFAtStringCore.cached_v_sftxt.setObject(udic as AnyObject?, forKey: self)
            self.setAttributedTitle(newValue?.sf_evalString, for: .normal)
        }
    }
    @IBInspectable var sf_title_highlighted : String? {
        get {
            if let userInfo = SFAtStringCore.cached_v_sftxt.object(forKey: self) as? [UInt : String] {
                return userInfo[UIControl.State.highlighted.rawValue]
            }
            return nil
        }
        set {
            let userInfo = SFAtStringCore.cached_v_sftxt.object(forKey: self)
            var udic : [UInt : String]
            if let x = userInfo as? [UInt : String]  {
                udic = x
            } else {
                udic = [UInt : String]()
            }
            udic[UIControl.State.highlighted.rawValue] = newValue
            SFAtStringCore.cached_v_sftxt.setObject(udic as AnyObject?, forKey: self)
            self.setAttributedTitle(newValue?.sf_evalString, for: .highlighted)
        }
    }
    @IBInspectable var sf_title_selected : String? {
        get {
            if let userInfo = SFAtStringCore.cached_v_sftxt.object(forKey: self) as? [UInt : String] {
                return userInfo[UIControl.State.selected.rawValue]
            }
            return nil
        }
        set {
            let userInfo = SFAtStringCore.cached_v_sftxt.object(forKey: self)
            var udic : [UInt : String]
            if let x = userInfo as? [UInt : String]  {
                udic = x
            } else {
                udic = [UInt : String]()
            }
            udic[UIControl.State.selected.rawValue] = newValue
            SFAtStringCore.cached_v_sftxt.setObject(udic as AnyObject?, forKey: self)
            self.setAttributedTitle(newValue?.sf_evalString, for: .selected)
        }
    }
    @IBInspectable var sf_title_disabled : String? {
        get {
            if let userInfo = SFAtStringCore.cached_v_sftxt.object(forKey: self) as? [UInt : String] {
                return userInfo[UIControl.State.disabled.rawValue]
            }
            return nil
        }
        set {
            let userInfo = SFAtStringCore.cached_v_sftxt.object(forKey: self)
            var udic : [UInt : String]
            if let x = userInfo as? [UInt : String]  {
                udic = x
            } else {
                udic = [UInt : String]()
            }
            udic[UIControl.State.disabled.rawValue] = newValue
            SFAtStringCore.cached_v_sftxt.setObject(udic as AnyObject?, forKey: self)
            self.setAttributedTitle(newValue?.sf_evalString, for: .disabled)
        }
    }
}

public extension UILabel {
    @IBInspectable override var sf_text : String? {
        get {
            super.sf_text
        }
        set {
            super.sf_text = newValue
            self.attributedText = newValue?.sf_evalString
        }
    }
}

// MARK: - Private extension
fileprivate extension UIView {
    @objc var sf_text : String? {
        get {
            SFAtStringCore.cached_v_sftxt.object(forKey: self) as? String
        }
        set {
            SFAtStringCore.cached_v_sftxt.setObject(newValue as AnyObject, forKey: self)
        }
    }
}
