IFNAME=eth0
STREAMS=7
PAYLOAD=1400
CLASS=A

if [ -n "$1" ]; then IFNAME=$1; fi
if [ -n "$2" ]; then STREAMS=$2; fi
if [ -n "$3" ]; then PAYLOAD=$3; fi
if [ -n "$4" ]; then CLASS=$4; fi

ARCH=I210 AVB_FEATURE_ENDPOINT=0 make all || exit 5

sudo killall daemon_cl
sudo rmmod igb_avb

sudo ./run_igb.sh $IFNAME
sudo ifconfig $IFNAME up
sudo ./run_gptp.sh $IFNAME&

sleep 5

(
cd lib/avtp_pipeline/build/bin &&
sudo ./openavb_harness -I $IFNAME -s $STREAMS \
echo_talker.ini,intf_nv_echo_string=O,intf_nv_echo_string_repeat=$PAYLOAD,map_nv_max_payload_size=$PAYLOAD,sr_class=$CLASS,map_nv_tx_rate=0,intf_nv_ignore_timestamp=0,report_seconds=0
)
