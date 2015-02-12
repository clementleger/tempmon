#!/bin/bash
DIR="/var/www/temp"

echo "Acquiring temperature"

temp=$(cat /sys/bus/w1/devices/28-000004269728/w1_slave | tr '\n' ' ' | cut -d "=" -f 3)
temp_dec=${temp:0:2}.${temp:2:3}

echo "Acquiring humidity"
humid=$(${DIR}/humid)
if [ $? != 0 ]; then
	echo "Failed to get humidity"
	humid=$(cat $DIR/last_humidity)
fi

echo $temp_dec > $DIR/last_temp
echo $humid > $DIR/last_humidity

if [ ! -f ${DIR}/hometemp.rrd ]; then
	echo "Creating ${DIR}/hometemp.rrd"
	rrdtool create ${DIR}/hometemp.rrd --start N --step 300 \
	DS:temp:GAUGE:600:-20:50 \
	DS:hum:GAUGE:600:0:100 \
	RRA:AVERAGE:0.5:1:12 \
	RRA:AVERAGE:0.5:1:288 \
	RRA:AVERAGE:0.5:12:168 \
	RRA:AVERAGE:0.5:12:720 \
	RRA:AVERAGE:0.5:288:365
fi

echo "Updating rrdb hometemp.rrd with temp $temp_dec and humidity $humid"

CMD="rrdtool update ${DIR}/hometemp.rrd N:$temp_dec:$humid"
echo "$CMD"
$CMD

#set to C if using Celsius
TEMP_SCALE="C"

#define the desired colors for the graphs
INTEMP_COLOR="#CC0000"
HUMID_COLOR="#0000FF"

echo "Drawing graphs"
#hourly
rrdtool graph $DIR/temp_hourly.png --start -4h \
DEF:temp=$DIR/hometemp.rrd:temp:AVERAGE \
LINE:temp$INTEMP_COLOR:"Inside Temperature [deg $TEMP_SCALE] Hourly"

rrdtool graph $DIR/humid_hourly.png --start -4h \
DEF:hum=$DIR/hometemp.rrd:hum:AVERAGE \
LINE:hum$HUMID_COLOR:"Relative Humidity [percent] Hourly"


#daily
rrdtool graph $DIR/temp_daily.png --start -1d \
DEF:temp=$DIR/hometemp.rrd:temp:AVERAGE \
LINE:temp$INTEMP_COLOR:"Inside Temperature [deg $TEMP_SCALE] Daily"

rrdtool graph $DIR/humid_daily.png --start -1d \
DEF:hum=$DIR/hometemp.rrd:hum:AVERAGE \
LINE:hum$HUMID_COLOR:"Relative Humidity [percent] Daily"


#weekly
rrdtool graph $DIR/temp_weekly.png --start -1w \
DEF:temp=$DIR/hometemp.rrd:temp:AVERAGE \
LINE:temp$INTEMP_COLOR:"Inside Temperature [deg $TEMP_SCALE] Weekly"

rrdtool graph $DIR/humid_weekly.png --start -1w \
DEF:hum=$DIR/hometemp.rrd:hum:AVERAGE \
LINE:hum$HUMID_COLOR:"Relative Humidity [percent] Weekly"

#monthly
#rrdtool graph $DIR/temp_monthly.png --start -1m \
#DEF:temp=$DIR/hometemp.rrd:temp:AVERAGE \
#LINE:temp$INTEMP_COLOR:"Inside Temperature [deg $TEMP_SCALE]"

#yearly
#rrdtool graph $DIR/temp_yearly.png --start -1y \
#DEF:temp=$DIR/hometemp.rrd:temp:AVERAGE \
#LINE:temp$INTEMP_COLOR:"Inside Temperature [deg $TEMP_SCALE]"
