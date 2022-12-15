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
NOLUS_PORT=45
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export NOLUS_CHAIN_ID=nolus-rila" >> $HOME/.bash_profile
echo "export NOLUS_PORT=${NOLUS_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$NOLUS_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$NOLUS_PORT\e[0m"
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
cd $HOME
wget -O go1.19.2.linux-amd64.tar.gz https://golang.org/dl/go1.19.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.2.linux-amd64.tar.gz && rm go1.19.2.linux-amd64.tar.gz
echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile
go version
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME && rm -rf nolus-core
git clone https://github.com/Nolus-Protocol/nolus-core
cd nolus-core
git checkout v0.1.39
make install

# config
nolusd config chain-id $NOLUS_CHAIN_ID
nolusd config keyring-backend test
nolusd config node tcp://localhost:${NOLUS_PORT}657

# init
nolusd init $NODENAME --chain-id $NOLUS_CHAIN_ID

# download genesis
wget -qO $HOME/.nolus/config/genesis.json wget "https://raw.githubusercontent.com/Nolus-Protocol/nolus-networks/main/testnet/nolus-rila/genesis.json"

# set peers and seeds
SEEDS=""
PEERS="17cc34fc4a5c91e67bc7e11b9c15cad10dd11336@138.201.221.94:26656,fd13b67b442e1798c4fc3ecc8a81513de149552e@213.239.215.77:34656,1a0bb6c35e2663202535d4b849ff06250762d299@213.239.216.252:35656,33d485f51f413fd4bf83ef8a971c10228a39cffb@62.171.161.172:26656,b6c8dc38a5dba19a3f10d23b3572065db9265fa3@65.109.85.225:9000,3043450abbb1026c2e73d8a2549ee2e395ea5454@65.108.78.41:36656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:43656,785789b6574c45b8cfefff08344fdfeda345c7e1@135.125.5.34:55666,3c4f8aa4bf226c331b32d93f51f089e47e753279@194.163.155.84:36656,81944abef95fcc39da818c458f0e0afab41d2f81@65.109.131.71:56656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.nolus/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NOLUS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NOLUS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NOLUS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NOLUS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NOLUS_PORT}660\"%" $HOME/.nolus/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NOLUS_PORT}317\"%; s%^address = \":8080\"%address = \":${NOLUS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NOLUS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NOLUS_PORT}091\"%" $HOME/.nolus/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.nolus/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.nolus/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.nolus/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.nolus/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025unls\"/" $HOME/.nolus/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.nolus/config/config.toml

# reset
nolusd tendermint unsafe-reset-all --home $HOME/.nolus

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/nolusd.service > /dev/null <<EOF
[Unit]
Description=nolus
After=network-online.target

[Service]
User=$USER
ExecStart=$(which nolusd) start --home $HOME/.nolus
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable nolusd
sudo systemctl restart nolusd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u nolusd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${NOLUS_PORT}657/status | jq .result.sync_info\e[0m"
