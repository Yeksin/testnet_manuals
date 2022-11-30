<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/200304455-120e6b06-2785-4c4f-8fc7-e9ef39dd653e.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/200304348-3539ebf8-e4f7-4b73-a259-35d06c41441e.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/204880127-32a167db-5282-4a8c-915b-d68f9f1a2cfd.png">
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
LOYAL_PORT=44
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export LOYAL_CHAIN_ID=loyal-1" >> $HOME/.bash_profile
echo "export LOYAL_PORT=${LOYAL_PORT}" >> $HOME/.bash_profile
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
cd $HOME && rm -rf loyal
git clone https://github.com/LoyalLabs/loyal.git
cd loyal
git checkout v0.25.1.3
make install
```

## Config app
```
loyald config chain-id $LOYAL_CHAIN_ID
loyald config keyring-backend test
loyald config node tcp://localhost:${LOYAL_PORT}657
```

## Init app
```
loyald init $NODENAME --chain-id $LOYAL_CHAIN_ID
```

## Download genesis
```
curl -s https://raw.githubusercontent.com/LoyalLabs/net/main/mainnet/genesis.json | jq -r .result.genesis > $HOME/.loyal/config/genesis.json
```

## Set seeds and peers
```
SEEDS="7490c272d1c9db40b7b9b61b0df3bb4365cb63a6@loyal-seed.netdots.net:26656,b66ecdf36bb19a9af0460b3ae0901aece93ae006@pubnode1.joinloyal.io:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.loyal/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${LOYAL_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${LOYAL_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${LOYAL_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${LOYAL_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${LOYAL_PORT}660\"%" $HOME/.loyal/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${LOYAL_PORT}317\"%; s%^address = \":8080\"%address = \":${LOYAL_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${LOYAL_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${LOYAL_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${LOYAL_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${LOYAL_PORT}546\"%" $HOME/.loyal/config/app.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.loyal/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.loyal/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.loyal/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.loyal/config/app.toml
```

## Set minimum gas price and timeout commit
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ulyl\"/" $HOME/.loyal/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.loyal/config/config.toml
```

## Reset chain data
```
loyald tendermint unsafe-reset-all --home $HOME/.loyal
```

## Create service
```
sudo tee /etc/systemd/system/loyald.service > /dev/null <<EOF
[Unit]
Description=nibi
After=network-online.target

[Service]
User=$USER
ExecStart=$(which loyald) start --home $HOME/.loyal
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
sudo systemctl enable loyald
sudo systemctl restart loyald && sudo journalctl -u loyald -f -o cat
```
