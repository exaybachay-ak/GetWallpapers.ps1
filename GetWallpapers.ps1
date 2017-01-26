#download raw reddit webpage for parsing
$url = "https://www.reddit.com/r/wallpapers/top/?sort=top&t=week"
$content = (Invoke-WebRequest -URI $url -UseBasicParsing -TimeoutSec 60).Content

#search for image URLs and place in an array
$wppattern = [regex]::Matches($content,'(?im)data-url="(http|https)://([^.]*\.[^.]*|[^.]*\.[^.]*\.[^.]*)/[^.]*\.(jpg|gif|png|bmp)') | select value

#sort the array to remove duplicates
$wppattern | select -uniq

#set up a storage location to put your images
$pathexists = Test-Path /tmp/img/
if ($pathexists -eq "Trus"){
	$storagepath = "/tmp/img/"
}
else{
	New-Item -ItemType Directory -Force -Path /tmp/img
	$storagepath = "/tmp/img/"
}

#loop through the array and download images
for ($i=0; $i -le $wppattern.length; $i++){
	#clean up array entries
	$image = $wppattern[$i]
	$image = $image -replace '@{Value=data-url="', ""
	$image = $image -replace '}', ""

	#check current URL for filetype
	$filetype = [regex]::Matches($image,'\....$')
	$imagestorage = $storagepath + $i + $filetype

	#download image to computer
	Invoke-WebRequest $image -OutFile $imagestorage
}
