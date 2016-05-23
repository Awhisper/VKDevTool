# VKDebugConsole

App内控制台，可以在脱离Xcode debug的情况下，调试内存，打印数据，修改UI等

方便在黑盒测试+内部体验的环境下，发现Bug后，直接在Bug现场调试内存，分析问题

下面是动画演示

![git](http://ww3.sinaimg.cn/mw690/678c3e91jw1f446h4dso0g20ao0j8jxi.gif)


恩 基于JSPatch做的 ╮(╯_╰)╭

增加了target()方法来获取当前显示的VC

后续可以完善的地方还有很多

- target采用window下当前的VC，如果targe不正常，可以修改`getCurrentVC`方法
- 获取target手段应该，支持可以全局触摸选择View当做target
- Log打印对象的值还能优化更方便一些，希望能像LLDB的PO一样
- 希望能支持直接输入OC的[]方括号语法（解析前预处理js）


- 希望可以把系统NSLog一并输出在这里(done)
- Log颜色可以进行区分处理，报错和输出分别展现(DONE)

要做的事情还好多啊╮(╯_╰)╭
而且 这控制台UI有点丑。。。