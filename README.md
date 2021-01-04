# getMythProgram.sh
command line script/utility to pull mythtv guide data through mythtv services API
eg I pull: program/channel starttime/endtime
calculates duration from start/end. 
Matches only current block and crawls back only 30minutes (for now) looking for matches.

*I created this for use with another project that itself is currently in development. Expect changes.

*tested only against mythtv 29.X servers, but should work with newer. 

**DEPENDS on a recent bash and the xmlstarlet program.

***SCRIPT IS INTENTIONALLY VERBOSE RIGHT NOW UNTIL NEAR COMPLETION
***NOTE THIS IS *NOT* PRODUCTION READY. FIRST RELEASE IN TESTING and ONLY COVERS A NARROW TIMESLOT RIGHT NOW.

TODO: add another parameter for tunerX or use auto by default


#eg use:

```
./getMythProgram.sh $HOSTNAME/IP $MYTHTV-CHANNEL
```

on my system , eg
```
sh getMythProgram.sh pbskids-tv.localdomain 1091
```

or 

```
./getMythProgram.sh 192.168.1.218 1163
     
Local Time FNOW:                              2021-01-04T02:38:57
UTC Time FNOWUTC:                             2021-01-04T10:38:57
TRIMMED TO HOUR-UTC Time FNOWUTCH:            2021-01-04T10:
TRIMMED TO HOUR-UTC Time FNOWUTCHMM:          2021-01-04T10:38
TMSS:					      30:00
ZMSS:					      00:00
FNOW3TMSS:		      		      2021-01-04T10:30:00
FNOW3ZMSS: 	      			      2021-01-04T10:00:00
HNOWNEW0:   			              2021-01-04T10:00:00
HNOWNEW:   			              2021-01-04T10:30:00
COUTURL0STARTTIME:                            2021-01-04T10:00:00
COUTURL0ENDTIME:                              2021-01-04T12:00:00
COUTURLSTARTTIME:                             
COUTURLENDTIME:                               
URL0:  		                              http://192.168.1.218:6544/Guide/GetProgramDetails?StartTime=2021-01-04T10:00:00&Chanid=1163
URL:  				              http://192.168.1.218:6544/Guide/GetProgramDetails?StartTime=2021-01-04T10:30:00&Chanid=1163
STARTTIMES TIMES NOT MATCHED@                 2021-01-04T10:30:00
TRYING EARLIER STARTTIME                      2021-01-04T10:00:00
PROGRAM:				      Warning From Space
PROGRAM_STARTTIME:		              2021-01-04T10:00:00Z
PROGRAM_ENDTIME:			      2021-01-04T12:00:00Z
PROGRAM_DURATION:			      120 minutes
     
```

### Script Contents.
### Note: at last update only looks backward 30 minutes, will add more soon.

```
#!/bin/bash
FNOW=$(date  +%FT%T)
echo "     "
echo "Local Time FNOW:                              $FNOW"

FNOWUTC=$(date --utc +%FT%T)
echo "UTC Time FNOWUTC:                             $FNOWUTC"

FNOWUTCH=$(echo $FNOWUTC|cut -c1-14)
echo "TRIMMED TO HOUR-UTC Time FNOWUTCH:            $FNOWUTCH"

FNOWUTCHMM=$(echo $FNOWUTC|cut -c1-16)
echo "TRIMMED TO HOUR-UTC Time FNOWUTCHMM:          $FNOWUTCHMM"

TMSS=30:00
echo "TMSS:					      $TMSS"

ZMSS=00:00
echo "ZMSS:					      $ZMSS"

FNOW3TMSS=$(echo $FNOWUTCH$TMSS)
echo "FNOW3TMSS:		      		      $FNOW3TMSS"

FNOW3ZMSS=$(echo $FNOWUTCH$ZMSS)
echo "FNOW3ZMSS: 	      			      $FNOW3ZMSS"


#starts initial starttime based on current time on hour FNOW3ZMSS or FNOW3TMSS format
# sets up vars for 30 minutes ago for two scenarios
if [ `echo $FNOWUTCHMM|cut -d: -f2` -lt 30 ];
        then
            HNOWNEW=$(echo $FNOW3ZMSS)
            HNOWNEW0=$(date -d "$(echo $HNOWNEW) 30min ago" +"%FT%T")
        else
            HNOWNEW=$(echo $FNOW3TMSS)
            HNOWNEW0=$(date -d "$(echo $HNOWNEW) 30min ago" +"%FT%T")

fi

#30 minutes earlier than HNOWNEW
echo "HNOWNEW0:   			              $HNOWNEW0"

echo "HNOWNEW:   			              $HNOWNEW"


#this gives both the 30minute(URL) and 60(URL0) minute start time lookups 
URL0="http://$1:6544/Guide/GetProgramDetails?StartTime=$HNOWNEW0&Chanid=$2"
URL="http://$1:6544/Guide/GetProgramDetails?StartTime=$HNOWNEW&Chanid=$2"


XMLSTARLET_ALL="/usr/bin/xmlstarlet sel -t -v //Title -nl -v //StartTime -nl -v //EndTime -nl -nl"
XMLSTARLET_TITLE="/usr/bin/xmlstarlet sel -t -v //Title -nl"
#XMLSTARLET_SUBTITLE="/usr/bin/xmlstarlet sel -t -v //SubTitle -nl"
#XMLSTARLET_ORIGINALAIRDATE="/usr/bin/xmlstarlet sel -t -v //OriginalAirdate -nl"
XMLSTARLET_STARTTIME="/usr/bin/xmlstarlet sel -t -v //StartTime -nl"
XMLSTARLET_ENDTIME="/usr/bin/xmlstarlet sel -t -v //EndTime -nl"


OUTURL0TITLE=$(curl -s $URL0|$XMLSTARLET_TITLE)
#OUTURL0SUBTITLE=$(curl -s $URL0|$XMLSTARLET_SUBTITLE)
#OUTURL0ORIGINALAIRDATE=$(curl -s $URL0|$XMLSTARLET_ORIGINALAIRDATE)
OUTURL0STARTTIME=$(curl -s $URL0|$XMLSTARLET_STARTTIME)
OUTURL0ENDTIME=$(curl -s $URL0|$XMLSTARLET_ENDTIME)
OUTURL0_ALL=$(curl -s $URL0|$XMLSTARLET_ALL)


OUTURLTITLE=$(curl -s $URL|$XMLSTARLET_TITLE)
#OUTURLSUBTITLE=$(curl -s $URL|$XMLSTARLET_SUBTITLE)
#OUTURLORIGINALAIRDATE=$(curl -s $URL|$XMLSTARLET_ORIGINALAIRDATE)
OUTURLSTARTTIME=$(curl -s $URL|$XMLSTARLET_STARTTIME)
OUTURLENDTIME=$(curl -s $URL|$XMLSTARLET_ENDTIME)
OUTURL_ALL=$(curl -s $URL|$XMLSTARLET_ALL)


COUTURL0STARTTIME=$(echo $OUTURL0STARTTIME|cut -c1-19)
echo "COUTURL0STARTTIME:                            $COUTURL0STARTTIME"
COUTURL0ENDTIME=$(echo $OUTURL0ENDTIME|cut -c1-19)
echo "COUTURL0ENDTIME:                              $COUTURL0ENDTIME"


COUTURLSTARTTIME=$(echo $OUTURLSTARTTIME|cut -c1-19)
echo "COUTURLSTARTTIME:                             $COUTURLSTARTTIME"
COUTURLENDTIME=$(echo $OUTURLENDTIME|cut -c1-19)
echo "COUTURLENDTIME:                               $COUTURLENDTIME"

echo "URL0:  		                              $URL0"
echo "URL:  				              $URL"

#calculate duration EndTime-StartTime=Duraton
EPOCOUTURL0STARTTIME=$(date -d "$(echo $OUTURL0STARTTIME)" +"%s")
EPOCOUTURL0ENDTIME=$(date -d "$(echo $OUTURL0ENDTIME)" +"%s")

EPOCOUTURLSTARTTIME=$(date -d "$(echo $OUTURLSTARTTIME)" +"%s")
EPOCOUTURLENDTIME=$(date -d "$(echo $OUTURLENDTIME)" +"%s")

# & [ "$COUTURLENDTIME" != "$HNOWNEW" ]; then

if [ "$COUTURLSTARTTIME" != "$HNOWNEW" ] ;then
	echo "STARTTIMES TIMES NOT MATCHED@                 $HNOWNEW"
	echo "TRYING EARLIER STARTTIME                      $HNOWNEW0"
	if [ "$COUTURL0STARTTIME" != "$HNOWNEW0" ]; then
		echo "STARTTIMES TIMES NOT MATCHED@                 $HNOWNEW or $HNOWNEW0"
		exit 1
	else
		echo "PROGRAM:				      $OUTURL0TITLE"
		echo "PROGRAM_STARTTIME:		              $OUTURL0STARTTIME"
		echo "PROGRAM_ENDTIME:			      $OUTURL0ENDTIME"
		#echo "EPOC OUTURLENDTIME is:     $EPOCOUTURLENDTIME"
		#echo "EPOC OUTURLSTARTTIME is:   $EPOCOUTURLSTARTTIME"
		let  "EPOCSECONDSURL0 = $EPOCOUTURL0ENDTIME - $EPOCOUTURL0STARTTIME "
		#echo "EPOCSECONDSURL0 = $EPOCSECONDSURL0"
		let  "DURATIONURL0 = $EPOCSECONDSURL0/60"
		echo "PROGRAM_DURATION:			      $DURATIONURL0 minutes"
	fi	
else	
	echo "PROGRAM:				      $OUTURLTITLE"
	echo "PROGRAM_STARTTIME:		              $OUTURLSTARTTIME"
	echo "PROGRAM_ENDTIME:			      $OUTURLENDTIME"
	#echo "EPOC OUTURLENDTIME is:     $EPOCOUTURLENDTIME"
	#echo "EPOC OUTURLSTARTTIME is:   $EPOCOUTURLSTARTTIME"
	let  "EPOCSECONDSURL = $EPOCOUTURLENDTIME - $EPOCOUTURLSTARTTIME "
	#echo "EPOCSECONDSURL = $EPOCSECONDSURL"
	let  "DURATIONURL = $EPOCSECONDSURL/60"
	echo "PROGRAM_DURATION:			      $DURATIONURL minutes"

fi
```
