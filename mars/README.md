<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/212442135-e36db0d3-a46a-4fe0-b502-55950ccdfc3e.png">
</p>

# Mars node setup for mars-1

### Yeksin Services for Mars Protocol: (Snapshots, State-Sync, Addrbook File, Live Peers and Cheatsheet)
- https://www.yeksin.net/mars

Official documentation:
- https://validatordocs.marsprotocol.io/TfYZfjcaUzFmiAkWDf7P/develop/mars-cli/marsd

Explorer:
- https://explorers.yeksin.net/mars

API:
- https://mars.api.yeksin.net

RPC:
- https://mars.rpc.yeksin.net

## Hardware Requirements
Like any Cosmos-SDK chain, the hardware requirements are pretty modest.

### Minimum Hardware Requirements
- 4x CPUs; the faster clock speed the better
 - 8GB RAM
 - 100GB of storage (SSD or NVME)
 - Permanent Internet connection (traffic will be minimal during testnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

### Recommended Hardware Requirements 
 - 8x CPUs; the faster clock speed the better
 - 64GB RAM
 - 1TB of storage (SSD or NVME)
 - Permanent Internet connection (traffic will be minimal during testnet; 10Mbps will be plenty - for production at least 100Mbps is expected)

## Set up your mars node

# Automatic Installation
You can setup your mars fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O mars.sh https://raw.githubusercontent.com/yeksin/testnet_manuals/main/mars/mars.sh && chmod +x mars.sh && ./mars.sh

```

When installation is finished please load variables into system
```
source $HOME/.bash_profile

```

# Manual Installation
If you want to setup fullnode manually follow the steps below

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
```

## Update packages
```
sudo apt update && sudo apt upgrade -y

```

## Install dependencies
```
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl build-essential git wget jq make gcc tmux chrony lz4 unzip

```

## Install go
```
sudo rm -rvf /usr/local/go/
wget https://golang.org/dl/go1.19.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz
rm go1.19.3.linux-amd64.tar.gz

echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile

```

## Download and build binaries
```
cd $HOME && rm -rf hub
git clone https://github.com/mars-protocol/hub.git && cd hub
git checkout v1.0.0
make install

```

## Create service
```
sudo tee /etc/systemd/system/marsd.service > /dev/null <<EOF
[Unit]
Description=Mars Network Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which marsd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable marsd

```

## Config app
```
MARS_PORT=58
echo "export MARS_CHAIN_ID=mars-1" >> $HOME/.bash_profile
echo "export MARS_PORT=${MARS_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

marsd config chain-id $MARS_CHAIN_ID
marsd config keyring-backend test
marsd config node tcp://localhost:${MARS_PORT}657
marsd init $NODENAME --chain-id $MARS_CHAIN_ID

```

## Download genesis and Addrbook (updates every: 1h)
```
wget https://snapshot.yeksin.net/mars/genesis.json -O $HOME/.mars/config/genesis.json
wget https://snapshot.yeksin.net/mars/addrbook.json -O $HOME/.mars/config/addrbook.json

```

## Set seeds and peers
```
SEEDS=""
PEERS="b60d9649dd154c169dcf08f47af7c1528c159818@104.248.41.168:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.mars/config/config.toml

```

## Config pruning, set minimum gas price, enable prometheus and reset chain data
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.mars/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.mars/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.mars/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.mars/config/app.toml

sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0umars\"/" $HOME/.mars/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.mars/config/config.toml

```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${MARS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${MARS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${MARS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${MARS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${MARS_PORT}660\"%" $HOME/.mars/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${MARS_PORT}317\"%; s%^address = \":8080\"%address = \":${MARS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${MARS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${MARS_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${MARS_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${MARS_PORT}546\"%" $HOME/.mars/config/app.toml

```

## Download Snapshot
```
curl -L https://snapshot.yeksin.net/mars/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.mars

```

## Start service
```
sudo systemctl start marsd

```

## Check logs
```
sudo journalctl -u marsd -f -o cat

```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
marsd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
marsd keys add $WALLET --recover
```

To get current list of wallets
```
marsd keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
MARS_WALLET_ADDRESS=$(marsd keys show $WALLET -a)
MARS_VALOPER_ADDRESS=$(marsd keys show $WALLET --bech val -a)
echo 'export MARS_WALLET_ADDRESS='${MARS_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export MARS_VALOPER_ADDRESS='${MARS_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Create validator
Before creating validator please make sure that you have at least 1 tlore (1 tlore is equal to 1000000 umars) and your node is synchronized

To check your wallet balance:
```
marsd query bank balances $MARS_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
marsd tx staking create-validator \
  --amount 1000000umars \
  --commission-max-change-rate 0.01 \
  --commission-max-rate 0.2 \
  --commission-rate 0.1 \
  --from $WALLET \
  --min-self-delegation 1 \
  --moniker $NODENAME \
  --pubkey $(marsd tendermint show-validator) \
  --chain-id mars-1 \
  -y
```

# Check Cheatsheet
- https://www.yeksin.net/mars/cheatsheet

