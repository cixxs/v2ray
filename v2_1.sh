#!/bin/bash
#wget -q https://github.com/cixxs/v2ray/raw/master/install.sh
#chmod +x install.sh
#bash install.sh
NETFLIX_IP="103.159.64.93"
wget https://github.com/XTLS/Xray-core/releases/download/v1.4.0/Xray-linux-64.zip
unzip Xray-linux-64.zip
chmod +x ./xray

wget https://github.com/fatedier/frp/releases/download/v0.35.1/frp_0.35.1_linux_amd64.tar.gz
tar -zxvf frp_0.35.1_linux_amd64.tar.gz
cp -r frp_0.35.1_linux_amd64 frp

wget -q https://github.com/cixxs/v2ray/releases/download/v2.21/gost
chmod +x ./gost
./gost -L=admin:xinxin8816@localhost:18080&

cat > ./frp/frpcfornet.ini << EOF
[common]
server_addr = 103.159.64.93
server_port = 12401
tcp_mux     = false
token = xinxin8816
pool_count = 50
login_fail_exit = false
[socks_1]
type = tcp
local_ip = 127.0.0.1
local_port = 18080
remote_port = 18081
EOF

cat > ./frp/frpc.ini << EOF
[common]
server_addr = xinxin8816.tpddns.cn
server_port = 7000
tcp_mux     = false
protocol = websocket
token = xinxin8816
pool_count = 50
heartbeat_interval = 1
login_fail_exit = false

[v2_1]
type = tcp
local_ip = 127.0.0.1
local_port = 22222
remote_port = 22222

#[Ngrok_1]
#type = tcp
#local_ip = 127.0.0.1
#local_port = 4040
#remote_port = 40402

[m2_1]
type = tcp
local_ip = 127.0.0.1
local_port = 22221
remote_port = 22232

#[SGNF Trojan]
#type = tcp
#local_ip = $NETFLIX_IP
#local_port = 22221
#remote_port = 30002
EOF

cd frp
chmod +x ./frpc
./frpc -c frpc.ini&
./frpc -c frpcfornet.ini&
#wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/2.52/nf_2.52_linux_amd64 && chmod +x nf && ./nf -method full
#cat /etc/v2ray/config.json
#sudo /usr/bin/v2ray/v2ray -config /etc/v2ray/config.json

cd ..
wget https://github.com/xinxin8816/ngrok/releases/download/1/ngrok
chmod 777 ./ngrok

cat > ./ding.cfg << EOF
server_addr: "vaiwan.com:443"
inspect_addr: disabled
trust_host_root_certs: true
EOF

cat > ./easydown.yml << EOF
tunnel: sorock
credentials-file: ./1234.json
protocol: http2
originRequest:
  connectTimeout: 30s
  noTLSVerify: true
ingress:
  - hostname: sorocky.googlecn.ga
    service: https://sorocky.com:22301
  - hostname: aliflow.googlecn.ga
    service: http://127.0.0.1:22221
  - service: http_status:404
EOF

wget -O 1234.json -q https://github.com/cixxs/v2ray/releases/download/v2.21/1dbd4eb5-9aed-4754-aa84-a73925fa1337.json
wget -O cloudflared -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x ./cloudflared
./cloudflared tunnel --config easydown.yml run&

sudo ./ngrok -config=./ding.cfg -subdomain=aligaba2 22221&
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
        "vnext": [
          {
            "address": "free-sg-01.gonetflix.xyz",
            "port": 443,
            "users": [
              {
                "id": "402d7490-6d4b-42d4-80ed-e681b0e6f1f9",
                "security": "auto",
                "alterId": 0
              }
            ]
          }
        ]
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
				"port": 12412,
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
			"outboundTag": "GoNetflix",
			"domain": ["geosite:netflix"]
		}, {
			"type": "field",
			"outboundTag": "IPv4_out",
			"ip": ["0.0.0.0/0"]
		}, {
			"type": "field",
			"outboundTag": "IPv4_out",
			"ip": ["::/0"]
		}, {
			"type": "field",
			"outboundTag": "IPv4_out",
			"inboundTag": ["dns_inbound"]
		}]
	}
}
EOF

sudo /root/workspace/code/xray run -config /root/workspace/code/config.json
