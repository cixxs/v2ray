#!/bin/bash
#wget -q https://github.com/cixxs/v2ray/raw/master/install.sh
#chmod +x install.sh
#bash install.sh
NETFLIX_IP="194.233.70.14"
wget -q https://github.com/XTLS/Xray-core/releases/download/v1.4.0/Xray-linux-64.zip
unzip Xray-linux-64.zip
chmod +x ./xray

wget -q https://github.com/rapiz1/rathole/releases/download/v0.3.8/rathole-x86_64-unknown-linux-gnu.zip
unzip rathole-x86_64-unknown-linux-gnu.zip
chmod +x ./rathole

wget -q https://github.com/fatedier/frp/releases/download/v0.35.1/frp_0.35.1_linux_amd64.tar.gz
tar -zxvf frp_0.35.1_linux_amd64.tar.gz
cp -r frp_0.35.1_linux_amd64 frp

cat > ./client.toml << EOF
[client]
remote_addr = "xinxin8816.tpddns.cn:2333"
[client.services.my_nas_ssh]
token = "use_a_secret_that_only_you_know"
local_addr = "127.0.0.1:22222"
EOF

./rathole client.toml&

cat > ./frp/frpc.ini << EOF
[common]
server_addr = xinxin8816.tpddns.cn
server_port = 7000
tcp_mux     = false
protocol = tcp
token = xinxin8816
#pool_count = 10
heartbeat_interval = 1
login_fail_exit = false

[v2_test]
type = tcp
local_ip = 127.0.0.1
local_port = 22222
remote_port = 22220

#[Ngrok_0]
#type = tcp
#local_ip = 127.0.0.1
#local_port = 4040
#remote_port = 40401

[m2_test]
type = tcp
local_ip = 127.0.0.1
local_port = 22221
remote_port = 22230

#[SGNF Trojan]
#type = tcp
#local_ip = $NETFLIX_IP
#local_port = 22221
#remote_port = 30002
EOF

cd frp
chmod +x ./frpc
./frpc -c frpc.ini&
#wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/2.52/nf_2.52_linux_amd64 && chmod +x nf && ./nf -method full
#cat /etc/v2ray/config.json
#sudo /usr/bin/v2ray/v2ray -config /etc/v2ray/config.json

cd ..
wget -q https://github.com/xinxin8816/ngrok/releases/download/1/ngrok
chmod 777 ./ngrok

cat > ./ding.cfg << EOF
server_addr: "vaiwan.com:443"
inspect_addr: disabled
trust_host_root_certs: true
EOF

sudo ./ngrok -config=./ding.cfg -subdomain=aligaba 22221&
#sudo ./ngrok -config=./ding.cfg -subdomain=emby 129.146.81.146:8096&

cat > /root/workspace/code/config.json << EOF
{
	"dns": {
		"servers": [
			"8.8.8.8",
			"8.8.4.4"
		],
		"tag": "dns_inbound"
	},
	"inbounds": [{
		"port": 22222,
		"protocol": "vless",
		"settings": {
			"clients": [{
				"id": "e55c8d17-2cf3-b21a-bcf1-eeacb011ed79",
				"flow": "xtls-rprx-direct"
			}],
			"decryption": "none"
		},
		"sniffing": {
			"enabled": true,
			"destOverride": ["http", "tls"]
		},
		"streamSettings": {
			"network": "tcp",
			"security": "xtls",
			"xtlsSettings": {
				"certificates": [{
					"certificate": [
						"-----BEGIN CERTIFICATE-----",
						"MIIBgTCCASagAwIBAgIRANuqjkzIm7ovlhAqjcyPpXcwCgYIKoZIzj0EAwIwJjER",
						"MA8GA1UEChMIWHJheSBJbmMxETAPBgNVBAMTCFhyYXkgSW5jMB4XDTIxMDMzMTAw",
						"NDcyMFoXDTIxMDYyOTAxNDcyMFowJjERMA8GA1UEChMIWHJheSBJbmMxETAPBgNV",
						"BAMTCFhyYXkgSW5jMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEams45H1NHQ6z",
						"ru+WBbmNkT85vw2jm+wIQEN8i2gK+gye0QOO3AGcWUBjgRVwNyMgQuc7/XZgLH2e",
						"gOdVg7M+OKM1MDMwDgYDVR0PAQH/BAQDAgWgMBMGA1UdJQQMMAoGCCsGAQUFBwMB",
						"MAwGA1UdEwEB/wQCMAAwCgYIKoZIzj0EAwIDSQAwRgIhAJb+daOGjqTGWDQBtCha",
						"D04nVqqQ1Du/r2BKsGh7AQprAiEAxV1ngGtYkyW6FrQiZ5y0WMn/0rYlKBMhmq4F",
						"8aJ9ReU=",
						"-----END CERTIFICATE-----"
					],
					"key": [
						"-----BEGIN RSA PRIVATE KEY-----",
						"MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgapMlsYo3znIrhLEM",
						"EftzObwPNyUP7AwyMBetYS+uOtShRANCAARqazjkfU0dDrOu75YFuY2RPzm/DaOb",
						"7AhAQ3yLaAr6DJ7RA47cAZxZQGOBFXA3IyBC5zv9dmAsfZ6A51WDsz44",
						"-----END RSA PRIVATE KEY-----"
					]
				}]
			}
		}
	}, {
		"port": 22221,
		"protocol": "vmess",
		"settings": {
			"clients": [{
				"id": "e55c8d17-2cf3-b21a-bcf1-eeacb011ed79"
			}]
		},
		"sniffing": {
			"enabled": true,
			"destOverride": ["http", "tls"]
		},
		"streamSettings": {
			"network": "ws"
		}
	}],
	"outbounds": [{
		"tag": "GoNetflix",
		"protocol": "vmess",
		"streamSettings": {
			"network": "ws",
			"security": "tls",
			"tlsSettings": {
				"allowInsecure": false
			},
			"wsSettings": {
				"path": "ws"
			}
		},
		"mux": {
			"enabled": true,
			"concurrency": 8
		},
		"settings": {
			"vnext": [{
				"address": "free-sg-01.gonetflix.xyz",
				"port": 443,
				"users": [{
					"id": "402d7490-6d4b-42d4-80ed-e681b0e6f1f9",
					"security": "auto",
					"alterId": 0
				}]
			}]
		}
	}, {
		"tag": "IPv4_out",
		"protocol": "freedom"
	}, {
		"tag": "SP_netflix_out",
		"protocol": "vless",
		"settings": {
			"vnext": [{
				"address": "$NETFLIX_IP",
				"port": 12912,
				"users": [{
					"id": "e55c8d17-2cf3-b21a-bcf1-eeacb011ed79",
					"encryption": "none",
					"flow": "xtls-rprx-direct"
				}]
			}]
		},
		"streamSettings": {
			"network": "tcp",
			"security": "xtls",
			"xtlsSettings": {
				"allowInsecure": true
			}
		}
	}, {
		"tag": "NF_out",
		"protocol": "freedom",
		"settings": {
			"domainStrategy": "UseIP"
		}
	}],
	"routing": {
		"domainStrategy": "IPIfNonMatch",
		"rules": [{
				"type": "field",
				"outboundTag": "IPv4_out",
				"domain": ["geosite:netflix"]
			}, {
				"type": "field",
				"outboundTag": "IPv4_out",
				"ip": ["0.0.0.0/0"]
			}, {
				"type": "field",
				"outboundTag": "SP_netflix_out",
				"ip": ["::/0"]
			}, {
				"type": "field",
				"outboundTag": "SP_netflix_out",
				"inboundTag": ["dns_inbound"]
			}
		]
	}
}
EOF

sudo /root/workspace/code/xray run -config /root/workspace/code/config.json