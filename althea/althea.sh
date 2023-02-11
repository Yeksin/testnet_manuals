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
source $HOME/.bash_profile

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
cd $HOME && rm -rf althea
git clone https://github.com/althea-net/althea-chain.git althea
cd althea
git checkout v0.3.2
make install

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/althea.service > /dev/null <<EOF
[Unit]
Description=Althea Network Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which althea) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable althea

# config
ALTHEA_PORT=34
echo "export ALTHEA_CHAIN_ID=althea_7357-1" >> $HOME/.bash_profile
echo "export ALTHEA_PORT=${ALTHEA_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

althea config chain-id $ALTHEA_CHAIN_ID
althea config keyring-backend test
althea config node tcp://localhost:${ALTHEA_PORT}657
althea init $NODENAME --chain-id $ALTHEA_CHAIN_ID

# download genesis & addrbook
wget https://snapshot.yeksin.net/althea/genesis.json -O $HOME/.althea/config/genesis.json
wget https://snapshot.yeksin.net/althea/addrbook.json -O $HOME/.althea/config/addrbook.json

# set peers and seeds
SEEDS=""
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.althea/config/config.toml

# Config pruning, set minimum gas price, enable prometheus and reset chain data
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.althea/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.althea/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.althea/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.althea/config/app.toml

sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001ualthea\"/" $HOME/.althea/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.althea/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${ALTHEA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${ALTHEA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${ALTHEA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${ALTHEA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${ALTHEA_PORT}660\"%" $HOME/.althea/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${ALTHEA_PORT}317\"%; s%^address = \":8080\"%address = \":${ALTHEA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${ALTHEA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${ALTHEA_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${ALTHEA_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${ALTHEA_PORT}546\"%" $HOME/.althea/config/app.toml

# start service
sudo systemctl start althea

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u althea -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${ALTHEA_PORT}657/status | jq .result.sync_info\e[0m"

