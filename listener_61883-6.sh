IFNAME=eth0
STREAMS=7
PAYLOAD=1400
CLASS=A
RATE=8000

if [ -n "$1" ]; then IFNAME=$1; fi
if [ -n "$2" ]; then STREAMS=$2; fi
if [ -n "$3" ]; then PAYLOAD=$3; fi
if [ -n "$4" ]; then CLASS=$4; fi
if [ $CLASS == "B" ]; then RATE=4000; fi 

ARCH=I210 AVB_FEATURE_ENDPOINT=0 make all || exit 5

sudo killall daemon_cl
sudo rmmod igb_avb

sudo ./run_igb.sh $IFNAME
sudo ifconfig $IFNAME up
sudo ./run_gptp.sh $IFNAME&

sleep 5

(
cd lib/avtp_pipeline/build/bin &&
sudo ./openavb_harness -I $IFNAME -s $STREAMS -d 0 -a a0:36:9f:2d:01:ad \
alsa_listener.ini,sr_class=$CLASS,map_nv_tx_rate=$RATE,report_seconds=0,,max_transit_usec=2000
)

