# VKDevTooL

[App内调试工具 VKDevTool](https://github.com/Awhisper/VKDevTool)

允许在

- 在脱离Xcode Debug的情况下
- 黑盒真机情况下

进行App的调试工作，包括：

- 调试内存对象
- 打印内存数据
- 修改UI
- 查看NSLog
- 查看所有网络请求记录
- 查看App界面层级

方便在黑盒测试+内部体验的环境下，发现Bug后，直接在Bug现场调试内存，分析问题


>这个工具在早期的VKDebugConsole的基础上完全推翻重做了，核心思路都不变，只是重新整理了工具的使用方式，工具的界面呈现，工具的模块划分，模块化可扩展支持
>
>[旧文档链接 -- VKDebugConsole App黑盒控制台](http://awhisper.github.io/2016/05/22/VKDebugConsole-App%E9%BB%91%E7%9B%92%E6%8E%A7%E5%88%B6%E5%8F%B0/)

# 使用介绍
<!--more-->

## 工程配置

- 将`VKDevTool`文件夹拖入工程文件
- 将`VKDevToolLogHeader.h`写入pch，以便开启NSLog的动态拦截记录，不导入ConsoleLog模块无法捕获NSLog
- 可以修改`VKDevToolDefine.h`中的`#ifdef DEBUG`来进行自定义的编译控制，如果不修改，默认Debug模式下VKDevTool工具才有效

## 编写代码

```objectivec
[VKDevTool enableDebugMode];
```

一行代码即可开启DevTool的功能，该功能内部有编译控制，Release版本会自动失效，无需使用者在这行代码外围在套一层`#ifdef DEBUG`


## 如何使用

进行完工程配置与写入代码之后可以通过如下方式，在App内打开工程模式菜单

- 模拟器下，使用键盘command+x快捷键唤起菜单
- 真机运行下，使用摇一摇唤起菜单


![main](http://o7bhtwerg.bkt.clouddn.com/devtoolmain.jpeg)


主菜单模块包含4个模块
- DebugScript
- ConsoleLog
- NetworkLog
- ViewHierarchy3D

>VKDevTool采取模块化设计，每个模块Module都可以独立分拆分离，同时支持用户定义扩展自己的模块，图中的额外2个模块为自定义模块


## 黑盒调试功能DebugScript

- 在主菜单中选择`DebugScript`
- 按提示点选任意一个界面元素
- 进入代码控制台
- 上面是代码输入框
- 下面是输出框

![main](http://o7bhtwerg.bkt.clouddn.com/devscript1.jpeg)


以上是一个预览界面，上方输入的代码都是基于JSPatch的，所有JSPatch的语法规则这里都一模一样可以使用，戳这里看JSPatch如何使用 [JSPatch语法](https://github.com/bang590/JSPatch/wiki)

- 真机摇一摇 or 模拟器Command+X 可以唤起DebugScript模块子菜单
- 模拟器下如果输入过代码Command+X可能不好使，通过模拟器菜单`Shake Gesture`功能模拟摇一摇，依旧可以唤起

子菜单包含以下几个功能

- `GetTarget`:

自动往输入框中输入getTarget的脚本代码，执行以后print Target信息，便于后续直接调试target的任意内存数据和执行方法

- `Get TargetVC`:

自动往输入框中输入getTargetVC的脚本代码，执行以后print Target所在的当前vc的信息，便于后续直接调试targetVC的任意内存数据和执行方法

- `ChangeTarget`:

自动往输入框中输入切换所选target的代码，执行后，重新返回选择target界面

- `ClearInput`:

清空输入区域

- `ClearOutput`:

清空输出区域

- `Exit`:

退出DebugScript

除此之外，DebugScript为JS代码添加了一个功能print()函数，可以print任意OC对象，如果对象是View，还会有额外的frame等信息输出

我们通过一个GIF动画，大体看一下调试JS代码如何使用，此处的Gif是旧的Gif，新版本的颜色样式都已经调整，加了子菜单快捷方式，但是用法完全不变

![git](http://ww2.sinaimg.cn/mw690/678c3e91jw1f4cejgkcipg20900gfasa.gif)


## 日志拦截功能ConsoleLog

在PCH中加入了`VKDevToolLogHeader.h`后，本模块会拦截所有NSLog打印日志，以及NSError生成记录，在这个界面进行列表展示

- NSLog记录采用宏覆盖的方式，拦截接管了所有NSLog请求，以白色展现在界面内。
- NSError记录采用Runtime Swizzle的方式，拦截了NSError的init，以红色展现在界面内

![log1](http://o7bhtwerg.bkt.clouddn.com/debuglog2.jpeg)

真机摇一摇 or 模拟器Command+X 可以唤起ConsoleLog模块子菜单

- NSError Hook:开启和关闭NSError拦截
- Copy to Pasteboard:把所有日志信息拷贝到剪切板
- Search Keyword:在众多日志中搜索关键字，关键字以蓝色展示
- Exit:退出

## 网络拦截功能NetworkLog

VKDevTool会采用NSURLProtocol的方案，拦截hook所有的http请求，一一记录起来，以列表的形式，展现在NetworkLog模块内

每个cell，都可以点击查看每一条网络请求的真实返回数据，并且支持复制到剪切板

真机摇一摇 or 模拟器Command+X 可以唤起NetworkLog模块子菜单

- Network Hook:可以选择开启和关闭http拦截
- Change Filter:可以通过过滤器，过滤含有固定字符串的网络请求，方便查找搜索
- Exit:退出

![net1](http://o7bhtwerg.bkt.clouddn.com/devnet1.jpeg)

## 页面层级ViewHierarchy3D

VKDevTool采用YY大神开源的[YYViewHierarchy3D](https://github.com/ibireme/YYViewHierarchy3D),实现了这个页面层级模块

- 真机摇一摇 or 模拟器Command+X 可以唤起ViewHierarchy3D模块子菜单
- 模拟器下Command+X可能不好使，通过模拟器菜单`Shake Gesture`功能模拟摇一摇，依旧可以唤起

![view1](http://o7bhtwerg.bkt.clouddn.com/devview1.jpeg)

## 其他扩展代码

```objectivec
[VKDevTool changeNetworktModuleFilter:@“xxxxx”];
```
这个接口控制网络请求HookLog的过滤器，只拦截含有xxxx字符串的http网络请求，同时在DevTool内还可以通过菜单，修改网络拦截过滤器

如果全都拦截，可以省略


```objectivec
[VKDevTool registKeyName:@"custom module name" withExtensionFunction:^{
    //todo your code
}];
```
VKDevTool采取模块化设计，每个模块Module都可以独立分拆分离，同时支持用户定义扩展自己的模块

这个接口用于给VKDevTool扩展主菜单模块，可以省略不写，只使用自带的4个模块。
