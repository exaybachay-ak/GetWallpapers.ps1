#set up a storage location to put your images
if (Test-Path C:\tmp\img){
	
	$storagepath = "C:\tmp\img\"

}

else{
	
	New-Item -ItemType Directory -Force -Path C:\tmp\img

}

$storagepath = "C:\tmp\img\"

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

####---->  http://theadminguy.com/2009/04/30/portscan-with-powershell/
function fastping{
  [CmdletBinding()]
  param(
  [String]$computername = $scanIp,
  [int]$delay = 100
  )

  $ping = new-object System.Net.NetworkInformation.Ping  # see http://msdn.microsoft.com/en-us/library/system.net.networkinformation.ipstatus%28v=vs.110%29.aspx
  try {
    if ($ping.send($computername,$delay).status -ne "Success") {
      return $false;
    }
    else {
      return $true;
    }
  } catch {
    return $false;
  }
}

#Check Internet connectivity before downloading images
$connectivity = fastping 8.8.8.8

if($connectivity -eq "True"){

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
}

#Prepare variables for setting wallpaper
$wallpapers = gci C:\tmp\img
$random = get-random -Maximum $wallpapers.Length
$randomwp = $wallpapers[$random].FullName
if (test-path .\randomwpvar.txt){
	$randomwpvar = get-content .\randomwpvar.txt
}

Function Set-WallPaper($Value){

    Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $value
    rundll32.exe user32.dll, UpdatePerUserSystemParameters ,1 ,True

}

if($random -eq $randomwpvar){
	while($random -eq $randomwpvar){
		$random = get-random -Maximum 23
		$randomwp = $wallpapers[$random].FullName
	}
}

Set-WallPaper -value $randomwp

$random | out-file -filepath .\randomwpvar.txt
