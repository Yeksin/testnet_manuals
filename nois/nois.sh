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
NOIS_PORT=54
echo "export NOIS_CHAIN_ID=nois-testnet-003" >> $HOME/.bash_profile
echo "export NOIS_PORT=${NOIS_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$NOIS_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$NOIS_PORT\e[0m"
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
cd $HOME && rm -rf full-node
git clone https://github.com/noislabs/full-node.git
cd full-node/full-node/ || return
git checkout nois-testnet-003
./build.sh
mkdir -p $HOME/go/bin
sudo mv out/noisd $HOME/go/bin/noisd
noisd version # 0.29.0-rc2

# config
noisd config chain-id $NOIS_CHAIN_ID
noisd config keyring-backend test
noisd config node tcp://localhost:${NOIS_PORT}657
noisd init $NODENAME --chain-id $NOIS_CHAIN_ID

# download genesis
wget https://snapshot.yeksin.net/nois/genesis.json -O $HOME/.noisd/config/genesis.json

# download addrbook
wget https://snapshot.yeksin.net/nois/addrbook.json -O $HOME/.noisd/config/addrbook.json

# set peers and seeds
SEEDS=""
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.noisd/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NOIS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NOIS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NOIS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NOIS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NOIS_PORT}660\"%" $HOME/.noisd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NOIS_PORT}317\"%; s%^address = \":8080\"%address = \":${NOIS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NOIS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NOIS_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${NOIS_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${NOIS_PORT}546\"%" $HOME/.noisd/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.noisd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.noisd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.noisd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.noisd/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.noisd/config/config.toml

# reset
noisd tendermint unsafe-reset-all --home $HOME/.noisd

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/noisd.service > /dev/null <<EOF
[Unit]
Description=Nois Network Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which noisd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable noisd
sudo systemctl restart noisd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u noisd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${NOIS_PORT}657/status | jq .result.sync_info\e[0m"
