# RecruiterHub

Authors
1. Ryan Helgeson
2. Ivy Zhang 
3. Tiffany Iong
4. MQ Malandvula

## Summary

The RecruiterHub App is designed to provide a platform for high school baseball players to post videos to be recruited to play college baseball. 
The app has in-app messaging in addition so that users can text on the app. Users will have the ability to search other users by name, as well as
view a general feed of videos that have been uploaded by users. Other minor features are, profile editing and commenting on videos.

## Special Instructions

For our app it is required that you have a Mac of some sort to be able to install XCode. This can be done by creating a Mac Virtual Machine using 
Virtual Box or another application of your choosing. Once you create the Mac Virtual Machine install XCode and clone the Github Repository. Open up the 
RecruiterHub.workspace file and XCode will open. Select the RecruiterHub scheme and the simulator you wish to run on. To add images/videos to the simulator, 
click and drag them on to the simulator and they will save automatically. Once the simulator is up and the app is installed, open the app, register,
and take a look.

## Project Organization

All source files can be located in this repository. The RecruiterHubTests folder includes a database testing file that unit tests reads from the database.

## Program Operation 

You will want to ensure that there is a stable internet connection so that you can retrieve/send data to the Firebase cloud storage. Contact Ryan Helgeson 
(helg9374@stthomas.edu) if there are any issues getting started following the special instructions to get going on build.

## Running Unit Tests 

Click into the DatabaseTests.swift file in the RecruiterHubTests folder of the workspace. To run all tests, go to where the class is defined in Line 11 of 
the code. Instead of saying 11 there should be a diamond, click the diamond and all tests will run. You can run each individual test by pressing the diamond
that appears next to each test function. It may take some time to run because it needs to create a simulator. 
