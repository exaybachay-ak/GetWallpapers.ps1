#set up a storage location to put your images
if (Test-Path C:\tmp\img){
	$null
}

else{
	New-Item -ItemType Directory -Force -Path C:\tmp\img
}

$storagepath = "C:\tmp\img\"

#configure logging
$getdate = Get-Date -format "yyyyMMMd"
$gethours = Get-Date -format "hhmm"
$logtime = "getWallpapers_$getdate" + "_" + "$gethours.log"
$pth = (pwd).path
$logfile = $pth + "\" + $logtime


#Changed URL to old.reddit.com because the new tiled layout only shows 5 wallpapers
$url = "https://old.reddit.com/r/wallpapers/top/?sort=top&t=week"
$data = (Invoke-WebRequest -URI $url -UseBasicParsing).content

#Set up a regex pattern and apply it to the data we received
[regex]$pattern = 'https://i\.(imgur|redd)\.(com|it)\/(.......|.............)\.(png|jpg|jpeg|gif)'
$images = $pattern.Matches($data)

#Create an array and put individual values into it
$imagearray = @()
foreach($im in $images){
	$imagearray += $im.value
}

#de-duplicate image array
$imagearray = $imagearray | select -uniq


#loop through the array and download images
for ($i=0; $i -lt $imagearray.length; $i++){
	
	#Grab extension for use layer in naming files
	[regex]$regex = '(\.png|\.gif|\.jpg|\.jpeg)'

	#check current URL for filetype    
	$filetype = $regex.Matches($imagearray[$i])

	#make a variable for the full path
	$imagestorage = $storagepath + $i + $filetype

	#download image to computer	
	Invoke-WebRequest $imagearray[$i] -OutFile $imagestorage

}

$wallpapers = gci C:\tmp\img
$random = get-random -Maximum 33
$randomwp = $wallpapers[$random].FullName


Function Set-WallPaper($Value){

    Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $value
    rundll32.exe user32.dll, UpdatePerUserSystemParameters ,1 ,True

}


Function DedupeImageDirectory(){
	###get existing file hashes
	$curhashes = gci $storagepath | %{ Get-Filehash($_.FullName) }

	###delete duplicates
    	$curhashes | sort-object Hash | % { 
        if($prevhash){
            if($prevhash.Hash -eq $_.Hash){
                write-output "Removing duplicate: $_.FullName" | out-file $logfile -Append;
                remove-item $_.Path;
            }
        }
        $prevhash = $_; 
    }
}


Set-WallPaper -value $randomwp


DedupeImageDirectory
