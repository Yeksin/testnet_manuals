# Manual node setup
If you want to setup fullnode manually follow the steps below

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
```

Save and import variables into system
```
OKP4_PORT=36
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export OKP4_CHAIN_ID=okp4-nemeton" >> $HOME/.bash_profile
echo "export OKP4_PORT=${OKP4_PORT}" >> $HOME/.bash_profile
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
cd $HOME
git clone https://github.com/okp4/okp4d.git
cd okp4d
git checkout v2.2.0
make install
```

## Config app
```
okp4d config chain-id $OKP4_CHAIN_ID
okp4d config keyring-backend test
okp4d config node tcp://localhost:${OKP4_PORT}657
```

## Init app
```
okp4d init $NODENAME --chain-id $OKP4_CHAIN_ID
```

## Download genesis and addrbook
```
wget -qO $HOME/.okp4d/config/genesis.json "https://raw.githubusercontent.com/okp4/networks/main/chains/nemeton/genesis.json"
```

## Set seeds and peers
```
SEEDS="8e1590558d8fede2f8c9405b7ef550ff455ce842@51.79.30.9:26656,bfffaf3b2c38292bd0aa2a3efe59f210f49b5793@51.91.208.71:26656,106c6974096ca8224f20a85396155979dbd2fb09@198.244.141.176:26656,a7f1dcf7441761b0e0e1f8c6fdc79d3904c22c01@38.242.150.63:36656"
PEERS="994c9398e55947b2f1f45f33fbdbffcbcad655db@okp4-testnet.nodejumper.io:29656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.okp4d/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${OKP4_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${OKP4_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${OKP4_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${OKP4_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${OKP4_PORT}660\"%" $HOME/.okp4d/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${OKP4_PORT}317\"%; s%^address = \":8080\"%address = \":${OKP4_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${OKP4_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${OKP4_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${OKP4_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${OKP4_PORT}546\"%" $HOME/.okp4d/config/app.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.okp4d/config/app.toml
```

## Set minimum gas price and timeout commit
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uknow\"/" $HOME/.okp4d/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.okp4d/config/config.toml
```

## Reset chain data
```
okp4d tendermint unsafe-reset-all --home $HOME/.okp4d
```

## Create service
```
sudo tee /etc/systemd/system/okp4d.service > /dev/null <<EOF
[Unit]
Description=okp4
After=network-online.target

[Service]
User=$USER
ExecStart=$(which okp4d) start --home $HOME/.okp4d
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

## Register and start service
```
sudo systemctl daemon-reload
sudo systemctl enable okp4d
sudo systemctl restart okp4d && sudo journalctl -u okp4d -f -o cat
```
