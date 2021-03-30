#!/bin/bash
#wget -q https://github.com/cixxs/v2ray/raw/master/install.sh
#chmod +x install.sh
#bash install.sh

wget -q https://github.com/XTLS/Xray-core/releases/download/v1.4.0/Xray-linux-64.zip
unzip Xray-linux-64.zip
chmod +x ./xray

wget -q https://github.com/fatedier/frp/releases/download/v0.35.1/frp_0.35.1_linux_amd64.tar.gz
tar -zxvf frp_0.35.1_linux_amd64.tar.gz
cp -r frp_0.35.1_linux_amd64 frp

cat > ./frp/frpc.ini << EOF
[common]
server_addr = xinxin8816.tpddns.cn
server_port = 7000
tcp_mux     = false
protocol = websocket
token = xinxin8816
#pool_count = 10
heartbeat_interval = 1
login_fail_exit = false

[v2_0]
type = tcp
local_ip = 127.0.0.1
local_port = 22222
remote_port = 22221
EOF

cd frp
chmod +x ./frpc
./frpc -c frpc.ini&
#wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/2.52/nf_2.52_linux_amd64 && chmod +x nf && ./nf -method full
#cat /etc/v2ray/config.json
#sudo /usr/bin/v2ray/v2ray -config /etc/v2ray/config.json

cat > ./config.json << EOF
{
	"inbounds": [{
		"port": 22222,
		"protocol": "vmess",
		"settings": {
			"clients": [{
				"id": "e55c8d17-2cf3-b21a-bcf1-eeacb011ed79"
			}]
		},
		"streamSettings": {
			"network": "tcp"
		}
	}],
	"outbounds": [{
		"protocol": "freedom"
	}]
}
EOF

sudo /root/workspace/code/xray run -config ./config.json
