#!/usr/bin/env bash
#
# Description: Auto system info & I/O test & network to China script
#
# Copyright (C) 2017 - 2020 Oldking <oooldking@gmail.com>
#
# Thanks: Bench.sh <i@teddysun.com>
#
# URL: https://www.oldking.net/350.html
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
SKYBLUE='\033[0;36m'
PLAIN='\033[0m'

about() {
	echo ""
	echo " ========================================================= "
	echo " \                 Superbench.sh  Script                 / "
	echo " \       Basic system info, I/O test and speedtest       / "
	echo " \                   v1.1.7 (7 Apr 2020)                 / "
	echo " \                   Created by Oldking                  / "
	echo " ========================================================= "
	echo ""
	echo " Intro: https://www.oldking.net/350.html"
	echo " Copyright (C) 2020 Oldking oooldking@gmail.com"
	echo ""
}

cancel() {
	echo ""
	next;
	echo " Abort ..."
	echo " Cleanup ..."
	cleanup;
	echo " Done"
	exit
}

trap cancel SIGINT

benchinit() {
	if [ -f /etc/redhat-release ]; then
	    release="centos"
	elif cat /etc/issue | grep -Eqi "debian"; then
	    release="debian"
	elif cat /etc/issue | grep -Eqi "ubuntu"; then
	    release="ubuntu"
	elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
	    release="centos"
	elif cat /proc/version | grep -Eqi "debian"; then
	    release="debian"
	elif cat /proc/version | grep -Eqi "ubuntu"; then
	    release="ubuntu"
	elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
	    release="centos"
	fi

	[[ $EUID -ne 0 ]] && echo -e "${RED}Error:${PLAIN} This script must be run as root!" && exit 1

	if  [ ! -e '/usr/bin/python' ]; then
	        echo " Installing Python ..."
	            if [ "${release}" == "centos" ]; then
	            		yum update > /dev/null 2>&1
	                    yum -y install python > /dev/null 2>&1
	                else
	                	apt-get update > /dev/null 2>&1
	                    apt-get -y install python > /dev/null 2>&1
	                fi
	        
	fi

	if  [ ! -e '/usr/bin/curl' ]; then
	        echo " Installing Curl ..."
	            if [ "${release}" == "centos" ]; then
	                yum update > /dev/null 2>&1
	                yum -y install curl > /dev/null 2>&1
	            else
	                apt-get update > /dev/null 2>&1
	                apt-get -y install curl > /dev/null 2>&1
	            fi
	fi

	if  [ ! -e '/usr/bin/wget' ]; then
	        echo " Installing Wget ..."
	            if [ "${release}" == "centos" ]; then
	                yum update > /dev/null 2>&1
	                yum -y install wget > /dev/null 2>&1
	            else
	                apt-get update > /dev/null 2>&1
	                apt-get -y install wget > /dev/null 2>&1
	            fi
	fi

	if  [ ! -e './speedtest-cli/speedtest' ]; then
		echo " Installing Speedtest-cli ..."
		wget --no-check-certificate -qO speedtest.tgz https://cdn.jsdelivr.net/gh/oooldking/script@1.1.7/speedtest_cli/ookla-speedtest-1.0.0-$(uname -m)-linux.tgz > /dev/null 2>&1
	fi
	mkdir -p speedtest-cli && tar zxvf speedtest.tgz -C ./speedtest-cli/ > /dev/null 2>&1 && chmod a+rx ./speedtest-cli/speedtest

	if  [ ! -e 'tools.py' ]; then
		echo " Installing tools.py ..."
		wget --no-check-certificate https://cdn.jsdelivr.net/gh/oooldking/script@1.1.7/tools.py > /dev/null 2>&1
	fi
	chmod a+rx tools.py

	if  [ ! -e 'fast_com.py' ]; then
		echo " Installing Fast.com-cli ..."
		wget --no-check-certificate https://cdn.jsdelivr.net/gh/sanderjo/fast.com@master/fast_com.py > /dev/null 2>&1
		wget --no-check-certificate https://cdn.jsdelivr.net/gh/sanderjo/fast.com@master/fast_com_example_usage.py > /dev/null 2>&1
	fi
	chmod a+rx fast_com.py
	chmod a+rx fast_com_example_usage.py

	sleep 5

	start=$(date +%s) 
}

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g' | tee -a $log
}

speed_test(){
	if [[ $1 == '' ]]; then
		speedtest-cli/speedtest -p no --accept-license > $speedLog 2>&1
		is_upload=$(cat $speedLog | grep 'Upload')
		result_speed=$(cat $speedLog | awk -F ' ' '/Result/{print $3}')
		if [[ ${is_upload} ]]; then
	        local REDownload=$(cat $speedLog | awk -F ' ' '/Download/{print $3}')
	        local reupload=$(cat $speedLog | awk -F ' ' '/Upload/{print $3}')
	        local relatency=$(cat $speedLog | awk -F ' ' '/Latency/{print $2}')

	        temp=$(echo "$relatency" | awk -F '.' '{print $1}')
        	if [[ ${temp} -gt 50 ]]; then
            	relatency="(*)"${relatency}
        	fi
	        local nodeName=$2

	        temp=$(echo "${REDownload}" | awk -F ' ' '{print $1}')
	        if [[ $(awk -v num1=${temp} -v num2=0 'BEGIN{print(num1>num2)?"1":"0"}') -eq 1 ]]; then
	        	printf "${YELLOW}%-18s${GREEN}%-18s${RED}%-20s${SKYBLUE}%-12s${PLAIN}\n" " ${nodeName}" "${reupload} Mbit/s" "${REDownload} Mbit/s" "${relatency} ms" | tee -a $log
	        fi
		else
	        local cerror="ERROR"
		fi
	else
		speedtest-cli/speedtest -p no -s $1 --accept-license > $speedLog 2>&1
		is_upload=$(cat $speedLog | grep 'Upload')
		if [[ ${is_upload} ]]; then
	        local REDownload=$(cat $speedLog | awk -F ' ' '/Download/{print $3}')
	        local reupload=$(cat $speedLog | awk -F ' ' '/Upload/{print $3}')
	        local relatency=$(cat $speedLog | awk -F ' ' '/Latency/{print $2}')
	        local nodeName=$2

	        temp=$(echo "${REDownload}" | awk -F ' ' '{print $1}')
	        if [[ $(awk -v num1=${temp} -v num2=0 'BEGIN{print(num1>num2)?"1":"0"}') -eq 1 ]]; then
	        	printf "${YELLOW}%-18s${GREEN}%-18s${RED}%-20s${SKYBLUE}%-12s${PLAIN}\n" " ${nodeName}" "${reupload} Mbit/s" "${REDownload} Mbit/s" "${relatency} ms" | tee -a $log
			fi
		else
	        local cerror="ERROR"
		fi
	fi
}

print_speedtest() {
	printf "%-18s%-18s%-20s%-12s\n" " Node Name" "Upload Speed" "Download Speed" "Latency" | tee -a $log
    speed_test '' 'Speedtest.net'
    speed_fast_com
	 speed_test '3633' '上海 电信'
	 speed_test '28139' '上海５Ｇ 电信'
	 speed_test '6168' '云南昆明 电信'
	 speed_test '27539' '云南昆明５Ｇ 电信'
	 speed_test '24012' '内蒙古呼和浩特 电信'
	 speed_test '21470' '内蒙古鄂尔多斯 电信'
	 speed_test '4751' '北京 电信'
	 speed_test '27377' '北京５Ｇ 电信'
	 speed_test '4624' '四川成都 电信'
	 speed_test '6714' '天津 电信'
	 speed_test '17145' '安徽安徽合肥 电信'
	 speed_test '9151' '广东广州 电信'
	 speed_test '10775' '广东广州 电信'
	 speed_test '17251' '广东广州 电信'
	 speed_test '27594' '广东广州５Ｇ 电信'
	 speed_test '5081' '广东深圳 电信'
	 speed_test '10192' '广西南宁 电信'
	 speed_test '10305' '广西南宁 电信'
	 speed_test '22724' '广西南宁 电信'
	 speed_test '27810' '广西南宁 电信'
	 speed_test '27304' '新疆乌鲁木齐 电信'
	 speed_test '27575' '新疆乌鲁木齐 电信'
	 speed_test '5316' '江苏南京 电信'
	 speed_test '26352' '江苏南京５Ｇ 电信'
	 speed_test '5324' '江苏徐州 电信'
	 speed_test '5396' '江苏苏州 电信'
	 speed_test '5317' '江苏连云港 电信'
	 speed_test '6345' '江西南昌 电信'
	 speed_test '6473' '江西南昌 电信'
	 speed_test '7643' '江西南昌 电信'
	 speed_test '16399' '江西南昌 电信'
	 speed_test '4595' '河南郑州 电信'
	 speed_test '7509' '浙江杭州 电信'
	 speed_test '20038' '湖北武汉 电信'
	 speed_test '23665' '湖北武汉 电信'
	 speed_test '23844' '湖北武汉 电信'
	 speed_test '24011' '湖北武汉 电信'
	 speed_test '6435' '湖北襄阳 电信'
	 speed_test '12637' '湖北襄阳 电信'
	 speed_test '6132' '湖南长沙 电信'
	 speed_test '28225' '湖南长沙 电信'
	 speed_test '3973' '甘肃兰州 电信'
	 speed_test '6592' '重庆 电信'
	 speed_test '16983' '重庆 电信'
	 speed_test '19076' '重庆 电信'
	 speed_test '19918' '青海西宁 电信'

	 speed_test '5083' '上海 联通'
	 speed_test '21005' '上海 联通'
	 speed_test '24447' '上海５Ｇ 联通'
	 speed_test '5103' '云南昆明 联通'
	 speed_test '5465' '内蒙古呼和浩特 联通'
	 speed_test '5145' '北京 联通'
	 speed_test '5505' '北京 联通'
	 speed_test '18462' '北京 联通'
	 speed_test '9484' '吉林长春 联通'
	 speed_test '10742' '吉林长春 联通'
	 speed_test '2461' '四川成都 联通'
	 speed_test '5475' '天津 联通'
	 speed_test '27154' '天津５Ｇ 联通'
	 speed_test '5509' '宁夏 联通'
	 speed_test '5724' '安徽合肥 联通'
	 speed_test '5039' '山东济南 联通'
	 speed_test '12538' '山东济南 联通'
	 speed_test '26180' '山东济南５Ｇ 联通'
	 speed_test '5710' '山东青岛 联通'
	 speed_test '12516' '山西太原 联通'
	 speed_test '12868' '山西太原 联通'
	 speed_test '19736' '山西太原 联通'
	 speed_test '3891' '广东广州 联通'
	 speed_test '26678' '广东广州５Ｇ 联通'
	 speed_test '10201' '广东深圳 联通'
	 speed_test '5674' '广西南宁 联通'
	 speed_test '6144' '新疆乌鲁木齐 联通'
	 speed_test '5446' '江苏南京 联通'
	 speed_test '13704' '江苏南京 联通'
	 speed_test '5097' '江西南昌 联通'
	 speed_test '7230' '江西南昌 联通'
	 speed_test '5131' '河南郑州 联通'
	 speed_test '6810' '河南郑州 联通'
	 speed_test '6245' '浙江宁波 联通'
	 speed_test '5300' '浙江杭州 联通'
	 speed_test '5985' '海南海口 联通'
	 speed_test '5485' '湖北武汉 联通'
	 speed_test '26677' '湖南株洲 联通'
	 speed_test '4870' '湖南长沙 联通'
	 speed_test '4690' '甘肃兰州 联通'
	 speed_test '5506' '福建厦门 联通'
	 speed_test '4884' '福建福州 联通'
	 speed_test '5750' '西藏拉萨 联通'
	 speed_test '5017' '辽宁沈阳 联通'
	 speed_test '5726' '重庆 联通'
	 speed_test '5992' '青海西宁 联通'
	 speed_test '5460' '黑龙江哈尔滨 联通'

	 speed_test '4665' '上海 移动'
	 speed_test '16719' '上海 移动'
	 speed_test '16803' '上海 移动'
	 speed_test '25637' '上海５Ｇ 移动'
	 speed_test '5892' '云南昆明 移动'
	 speed_test '26728' '云南昆明 移动'
	 speed_test '17085' '内蒙古呼和浩特 移动'
	 speed_test '27019' '内蒙古呼和浩特 移动'
	 speed_test '17230' '内蒙古阿拉善 移动'
	 speed_test '4713' '北京 移动'
	 speed_test '25858' '北京 移动'
	 speed_test '16375' '吉林长春 移动'
	 speed_test '4575' '四川成都 移动'
	 speed_test '24337' '四川成都 移动'
	 speed_test '28211' '四川成都 移动'
	 speed_test '17184' '天津 移动'
	 speed_test '16392' '宁夏银川 移动'
	 speed_test '26940' '宁夏银川 移动'
	 speed_test '4377' '安徽合肥 移动'
	 speed_test '26404' '安徽合肥 移动'
	 speed_test '17388' '山东临沂 移动'
	 speed_test '16314' '山东济南 移动'
	 speed_test '17480' '山东济南 移动'
	 speed_test '25881' '山东济南 移动'
	 speed_test '17432' '山东青岛 移动'
	 speed_test '16005' '山西太原 移动'
	 speed_test '6611' '广东广州 移动'
	 speed_test '4515' '广东深圳 移动'
	 speed_test '15863' '广西南宁 移动'
	 speed_test '3784' '新疆乌鲁木齐 移动'
	 speed_test '16858' '新疆乌鲁木齐 移动'
	 speed_test '26938' '新疆乌鲁木齐５Ｇ 移动'
	 speed_test '17228' '新疆伊犁 移动'
	 speed_test '17227' '新疆和田 移动'
	 speed_test '17245' '新疆喀什 移动'
	 speed_test '17222' '新疆阿勒泰 移动'
	 speed_test '21590' '江苏南京 移动'
	 speed_test '27249' '江苏南京５Ｇ 移动'
	 speed_test '21530' '江苏南通 移动'
	 speed_test '21722' '江苏宿迁 移动'
	 speed_test '21845' '江苏常州 移动'
	 speed_test '22349' '江苏徐州 移动'
	 speed_test '21600' '江苏扬州 移动'
	 speed_test '5122' '江苏无锡 移动'
	 speed_test '21973' '江苏无锡 移动'
	 speed_test '26850' '江苏无锡５Ｇ 移动'
	 speed_test '21642' '江苏泰州 移动'
	 speed_test '22037' '江苏淮安 移动'
	 speed_test '21946' '江苏盐城 移动'
	 speed_test '3927' '江苏苏州 移动'
	 speed_test '21472' '江苏苏州 移动'
	 speed_test '21584' '江苏连云港 移动'
	 speed_test '17320' '江苏镇江 移动'
	 speed_test '16294' '江西南昌 移动'
	 speed_test '16332' '江西南昌 移动'
	 speed_test '25883' '江西南昌 移动'
	 speed_test '17223' '河北石家庄 移动'
	 speed_test '10939' '河南商丘 移动'
	 speed_test '4486' '河南郑州 移动'
	 speed_test '18970' '河南郑州 移动'
	 speed_test '26331' '河南郑州５Ｇ 移动'
	 speed_test '6715' '浙江宁波 移动'
	 speed_test '4647' '浙江杭州 移动'
	 speed_test '12278' '浙江杭州 移动'
	 speed_test '16503' '海南海口 移动'
	 speed_test '16395' '湖北武汉 移动'
	 speed_test '26357' '湖北武汉 移动'
	 speed_test '26547' '湖北武汉 移动'
	 speed_test '15862' '湖南长沙 移动'
	 speed_test '28491' '湖南长沙５Ｇ 移动'
	 speed_test '16145' '甘肃兰州 移动'
	 speed_test '16171' '福建福州 移动'
	 speed_test '17494' '西藏拉萨 移动'
	 speed_test '18444' '西藏拉萨 移动'
	 speed_test '7404' '贵州贵阳 移动'
	 speed_test '16398' '贵州贵阳 移动'
	 speed_test '25728' '辽宁大连 移动'
	 speed_test '16167' '辽宁沈阳 移动'
	 speed_test '16409' '重庆 移动'
	 speed_test '17584' '重庆 移动'
	 speed_test '26380' '陕西西安 移动'
	 speed_test '16915' '青海西宁 移动'
	 speed_test '18504' '青海西宁 移动'
	 speed_test '29083' '青海西宁５Ｇ 移动'
	 speed_test '17437' '黑龙江哈尔滨 移动'
	 speed_test '26656' '黑龙江哈尔滨５Ｇ 移动'


	rm -rf speedtest*
}

print_speedtest_fast() {
	printf "%-18s%-18s%-20s%-12s\n" " Node Name" "Upload Speed" "Download Speed" "Latency" | tee -a $log
    speed_test '' 'Speedtest.net'
    speed_fast_com
    speed_test '27377' 'Beijing 5G   CT'
	speed_test '24447' 'ShangHai 5G  CU'
	speed_test '27249' 'Nanjing 5G   CM'
	 
	rm -rf speedtest*
}

speed_fast_com() {
	temp=$(python fast_com_example_usage.py 2>&1)
	is_down=$(echo "$temp" | grep 'Result') 
		if [[ ${is_down} ]]; then
	        temp1=$(echo "$temp" | awk -F ':' '/Result/{print $2}')
	        temp2=$(echo "$temp1" | awk -F ' ' '/Mbps/{print $1}')
	        local REDownload="$temp2 Mbit/s"
	        local reupload="0.00 Mbit/s"
	        local relatency="-"
	        local nodeName="Fast.com"

	        printf "${YELLOW}%-18s${GREEN}%-18s${RED}%-20s${SKYBLUE}%-12s${PLAIN}\n" " ${nodeName}" "${reupload}" "${REDownload}" "${relatency}" | tee -a $log
		else
	        local cerror="ERROR"
		fi
	rm -rf fast_com_example_usage.py
	rm -rf fast_com.py

}

io_test() {
    (LANG=C dd if=/dev/zero of=test_file_$$ bs=512K count=$1 conv=fdatasync && rm -f test_file_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

calc_disk() {
    local total_size=0
    local array=$@
    for size in ${array[@]}
    do
        [ "${size}" == "0" ] && size_t=0 || size_t=`echo ${size:0:${#size}-1}`
        [ "`echo ${size:(-1)}`" == "K" ] && size=0
        [ "`echo ${size:(-1)}`" == "M" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' / 1024}' )
        [ "`echo ${size:(-1)}`" == "T" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' * 1024}' )
        [ "`echo ${size:(-1)}`" == "G" ] && size=${size_t}
        total_size=$( awk 'BEGIN{printf "%.1f", '$total_size' + '$size'}' )
    done
    echo ${total_size}
}

power_time() {

	result=$(smartctl -a $(result=$(cat /proc/mounts) && echo $(echo "$result" | awk '/data=ordered/{print $1}') | awk '{print $1}') 2>&1) && power_time=$(echo "$result" | awk '/Power_On/{print $10}') && echo "$power_time"
}

install_smart() {
	if  [ ! -e '/usr/sbin/smartctl' ]; then
		echo "Installing Smartctl ..."
	    if [ "${release}" == "centos" ]; then
	    	yum update > /dev/null 2>&1
	        yum -y install smartmontools > /dev/null 2>&1
	    else
	    	apt-get update > /dev/null 2>&1
	        apt-get -y install smartmontools > /dev/null 2>&1
	    fi      
	fi
}

ip_info4(){
	ip_date=$(curl -4 -s http://api.ip.la/en?json)
	echo $ip_date > ip_json.json
	isp=$(python tools.py geoip isp)
	as_tmp=$(python tools.py geoip as)
	asn=$(echo $as_tmp | awk -F ' ' '{print $1}')
	org=$(python tools.py geoip org)
	if [ -z "ip_date" ]; then
		echo $ip_date
		echo "hala"
		country=$(python tools.py ipip country_name)
		city=$(python tools.py ipip city)
		countryCode=$(python tools.py ipip country_code)
		region=$(python tools.py ipip province)
	else
		country=$(python tools.py geoip country)
		city=$(python tools.py geoip city)
		countryCode=$(python tools.py geoip countryCode)
		region=$(python tools.py geoip regionName)	
	fi
	if [ -z "$city" ]; then
		city=${region}
	fi

	echo -e " ASN & ISP            : ${SKYBLUE}$asn, $isp${PLAIN}" | tee -a $log
	echo -e " Organization         : ${YELLOW}$org${PLAIN}" | tee -a $log
	echo -e " Location             : ${SKYBLUE}$city, ${YELLOW}$country / $countryCode${PLAIN}" | tee -a $log
	echo -e " Region               : ${SKYBLUE}$region${PLAIN}" | tee -a $log

	rm -rf tools.py
	rm -rf ip_json.json
}

virt_check(){
	if hash ifconfig 2>/dev/null; then
		eth=$(ifconfig)
	fi

	virtualx=$(dmesg) 2>/dev/null

    if  [ $(which dmidecode) ]; then
		sys_manu=$(dmidecode -s system-manufacturer) 2>/dev/null
		sys_product=$(dmidecode -s system-product-name) 2>/dev/null
		sys_ver=$(dmidecode -s system-version) 2>/dev/null
	else
		sys_manu=""
		sys_product=""
		sys_ver=""
	fi
	
	if grep docker /proc/1/cgroup -qa; then
	    virtual="Docker"
	elif grep lxc /proc/1/cgroup -qa; then
		virtual="Lxc"
	elif grep -qa container=lxc /proc/1/environ; then
		virtual="Lxc"
	elif [[ -f /proc/user_beancounters ]]; then
		virtual="OpenVZ"
	elif [[ "$virtualx" == *kvm-clock* ]]; then
		virtual="KVM"
	elif [[ "$cname" == *KVM* ]]; then
		virtual="KVM"
	elif [[ "$cname" == *QEMU* ]]; then
		virtual="KVM"
	elif [[ "$virtualx" == *"VMware Virtual Platform"* ]]; then
		virtual="VMware"
	elif [[ "$virtualx" == *"Parallels Software International"* ]]; then
		virtual="Parallels"
	elif [[ "$virtualx" == *VirtualBox* ]]; then
		virtual="VirtualBox"
	elif [[ -e /proc/xen ]]; then
		virtual="Xen"
	elif [[ "$sys_manu" == *"Microsoft Corporation"* ]]; then
		if [[ "$sys_product" == *"Virtual Machine"* ]]; then
			if [[ "$sys_ver" == *"7.0"* || "$sys_ver" == *"Hyper-V" ]]; then
				virtual="Hyper-V"
			else
				virtual="Microsoft Virtual Machine"
			fi
		fi
	else
		virtual="Dedicated"
	fi
}

power_time_check(){
	echo -ne " Power time of disk   : "
	install_smart
	ptime=$(power_time)
	echo -e "${SKYBLUE}$ptime Hours${PLAIN}"
}

freedisk() {
	freespace=$( df -m . | awk 'NR==2 {print $4}' )
	if [[ $freespace == "" ]]; then
		$freespace=$( df -m . | awk 'NR==3 {print $3}' )
	fi
	if [[ $freespace -gt 1024 ]]; then
		printf "%s" $((1024*2))
	elif [[ $freespace -gt 512 ]]; then
		printf "%s" $((512*2))
	elif [[ $freespace -gt 256 ]]; then
		printf "%s" $((256*2))
	elif [[ $freespace -gt 128 ]]; then
		printf "%s" $((128*2))
	else
		printf "1"
	fi
}

print_io() {
	if [[ $1 == "fast" ]]; then
		writemb=$((128*2))
	else
		writemb=$(freedisk)
	fi
	
	writemb_size="$(( writemb / 2 ))MB"
	if [[ $writemb_size == "1024MB" ]]; then
		writemb_size="1.0GB"
	fi

	if [[ $writemb != "1" ]]; then
		echo -n " I/O Speed( $writemb_size )   : " | tee -a $log
		io1=$( io_test $writemb )
		echo -e "${YELLOW}$io1${PLAIN}" | tee -a $log
		echo -n " I/O Speed( $writemb_size )   : " | tee -a $log
		io2=$( io_test $writemb )
		echo -e "${YELLOW}$io2${PLAIN}" | tee -a $log
		echo -n " I/O Speed( $writemb_size )   : " | tee -a $log
		io3=$( io_test $writemb )
		echo -e "${YELLOW}$io3${PLAIN}" | tee -a $log
		ioraw1=$( echo $io1 | awk 'NR==1 {print $1}' )
		[ "`echo $io1 | awk 'NR==1 {print $2}'`" == "GB/s" ] && ioraw1=$( awk 'BEGIN{print '$ioraw1' * 1024}' )
		ioraw2=$( echo $io2 | awk 'NR==1 {print $1}' )
		[ "`echo $io2 | awk 'NR==1 {print $2}'`" == "GB/s" ] && ioraw2=$( awk 'BEGIN{print '$ioraw2' * 1024}' )
		ioraw3=$( echo $io3 | awk 'NR==1 {print $1}' )
		[ "`echo $io3 | awk 'NR==1 {print $2}'`" == "GB/s" ] && ioraw3=$( awk 'BEGIN{print '$ioraw3' * 1024}' )
		ioall=$( awk 'BEGIN{print '$ioraw1' + '$ioraw2' + '$ioraw3'}' )
		ioavg=$( awk 'BEGIN{printf "%.1f", '$ioall' / 3}' )
		echo -e " Average I/O Speed    : ${YELLOW}$ioavg MB/s${PLAIN}" | tee -a $log
	else
		echo -e " ${RED}Not enough space!${PLAIN}"
	fi
}

print_system_info() {
	echo -e " CPU Model            : ${SKYBLUE}$cname${PLAIN}" | tee -a $log
	echo -e " CPU Cores            : ${YELLOW}$cores Cores ${SKYBLUE}$freq MHz $arch${PLAIN}" | tee -a $log
	echo -e " CPU Cache            : ${SKYBLUE}$corescache ${PLAIN}" | tee -a $log
	echo -e " OS                   : ${SKYBLUE}$opsy ($lbit Bit) ${YELLOW}$virtual${PLAIN}" | tee -a $log
	echo -e " Kernel               : ${SKYBLUE}$kern${PLAIN}" | tee -a $log
	echo -e " Total Space          : ${SKYBLUE}$disk_used_size GB / ${YELLOW}$disk_total_size GB ${PLAIN}" | tee -a $log
	echo -e " Total RAM            : ${SKYBLUE}$uram MB / ${YELLOW}$tram MB ${SKYBLUE}($bram MB Buff)${PLAIN}" | tee -a $log
	echo -e " Total SWAP           : ${SKYBLUE}$uswap MB / $swap MB${PLAIN}" | tee -a $log
	echo -e " Uptime               : ${SKYBLUE}$up${PLAIN}" | tee -a $log
	echo -e " Load Average         : ${SKYBLUE}$load${PLAIN}" | tee -a $log
	echo -e " TCP CC               : ${YELLOW}$tcpctrl${PLAIN}" | tee -a $log
}

print_end_time() {
	end=$(date +%s) 
	time=$(( $end - $start ))
	if [[ $time -gt 60 ]]; then
		min=$(expr $time / 60)
		sec=$(expr $time % 60)
		echo -ne " Finished in  : ${min} min ${sec} sec" | tee -a $log
	else
		echo -ne " Finished in  : ${time} sec" | tee -a $log
	fi

	printf '\n' | tee -a $log

	bj_time=$(curl -s http://cgi.im.qq.com/cgi-bin/cgi_svrtime)

	if [[ $(echo $bj_time | grep "html") ]]; then
		bj_time=$(date -u +%Y-%m-%d" "%H:%M:%S -d '+8 hours')
	fi
	echo " Timestamp    : $bj_time GMT+8" | tee -a $log
	echo " Results      : $log"
}

get_system_info() {
	cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
	cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
	freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
	corescache=$( awk -F: '/cache size/ {cache=$2} END {print cache}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
	tram=$( free -m | awk '/Mem/ {print $2}' )
	uram=$( free -m | awk '/Mem/ {print $3}' )
	bram=$( free -m | awk '/Mem/ {print $6}' )
	swap=$( free -m | awk '/Swap/ {print $2}' )
	uswap=$( free -m | awk '/Swap/ {print $3}' )
	up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days %d hour %d min\n",a,b,c)}' /proc/uptime )
	load=$( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
	opsy=$( get_opsy )
	arch=$( uname -m )
	lbit=$( getconf LONG_BIT )
	kern=$( uname -r )

	disk_size1=$( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|overlay|shm|udev|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $2}' )
	disk_size2=$( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|overlay|shm|udev|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $3}' )
	disk_total_size=$( calc_disk ${disk_size1[@]} )
	disk_used_size=$( calc_disk ${disk_size2[@]} )

	tcpctrl=$( sysctl net.ipv4.tcp_congestion_control | awk -F ' ' '{print $3}' )

	virt_check
}

print_intro() {
	printf ' Superbench.sh -- https://www.oldking.net/350.html\n' | tee -a $log
	printf " Mode  : \e${GREEN}%s\e${PLAIN}    Version : \e${GREEN}%s${PLAIN}\n" $mode_name 1.1.7 | tee -a $log
	printf ' Usage : wget -qO- sb.oldking.net | bash\n' | tee -a $log
}

sharetest() {
	echo " Share result:" | tee -a $log
	echo " · $result_speed" | tee -a $log
	log_preupload
	case $1 in
	'ubuntu')
		share_link="https://paste.ubuntu.com"$( curl -v --data-urlencode "content@$log_up" -d "poster=superbench.sh" -d "syntax=text" "https://paste.ubuntu.com" 2>&1 | \
			grep "Location" | awk '{print $3}' );;
	'haste' )
		share_link=$( curl -X POST -s -d "$(cat $log)" https://hastebin.com/documents | awk -F '"' '{print "https://hastebin.com/"$4}' );;
	'clbin' )
		share_link=$( curl -sF 'clbin=<-' https://clbin.com < $log );;
	'ptpb' )
		share_link=$( curl -sF c=@- https://ptpb.pw/?u=1 < $log );;
	esac

	echo " · $share_link" | tee -a $log
	next
	echo ""
	rm -f $log_up

}

log_preupload() {
	log_up="$HOME/superbench_upload.log"
	true > $log_up
	$(cat superbench.log 2>&1 | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" > $log_up)
}

cleanup() {
	rm -f test_file_*
	rm -rf speedtest*
	rm -f fast_com*
	rm -f tools.py
	rm -f ip_json.json
}

bench_all(){
	mode_name="Standard"
	about;
	benchinit;
	clear
	next;
	print_intro;
	next;
	get_system_info;
	print_system_info;
	ip_info4;
	next;
	print_io;
	next;
	print_speedtest;
	next;
	print_end_time;
	next;
	cleanup;
	sharetest ubuntu;
}

fast_bench(){
	mode_name="Fast"
	about;
	benchinit;
	clear
	next;
	print_intro;
	next;
	get_system_info;
	print_system_info;
	ip_info4;
	next;
	print_io fast;
	next;
	print_speedtest_fast;
	next;
	print_end_time;
	next;
	cleanup;
}

log="./superbench.log"
true > $log
speedLog="./speedtest.log"
true > $speedLog

case $1 in
	'info'|'-i'|'--i'|'-info'|'--info' )
		about;sleep 3;next;get_system_info;print_system_info;next;;
    'version'|'-v'|'--v'|'-version'|'--version')
		next;about;next;;
   	'io'|'-io'|'--io'|'-drivespeed'|'--drivespeed' )
		next;print_io;next;;
	'speed'|'-speed'|'--speed'|'-speedtest'|'--speedtest'|'-speedcheck'|'--speedcheck' )
		about;benchinit;next;print_speedtest;next;cleanup;;
	'ip'|'-ip'|'--ip'|'geoip'|'-geoip'|'--geoip' )
		about;benchinit;next;ip_info4;next;cleanup;;
	'bench'|'-a'|'--a'|'-all'|'--all'|'-bench'|'--bench' )
		bench_all;;
	'about'|'-about'|'--about' )
		about;;
	'fast'|'-f'|'--f'|'-fast'|'--fast' )
		fast_bench;;
	'share'|'-s'|'--s'|'-share'|'--share' )
		bench_all;
		is_share="share"
		if [[ $2 == "" ]]; then
			sharetest ubuntu;
		else
			sharetest $2;
		fi
		;;
	'debug'|'-d'|'--d'|'-debug'|'--debug' )
		get_ip_whois_org_name;;
*)
    bench_all;;
esac

if [[  ! $is_share == "share" ]]; then
	case $2 in
		'share'|'-s'|'--s'|'-share'|'--share' )
			if [[ $3 == '' ]]; then
				sharetest ubuntu;
			else
				sharetest $3;
			fi
			;;
	esac
fi
