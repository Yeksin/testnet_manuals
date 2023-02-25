<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/221384811-83089cb9-6eee-47ad-9426-b1560abb5b82.png">
</p>

# Coreum node setup for coreum-testnet-1

### Yeksin Services for Coreum: (Snapshots, State-Sync, Addrbook File, Live Peers and Cheatsheet)
- https://www.yeksin.net/coreum

Official documentation:
- https://docs.coreum.dev/overview/introduction.html

Explorer:
- https://explorers.yeksin.net/coreum-testnet

API:
- https://coreum.api.yeksin.net

RPC:
- https://coreum.rpc.yeksin.net

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


# Installation
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
cd
wget https://github.com/CoreumFoundation/coreum/releases/download/v0.1.1/cored-linux-amd64
sudo chmod +x cored-linux-amd64
mkdir -p $HOME/go/bin
sudo mv cored-linux-amd64 $HOME/go/bin/cored

```

## Create service
```
sudo tee /etc/systemd/system/cored.service > /dev/null <<EOF
[Unit]
Description=Coreum Network Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cored) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable cored

```

## Config app
```
COREUM_PORT=42
echo "export COREUM_CHAIN_ID=coreum-testnet-1" >> $HOME/.bash_profile
echo "export COREUM_PORT=${COREUM_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

cored config chain-id $COREUM_CHAIN_ID
cored config keyring-backend test
cored config node tcp://localhost:${COREUM_PORT}657
cored init $NODENAME --chain-id $COREUM_CHAIN_ID

```

## Download genesis and Addrbook (updates every: 1h)
```
wget https://snapshot.yeksin.net/coreum/genesis.json -O $HOME/.core/coreum-testnet-1/config/genesis.json
wget https://snapshot.yeksin.net/coreum/addrbook.json -O $HOME/.core/coreum-testnet-1/config/addrbook.json

```

## Set seeds and peers
```
SEEDS=""
PEERS="1550478b6d7f4bd520e3d7499c7fd4c6e2b28c83@51.89.7.237:26654,77fedae18b48c8348b9fde0a2bdc4fb1bb0d0c17@65.109.93.152:30656,39a34cd4f1e908a88a726b2444c6a407f67e4229@158.160.59.199:26656,0aa5fa2507ada8a555d156920c0b09f0d633b0f9@34.173.227.148:26656,479773376706c0643289a365e84e440cced10bb9@146.190.81.135:21656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.core/coreum-testnet-1/config/config.toml

```

## Config pruning, set minimum gas price
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.core/coreum-testnet-1/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.core/coreum-testnet-1/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.core/coreum-testnet-1/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.core/coreum-testnet-1/config/app.toml

sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utestcore\"/" $HOME/.core/coreum-testnet-1/config/app.toml

```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${COREUM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${COREUM_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${COREUM_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${COREUM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${COREUM_PORT}660\"%" $HOME/.core/coreum-testnet-1/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${COREUM_PORT}317\"%; s%^address = \":8080\"%address = \":${COREUM_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${COREUM_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${COREUM_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${COREUM_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${COREUM_PORT}546\"%" $HOME/.core/coreum-testnet-1/config/app.toml

```

## Download Snapshot
```
curl -L https://snapshot.yeksin.net/coreum/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.core/coreum-testnet-1

```

## Start service
```
sudo systemctl restart cored

```

## Check logs
```
sudo journalctl -u cored -f -o cat

```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
cored keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
cored keys add $WALLET --recover
```

To get current list of wallets
```
cored keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
COREUM_WALLET_ADDRESS=$(cored keys show $WALLET -a)
COREUM_VALOPER_ADDRESS=$(cored keys show $WALLET --bech val -a)
echo 'export COREUM_WALLET_ADDRESS='${COREUM_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export COREUM_VALOPER_ADDRESS='${COREUM_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Create validator
Before creating validator please make sure that you have at least 1 testcore (1 testcore is equal to 1000000 utestcore) and your node is synchronized

To check your wallet balance:
```
cored query bank balances $COREUM_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
cored tx staking create-validator \
  --amount 20000000000utestcore  \
  --commission-max-change-rate 0.01 \
  --commission-max-rate 0.2 \
  --commission-rate 0.1 \
  --min-self-delegation="20000000000" \
  --from $WALLET \
  --min-self-delegation 1 \
  --moniker $NODENAME \
  --pubkey $(cored tendermint show-validator) \
  --chain-id coreum-testnet-1 \
  -y
```

# Check Cheatsheet
- https://www.yeksin.net/coreum/cheatsheet


