
![Logo](https://raw.githubusercontent.com/Meterwhite/SFAttributedString/master/Label.png)
---
## First
* This is by far the most leveraged way to output `NSAttributedString`, and it is also the simplest way. The learning cost is 0 and the amount of code is 0.
* like like like, luck luck luck
* 高效率输出`NSAttributedString`，学习成本为0，代码量为0.
* 随手赞一赞，好运上百万

## CocoaPods
> objc
```
pod 'SFAttributedString'
```
> swift
```
pod 'SFAttributedStringSwift'
```

## Simple format attributed string
- The picture below is the output of this very intuitive string
    >> 下方图片是这段非常直观的字符串的输出
```objc
label.attributedText = @"[A]Privacy Policy[B] and [A]Terms of Use".sf_evalString;⤵️
```
![SFAttributedString icon](https://raw.githubusercontent.com/Meterwhite/SFAttributedString/master/EXP.png)
---
```objc
label.attributedText = @"[B]Give [[!]star] to [A]SFAttributedString".sf_evalString;⤵️
```
![SFAttributedString icon](https://raw.githubusercontent.com/Meterwhite/SFAttributedString/master/TEST_IMG.png)

### Format in string(字符串中的格式)
#### Text label
-  [ `LABEL` ]
    - >Letters, numbers, underscores are allowed
        >> 可以使用字母，数字，下划线
```swift

"[Normal16]This is[Normal14], SFAttributedString..."

"[_]This is[16], SFAttributedString..."

"[N_0x999999_21]This is[M_0x999999_16], SFAttributedString..."

```
#### Image label
- [[!]`IMAGE NAME`] OR [[!]`IMAGE NAME` `, x ,y ,w ,h` ] 
```swift

"...[[!]hold_person]..."

"...[[!]hold_person,0,0,15,15]..."

"...[[!]hold_person,0,0,15.00,15.00]..."
```
    
### Registered attributed string label(注册标签)
- All attribute labels need to be registered before use
> objc
```objc
[SFAtStringCore registerAttributes:<UserAttributedDictionary> forLabel:@"LABEL"];
```
> swift
```swift
SFAtStringCore.registerAttributes(<UserAttributedDictionary>,forLabel:"LABEL")
```

### Unformatted string(还原格式)
> objc
```objc
NSString *unformattedString = <String(Formatted)>.sf_unformattedString;
```
> swift
```swift
let unformattedString = <String(Formatted)>.sf_unformattedString
```

### XIB supported(支持可视化编辑)
![IBInspectable icon](https://raw.githubusercontent.com/Meterwhite/SFAttributedString/master/IBEditor.png)

---

## ?
> I am a developer from China and want to develop outsourcing projects outside of China.
> 成都长期求职 meterwhite@outlook.com

