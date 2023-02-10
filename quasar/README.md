<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/217306354-adaaa36e-b29e-4a81-802c-782e169eaa84.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/218180696-9c29403c-636e-4a4d-bfa1-f6936141a290.png">
</p>

# Quasar node setup for qsr-questnet-04

### Yeksin Services for Quasar Protocol: (Snapshots, State-Sync, Addrbook File, Live Peers and Cheatsheet)
- https://www.yeksin.net/quasar

Official documentation:
- https://docs.quasar.fi

Explorer:
- https://explorers.yeksin.net/quasar-testnet

API:
- https://quasar.api.yeksin.net

RPC:
- https://quasar.rpc.yeksin.net

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

## Set up your quasar node

# Automatic Installation
You can setup your quasar fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O quasar.sh https://raw.githubusercontent.com/yeksin/testnet_manuals/main/quasar/quasar.sh && chmod +x quasar.sh && ./quasar.sh

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
cd $HOME
wget https://github.com/quasar-finance/binary-release/raw/main/v0.0.2-alpha-11/quasarnoded-linux-amd64

sudo mv quasarnoded-linux-amd64 quasarnoded
sudo chmod +x quasarnoded
sudo mv quasarnoded $HOME/go/bin/quasarnoded
quasarnoded version # 0.0.2-alpha-11

```

## Create service
```
sudo tee /etc/systemd/system/quasarnoded.service > /dev/null <<EOF
[Unit]
Description= Quasar Network Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which quasarnoded) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable quasarnoded

```

## Config app
```
QUASAR_PORT=36
echo "export QUASAR_CHAIN_ID=qsr-questnet-04" >> $HOME/.bash_profile
echo "export QUASAR_PORT=${QUASAR_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

quasarnoded config chain-id $QUASAR_CHAIN_ID
quasarnoded config keyring-backend test
quasarnoded config node tcp://localhost:${QUASAR_PORT}657
quasarnoded init $NODENAME --chain-id $QUASAR_CHAIN_ID

```

## Download genesis and Addrbook (updates every: 1h)
```
wget https://snapshot.yeksin.net/quasar/genesis.json -O $HOME/.quasarnode/config/genesis.json
wget https://snapshot.yeksin.net/quasar/addrbook.json -O $HOME/.quasarnode/config/addrbook.json

```

## Set seeds and peers
```
SEEDS="7ed8e233e5fdb21bf70ac7f635130c7a8b0a4967@quasar-testnet-seed.swiss-staking.ch:10056"
PEERS="8a19aa6e874ed5720aad2e7d02567ec932d92d22@141.94.248.63:26656,444b80ce750976df59b88ac2e08d720e1dbbf230@68.183.75.239:26666,20b4f9207cdc9d0310399f848f057621f7251846@222.106.187.13:40606,7ef67269c8ec37ff8a538a5ae83ca670fd2da686@137.184.192.123:26656,19afe579cc0a2b38ca87143f779f45e9a7f18a2f@18.134.191.148:26656,a23f002bda10cb90fa441a9f2435802b35164441@38.146.3.203:18256,bba6e85e3d1f1d9c127324e71a982ddd86af9a99@88.99.3.158:18256,966acc999443bae0857604a9fce426b5e09a7409@65.108.105.48:18256 ,177144bed1e280a6f2435d253441e3e4f1699c6d@65.109.85.226:8090,769ebaa9942375e70cebc21a75a2cfda41049d99@135.181.210.186:26656,8937bdacf1f0c8b2d1ffb4606554eaf08bd55df4@5.75.255.107:26656,99a0695a7358fa520e6fcd46f91492f7cf205d4d@34.175.159.249:26656,47401f4ac3f934afad079ddbe4733e66b58b67da@34.175.244.202:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.quasarnode/config/config.toml

```

## Config pruning, set minimum gas price, enable prometheus and reset chain data
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.quasarnode/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.quasarnode/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.quasarnode/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.quasarnode/config/app.toml

sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.quasarnode/config/config.toml

```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${QUASAR_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${QUASAR_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${QUASAR_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${QUASAR_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${QUASAR_PORT}660\"%" $HOME/.quasarnode/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${QUASAR_PORT}317\"%; s%^address = \":8080\"%address = \":${QUASAR_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${QUASAR_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${QUASAR_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${QUASAR_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${QUASAR_PORT}546\"%" $HOME/.quasarnode/config/app.toml

```

## Download Snapshot
```
curl -L https://snapshot.yeksin.net/quasar/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.quasarnode

```

## Start service
```
sudo systemctl start quasarnoded

```

## Check logs
```
sudo journalctl -u quasarnoded -f -o cat

```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
quasarnoded keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
quasarnoded keys add $WALLET --recover
```

To get current list of wallets
```
quasarnoded keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
QUASAR_WALLET_ADDRESS=$(quasarnoded keys show $WALLET -a)
QUASAR_VALOPER_ADDRESS=$(quasarnoded keys show $WALLET --bech val -a)
echo 'export QUASAR_WALLET_ADDRESS='${QUASAR_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export QUASAR_VALOPER_ADDRESS='${QUASAR_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Create validator
Before creating validator please make sure that you have at least 1 tlore (1 tlore is equal to 1000000 uqsr) and your node is synchronized

To check your wallet balance:
```
quasarnoded query bank balances $QUASAR_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
quasarnoded tx staking create-validator \
  --amount 1000000uqsr \
  --commission-max-change-rate 0.01 \
  --commission-max-rate 0.2 \
  --commission-rate 0.1 \
  --from $WALLET \
  --min-self-delegation 1 \
  --moniker $NODENAME \
  --pubkey $(quasarnoded tendermint show-validator) \
  --chain-id qsr-questnet-04 \
  -y
```

# Check Cheatsheet
- https://www.yeksin.net/quasar/cheatsheet


