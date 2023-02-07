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
KYVE_PORT=24
echo "export KYVE_CHAIN_ID=kaon-1" >> $HOME/.bash_profile
echo "export KYVE_PORT=${KYVE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$KYVE_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$KYVE_PORT\e[0m"
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
cd $HOME
wget https://files.kyve.network/chain/v1.0.0-rc0/kyved_linux_amd64.tar.gz
tar -xvzf kyved_linux_amd64.tar.gz

sudo mv chaind kyved
sudo chmod +x kyved
sudo mv kyved $HOME/go/bin/kyved
rm kyved_linux_amd64.tar.gz

# config
kyved config chain-id $KYVE_CHAIN_ID
kyved config keyring-backend test
kyved config node tcp://localhost:${KYVE_PORT}657
kyved init $NODENAME --chain-id $KYVE_CHAIN_ID

# download genesis
wget https://snapshot.yeksin.net/kyve/genesis.json -O $HOME/.kyve/config/genesis.json

# download addrbook
wget https://snapshot.yeksin.net/kyve/addrbook.json -O $HOME/.kyve/config/addrbook.json

# set peers and seeds
SEEDS=""
PEERS="bc8b5fbb40a1b82dfba591035cb137278a21c57d@52.59.65.9:26656,801fa026c6d9227874eeaeba288eae3b800aad7f@52.29.15.250:26656,78d76da232b5a9a5648baa20b7bd95d7c7b9d249@142.93.161.118:26656,b68e5131552e40b9ee70427879eb34e146ef20df@18.194.131.3:26656,59addee10822d8cfe2c4635a404ab67687357449@141.95.33.158:26651,bbb7a427e04d38c74f574f6f0162e1359b66b330@93.115.25.18:39656,7258cf2c1867cc5b997baa19ff4a3e13681f14f4@68.183.143.17:26656,430845649afaad0a817bdf36da63b6f93bbd8bd1@3.67.29.225:26656,e8c9a0f07bc34fb870daaaef0b3da54dbf9c5a3b@15.235.10.35:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.kyve/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${KYVE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${KYVE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${KYVE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${KYVE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${KYVE_PORT}660\"%" $HOME/.kyve/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${KYVE_PORT}317\"%; s%^address = \":8080\"%address = \":${KYVE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${KYVE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${KYVE_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${KYVE_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${KYVE_PORT}546\"%" $HOME/.kyve/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.kyve/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.kyve/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.kyve/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.kyve/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0tkyve\"/" $HOME/.kyve/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.kyve/config/config.toml

# reset
kyved tendermint unsafe-reset-all --home $HOME/.kyve

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/kyved.service > /dev/null <<EOF
[Unit]
Description=Kyve Network Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which kyved) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable kyved
sudo systemctl restart kyved

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u kyved -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${KYVE_PORT}657/status | jq .result.sync_info\e[0m"
