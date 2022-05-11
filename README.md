# Calendar Demo App
Project for familiarization with Flutter and Dart

# Requirements 
## Home Page:
Not much needed on first page
Able to open side menu from left (swiping and/or hamburger menu button to open it up)
Button in side menu to open Calendar Page (using navigator push)

## Calendar overview page:
https://pub.dev/packages/table_calendar you may use others
Able to see calendar overview in this page
Can create new event via plus button at bottom right

## Event creation page:
For the start date field it should be set to whatever date was selected in previous page (still changable), meaning you need to pass that info to this page during navigator push
Standard stuff like event title, whole day vs start/end time, multiple days selection should be in. Refer to the calendar package to see what's already available.
After adding event, it should be visible on calendar immediately

You can use sharedpreferences or Hive (https://pub.dev/packages/hive) to save app data
Add any bells and whistles as you see fit