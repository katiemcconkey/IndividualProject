# EyeSpy 2.0 : A location-based mobile game

**What is EyeSpy 2.0?**\
EyeSpy 2.0 is an outdoor mobile game that involves playing against other users. 

The game works by users exploring the city and uploading images or text tags of geographic locations, when an item is uploaded a scan of all nearby wifi networks is completed and stored. 

Other users are then able to explore their area to find the place these images and text tags were uploaded in an attempt to confirm them. In order to confirm an image or text tag, another scan of nearby wifi is completed and depending on the size of the original scan there is a specified amount of overlap needed in order to confirm the images.

As EyeSpy 2.0 is a game with a purpose the result of this game is a data set of images and text tags which could be used in the future to aid navigation 

**File Structure**\
All of the main code is found within mobile_game/lib. Within this folder their are two sub folders, [databse](mobile_game/lib/database/) and [screens](mobile_game/lib/screens/). 

The folder database contains all code for the backend of the app. This folder is split into 4 files, 3 of these are for each property of the database and the last is for methods to upload the data.

The folder screens contains all the code for the front end of the app. Every screen seen in the application is developed in this section.

**Build Instructions**\
**An Android device is required to build and run this code**\
**A laptop with atleast Flutter 2.9.0-0.1**\
Instructions to build code: 
* You first must download the zip file from github 
* Then unzip the file
* Open the code in Visual Studio
* Using the terminal move into the mobile_game directory \
Before building the code you must connect to a device
* To do this you must connect your device to your Android through a USB
* You then must navigate through your settings to developer options and turn on USB debugging
* Once the device is connect un the command **flutter run** in the terminal, the code will build and the app will start up 
  
Instructions to run code : \
For more in depth instructions on how to run this code visit [manual.md](manual.md)

**Test Steps** \
From the mobile_game directory run the command **Flutter doctor -v**. This checks for any problems with everything that has been downloaded. \
To Test my code, you just have to run it using the instructions found in [manual.md](manual.md)
