# VKDebugTooL


整体全面推翻重做

已经完成

怎么使用看demo

我先不写详细的readme了，以后会补


TODO LIST:
consolelog 加入搜索功能（搜索+高亮看起来是个大坑T_T）




<!--

App内控制台，可以在脱离Xcode debug的情况下，调试内存，打印数据，修改UI等

方便在黑盒测试+内部体验的环境下，发现Bug后，直接在Bug现场调试内存，分析问题

先大体看一下GIF动画如何使用

![git](http://ww2.sinaimg.cn/mw690/678c3e91jw1f4cejgkcipg20900gfasa.gif)


Git地址 [VKDebugConsole](https://github.com/Awhisper/VKDebugConsole)

恩 基于JSPatch做的 ╮(╯_╰)╭

吐槽：界面好难看。。NSLog很多的时候有点乱。。

基本上初步的功能都补全了，能在自己项目里用上了，还算方便

后续优化指令，优化功能，优化界面，还需要持续进行（眼下这个看着太难看，指令也太难用了）

# 基本使用

- `[VKDebugConsole showBt]`方法会在window上增加一个debug按钮

- 点一下会变成select状态，触摸屏幕中任何view可以选择一个target
- 选择target后，console控制台打开，按钮变为Hidden
- 上部分为输入区，输入调试代码
- 下部分为输出区，输出调试信息，NSLog信息，调试错误（未来还会扩展其他
- 再次点击Hidden按钮会退出控制台

# 调试代码

因为是基于JSPatch的，所有JSPatch的语法规则这里都一模一样可以使用，可以参考一下动画中的用法，不过大部分用法还是遵从JSPatch，戳这里看如何使用 [JSPatch语法](https://github.com/bang590/JSPatch/wiki)

除了JSPatch支持的基本语法，还支持如下几条命令

- `target()`:获取刚才通过手选的界面View
- `targetVC()`获取刚才通过手选的界面View所在的VC
- `getParentVC(v)`输入一个View，获取所在的VC
- `print(item)`输出一个对象到控制台，单独处理了Label和View的描述信息，更加方便直观（可以扩展更多单独处理的对象类型）
- `changeSelect()`重新手选获取新target
- `exit()`退出控制台
- `clearOutput()`清空控制台输出区
- `clearInput()`清空控制台输入区

# 支持剪贴板

很明显，在APP黑盒的情况下，写代码是非常不方便的，用手机上面的软键盘，于是支持了剪贴板

- 打开控制台
- 在电脑上的编辑器里写好代码
- 无论以QQ微信等各种形式发到手机上，在手机上复制
- 切回APP显示控制台的时候，会自动把剪贴板的内容，复制到输入区

# 支持NSLog
写一个这样的宏在你的pch里面，覆盖NSLog

```objectivec
#ifndef __OPTIMIZE__

#import "VKLogManager.h"

#define NSLog(...) NSLog(__VA_ARGS__);\
                   VKLog(__VA_ARGS__)\

#else
#define NSLog(...) {}

#endif
```

在执行NSLog的同时，再自动执行一次VKLog，这样所有NSLog的打印就都同时打印在LLDB上和VKDebugConsole上了

支持了 红（出错） 黄（console.log） 白（系统NSlog）三种颜色

开启控制台后，程序再次输出的NSLog也能进入控制台区域方便查看

# 编译控制

所有的代码在debug模式下会生效，在release模式下会自动不参与编译，直接失效，不用担心发版前忘记关掉代码，导致线上暴露的问题

# 支持NSError

hook了系统的NSError生成，所有生成创建的NSError会自动记录log，并且以红色展示在控制台

# TODO LIST:

- 指令更易输入，能支持输入oc的方括号语法
- 界面更好看点吧，至少整理下控制台输出界面，可读性太差
- 扩展更多地方便调试的接口和指令
- 支持网络日志，所有的网络请求接口以及返回数据，会以网络日志的方式，在console里面查询
- 日志筛选控制
- ......

-->