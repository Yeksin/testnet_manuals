<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/200304455-120e6b06-2785-4c4f-8fc7-e9ef39dd653e.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/200304348-3539ebf8-e4f7-4b73-a259-35d06c41441e.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/206032279-754840e1-56e2-447e-ba51-4977e3e703db.png">
</p>

# Manual node setup
If you want to setup fullnode manually follow the steps below

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
```

Save and import variables into system
```
REALIO_PORT=52
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export REALIO_CHAIN_ID=realionetwork_1110-2" >> $HOME/.bash_profile
echo "export REALIO_PORT=${REALIO_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Update packages
```
sudo apt update && sudo apt upgrade -y
```

## Install dependencies
```
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y
```

## Install go
```
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
```

## Download and build binaries
```
cd $HOME && rm -rf realio-network
git clone https://github.com/realiotech/realio-network.git && cd realio-network
git checkout v0.6.2
make install
```

## Config app
```
realio-networkd config chain-id $REALIO_CHAIN_ID
realio-networkd config keyring-backend test
realio-networkd config node tcp://localhost:${REALIO_PORT}657
```

## Init app
```
realio-networkd init $NODENAME --chain-id $REALIO_CHAIN_ID
```

## Download genesis
```
wget https://raw.githubusercontent.com/realiotech/testnets/main/realionetwork_1110-2/genesis.json -O $HOME/.realio-network/config/genesis.json
```

## Set seeds and peers
```
SEEDS="aa194e9f9add331ee8ba15d2c3d8860c5a50713f@143.110.230.177:26656"
PEERS="ecfd533285802f97ba35138cccc095d296afbc4c@65.108.79.57:55656,aa194e9f9add331ee8ba15d2c3d8860c5a50713f@143.110.230.177:26656,b951522911e62334b6e08c65d996699088957967@194.163.165.176:36656,3bd4080934277762848e8bbd126d2eaccb7cbffc@135.181.20.30:46656,704eb376ec58ce6b4d1df7dfd7f0be7e79d5f200@65.108.142.47:26556,a7dbc9d642bb838951c52362411af6e7ced67e25@realio.peer.stavr.tech:21096,1e7e1faf277d19df05facebe2a7e403044662234@213.239.217.52:37656,cc3826b4acd943cd104dea8af70d1e598b803dc6@75.119.130.18:12656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.realio-network/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${REALIO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${REALIO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${REALIO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${REALIO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${REALIO_PORT}660\"%" $HOME/.realio-network/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${REALIO_PORT}317\"%; s%^address = \":8080\"%address = \":${REALIO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${REALIO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${REALIO_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${REALIO_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${REALIO_PORT}546\"%" $HOME/.realio-network/config/app.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.realio-network/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.realio-network/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.realio-network/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.realio-network/config/app.toml
```

## Set minimum gas price and timeout commit
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ario\"/" $HOME/.realio-network/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.realio-network/config/config.toml
```

## Reset chain data
```
realio-networkd tendermint unsafe-reset-all --home $HOME/.realio-network
```

## Create service
```
sudo tee /etc/systemd/system/realio-networkd.service > /dev/null <<EOF
[Unit]
Description=realio-networkd
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which realio-networkd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

## Register and start service
```
sudo systemctl daemon-reload
sudo systemctl enable realio-networkd
sudo systemctl restart realio-networkd && sudo journalctl -u realio-networkd -f -o cat
```
