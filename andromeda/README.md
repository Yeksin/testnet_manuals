<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/218453220-c8c99caf-f10e-4101-a18e-1401b19b8900.png">
</p>

# Andromeda node setup for galileo-3

### Yeksin Services for Andromeda Protocol: (Snapshots, State-Sync, Addrbook File, Live Peers and Cheatsheet)
- https://www.yeksin.net/andromeda

Official documentation:
- https://docs.andromedaprotocol.io

Explorer:
- https://explorers.yeksin.net/andromeda-testnet

API:
- https://andromeda.api.yeksin.net

RPC:
- https://andromeda.rpc.yeksin.net

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


#Installation
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
cd $HOME && rm -rf andromedad
git clone https://github.com/andromedaprotocol/andromedad.git
cd andromedad
git checkout galileo-3-v1.1.0-beta1 
make install

```

## Create service
```
sudo tee /etc/systemd/system/andromedad.service > /dev/null <<EOF
[Unit]
Description= Andromeda Network Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which andromedad) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable andromedad

```

## Config app
```
ANDROMEDA_PORT=11
echo "export ANDROMEDA_CHAIN_ID=galileo-3" >> $HOME/.bash_profile
echo "export ANDROMEDA_PORT=${ANDROMEDA_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

andromedad config chain-id $ANDROMEDA_CHAIN_ID
andromedad config keyring-backend test
andromedad config node tcp://localhost:${ANDROMEDA_PORT}657
andromedad init $NODENAME --chain-id $ANDROMEDA_CHAIN_ID

```

## Download genesis and Addrbook (updates every: 1h)
```
wget https://snapshot.yeksin.net/andromeda/genesis.json -O $HOME/.andromedad/config/genesis.json
wget https://snapshot.yeksin.net/andromeda/addrbook.json -O $HOME/.andromedad/config/addrbook.json

```

## Set seeds and peers
```
SEEDS=""
PEERS="06d4ab2369406136c00a839efc30ea5df9acaf11@10.128.0.44:26656,43d667323445c8f4d450d5d5352f499fa04839a8@192.168.0.237:26656,29a9c5bfb54343d25c89d7119fade8b18201c503@192.168.101.79:26656,6006190d5a3a9686bbcce26abc79c7f3f868f43a@37.252.184.230:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.andromedad/config/config.toml

```

## Config pruning, set minimum gas price, enable prometheus and reset chain data
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.andromedad/config/app.toml

sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.andromedad/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uandr\"/" $HOME/.andromedad/config/app.toml

```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${ANDROMEDA_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${ANDROMEDA_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${ANDROMEDA_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${ANDROMEDA_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${ANDROMEDA_PORT}660\"%" $HOME/.andromedad/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${ANDROMEDA_PORT}317\"%; s%^address = \":8080\"%address = \":${ANDROMEDA_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${ANDROMEDA_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${ANDROMEDA_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${ANDROMEDA_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${ANDROMEDA_PORT}546\"%" $HOME/.andromedad/config/app.toml

```

## Download Snapshot
```
curl -L https://snapshot.yeksin.net/andromeda/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.andromedad

```

## Start service
```
sudo systemctl start andromedad

```

## Check logs
```
sudo journalctl -u andromedad -f -o cat

```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
andromedad keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
andromedad keys add $WALLET --recover
```

To get current list of wallets
```
andromedad keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
ANDROMEDA_WALLET_ADDRESS=$(andromedad keys show $WALLET -a)
ANDROMEDA_VALOPER_ADDRESS=$(andromedad keys show $WALLET --bech val -a)
echo 'export ANDROMEDA_WALLET_ADDRESS='${ANDROMEDA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export ANDROMEDA_VALOPER_ADDRESS='${ANDROMEDA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Create validator
Before creating validator please make sure that you have at least 1 tlore (1 tlore is equal to 100000 uandr) and your node is synchronized

To check your wallet balance:
```
andromedad query bank balances $ANDROMEDA_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
andromedad tx staking create-validator \
  --amount 100000uandr \
  --commission-max-change-rate 0.01 \
  --commission-max-rate 0.2 \
  --commission-rate 0.1 \
  --from $WALLET \
  --min-self-delegation 1 \
  --moniker $NODENAME \
  --pubkey $(andromedad tendermint show-validator) \
  --chain-id galileo-3 \
  -y
```

# Check Cheatsheet
- https://www.yeksin.net/andromeda/cheatsheet


