#Developing a Tizen App

###To create a Tizen App,first install Samsung Tizen TV SDK  from link http://www.samsungdforum.com/Devtools/Sdkdownload which contains Samsung TV IDE.

Start the application and select a workspace to store your tizen application .

After this ,Create a new Tizen Web Project by selecting File->New->TIzen Web Project.

From the Templates for TV-1.0 ,select Tizen Web UI Framework  Template for  Master Detail Application /Multi Page Application/Navigation Application / Single Page Application based upon your requirement and give a name to the project.

A Project with mentioned name will get created in the IDE. It will contain the folders as shown in the image.

Now you can develop your Tizen application by making changes in the files of project and adding other files.

To Run the Tizen application, Build the package of the project .You can build the project by right clicking on the name of project in the project explorer and selecting the option of “build package”.

After the completion of build, a “projectname.wgt” file will get created .

To test run on system, you can select Run as-> TV Web Simulator (right click on project name)

To Run on TV, copy the .wgt file in USB drive in directory named userwidget.Plug in the USB drive in Tizen TV .TV will install the application .Go to Smart Hub-> My Apps and run the installed application.

#Prerequisites

For accessing the functionalities offered by Smart View you need to include the MSF library in your HTML if you are developing a Web Application.

	<script language="javascript" type="text/javascript" src="./lib/msf-2.0.14.min.js"></script>
 

Msf-2.0.14.min.js should be added in the project (like in directory named lib of project) so that it can be accessed by the application for implementation of MSF functionalities.

#Check for MSF Support

Check whether MSF Service is available or not, if available then proceed further. You can simply check for MSF service by accessing window object as below :

 
	if (window.msf) {
	     // your code here
	} 
 

#Get MSF service object

If msf service is supported, then you need to get the MSF service object. This is done by getting reference of the service object using method called local. local methods callback provides reference to the msf service currently running on the device ( this method is generally called on Host, in this case Samsung Smart Television ). as demonstrated below

 
	_msf.local(function( err, service) {
	     // your code here
	}
 

#Channel Creation

Once you get the msf service, you need to create a channel which will be used for communication between different devices and Samsung Television. Inside the local method callback, use the serviceobject to create the channel. Channel is created using the following syntax :



	var channel = service.channel("com.samsung.multiscreen.chatApp");

#Register Callbacks

Once channel is created you can use the channel object to register callbacks that are needed to handle various events triggered on the channel. The callbacks are registered as shown below :

 
	hostChannel.on(CHANNEL_CONNECT, handleConnectEvent.bind(instance));
	hostChannel.on(CHANNEL_DISCONNECT, handleDisconnectEvent.bind(instance));
	hostChannel.on(CHANNEL_CLIENT_CONNECT, handleClientConnectEvent.bind(instance));
	hostChannel.on(CHANNEL_CLIENT_DISCONNECT, handleClientDisconnectEvent.bind(instance));
	hostChannel.on(CHANNEL_MESSAGE, handleMessageEvent.bind(instance));
	hostChannel.on(CHANNEL_ERROR, handleErrorEvent.bind(instance));

	//host channel stores the reference of the channel created for the application

#Handling Communication

The communication is managed by handling the publish callback using the “say” event which is mapped to handleMessageEvent in the given application.

You can use publish method of host to send message to any client connected on the channel as below :

	hostChannel.publish('say', <messasge to be send>, <id of the client receiving the message>);

There are different callbacks that you can handle for handling the different kinds of event like:


 
	function handleClientConnectEvent(client) {
	           // this is the handler mapped against the client connect event
	}
	
	function handleClientDisconnectEvent(client) {
	         // this is the handler mapped against the client disconnect event
	 }
 


 
