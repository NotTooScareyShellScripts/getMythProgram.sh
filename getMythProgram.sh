#!/bin/bash
FNOW=$(date  +%FT%T)
echo "     "
echo "Local Time FNOW is now:                       $FNOW"

FNOWUTC=$(date --utc +%FT%T)
echo "UTC Time FNOWUTC is now:                      $FNOWUTC"

FNOWUTCH=$(echo $FNOWUTC|cut -c1-14)
echo "TRIMMED TO HOUR-UTC Time FNOWUTCH is now:     $FNOWUTCH"

FNOWUTCHMM=$(echo $FNOWUTC|cut -c1-16)
echo "TRIMMED TO HOUR-UTC Time FNOWUTCHMM is now:   $FNOWUTCHMM"

TMSS=30:00
echo "TMSS is:					    $TMSS"

ZMSS=00:00
echo "ZMSS is:					    $ZMSS"

FNOW3TMSS=$(echo $FNOWUTCH$TMSS)
echo "FNOW3TMSS is:		      		      $FNOW3TMSS"

FNOW3ZMSS=$(echo $FNOWUTCH$ZMSS)
echo "FNOW3ZMSS is: 	      			      $FNOW3ZMSS"


if [ `echo $FNOWUTCHMM|cut -d: -f2` -lt 30 ];
        then
            HNOWNEW=$(echo $FNOW3ZMSS)
            #echo "Current Time on Hour < 30, using $ZMSS/TIMESTAMP $HNOW for starttime query specifier"
        else
            HNOWNEW=$(echo $FNOW3TMSS)
            #echo "Current Time on Hour  > 30, using $TMSS/TIMESTAMP $HNOW for starttime query specifier"
fi

echo "HNOWNEW is: 	      			      $HNOWNEW"



URL="http://$1:6544/Guide/GetProgramDetails?StartTime=$HNOWNEW&Chanid=$2"
#echo "URL is: $URL"





XMLSTARLET_ALL="/usr/bin/xmlstarlet sel -t -v //Title -nl -v //StartTime -nl -v //EndTime -nl -nl"
XMLSTARLET_TITLE="/usr/bin/xmlstarlet sel -t -v //Title -nl"
XMLSTARLET_SUBTITLE="/usr/bin/xmlstarlet sel -t -v //SubTitle -nl"
XMLSTARLET_ORIGINALAIRDATE="/usr/bin/xmlstarlet sel -t -v //OriginalAirdate -nl"
XMLSTARLET_STARTTIME="/usr/bin/xmlstarlet sel -t -v //StartTime -nl"
XMLSTARLET_ENDTIME="/usr/bin/xmlstarlet sel -t -v //EndTime -nl"


OUTURLTITLE=$(curl -s $URL|$XMLSTARLET_TITLE)
OUTURLSUBTITLE=$(curl -s $URL|$XMLSTARLET_SUBTITLE)
OUTURLORIGINALAIRDATE=$(curl -s $URL|$XMLSTARLET_ORIGINALAIRDATE)
OUTURLSTARTTIME=$(curl -s $URL|$XMLSTARLET_STARTTIME)
OUTURLENDTIME=$(curl -s $URL|$XMLSTARLET_ENDTIME)
OUTURL_ALL=$(curl -s $URL|$XMLSTARLET_ALL)


COUTURLSTARTTIME=$(echo $OUTURLSTARTTIME|cut -c1-19)
echo "COUTURLSTARTTIME is                           $COUTURLSTARTTIME"

COUTURLENDTIME=$(echo $OUTURLENDTIME|cut -c1-19)
echo "COUTURLENDTIME is                             $COUTURLENDTIME"

echo "URL is: $URL"


echo " "

# & [ "$COUTURLENDTIME" != "$HNOWNEW" ]; then

if [ "$COUTURLSTARTTIME" != "$HNOWNEW" ]; then
	echo "STARTTIMES TIMES NOT MATCHED@                 $HNOWNEW"
	FNOWPREV30=$(date -d "$(echo $HNOWNEW) 30min ago" +"%FT%T")
	echo "Trying Next Previous Slot:                    $FNOWPREV30"
	if [ "$COUTURLSTARTTIME" != "$FNOWPREV30" ];then 
		echo "prev 30 minutes NOT MATCHED @ 	              $FNOWPREV30"
		echo " "
		echo "Show must have started even earlier than 30minutes ago"
		exit 1
	else
		break
	fi

else	
	echo "$OUTURLTITLE"
	echo "$OUTURLSUBTITLE"
	echo "$OUTURLORIGINALAIRDATE"
	echo "$OUTURLSTARTTIME"
	echo "$OUTURLENDTIME"
fi



#calculate duration EndTime-StartTime=Duraton
EPOCOUTURLENDTIME=$(date -d "$(echo $OUTURLENDTIME)" +"%s")
EPOCOUTURLSTARTTIME=$(date -d "$(echo $OUTURLSTARTTIME)" +"%s")
echo "EPOC OUTURLENDTIME is:     $EPOCOUTURLENDTIME"
echo "EPOC OUTURLSTARTTIME is:   $EPOCOUTURLSTARTTIME"

let "EPOCSECONDS = $EPOCOUTURLENDTIME - $EPOCOUTURLSTARTTIME "
echo "EPOCSECONDS = $EPOCSECONDS"

let "DURATION = $EPOCSECONDS/60"
echo "PROGAM DURATION is:   $DURATION minutes"


#echo "Total Duration of $OUTURLTITLE is: $DURATION in minutes"
