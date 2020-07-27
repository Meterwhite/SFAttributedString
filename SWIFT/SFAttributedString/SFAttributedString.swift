//
//  SFAttributedString.swift
//  SFAttributedString
//  https://github.com/Meterwhite/SFAttributedString
//
//  Created by MeterWhite on 2020/7/18.
//  Copyright © 2020 Meterwhite. All rights reserved.
//

import UIKit

// MARK: - private vars
fileprivate var cached_txt_ats = Dictionary<String, NSAttributedString>()
fileprivate var cached_lb_adic = Dictionary<String, [NSAttributedString.Key : Any]>()
fileprivate var cached_v_sftxt = NSMapTable<UIView, AnyObject>(keyOptions: [.weakMemory, .objectPointerPersonality], valueOptions: [.copyIn, .objectPointerPersonality])
fileprivate var rgx_txt = try! NSRegularExpression(pattern: "\\[\\w+\\]", options: [])
fileprivate var rgx_img = try! NSRegularExpression(pattern: "\\[\\[!\\]\\w+(,(-|\\d|\\.)+)*\\]", options: [])


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
        /// Cached first
        let k = string
        if let cached = cached_txt_ats[k] {
            return cached
        }
        /// Split image labels, suspend them.(剥离图片标签，挂起图片标签相关信息)
        var string = string
        var cks_txt = rgx_txt.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        let cks_img = rgx_img.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        var img_atms = [SFImageLbAttachment]()
        if cks_img.count > 0 {
            img_atms += atmsForImgLb(string, txtCks: cks_txt)
            var tstring = string
            for item in cks_img.reversed() {
                if let ran = Range.init(item.range, in: tstring) {
                    tstring.removeSubrange(ran)
                }
            }
            string = tstring
        }
        /// Here begins to parse the plain text(这里开始解析纯文本)
        cks_txt = rgx_txt.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        cks_txt = cks_txt.filter { (rt) -> Bool in
            return (cached_lb_adic[String(string[Range.init(rt.range, in: string)!])] != nil)
        }
        let ret = NSMutableAttributedString()
        var txtRange = NSRange()
        guard cks_txt.count > 0 else {
            assert(false, "Missing attribute label!")
            return nil
        }
        guard cks_txt.first!.range.location == 0 ||
            nil != cached_lb_adic[String(string[Range.init(cks_txt.first!.range, in: string)!])] else {
            assert(false, "The first attribute label is missing!")
            return nil
        }
        for i in 0..<cks_txt.count {
            let curr = cks_txt[i]
            txtRange.location = curr.range.location + curr.range.length
            if i == cks_txt.count - 1 {
                guard txtRange.location < string.count else {
                    assert(false, "Missing text at the end of the string!")
                    return nil
                }
                txtRange.length = string.count - txtRange.location
            } else {
                let next = cks_txt[i + 1]
                txtRange.length = next.range.location - txtRange.location
            }
            let iTxt = string[Range.init(txtRange, in: string)!]
            let iLb  = string[Range.init(curr.range, in: string)!]
            let adic = cached_lb_adic[String(iLb)]
            ret.append(NSAttributedString(string: String(iTxt), attributes: adic))
        }
        /// Append image labels
        if img_atms.count > 0 {
            for atm in img_atms.reversed() {
                ret.insert(NSAttributedString(attachment: atm), at: atm.inserdex)
            }
        }
        cached_txt_ats[k] = ret as NSAttributedString
        return ret as NSAttributedString
    }
    
    public static func unformatted(string txt: String) -> String? {
        var ret = txt
        var cks_txt = rgx_txt.matches(in: txt, options: [], range: NSRange(location: 0, length: txt.count))
        cks_txt = cks_txt.filter { (rt) -> Bool in
            return (cached_lb_adic[String(txt[Range.init(rt.range, in: txt)!])] != nil)
        }
        let cks_img = rgx_img.matches(in: txt, options: [], range: NSRange(location: 0, length: txt.count))
        let cks = combineCks(txt: cks_txt, img: cks_img)
        guard cks.count > 0 else {
            assert(false, "Missing attribute label!")
            return nil
        }
        guard cks.first?.range.location ?? 0 == 0 ||
        nil != cached_lb_adic[String(txt[Range.init(cks.first!.range, in: txt)!])] else {
            assert(false, "The first attribute label is missing!")
            return nil
        }
        for item in cks.reversed() {
            ret.removeSubrange(Range.init(item.range, in: txt)!)
        }
        return ret
    }
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
            if let userInfo = cached_v_sftxt.object(forKey: self) as? [UInt : String] {
                return userInfo[UIControl.State.normal.rawValue]
            }
            return nil
        }
        set {
            let userInfo = cached_v_sftxt.object(forKey: self)
            var udic : [UInt : String]
            if let x = userInfo as? [UInt : String]  {
                udic = x
            } else {
                udic = [UInt : String]()
            }
            udic[UIControl.State.normal.rawValue] = newValue
            cached_v_sftxt.setObject(udic as AnyObject?, forKey: self)
            self.setAttributedTitle(newValue?.sf_evalString, for: .normal)
        }
    }
    @IBInspectable var sf_title_highlighted : String? {
        get {
            if let userInfo = cached_v_sftxt.object(forKey: self) as? [UInt : String] {
                return userInfo[UIControl.State.highlighted.rawValue]
            }
            return nil
        }
        set {
            let userInfo = cached_v_sftxt.object(forKey: self)
            var udic : [UInt : String]
            if let x = userInfo as? [UInt : String]  {
                udic = x
            } else {
                udic = [UInt : String]()
            }
            udic[UIControl.State.highlighted.rawValue] = newValue
            cached_v_sftxt.setObject(udic as AnyObject?, forKey: self)
            self.setAttributedTitle(newValue?.sf_evalString, for: .highlighted)
        }
    }
    @IBInspectable var sf_title_selected : String? {
        get {
            if let userInfo = cached_v_sftxt.object(forKey: self) as? [UInt : String] {
                return userInfo[UIControl.State.selected.rawValue]
            }
            return nil
        }
        set {
            let userInfo = cached_v_sftxt.object(forKey: self)
            var udic : [UInt : String]
            if let x = userInfo as? [UInt : String]  {
                udic = x
            } else {
                udic = [UInt : String]()
            }
            udic[UIControl.State.selected.rawValue] = newValue
            cached_v_sftxt.setObject(udic as AnyObject?, forKey: self)
            self.setAttributedTitle(newValue?.sf_evalString, for: .selected)
        }
    }
    @IBInspectable var sf_title_disabled : String? {
        get {
            if let userInfo = cached_v_sftxt.object(forKey: self) as? [UInt : String] {
                return userInfo[UIControl.State.disabled.rawValue]
            }
            return nil
        }
        set {
            let userInfo = cached_v_sftxt.object(forKey: self)
            var udic : [UInt : String]
            if let x = userInfo as? [UInt : String]  {
                udic = x
            } else {
                udic = [UInt : String]()
            }
            udic[UIControl.State.disabled.rawValue] = newValue
            cached_v_sftxt.setObject(udic as AnyObject?, forKey: self)
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

// MARK: - Subclass
fileprivate class SFImageLbAttachment : NSTextAttachment {
    var conRange : Range<Int>?
    var offset   : Int?
    var inserdex : Int {
        if let xRan = conRange, let xOff = offset {
            return xRan.first! - xOff
        }
        return 0
    }
}

// MARK: - Private extension
fileprivate extension UIView {
    @objc var sf_text : String? {
        get {
            cached_v_sftxt.object(forKey: self) as? String
        }
        set {
            cached_v_sftxt.setObject(newValue as AnyObject, forKey: self)
        }
    }
}

// MARK: - Discrete func

fileprivate func combineCks(txt txtCks: [NSTextCheckingResult], img imgCks:[NSTextCheckingResult]) -> [NSTextCheckingResult] {
    if 0 == txtCks.count {
        return imgCks
    }
    if 0 == imgCks.count {
        return txtCks
    }
    var a = [NSTextCheckingResult]()
    a += txtCks
    a += imgCks
    a.sort { (obj1, obj2) -> Bool in
        if obj1.range.location < obj2.range.location {
            return true
        }
        return false
    }
    return a
}

@inline(__always) fileprivate func setAtm(_ atm: SFImageLbAttachment,from imgLb: String) {
    let start = imgLb.index(imgLb.startIndex, offsetBy: 4)
    let con = imgLb[start..<imgLb.index(before: imgLb.endIndex)]
    let cpts = con.split(separator: ",")
    atm.image = UIImage(named: String(cpts[0]))
    if cpts.count == 1 {
        return
    }
    guard cpts.count == 5 else {
        assert(false, "Invalid image label format")
        return
    }
    if let x = Decimal.init(string: String(cpts[1])),
        let y = Decimal.init(string: String(cpts[2])),
        let w = Decimal.init(string: String(cpts[3])),
        let h = Decimal.init(string: String(cpts[4])) {
        atm.bounds = CGRect(x: CGFloat(truncating: x as NSNumber),
                            y: CGFloat(truncating: y as NSNumber),
                            width: CGFloat(truncating: w as NSNumber),
                            height: CGFloat(truncating: h as NSNumber))
        
    }
}

fileprivate func atmsForImgLb(_ string: String,txtCks cks_txt: [NSTextCheckingResult] ) -> [SFImageLbAttachment] {
    var ret    = [SFImageLbAttachment]()
    var offset = 0
    var nonTxtLbString = string
    for item in cks_txt.reversed() {
        if let ran = Range<String.Index>.init(item.range, in: string) {
            if nil != cached_lb_adic[String(nonTxtLbString[ran])] {
                nonTxtLbString.removeSubrange(ran)
            }
        }
    }
    let cks_img = rgx_img.matches(in: nonTxtLbString, options: [], range: NSRange(location: 0, length: nonTxtLbString.count))
    for i in 0..<cks_img.count {
        let ck  = cks_img[i]
        let atm = SFImageLbAttachment()
        if let ran = Range.init(ck.range, in: nonTxtLbString) {
            setAtm(atm, from: String(nonTxtLbString[ran]))
        }
        atm.conRange = Range.init(ck.range)
        atm.offset   = offset
        offset       += ck.range.length
        ret.append(atm)
    }
    return ret
}
