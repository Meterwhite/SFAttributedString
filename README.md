
![Logo](https://raw.githubusercontent.com/Meterwhite/SFAttributedString/master/Label.png)
---
## FIRST
* This is by far the most leveraged way to output `NSAttributedString`, and it is also the simplest way. The learning cost is 0 and the amount of code is 0.
* like like like, luck luck luck
* 这是迄今为止输出`NSAttributedString`杠杆最高的方式，也是最简单的方式，学习成本为0，代码量为0.
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

### WHY?
 > It is often necessary to think that we are software engineers, not software coders. The most efficient way is to package the difficulties and repeat simple things, rather than repeating it after reducing the difficulties, because this is still repeating difficult things, as is the case with the following open source projects.
    >> 时常需要思考我们是软件工程师，而不是软件代码师。最高效的方式是将困难打包然后重复简单的事情，而不是将困难减小后再重复它，因为这还是重复困难的事情，下面的开源项目就是如此。
```swift
//SJAttributesFactory
let text = NSAttributedString.sj.makeText { (make) in
    make.font(.boldSystemFont(ofSize: 20)).textColor(.black).lineSpacing(8)
    make.append("Hello world!")
}
```
```objc
//Typeset
@"Hello".typeset.from(0).to(2).red.string;
@"Hello".typeset.location(0).length(2).red.string;
@"Hello".typeset.range(NSMakeRange(0,2)).red.string;
@"Hello".typeset.match(@"He").red.string;
```

### Format in string(字符串中的格式)
-  `[` + `LABEL`+`]`
    - >Letters, numbers, underscores are allowed
        >> 可以使用字母，数字，下划线

```swift

"[Normal16]This is[Normal14], SFAttributedString..."

"[_]This is[16], SFAttributedString..."

"[N_0x999999_21]This is[M_0x999999_16], SFAttributedString..."

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

### Unformatted string(反格式化)
> objc
```objc
NSString *unformattedString = <SFAttributedString>.sf_unformattedString;
```
> swift
```swift
let unformattedString = <SFAttributedString>.sf_unformattedString
```

### XIB supported(支持可视化编辑)
![IBInspectable icon](https://raw.githubusercontent.com/Meterwhite/SFAttributedString/master/IBEditor.png)

---

## ?
- > Increase the cache mechanism, more efficient
    >> 增加缓存机制，更加高效
- > Add image attribute labels
    >> 增加图片的属性标签
