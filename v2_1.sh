#!/bin/bash
#wget -q https://github.com/cixxs/v2ray/raw/master/install.sh
#chmod +x install.sh
#bash install.sh

sudo apt-get update
sudo apt-get install -y --fix-missing openssl

NETFLIX_IP="103.159.64.93"
wget -q https://github.com/XTLS/Xray-core/releases/download/v1.8.3/Xray-linux-64.zip
unzip Xray-linux-64.zip
chmod +x ./xray

wget -q https://github.com/fatedier/frp/releases/download/v0.43.0/frp_0.43.0_linux_amd64.tar.gz
tar -zxvf frp_0.43.0_linux_amd64.tar.gz
mv frp_0.43.0_linux_amd64 frp

wget -q https://github.com/rapiz1/rathole/releases/download/v0.5.0/rathole-x86_64-unknown-linux-gnu.zip
unzip rathole-x86_64-unknown-linux-gnu.zip
chmod +x ./rathole

wget -q https://github.com/cixxs/v2ray/releases/download/v2.21/gost
chmod +x ./gost
./gost -L=admin:xinxin8816@localhost:18080&

cat > ./rathole.toml << EOF
[client]
remote_addr = "xinxin8816.3322.org:8001"
default_token = "default_token_if_not_specify"

[client.services.v2_1_VLESS]
local_addr = "127.0.0.1:22222"

[client.services.v2_1_VMESS]
local_addr = "0.0.0.0:22221"
EOF

cat > ./frp/frpcfororacle.ini << EOF
[common]
server_addr = my.qxin.info
server_port = 8000
tcp_mux     = false
tls_enable = true
protocol = tcp
token = xinxin8816
pool_count = 20
#heartbeat_interval = 1
login_fail_exit = false
dns_server = 8.8.8.8

[v2_1 VLESS]
type = tcp
local_ip = 127.0.0.1
local_port = 22222
remote_port = 22222

[v2_1 VMESS]
type = tcp
local_ip = 127.0.0.1
local_port = 22221
remote_port = 22232
EOF

cat > ./frp/frpcforsorocky.ini << EOF
[common]
server_addr = bj.sorocky.com
server_port = 7000
tcp_mux     = false
tls_enable = true
token = 9BLsFbsSHw65FAi
pool_count = 50
login_fail_exit = false

[Zealer-PEK-SIN_1]
type = tcp
local_ip = sg.sorocky.com
local_port = 22220
remote_port = 22221

[Zealer-PEK-SJC_1]
type = tcp
local_ip = sorocky.com
local_port = 22221
remote_port = 22231
EOF

cat > ./frp/frpc.ini << EOF
[common]
#server_addr = my.qxin.info
server_addr = xinxin8816.3322.org
server_port = 8001
tcp_mux     = false
tls_enable = false
protocol = tcp
token = xinxin8816
pool_count = 50
#heartbeat_interval = 1
login_fail_exit = false
dns_server = 8.8.8.8

[v2_1 VLESS]
type = tcp
local_ip = 127.0.0.1
local_port = 22222
remote_port = 22222

[v2_1 VMESS]
type = tcp
local_ip = 127.0.0.1
local_port = 22221
remote_port = 22232

#[Sanjose_443_1]
#type = https
#local_ip = sanjose.zeallr.com
#local_port = 443
#custom_domains = sanjose.zeallr.com
#plugin = https2https
#plugin_local_addr = sanjose.zeallr.com
#plugin_crt_path = ./domain.crt
#plugin_key_path = ./domain.key

#[Odyssey_443_1]
#type = https
#local_ip = odyssey.zeallr.com
#local_port = 443
#custom_domains = odyssey.zeallr.com

#[Ngrok_1]
#type = tcp
#local_ip = 127.0.0.1
#local_port = 4040
#remote_port = 40402

#[m2_1]
#type = tcp
#local_ip = 127.0.0.1
#local_port = 22221
#remote_port = 22232

#[SGNF Trojan]
#type = tcp
#local_ip = $NETFLIX_IP
#local_port = 22221
#remote_port = 30002
EOF

cd frp
chmod +x ./frpc
#./frpc -c frpc.ini&
#./frpc -c frpcforsorocky.ini&
./frpc -c frpcfororacle.ini&
#wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/2.52/nf_2.52_linux_amd64 && chmod +x nf && ./nf -method full
#cat /etc/v2ray/config.json
#sudo /usr/bin/v2ray/v2ray -config /etc/v2ray/config.json

cd ..
./rathole --client rathole.toml&
wget https://github.com/xinxin8816/ngrok/releases/download/1/ngrok
chmod 777 ./ngrok

cat > ./ding.cfg << EOF
server_addr: "vaiwan.com:443"
inspect_addr: disabled
trust_host_root_certs: true
EOF

cat > ./easydown.yml << EOF
tunnel: aliflow
credentials-file: ./1234.json
protocol: http2
originRequest:
  connectTimeout: 30s
  noTLSVerify: true
ingress:
  - hostname: sorocky.goog.pp.ua
    service: https://sorocky.com:22301
  - hostname: aliflow.goog.pp.ua
    service: http://127.0.0.1:22220
  - service: http_status:404
EOF

wget -O 1234.json -q https://github.com/cixxs/v2ray/releases/download/v2.21/2a07cc65-9297-4521-8dd2-50dd87d32093.json
wget -O cloudflared -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x ./cloudflared
./cloudflared tunnel --config easydown.yml run&

sudo ./ngrok -config=./ding.cfg -subdomain=aligaba2 22221&
#sudo ./ngrok -config=./ding.cfg -subdomain=emby 129.146.81.146:8096&

cat > /root/workspace/code/config.json << EOF
{
    "dns":{
        "servers":[
            "8.8.8.8",
            "8.8.4.4"
        ],
        "tag":"dns_inbound"
    },
    "inbounds":[
        {
            "port":22222,
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"e55c8d17-2cf3-b21a-bcf1-eeacb011ed79",
                        "flow":"xtls-rprx-vision"
                    }
                ],
                "decryption":"none"
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls"
                ]
            },
            "streamSettings":{
                "network":"tcp",
                "security":"reality",
                "realitySettings":{
                    "show":false,
                    "dest":"www.microsoft.com:443",
                    "serverNames":[
                        "www.microsoft.com"
                    ],
                    "privateKey":"GMpD9poxqOGY3t6zKSmTZvnNg7gf9n_BNV7B8aqbGmU",
                    "shortIds":[
                        "",
                        "0123456789abcdef"
                    ]
                }
            }
        },
        {
            "port":22221,
            "protocol":"vmess",
            "settings":{
                "clients":[
                    {
                        "id":"e55c8d17-2cf3-b21a-bcf1-eeacb011ed79"
                    }
                ]
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls"
                ]
            },
            "streamSettings":{
                "network":"ws",
                "security":"tls",
                "tlsSettings":{
                    "certificates":[
                        {
                            "certificate":[
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
                            "key":[
                                "-----BEGIN RSA PRIVATE KEY-----",
                                "MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgapMlsYo3znIrhLEM",
                                "EftzObwPNyUP7AwyMBetYS+uOtShRANCAARqazjkfU0dDrOu75YFuY2RPzm/DaOb",
                                "7AhAQ3yLaAr6DJ7RA47cAZxZQGOBFXA3IyBC5zv9dmAsfZ6A51WDsz44",
                                "-----END RSA PRIVATE KEY-----"
                            ]
                        }
                    ]
                }
            }
        },
        {
            "port":22220,
            "protocol":"vmess",
            "settings":{
                "clients":[
                    {
                        "id":"e55c8d17-2cf3-b21a-bcf1-eeacb011ed79"
                    }
                ]
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls"
                ]
            },
            "streamSettings":{
                "network":"ws"
            }
        }
    ],
    "outbounds":[
        {
            "tag":"GoNetflix",
            "protocol":"vmess",
            "streamSettings":{
                "network":"ws",
                "security":"tls",
                "tlsSettings":{
                    "allowInsecure":false
                },
                "wsSettings":{
                    "path":"ws"
                }
            },
            "mux":{
                "enabled":true,
                "concurrency":8
            },
            "settings":{
                "vnext":[
                    {
                        "address":"free-sg-01.unblocknetflix.cf",
                        "port":443,
                        "users":[
                            {
                                "id":"402d7490-6d4b-42d4-80ed-e681b0e6f1f9",
                                "security":"auto",
                                "alterId":0
                            }
                        ]
                    }
                ]
            }
        },
        {
            "tag":"IPv4_out",
            "protocol":"freedom"
        },
        {
            "tag":"enterprise",
            "protocol":"vmess",
            "settings":{
                "vnext":[
                    {
                        "address":"sorocky.com",
                        "port":4001,
                        "users":[
                            {
                                "id":"e55c8d17-2cf3-b21a-bcf1-eeacb011ed79",
                                "alterId":0,
                                "email":"Zealer",
                                "security":"auto"
                            }
                        ]
                    }
                ]
            },
            "streamSettings":{
                "network":"tcp"
            },
            "mux":{
                "enabled":false,
                "concurrency":-1
            }
        },
        {
            "tag":"NF_out",
            "protocol":"freedom",
            "settings":{
                "domainStrategy":"UseIP"
            }
        },
        {
            "tag":"netmusic_out",
            "protocol":"http",
            "settings":{
                "servers":[
                    {
                        "address":"sg.sorocky.com",
                        "port":8080
                    }
                ]
            }
        }
    ],
    "routing":{
        "domainStrategy":"IPIfNonMatch",
        "rules":[
            {
                "type":"field",
                "outboundTag":"enterprise",
                "domain":[
                    "geosite:youtube"
                ]
            },
            {
                "type":"field",
                "outboundTag":"IPv4_out",
                "domain":[
                    "geosite:netflix"
                ]
            },
            {
                "type":"field",
                "outboundTag":"IPv4_out",
                "ip":[
                    "0.0.0.0/0"
                ]
            },
            {
                "type":"field",
                "outboundTag":"enterprise",
                "domain":[
                    "openai.com"
                ]
            },
            {
                "type":"field",
                "outboundTag":"netmusic_out",
                "domain":[
                    "music.163.com",
                    "music.126.net"
                ]
            },
            {
                "type":"field",
                "outboundTag":"IPv4_out",
                "ip":[
                    "::/0"
                ]
            },
            {
                "type":"field",
                "outboundTag":"IPv4_out",
                "inboundTag":[
                    "dns_inbound"
                ]
            }
        ]
    }
}
EOF

sudo /root/workspace/code/xray run -config /root/workspace/code/config.json
