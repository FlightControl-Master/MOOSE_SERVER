# MOOSE SERVER STATISTICS project
MOOSE Server Statistics project for DCS World servers beyond DCS 1.5 and DCS 2.0

HubJack: The MOOSE Server Statistics code is WIP and is not useful at the moment. Work is done on the code every day but running tests and debugging on private server. Master will be updated as soon as a new tested version is running stable on the private server. So for now please comment and contribute but be careful if you plan to use the master build.

The project aims to create a statistics central for flight logging based on each pilot’s flight time. The statistics will be collected for multiple server instances and can be used by all DCS World servers. By registering your server with MOOSE we will provide all the code to bring all your statistics over to the central server and implement it in the main statistics log. Statistics will by standard be focused on teamwork rather than individual performance but as a registered member of the MOOSE Server Statistics providers you can request PHP pages that individually view scores for your server. The MOOSE Server Statistics project will provide all code to locally create the needed .csv files so you can build your own webserver if you like. The webpage and MySQL setup is highly individual and will not be provided in the GitHub MOOSE Server project. If your team plan on setting up your own DCS World statistics page based on APACHE, MySQL(MariaDB), PHP and FTP we may give information on how to get started. Please contact us at Slack MOOSE.

MOOSE Server now writes logs to it's own directory for easy pickup and move to webserver. The directory is in the servers "Saved Games/DCS" folder and named "MooseLogs". The directory regreates itself when needed so you can rename it before moving. Please remember that DCS World must be stopped to rename the folder.

MOOSE SERVER DONE: Export of Mission data, player data and event data. Finished reading local server info.
Works in current version. 

MOOSE SERVER WIP: Error logging (if needed), programming past DCS bugs, looking for solution to get player
takeoff and landing information. May need to get the chat to go around DCS bugs on this one. 
Need to implement version number on the file heading.


WEBSITE WIP: adjusting info export to .csv files, preparing file transport to webserver, testing MySQL server import, building MySQL views, creating simple stats webpage in PHP. 


MOOSE SERVER FUTURE DEVELOPMENT priority list:

1. Collect MOOSE mission statistics file (.csv) that will enable kill and weapons usage together with optional scoring details.

2. Link public server play to the shared tacview file of each recorded round.

3. Personal player accounts on the MOOSE central statistics server to keep recordings of your local single player flights.

4. Make personal account admin for player to select which flights should be public statistics or private (test flights etc.).

5. To be decided...



Regards, HubJack

(this project is also a learning project for me to use GitHub's features. Thank you flightControl)
