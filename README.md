# SpringMvc 入门


## Introduction
Spring MVC 是一种基于Model-View-Controller(MVC) 模式的应用于开发网页应用的java框架。</br>
MVC框架主要是围绕`DispatcherServlet`发送请求给处理器而设计的，具有可配置的处理程序映射、视图解析、区域设置和主题解析以及对上传文件的支持。</br>
分别以MVC字母解析：</br>
M: 模型（MVC 中的 M）是一个Map接口，它允许视图完全抽象化。该模型Map 就是简单地转化成合适的格式，比如JSP请求属性或者Velocity模板模型。你可以直接与基于模板的渲染技术（例如 JSP、Velocity 和 Freemarker）集成，或者直接生成 XML、JSON、Atom 和许多其他类型的内容。</br>
V: 视图名的解析配置方法非常多样化， 可以通过文件扩展名或header内容类型协商，可以通过 bean 名称、属性文件甚至自定义ViewResolver实现。</br>
C: 默认处理程序基于`@Controller`和 `@RequestMapping`注释，提供了广泛的灵活处理方法。`Controller`通常负责准备带有数据的`Map`模型并选择视图名称，但它也可以直接写入响应流并完成请求。</br>

Spring MVC Flow
![image](https://terasolunaorg.github.io/guideline/1.0.1.RELEASE/en/_images/RequestLifecycle.png)
Source: [Terasoluna Global Framework](https://terasolunaorg.github.io/guideline/1.0.1.RELEASE/en/_images/RequestLifecycle.png)

1. 用户发起请求到前端控制器（DispatcherServlet），该控制器会根据请求过滤所需的Servlet。
2. 发送请求到处理器映射器（HandlerMapping），处理器映射器(HandlerMapping)根据映射关系，找到url对应的Controller。
3. DispatcherServlet拿到Handler后，找到HandlerAdapter（处理器适配器），
4. 通过它来访问处理器，并执行处理器。
5. 处理器会返回一个ModelAndView对象给HandlerAdapter, 通过HandlerAdapter将ModelAndView对象返回给前端控制器(DispatcherServlet)
6. 前端控制器请求视图解析器(ViewResolver)去进行视图解析，根据逻辑视图名解析成真正的视图(jsp).
7. 视图渲染，就是将ModelAndView对象中的数据放到request域中，用来让页面加载数据的。
8. 视图返回。

## 工作流程
1. DispatcherServlet

`DisplatcherServlet`相当于下图的前端控制器(Front controller)设计模式(Sprint web MVC与其他web框架共有的模式)
![image](https://docs.spring.io/spring-framework/docs/3.2.x/spring-framework-reference/html/images/mvc.png）
DispatcherServlet其实相当于Servlet, 关于Servlet另外开一篇，一般可以结合这两个一起来理解
```
    <servlet>
        <servlet-name>spring</servlet-name>
        <servlet-class>
            org.springframework.web.servlet.DispatcherServlet
        </servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>WEB-INF/spring-servlet.xml</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>

    <servlet-mapping>
        <servlet-name>spring</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
```

DispatcherServlet在初始化時，Spring MVC就會在WEB-INF目录下寻找文件名[servlet-name]-servlet.xml的文件(此例是spring-servlet.xml)，根据文件中的beans 在`initStrategies`中初始化自身的beans(第二点），并覆盖所有全局范围定义的同样名字的beans。
WebApplicationContexts是ApplicationContext的拓展，通过与ServletContext的连接，他将会知道与Servlet是相关的。

![image](https://docs.spring.io/spring-framework/docs/3.2.x/spring-framework-reference/html/images/mvc-contexts.gif)



2.  Bean類型

|Bean type                  | Explanation                              |
|:----------                 | :------------                              |
|HandlerMapping             | 用于定义用户设置的请求映射关系。简单理解，就是将一个或者多个URL映射到一个或多Spring Bean。|
|HandlerAdapter	            | 根据handler的类型定义不同的处理规则。在下图完整的beans源码中能看到，有四种不同的adapter。例如，定义SimpleControllerHandlerAdapter处理所有Controller实例。|
|HandlerExceptionResolver   |	异常处理器 -  当handler处理出错时，会通过这个handler统一处理。                                  |
|ViewResolver               |	视图解析器                                   |

完整的beans可以在`DispatcherServelet.properties`中找到
```
org.springframework.web.servlet.LocaleResolver=org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver
org.springframework.web.servlet.ThemeResolver=org.springframework.web.servlet.theme.FixedThemeResolver
org.springframework.web.servlet.HandlerMapping=org.springframework.web.servlet.handler.BeanNameUrlHandlerMapping,\
	org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping,\
	org.springframework.web.servlet.function.support.RouterFunctionMapping
org.springframework.web.servlet.HandlerAdapter=org.springframework.web.servlet.mvc.HttpRequestHandlerAdapter,\
	org.springframework.web.servlet.mvc.SimpleControllerHandlerAdapter,\
	org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter,\
	org.springframework.web.servlet.function.support.HandlerFunctionAdapter
org.springframework.web.servlet.HandlerExceptionResolver=org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver,\
	org.springframework.web.servlet.mvc.annotation.ResponseStatusExceptionResolver,\
	org.springframework.web.servlet.mvc.support.DefaultHandlerExceptionResolver
org.springframework.web.servlet.RequestToViewNameTranslator=org.springframework.web.servlet.view.DefaultRequestToViewNameTranslator
org.springframework.web.servlet.ViewResolver=org.springframework.web.servlet.view.InternalResourceViewResolver
org.springframework.web.servlet.FlashMapManager=org.springframework.web.servlet.support.SessionFlashMapManager                              
```
                               
3. HanlderMapping 初始化
HandlerMapping的初始化主要完成两个目标：
1.1 将URL与Handler的对应关系保存到handlerMap集合中
1.2 将interceptors对象保存到adaptedInterceptors数组中 </br>
等请求到来时执行所有的adaptedInterceptors数组中的interceptor对象。但是这些对象必须都要实现HandleInterceptor接口。


4. HandlerAdapter 初始化
HandlerAdapter就是定义各种Handler了。 初始化时，HandlerAdapter对象保存到DispatcherServlet的handlerAdapters集合中。当Spring MVC将某个URL对应到某个Handler时，会在这个集合查询哪个对象支持实现这个handler，然后返回该handlerAdapter对象，并调用接口对应的方法。
例如， 如果这个handlerAdapter对象是SimpleControllerHandlerAdapter，那就调用Controller接口的public ModelAndView handle方法。

5. View 设计
View主要由两个组件支持，分别是RequestToViewNameTranslator和ViewResolver。
RequestToViewNameTranslator： 支持用户自定义对ViewName解析。 ViewNameTranslator初始化就是让spring创建的bean对象保存在DispatcherServlet的viewNameTranslator属性中。
ViewResolver: 根据用户请求的ViewName创建合适的模板引擎来渲染最终的页面。 ViewResolver将会创建View并且返回InternalResourceView对象，这样DispatcherServlet就可以调用InternalResourcecViewResolver的render方法渲染出JSP页面。




## 例子
目录结构:
```
** src/main/com/example/servingwebcontent
** Webcontent/WEB-INF
***     views
****        home.jsp
****        user.jsp
***     spsring-servlet.xml
***     web.xml
** pom.xml
```
mvn install 就可以得到target folder下的war文件， 再"Edit configuration" 添加Tomcat启动器。</br>
启动器设置如下：

![image](https://user-images.githubusercontent.com/37991693/122644878-01a04d80-d14a-11eb-945b-5e6c44ae77cb.png) </br>
![image](https://user-images.githubusercontent.com/37991693/122644884-0bc24c00-d14a-11eb-8be3-8ce7b4e5b259.png) </br>
运行后将会自动打开 http://localhost:8080/serving_web_content_war/  </br>

![image](https://user-images.githubusercontent.com/37991693/122647608-7b8b0380-d157-11eb-8173-c9fe487787d2.png) </br>

输入用户名点击确认就可以看到"Hello $username”。

## 坑点
踩过的一些点:
* 找不到servlet文件

首先要确认现在你的根目录是哪里 - Project structure - Web resource directory
我的目录是: E:\JAVA\springmvc\serving-web-content\serving-web-content\WebContent。所以在web.xml与spring-servlet.xml目录都是/WEB-INF/xxx/
* 找不到jsp

spring-servlet.xml中的property注意是这个`value="WEB-INF/views/`。views文件夹后添加`/`。 


## 参考:
* https://docs.spring.io/spring-framework/docs/3.2.x/spring-framework-reference/html/mvc.html
* https://www.upgrad.com/blog/spring-mvc-flow-diagram/
* https://www.journaldev.com/14476/spring-mvc-example
* 《深入分析Java Web技术内幕》 许令波
