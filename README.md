# getMythProgram.sh
command line script/utility to pull mythtv guide data through mythtv services API
eg I pull: program/channel starttime/endtime

calculates duration from start/end. 
It will go back up to two hours to find a matching program to display.

*I created this for use with another project that itself is currently in development. Expect changes.
	*tested only against mythtv 29.X servers, but should work with newer. 
  		**DEPENDS on a recent bash and the xmlstarlet program.

***SCRIPT IS INTENTIONALLY VERBOSE RIGHT NOW UNTIL NEAR COMPLETION
***NOTE THIS IS *NOT* PRODUCTION READY. FIRST RELEASE IN TESTING and ONLY COVERS A NARROW TIMESLOT RIGHT NOW.

#eg use:

```
./getMythProgram.sh $HOSTNAME/IP $MYTHTV-CHANNEL
```

on my system , eg
```
./getMythProgram.sh rpi4-vc4xdev 1163
```

or by its ip, with example output with full verbosity

```
./getMythProgram.sh 192.168.1.218 1163
     
Local Time FNOW:                              2021-01-04T04:02:33
UTC Time FNOWUTC:                             2021-01-04T12:02:33
TRIMMED TO HOUR-UTC Time FNOWUTCH:            2021-01-04T12:
TRIMMED TO HOUR-UTC Time FNOWUTCHMM:          2021-01-04T12:02
TMSS:					      30:00
ZMSS:					      00:00
FNOW3TMSS:		      		      2021-01-04T12:30:00
FNOW3ZMSS: 	      			      2021-01-04T12:00:00
HNOWNEW120:   			              2021-01-04T10:00:00
HNOWNEW90:   			              2021-01-04T10:30:00
HNOWNEW60:   			              2021-01-04T11:00:00
HNOWNEW30:   			              2021-01-04T11:30:00
HNOWNEW:   			              2021-01-04T12:00:00
COUTURL120STARTTIME:                          2021-01-04T10:00:00
COUTURL120ENDTIME:                            2021-01-04T12:00:00
COUTURL90STARTTIME:                           
COUTURL90ENDTIME:                             
COUTURL60STARTTIME:                           
COUTURL60ENDTIME:                             
COUTURL30STARTTIME:                           
COUTURL30ENDTIME:                             
COUTURLSTARTTIME:                             2021-01-04T12:00:00
COUTURLENDTIME:                               2021-01-04T12:30:00
URL120:  		                      http://192.168.1.218:6544/Guide/GetProgramDetails?StartTime=2021-01-04T10:00:00&Chanid=1163
URL90:  		                      http://192.168.1.218:6544/Guide/GetProgramDetails?StartTime=2021-01-04T10:30:00&Chanid=1163
URL60:  		                      http://192.168.1.218:6544/Guide/GetProgramDetails?StartTime=2021-01-04T11:00:00&Chanid=1163
URL30:  		                      http://192.168.1.218:6544/Guide/GetProgramDetails?StartTime=2021-01-04T11:30:00&Chanid=1163
URL:  				              http://192.168.1.218:6544/Guide/GetProgramDetails?StartTime=2021-01-04T12:00:00&Chanid=1163
PROGRAM:				      The Key To Healthy Living
PROGRAM_STARTTIME:		              2021-01-04T12:00:00Z
PROGRAM_ENDTIME:			      2021-01-04T12:30:00Z
PROGRAM_DURATION:			      30 minutes
```

or by its ip, with example output standard output format
# This mythtv server uses ONLY EIT data from OTA and antenna

```

/getMythProgram.sh 192.168.1.218 1163
     
Local Time FNOW:                              2021-01-04T04:35:02
UTC Time FNOWUTC:                             2021-01-04T12:35:02
PROGRAM:				      Paid Programming
PROGRAM_STARTTIME:		              2021-01-04T12:30:00Z
PROGRAM_ENDTIME:			      2021-01-04T13:00:00Z
PROGRAM_DURATION:			      30 minutes


```

# This mythtv server uses schedules direct data

```
./getMythProgram.sh 192.168.1.162 1163
     
Local Time FNOW:                              2021-01-04T04:35:22
UTC Time FNOWUTC:                             2021-01-04T12:35:22
PROGRAM:				      Paid Programming
PROGRAM_STARTTIME:		              2021-01-04T12:30:00Z
PROGRAM_ENDTIME:			      2021-01-04T13:00:00Z
PROGRAM_DURATION:			      30 minutes
```







Test against different mythtv server diff channel
```
./getMythProgram.sh 192.168.1.162 1283
     
Local Time FNOW:                              2021-01-04T04:31:30
UTC Time FNOWUTC:                             2021-01-04T12:31:30
PROGRAM:				      Molly of Denali
PROGRAM_STARTTIME:		              2021-01-04T12:30:00Z
PROGRAM_ENDTIME:			      2021-01-04T13:00:00Z
PROGRAM_DURATION:			      30 minutes
```






# Script Contents:
```
#!/bin/bash
FNOW=$(date  +%FT%T)
echo "     "
echo "Local Time FNOW:                              $FNOW"

FNOWUTC=$(date --utc +%FT%T)
echo "UTC Time FNOWUTC:                             $FNOWUTC"

FNOWUTCH=$(echo $FNOWUTC|cut -c1-14)
#echo "TRIMMED TO HOUR-UTC Time FNOWUTCH:            $FNOWUTCH"

FNOWUTCHMM=$(echo $FNOWUTC|cut -c1-16)
#echo "TRIMMED TO HOUR-UTC Time FNOWUTCHMM:          $FNOWUTCHMM"

TMSS=30:00
#echo "TMSS:					      $TMSS"

ZMSS=00:00
#echo "ZMSS:					      $ZMSS"

FNOW3TMSS=$(echo $FNOWUTCH$TMSS)
#echo "FNOW3TMSS:		      		      $FNOW3TMSS"

FNOW3ZMSS=$(echo $FNOWUTCH$ZMSS)
#echo "FNOW3ZMSS: 	      			      $FNOW3ZMSS"


#starts initial starttime based on current time on hour FNOW3ZMSS or FNOW3TMSS format
if [ `echo $FNOWUTCHMM|cut -d: -f2` -lt 30 ];
        then
            HNOWNEW=$(echo $FNOW3ZMSS)
            HNOWNEW30=$(date -d "$(echo $HNOWNEW) 30min ago" +"%FT%T")
            HNOWNEW60=$(date -d "$(echo $HNOWNEW) 60min ago" +"%FT%T")
            HNOWNEW90=$(date -d "$(echo $HNOWNEW) 90min ago" +"%FT%T")
            HNOWNEW120=$(date -d "$(echo $HNOWNEW) 120min ago" +"%FT%T")
        else
            HNOWNEW=$(echo $FNOW3TMSS)
            HNOWNEW30=$(date -d "$(echo $HNOWNEW) 30min ago" +"%FT%T")
            HNOWNEW60=$(date -d "$(echo $HNOWNEW) 60min ago" +"%FT%T")
            HNOWNEW90=$(date -d "$(echo $HNOWNEW) 90min ago" +"%FT%T")
            HNOWNEW120=$(date -d "$(echo $HNOWNEW) 120min ago" +"%FT%T")

fi



#echo "HNOWNEW120:   			              $HNOWNEW120"
#echo "HNOWNEW90:   			              $HNOWNEW90"
#echo "HNOWNEW60:   			              $HNOWNEW60"
#echo "HNOWNEW30:   			              $HNOWNEW30"
#echo "HNOWNEW:   			              $HNOWNEW"

URL120="http://$1:6544/Guide/GetProgramDetails?StartTime=$HNOWNEW120&Chanid=$2"
URL90="http://$1:6544/Guide/GetProgramDetails?StartTime=$HNOWNEW90&Chanid=$2"
URL60="http://$1:6544/Guide/GetProgramDetails?StartTime=$HNOWNEW60&Chanid=$2"
URL30="http://$1:6544/Guide/GetProgramDetails?StartTime=$HNOWNEW30&Chanid=$2"
URL="http://$1:6544/Guide/GetProgramDetails?StartTime=$HNOWNEW&Chanid=$2"

XMLSTARLET_ALL="/usr/bin/xmlstarlet sel -t -v //Title -nl -v //StartTime -nl -v //EndTime -nl -nl"
XMLSTARLET_TITLE="/usr/bin/xmlstarlet sel -t -v //Title -nl"
#XMLSTARLET_SUBTITLE="/usr/bin/xmlstarlet sel -t -v //SubTitle -nl"
#XMLSTARLET_ORIGINALAIRDATE="/usr/bin/xmlstarlet sel -t -v //OriginalAirdate -nl"
XMLSTARLET_STARTTIME="/usr/bin/xmlstarlet sel -t -v //StartTime -nl"
XMLSTARLET_ENDTIME="/usr/bin/xmlstarlet sel -t -v //EndTime -nl"

OUTURL120TITLE=$(curl -s $URL120|$XMLSTARLET_TITLE)
#OUTURL120SUBTITLE=$(curl -s $URL120|$XMLSTARLET_SUBTITLE)
#OUTURL120ORIGINALAIRDATE=$(curl -s $URL120|$XMLSTARLET_ORIGINALAIRDATE)
OUTURL120STARTTIME=$(curl -s $URL120|$XMLSTARLET_STARTTIME)
OUTURL120ENDTIME=$(curl -s $URL120|$XMLSTARLET_ENDTIME)
OUTURL120_ALL=$(curl -s $URL120|$XMLSTARLET_ALL)

OUTURL90TITLE=$(curl -s $URL90|$XMLSTARLET_TITLE)
#OUTURL90SUBTITLE=$(curl -s $URL90|$XMLSTARLET_SUBTITLE)
#OUTURL90ORIGINALAIRDATE=$(curl -s $URL90|$XMLSTARLET_ORIGINALAIRDATE)
OUTURL90STARTTIME=$(curl -s $URL90|$XMLSTARLET_STARTTIME)
OUTURL90ENDTIME=$(curl -s $URL90|$XMLSTARLET_ENDTIME)
OUTURL90_ALL=$(curl -s $URL90|$XMLSTARLET_ALL)


OUTURL60TITLE=$(curl -s $URL60|$XMLSTARLET_TITLE)
#OUTURL60SUBTITLE=$(curl -s $URL60|$XMLSTARLET_SUBTITLE)
#OUTURL60ORIGINALAIRDATE=$(curl -s $URL60|$XMLSTARLET_ORIGINALAIRDATE)
OUTURL60STARTTIME=$(curl -s $URL60|$XMLSTARLET_STARTTIME)
OUTURL60ENDTIME=$(curl -s $URL60|$XMLSTARLET_ENDTIME)
OUTURL60_ALL=$(curl -s $URL60|$XMLSTARLET_ALL)


OUTURL30TITLE=$(curl -s $URL30|$XMLSTARLET_TITLE)
#OUTURL30SUBTITLE=$(curl -s $URL30|$XMLSTARLET_SUBTITLE)
#OUTURL30ORIGINALAIRDATE=$(curl -s $URL30|$XMLSTARLET_ORIGINALAIRDATE)
OUTURL30STARTTIME=$(curl -s $URL30|$XMLSTARLET_STARTTIME)
OUTURL30ENDTIME=$(curl -s $URL30|$XMLSTARLET_ENDTIME)
OUTURL30_ALL=$(curl -s $URL30|$XMLSTARLET_ALL)


OUTURLTITLE=$(curl -s $URL|$XMLSTARLET_TITLE)
#OUTURLSUBTITLE=$(curl -s $URL|$XMLSTARLET_SUBTITLE)
#OUTURLORIGINALAIRDATE=$(curl -s $URL|$XMLSTARLET_ORIGINALAIRDATE)
OUTURLSTARTTIME=$(curl -s $URL|$XMLSTARLET_STARTTIME)
OUTURLENDTIME=$(curl -s $URL|$XMLSTARLET_ENDTIME)
OUTURL_ALL=$(curl -s $URL|$XMLSTARLET_ALL)

COUTURL120STARTTIME=$(echo $OUTURL120STARTTIME|cut -c1-19)
#echo "COUTURL120STARTTIME:                          $COUTURL120STARTTIME"
COUTURL120ENDTIME=$(echo $OUTURL120ENDTIME|cut -c1-19)
#echo "COUTURL120ENDTIME:                            $COUTURL120ENDTIME"

COUTURL90STARTTIME=$(echo $OUTURL90STARTTIME|cut -c1-19)
#echo "COUTURL90STARTTIME:                           $COUTURL90STARTTIME"
COUTURL90ENDTIME=$(echo $OUTURL90ENDTIME|cut -c1-19)
#echo "COUTURL90ENDTIME:                             $COUTURL90ENDTIME"

COUTURL60STARTTIME=$(echo $OUTURL60STARTTIME|cut -c1-19)
#echo "COUTURL60STARTTIME:                           $COUTURL60STARTTIME"
COUTURL60ENDTIME=$(echo $OUTURL60ENDTIME|cut -c1-19)
#echo "COUTURL60ENDTIME:                             $COUTURL60ENDTIME"

COUTURL30STARTTIME=$(echo $OUTURL30STARTTIME|cut -c1-19)
#echo "COUTURL30STARTTIME:                           $COUTURL30STARTTIME"
COUTURL30ENDTIME=$(echo $OUTURL30ENDTIME|cut -c1-19)
#echo "COUTURL30ENDTIME:                             $COUTURL30ENDTIME"

COUTURLSTARTTIME=$(echo $OUTURLSTARTTIME|cut -c1-19)
#echo "COUTURLSTARTTIME:                             $COUTURLSTARTTIME"
COUTURLENDTIME=$(echo $OUTURLENDTIME|cut -c1-19)
#echo "COUTURLENDTIME:                               $COUTURLENDTIME"

#echo "URL120:  		                      $URL120"
#echo "URL90:  		                      $URL90"
#echo "URL60:  		                      $URL60"
#echo "URL30:  		                      $URL30"
#echo "URL:  				              $URL"

#calculate duration EndTime-StartTime=Duraton

EPOCOUTURL120STARTTIME=$(date -d "$(echo $OUTURL120STARTTIME)" +"%s")
EPOCOUTURL120ENDTIME=$(date -d "$(echo $OUTURL120ENDTIME)" +"%s")

EPOCOUTURL90STARTTIME=$(date -d "$(echo $OUTURL90STARTTIME)" +"%s")
EPOCOUTURL90ENDTIME=$(date -d "$(echo $OUTURL90ENDTIME)" +"%s")

EPOCOUTURL60STARTTIME=$(date -d "$(echo $OUTURL60STARTTIME)" +"%s")
EPOCOUTURL60ENDTIME=$(date -d "$(echo $OUTURL60ENDTIME)" +"%s")

EPOCOUTURL30STARTTIME=$(date -d "$(echo $OUTURL30STARTTIME)" +"%s")
EPOCOUTURL30ENDTIME=$(date -d "$(echo $OUTURL30ENDTIME)" +"%s")

EPOCOUTURLSTARTTIME=$(date -d "$(echo $OUTURLSTARTTIME)" +"%s")
EPOCOUTURLENDTIME=$(date -d "$(echo $OUTURLENDTIME)" +"%s")

# & [ "$COUTURLENDTIME" != "$HNOWNEW" ]; then

if [ "$COUTURLSTARTTIME" != "$HNOWNEW" ] ;then
	echo "STARTTIMES TIMES NOT MATCHED@                 $HNOWNEW"
	echo "TRYING EARLIER STARTTIME                      $HNOWNEW30"
	if [ "$COUTURL30STARTTIME" != "$HNOWNEW30" ]; then
		echo "STARTTIMES TIMES NOT MATCHED@                 $HNOWNEW or $HNOWNEW30"
		echo "TRYING EARLIER STARTTIME                      $HNOWNEW60"
		if [ "$COUTURL60STARTTIME" != "$HNOWNEW60" ]; then
			echo "STARTTIMES TIMES NOT MATCHED@                 $HNOWNEW or $HNOWNEW30 or $HNOWNEW60"
			echo "TRYING EARLIER STARTTIME                      $HNOWNEW90"
			if [ "$COUTURL90STARTTIME" != "$HNOWNEW90" ]; then
				echo "STARTTIMES TIMES NOT MATCHED@                 $HNOWNEW or $HNOWNEW30 or $HNOWNEW90"
				echo "TRYING EARLIER STARTTIME                      $HNOWNEW120"
				if [ "$COUTURL120STARTTIME" != "$HNOWNEW120" ]; then
					echo "STARTTIMES TIMES NOT MATCHED@                 $HNOWNEW or $HNOWNEW30 or $HNOWNEW90 or $HNOWNEW120"
					exit 1
				else
					echo "PROGRAM:				      $OUTURL120TITLE"
					echo "PROGRAM_STARTTIME:		              $OUTURL120STARTTIME"
					echo "PROGRAM_ENDTIME:			      $OUTURL120ENDTIME"
					#echo "EPOC OUTURL120ENDTIME is:     $EPOCOUTURL120ENDTIME"
					#echo "EPOC OUTURL120STARTTIME is:   $EPOCOUTURL120STARTTIME"
					let  "EPOCSECONDSURL120 = $EPOCOUTURL120ENDTIME - $EPOCOUTURL120STARTTIME "
					#echo "EPOCSECONDSURL120 = $EPOCSECONDSURL120"
					let  "DURATIONURL120 = $EPOCSECONDSURL120/60"
					echo "PROGRAM_DURATION:			      $DURATIONURL120 minutes"
				fi
			else
				echo "PROGRAM:				      $OUTURL90TITLE"
				echo "PROGRAM_STARTTIME:		              $OUTURL90STARTTIME"
				echo "PROGRAM_ENDTIME:			      $OUTURL90ENDTIME"
				#echo "EPOC OUTURL90ENDTIME is:     $EPOCOUTURL90ENDTIME"
				#echo "EPOC OUTURL90STARTTIME is:   $EPOCOUTURL90STARTTIME"
				let  "EPOCSECONDSURL90 = $EPOCOUTURL90ENDTIME - $EPOCOUTURL90STARTTIME "
				#echo "EPOCSECONDSURL90 = $EPOCSECONDSURL90"
				let  "DURATIONURL90 = $EPOCSECONDSURL90/60"
				echo "PROGRAM_DURATION:			      $DURATIONURL90 minutes"
			fi	


		else
			echo "PROGRAM:				      $OUTURL60TITLE"
			echo "PROGRAM_STARTTIME:		              $OUTURL60STARTTIME"
			echo "PROGRAM_ENDTIME:			      $OUTURL60ENDTIME"
			#echo "EPOC OUTURL60ENDTIME is:     $EPOCOUTURL60ENDTIME"
			#echo "EPOC OUTURL60STARTTIME is:   $EPOCOUTURL60STARTTIME"
			let  "EPOCSECONDSURL60 = $EPOCOUTURL30ENDTIME - $EPOCOUTURL60STARTTIME "
			#echo "EPOCSECONDSURL60 = $EPOCSECONDSURL60"
			let  "DURATIONURL60 = $EPOCSECONDSURL60/60"
			echo "PROGRAM_DURATION:			      $DURATIONURL30 minutes"
		fi	
	else
		echo "PROGRAM:				      $OUTURL30TITLE"
		echo "PROGRAM_STARTTIME:		              $OUTURL30STARTTIME"
		echo "PROGRAM_ENDTIME:			      $OUTURL30ENDTIME"
		#echo "EPOC OUTURLENDTIME is:     $EPOCOUTURLENDTIME"
		#echo "EPOC OUTURLSTARTTIME is:   $EPOCOUTURLSTARTTIME"
		let  "EPOCSECONDSURL30 = $EPOCOUTURL30ENDTIME - $EPOCOUTURL30STARTTIME "
		#echo "EPOCSECONDSURL30 = $EPOCSECONDSURL30"
		let  "DURATIONURL30 = $EPOCSECONDSURL30/60"
		echo "PROGRAM_DURATION:			      $DURATIONURL30 minutes"
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


<!---
### Example 1 Source for comparision for above
#![mythtv.guide](/mythtv.guide.qsp.png)
-->
