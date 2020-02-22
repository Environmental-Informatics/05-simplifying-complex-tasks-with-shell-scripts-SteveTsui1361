#!/bin/bash
#This script is used to process a bunch of location data and plot the rearranged data for different file types
#xu1361 2/20/2020

# Part1: Identify and separate out "high elevation stations" from the rest
# Extract needed files path
for file in StationData
do
  files=`grep -RL '# Station Altitude: [>=200]'| grep 'txt$'`
done

# Check whether the higherelvation directory exit
if [ -d HigherElevation ]
then
    echo 'HigherElevation directory already exits'
else
    mkdir HigherElevation
fi

# Copy needed files into new directory
for text in $files
do
  cp $text HigherElevation
done

# Part2:Plot the location of all stations, while highlighting the higher elevation stations
# Extract xy value from all stations
awk '/Longitude/ {print -1 * $NF}' StationData/Station_*.txt > Long.list
awk '/Latitude/ {print $NF}' StationData/Station_*.txt > Lat.list
paste Long.list Lat.list > AllStation.xy

# Extract xy value from higherelevation stations
awk '/Longitude/ {print -1 * $NF}' HigherElevation/Station_*.txt > Long.list
awk '/Latitude/ {print $NF}' HigherElevation/Station_*.txt > Lat.list
paste Long.list Lat.list > HEStation.xy

# Load gmt module
module load gmt

# Generate a plot
gmt pscoast  -JU16/4i -R-93/-86/36/43 -B2f0.5 -Cl/blue -Dh -Ia/blue -Na/orange -P -K -V > SoilMoistureStations.ps
gmt psxy AllStation.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps  
gmt psxy HEStation.xy -J -R -Sc0.05 -Gred -O -V >> SoilMoistureStations.ps

#Part3: Convert the figure into their image format
# Convert to epsi file 
ps2epsi SoilMoistureStations.ps SoilMoistureStations.epsi

# Convert to tif format
convert SoilMoistureStations.epsi -density 150 SoilMoistureStations.tif
