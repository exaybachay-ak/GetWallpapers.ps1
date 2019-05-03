# GetWallpapers.ps1
Download the best new wallpapers from Reddit with PowerShell

# Instructions
1. Download GetWallpapers.zip and extract it
2. Open Task Scheduler (taskschd.msc)
3. Click Action -> Import Task
4. Locate extracted task template file and import it
5. Update task to use your local user instead of SYSTEM (this is required to enable network functionality)

That should be it.  Now you will have getWallpapers.ps1 run every time you log in, and it will get new wallpapers every 15 minutes unless you change the start-sleep timer from 900 (15 minutes) to whatever you would rather have.
