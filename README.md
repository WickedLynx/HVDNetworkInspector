HVDNetworkInspector
===================

##What it does?

_HVDNetworkInspector_ keeps track of all network connections in your app and allows you to visualise them. 

![Screenshot](http://i.imgur.com/yPBP4Y3.png)

## How to use?

### Setup

Download the source code from here. Then:

1.	Drag _HVDNetworkInspector.xcodeproj_ into your project
2. 	Add _HVDNetworkInspector_ as a dependancy of your target
3.	Link your target with _libHVDNetworkInspector.a_

![Setup](http://i.imgur.com/5ijIjdh.png)

### Usage

1.	Import the header:  
>		#import <HVDNetworkInspector/HVDNetworkInspector.h>

2. 	Before you start creating network requests, call:  
>		[HVDNetworkInspector loadInspector];
	  You should only call this once in your app, typically in `application:didFinishLaunchingWithOptions:`.

3.	To show the connection summary, call:  
>		[HVDNetworkInspector showReport];
    

