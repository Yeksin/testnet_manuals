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
UPTICK_PORT=15
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export UPTICK_CHAIN_ID=uptick_7000-1" >> $HOME/.bash_profile
echo "export UPTICK_PORT=${UPTICK_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$UPTICK_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$UPTICK_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux -y

# install go
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
wget https://download.uptick.network/download/uptick/testnet/release/v0.2.3/v0.2.3.tar.gz --no-check-certificate
tar -zxvf v0.2.3.tar.gz
sudo chmod +x uptick-v0.2.3/linux/uptickd
sudo mv uptick-v0.2.3/linux/uptickd $HOME/go/bin/

# config
uptickd config chain-id $UPTICK_CHAIN_ID
uptickd config keyring-backend test
uptickd config node tcp://localhost:${UPTICK_PORT}657

# init
uptickd init $NODENAME --chain-id $UPTICK_CHAIN_ID

# download configuration
curl -o $HOME/.uptickd/config/genesis.json https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7000-1/genesis.json
curl -o $HOME/.uptickd/config/addrbook.json https://raw.githubusercontent.com/yeksinNodes/testnet_manuals/main/uptick/addrbook.json
curl -o $HOME/.uptickd/config/config.toml https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7000-1/config.toml
curl -o $HOME/.uptickd/config/app.toml https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7000-1/app.toml

# set peers and seeds
SEEDS=$(curl -sL https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7000-1/seeds.txt | tr '\n' ',')
PEERS=$(curl -sL https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7000-1/peers.txt | tr '\n' ',')
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.uptickd/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://0.0.0.0:26658\"%proxy_app = \"tcp://0.0.0.0:${UPTICK_PORT}658\"%; s%^laddr = \"tcp://0.0.0.0:26657\"%laddr = \"tcp://0.0.0.0:${UPTICK_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${UPTICK_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${UPTICK_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${UPTICK_PORT}660\"%" $HOME/.uptickd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${UPTICK_PORT}317\"%; s%^address = \":8080\"%address = \":${UPTICK_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${UPTICK_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${UPTICK_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${UPTICK_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${UPTICK_PORT}546\"%" $HOME/.uptickd/config/app.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.uptickd/config/config.toml

# config pruning
pruning="nothing"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.uptickd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.uptickd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.uptickd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.uptickd/config/app.toml

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0auptick\"/" $HOME/.uptickd/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.uptickd/config/config.toml

# restore data
cd  $HOME/.uptickd
rm -rf data
wget -O data.tar.gz https://download.uptick.network/download/uptick/testnet/node/data/data.tar.gz --no-check-certificate
tar -zxvf data.tar.gz
rm -rf data.tar.gz

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/uptickd.service > /dev/null <<EOF
[Unit]
Description=uptick
After=network-online.target

[Service]
User=$USER
ExecStart=$(which uptickd) start --home $HOME/.uptickd
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable uptickd
sudo systemctl restart uptickd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u uptickd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${UPTICK_PORT}657/status | jq .result.sync_info\e[0m"
