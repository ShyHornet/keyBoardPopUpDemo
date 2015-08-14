##为什么要做这个效果
------
在qq微信中，你会注意到一个效果，就是在你点击输入框时输入框会跟随键盘一起向上弹出，当你点击其他地方时，输入框又会跟随键盘一起向下收回.你会发现二者完全无缝连接，也许你会说直接在键盘弹出的时候把输入框也向上移动不就行了？但是我使用这种方法的时候，发现效果十分不理想，原因有以下几点:
1.键盘弹出动画并不是匀速，键盘和输入框的时间曲线不完全一致,运动不同步
2.各种键盘的高度不一样（比如搜狗输入法就比系统自带键盘要高）
3.无法确定键盘动画的时间，会导致延迟

##解决方案
___
>这里应用了两种在ios编程中很重要的思想:`Key-value coding` (KVC) 和 `key-value observing` (KVO)

1.使用`  NSNotificationCenter.defaultCenter().addObserver()`添加对`UIKeyboardWillShowNotification`和`UIKeyboardWillHideNotification`键的监控，当这些值发生改变时发送通知
```Swift
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyBoardWillShow:", name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyBoardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
```
2.实现两个监控方法

实现键盘弹出的方法:

```Swift
    func keyBoardWillShow(note:NSNotification)
    {
    
        //1
        let userInfo  = note.userInfo as! NSDictionary
        //2
        var  keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        //3
        var keyBoardBoundsRect = self.view.convertRect(keyBoardBounds, toView:nil)
        //4
        var keyBaoardViewFrame = keyBaordView.frame
        var deltaY = keyBoardBounds.size.height
        //5
        let animations:(() -> Void) = {
            
            self.keyBaordView.transform = CGAffineTransformMakeTranslation(0,-deltaY)
        
        if duration > 0 {
            let options = UIViewAnimationOptions(UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
            
            
        }else{
            
            animations()
        }
        
    }
```
代码分析

//1
```Swift
    let userInfo  = note.userInfo as! NSDictionary
  ```
  将通知的用户信息取出,转化为字典类型，里面所存的就是我们所需的信息:键盘动画的时长、时间曲线;键盘的位置、高度信息。有了这些信息我们就可以do some magic了~
//2
通过对应的键`UIKeyboardFrameEndUserInfoKey`，取出键盘位置信息
通过`UIKeyboardAnimationDurationUserInfoKey`,取出动画时长信息
//3
```swift
    var keyBoardBoundsRect = self.view.convertRect(keyBoardBounds, toView:nil)
```
由于取出的位置信息是绝对的，所以要将其转换为对应于当前view的位置，否则位置信息会出错！
//4 
```Swift
       var keyBaoardViewFrame = keyBaordView.frame
       var deltaY = keyBoardBounds.size.height
```
保存下输入框的位置信息和y坐标需要变换的量以便后面调用

//5
```Swift
        let animations:(() -> Void) = {
            
            self.keyBaordView.transform = CGAffineTransformMakeTranslation(0,-deltaY)
        
        if duration > 0 {
            let options = UIViewAnimationOptions(UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
            
            
        }else{
            
            animations()
        }
        
    }
```
首先使用仿射变换`CGAffineTransformMakeTranslation`，使输入框的高度减少deltaY也就是跟随键盘的位置向上移动;
#####此处最重要的部分在这里
```swift
     let options = UIViewAnimationOptions(UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
```
这里是将时间曲线信息(一个64为的无符号整形)转换为`UIViewAnimationOptions`，要通过左移动16来完成类型转换。
自我感觉这是apple做的不太好的地方，它居然没有用来进行类型转换的方法，竟然还得要位！运！算！不过相信今后这个坑会被填上吧。。

然后呢就是把这些东西全部装进UIView的动画函数中，执行动画
```swift
     UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
```
这样键盘弹出的方法就完全实现了！
接下来就是收回键盘的部分了:
这部分呢就比较简单了，收回键盘时只需要动画时长`duration`和时间曲线信息`options`所以只要留下他们就行了，然后再将输入框的位置还原即可，这里有一个很巧妙的办法
```Swift
    self.keyBaordView.transform = CGAffineTransformIdentity
```
这样就可以还原所有变换~
下面是该方法的实现:
```Swift
  func keyBoardWillHide(note:NSNotification)
    {
    
        let userInfo  = note.userInfo as! NSDictionary
        
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        
        let animations:(() -> Void) = {
            
            self.keyBaordView.transform = CGAffineTransformIdentity
            
        }
        
        if duration > 0 {
            let options = UIViewAnimationOptions(UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
            
            
        }else{
            
            animations()
        }
              
    }
```
实际上这个方法不会运行，因为并没有判断是否应该收回键盘，我的解决方法是当手指点击输入框之上的任何地方就会收回键盘，这个在我的完整demo会看到。

####如果本篇文章对你有帮助，可以点一下右上角star⭐️,大家的支持与鼓励是继续写作的动力~




