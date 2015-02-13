# tempmon
Temperature monitoring on Raspberry PI

## Requirements
* rrdtools
* Wiring library
    * http://wiringpi.com/download-and-install/

## Build

$ cd src
$ make

## Usage

In order to plot graphical curves and store data in the rrdtool database, the script must be called every 5 minutes.
To do so, a call to the script can be added in crontab (using crontab -e):

*/5 * * * * /script_dir/gettemp.sh >> /tmp/gettemp.log

## More informations

http://clement-leger.fr/doku.php?id=en:temp_hw
