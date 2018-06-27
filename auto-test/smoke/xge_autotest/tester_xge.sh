#!/bin/bash

TESTER_HNS_TOP_DIR=$(cd "`dirname $0`" ; pwd)

# Load common function
#. ${TESTER_HNS_TOP_DIR}/config/xge_test_config
#. ${TESTER_HNS_TOP_DIR}/config/xge_test_lib

# Load the public configuration library
#. ${TESTER_HNS_TOP_DIR}/../config/common_config

T_SERVER_IP=''
T_CLIENT_IP=''
T_CTRL_NIC=''


checklist()
{
  TABLE_LIST=$( whiptail --title "Test Case List" --checklist
  "Choose test case you want to run this time:" 15 60 4
  "case 1" ON
  "case 2" ON
  "case 3" OFF
  "case 4" OFF
  "case 5" ON 3>&1 1>&2 2>&3)

  if [ $? -eq 0 ];then
	  echo "The choosen list is $TABLE_LIST"
  else
	echo "choose cancel"
  fi
}

###################################################################################
#Usage
###################################################################################

Usage()
{
cat <<EOF    
Usage: ./xge_autotest/tester_hns.sh [options]
Options:
	-h, --help: Display this information
	-s, --sip: Server IP: this ip used to ssh with client
	-c, --cip: Client IP: this ip is client ip connect with server
	-n, --ctrlNIC: the network card used to control client
	-t, --test: the tester name .if other cfg is not set,
		    tester name can help to get latest cfg you used
		    this para is forced to be set.
Example:
	bash tester_hns.sh -t luojiaxing  -s "192.168.3.152" -c "192.168.3.153" -n "eth3"

	bash tester_hns.sh -t luojiaxing # if no other para,scripts will use the latest user cfg

EOF
}

##################################################################################
#Get all args
###################################################################################
echo -e "\033[5;35m Welcom to Use Plinth Test Suite! \033[0m"    
cat << EOF
------------/\-------------
-----------/  \-------------
          /    \\
EOF

echo -e "\033[33m Luojiaxing \033[0m  \033[32m Chenjing \033[0m "

echo "  "
echo ">---------------------------------------------------------<"
echo "Thank you to ALL tester for providing high quality scripts!"
echo -e "Tester: \033[34m hehui\033[0m \033[35m  wanghaifeng\033[0m "
echo ">---------------------------------------------------------< "  
echo "  "

checklist

if [ ! -n "$1" ];then
	Usage
	exit 1
fi

while test $# != 0
do
	case $1 in
		--*=*) ac_option=`expr "X$1" : 'X\([^=]*\)='` ; ac_optarg=`expr "X$1" : 'X[^=]*=\(.*\)'` ; ac_shift=: ;;
		-*) ac_option=$1 ; ac_optarg=$2; ac_shift=shift ;;
		*) ac_option=$1 ; ac_shift=: ;;
	esac

	case $ac_option in
        	-h | --help) Usage ; exit 0 ;;
		-s | --sip) T_SERVER_IP=$ac_optarg ;;
		-c | --cip) T_CLIENT_IP=$ac_optarg ;;
        	-n | --ctrlNIC) T_CTRL_NIC=$ac_optarg ;;
		-t | --tester) T_TESTER=$ac_optarg ;;
		*) Usage ; echo "Unknown option $1"; exit 1 ;;
	esac

	$ac_shift
	shift
done

##################################################################################
#input the parameter
###################################################################################

if [ x"$T_TESTER" = x"" ];then
	echo "Tester name is not input!Please input it use -t..."
	exit 1
fi

. ${TESTER_HNS_TOP_DIR}/../config/common_config
. ${TESTER_HNS_TOP_DIR}/../config/common_lib
##################################################################################
#Get latest cfg pass to empty patameter
###################################################################################

if [ ! -d ${PLINTH_BASE_WORKSPACE}/user/${T_TESTER}/hns ];then
	mkdir -p ${PLINTH_BASE_WORKSPACE}/user/${T_TESTER}/hns
fi

if [ ! -f ${PLINTH_BASE_WORKSPACE}/user/${T_TESTER}/hns/cfg ];then
	touch ${PLINTH_BASE_WORKSPACE}/user/${T_TESTER}/hns/cfg
fi

if [ x"${T_SERVER_IP}" = x"" ];then
	echo "User not input the cfg of Server IP,use user pre-define value!"
	T_SERVER_IP=`cat ${PLINTH_BASE_WORKSPACE}/user/${T_TESTER}/hns/cfg | grep "T_SERVER_IP" | awk -F':' '{print $NF}'`
fi

g_server_ip=$T_SERVER_IP

if [ x"${T_CTRL_NIC}" = x"" ];then
	echo "User not input the cfg of NIC,use user pre-define value!"
	T_CTRL_NIC=`cat ${PLINTH_BASE_WORKSPACE}/user/${T_TESTER}/hns/cfg | grep "T_CTRL_NIC" | awk -F':' '{print $NF}'`
fi

g_ctrlNIC=$T_CTRL_NIC

if [ x"${T_CLIENT_IP}" = x"" ];then
	echo "User not input the cfg of Client IP,use user pre-define value!"
	T_CLIENT_IP=`cat ${PLINTH_BASE_WORKSPACE}/user/${T_TESTER}/hns/cfg | grep "T_CLIENT_IP" | awk -F':' '{print $NF}'`
fi

g_client_ip=$T_CLIENT_IP



##################################################################################
#Update the cfg
###################################################################################
echo "HNS cfg save by ${T_TESTER}" > ${PLINTH_BASE_WORKSPACE}/user/${T_TESTER}/hns/cfg


if [ x"$T_SERVER_IP" != x"" ];then
    echo "T_SERVER_IP:${T_SERVER_IP}" >> ${PLINTH_BASE_WORKSPACE}/user/${T_TESTER}/hns/cfg
fi

if [ x"$T_CLIENT_IP" != x"" ];then
    echo "T_CLIENT_IP:${T_CLIENT_IP}" >> ${PLINTH_BASE_WORKSPACE}/user/${T_TESTER}/hns/cfg
fi

if [ x"${T_CTRL_NIC}" != x"" ];then
    echo "T_CTRL_NIC:${T_CTRL_NIC}" >> ${PLINTH_BASE_WORKSPACE}/user/${T_TESTER}/hns/cfg
fi

if [ x"${T_SERVER_IP}" = x"" ] || [ x"${T_CTRL_NIC}" = x"" ] || [ x"${T_CLIENT_IP}" = x"" ];then
	echo ">--------------------------------------------------------------------------------<"
    echo -e "\033[31m Lose some cfg .Please input full parameter to recover the latest cfg! \033[0m"
    echo ">--------------------------------------------------------------------------------<"

	exit 1
else

	echo ">--------------------------------------------------------------------------------<"
    echo -e "\033[32m This time Run the test with the cfg as: SIP=${T_SERVER_IP} CIP=${T_CLIENT_IP} NIC=${T_CTRL_NIC} \033[0m"
	echo ">--------------------------------------------------------------------------------<"
fi

COM="true"
source ${TESTER_HNS_TOP_DIR}/xge_main.sh

#COM="true"

# clean exit so lava-test can trust the results
exit 0

