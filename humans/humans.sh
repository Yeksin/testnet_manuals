#!/bin/bash

echo -e "\033[0;35m"
echo "                                                                -=*****+-.     :-+*###+. "
echo " ▓██   ██▓▓█████  ██ ▄█▀  ██████  ██▓ ███▄    █              -#*-.      :+#++%%#**@@@@@: "
echo "  ▒██  ██▒▓█   ▀  ██▄█▒ ▒██    ▒ ▓██▒ ██ ▀█   █            .#+             -%=    +@@%:  "
echo "   ▒██ ██░▒███   ▓███▄░ ░ ▓██▄   ▒██▒▓██  ▀█ ██▒          .@-               .%= .#@%=    "
echo "   ░ ▐██▓░▒▓█  ▄ ▓██ █▄   ▒   ██▒░██░▓██▒  ▐▌██▒          #+                 :@#@#-      "
echo "   ░ ██▒▓░░▒████▒▒██▒ █▄▒██████▒▒░██░▒██░   ▓██░          @:               .+%@+.        "
echo "    ██▒▒▒ ░░ ▒░ ░▒ ▒▒ ▓▒▒ ▒▓▒ ▒ ░░▓  ░ ▒░   ▒ ▒          .%=            .=%#=:@.         "
echo "  ▓██ ░▒░  ░ ░  ░░ ░▒ ▒░░ ░▒  ░ ░ ▒ ░░ ░░   ░ ▒░       -#%+@.        -+%#=.  #+          "
echo "  ▒ ▒ ░░     ░   ░ ░░ ░ ░  ░  ░   ▒ ░   ░   ░ ░      =@%:  -%-   -+#%+-    .#+           "
echo "  ░ ░        ░  ░░  ░         ░   ░           ░    -@@@-   .-@%%@*-.     -**:            "
echo "  ░ ░                                             -@@@@@%%@@#+-:+*******+-               "
echo "                                                  .+##*+=-.                    yeksin.net"
echo -e "\e[0m"

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
HUMANS_PORT=44
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export HUMANS_CHAIN_ID=testnet-1" >> $HOME/.bash_profile
echo "export HUMANS_PORT=${HUMANS_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$HUMANS_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$HUMANS_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download and build binaries
cd $HOME && rm -rf humans
git clone https://github.com/humansdotai/humans && cd humans
git pull
git fetch --tags
git checkout v1.0.0
make install

# config
humansd config chain-id $HUMANS_CHAIN_ID
humansd config keyring-backend test
humansd config node tcp://localhost:${HUMANS_PORT}657

# init
humansd init $NODENAME --chain-id $HUMANS_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.humans/config/genesis.json wget "https://snapshot.yeksin.net/humans/genesis.json"
wget -qO $HOME/.humans/config/addrbook.json wget "https://snapshot.yeksin.net/humans/addrbook.json"

# set peers and seeds
SEEDS=""
PEERS="09af742cbdb91cad85dad8d6cf17d2dc178fe4ba@167.235.97.139:26656,aac683209559ca9ea48de4c47f3806483a5ec13f@185.244.180.97:26656,bc0677f947c43f676b86fce1cfd063aa48580aad@172.104.76.251:26656,5e41a64298ca653af5297833c6a47eb1ad1bf367@154.38.161.212:36656,5e9a778625c2d4f2ffa0691f50342a58e8b9bfdd@45.136.40.14:26656,1df6735ac39c8f07ae5db31923a0d38ec6d1372b@45.136.40.6:26656,9726b7ba17ee87006055a9b7a45293bfd7b7f0fc@45.136.40.16:26656,1a06290cf2da4a2cf513036180d250035266b109@45.136.40.20:26656,6e84cde074d4af8a9df59d125db3bf8d6722a787@45.136.40.18:26656,6e7fb6dff31da195d4fd92cdfbf049fc0ddc8403@45.136.40.21:26656,4de8c8acccecc8e0bed4a218c2ef235ab68b5cf2@45.136.40.12:26656,0794ff9952e1b6c6ead96359fecc52932e115eab@45.136.40.15:26656,d55876bc04e363bbe68a7fb344dd65632e310f45@138.201.121.185:26668,9e83df8d212ae04fd67d24b9f45971887d28d423@65.109.85.170:45656,9a20e4a0c977950db219770c1523a1b6182af367@79.143.179.196:46656,eda3e2255f3c88f97673d61d6f37b243de34e9d9@45.136.40.13:26656,1802da0f18dcf6752ed789d81b4f5e003f80719b@45.136.40.19:26656,2cc7701b7d2a9e0384ad787061edd4e5e63357d3@65.109.34.41:26656,3f13ad6e8795479b051d147a5049bf4bd0a63817@65.108.142.47:22656,e9ba9556b7076a679ea117b44ef18eeb59dc8f61@45.136.40.17:26656,547e5c5573f9f3077abf87d942d5fe74be0548df@65.109.38.55:26656,2cc5eb1ce7fe9744a9938611e0f3a47d3cc8b195@65.109.54.15:15656,c39257353508f74c5028efa5b4290561580ac4c1@164.68.102.193:26656,fb41827ecf20d787b02a40c9b002c01c14a80245@81.196.190.108:20656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.humans/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${HUMANS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${HUMANS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${HUMANS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${HUMANS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${HUMANS_PORT}660\"%" $HOME/.humans/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${HUMANS_PORT}317\"%; s%^address = \":8080\"%address = \":${HUMANS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${HUMANS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${HUMANS_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${HUMANS_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${HUMANS_PORT}546\"%" $HOME/.humans/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.humans/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.humans/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.humans/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.humans/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uheart\"/" $HOME/.humans/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.humans/config/config.toml

# reset
humansd tendermint unsafe-reset-all --home $HOME/.humans

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/humansd.service > /dev/null <<EOF
[Unit]
Description=humansd
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which humansd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable humansd
sudo systemctl restart humansd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u humansd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${HUMANS_PORT}657/status | jq .result.sync_info\e[0m"
