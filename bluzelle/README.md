<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/220400984-d27a7ba7-4847-45ba-b3a0-873ec808fefa.png">
</p>

# Bluzelle node setup for bluzelle-8

### Yeksin Services for Bluzelle: (Snapshots, State-Sync, Addrbook File, Live Peers and Cheatsheet)
- https://www.yeksin.net/bluzelle

Official documentation:
- https://docs.bluzelle.com/developers

Explorer:
- https://explorers.yeksin.net/bluzelle

API:
- https://bluzelle.api.yeksin.net

RPC:
- https://bluzelle.rpc.yeksin.net

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
wget https://golang.org/dl/go1.17.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.17.linux-amd64.tar.gz
rm go1.17.linux-amd64.tar.gz

echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile

```

## Download and build binaries
```
cd $HOME
git clone https://github.com/bluzelle/bluzelle-public bluzelle
cd bluzelle
git checkout 7bc61cc3ffe0cc90228b10a4db11f678d1db1160
cd curium
ignite chain serve

```

## Create service
```
sudo tee /etc/systemd/system/curiumd.service > /dev/null <<EOF
[Unit]
Description=Bluzelle Network Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which curiumd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable curiumd

```

## Config app
```
echo "export BLUZELLE_CHAIN_ID=bluzelle-8" >> $HOME/.bash_profile
source $HOME/.bash_profile

curiumd config chain-id $BLUZELLE_CHAIN_ID
curiumd config keyring-backend test
curiumd init $NODENAME --chain-id $BLUZELLE_CHAIN_ID

```

## Download genesis and Addrbook (updates every: 1h)
```
wget https://snapshot.yeksin.net/bluzelle/genesis.json -O $HOME/.curium/config/genesis.json
wget https://snapshot.yeksin.net/bluzelle/addrbook.json -O $HOME/.curium/config/addrbook.json

```

## Set seeds and peers
```
SEEDS=""
PEERS="d3150799a6be2561ed6df3e266264140a6e2514d@35.158.183.94:26656,ec45a9687a7aa8c3aeebe1d135d255c450e5ad02@13.57.179.7:26656,ecec40366517cafc9db0b638ebab28ad6344a2f4@18.143.156.117:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.curium/config/config.toml

```

## Config pruning, set minimum gas price
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.curium/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.curium/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.curium/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.curium/config/app.toml

sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ubnt\"/" $HOME/.curium/config/app.toml

```

## Download Snapshot
```
curl -L https://snapshot.yeksin.net/bluzelle/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.curium

```

## Start service
```
sudo systemctl restart curiumd

```

## Check logs
```
sudo journalctl -u curiumd -f -o cat

```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
curiumd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
curiumd keys add $WALLET --recover
```

To get current list of wallets
```
curiumd keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
BLUZELLE_WALLET_ADDRESS=$(curiumd keys show $WALLET -a)
BLUZELLE_VALOPER_ADDRESS=$(curiumd keys show $WALLET --bech val -a)
echo 'export BLUZELLE_WALLET_ADDRESS='${BLUZELLE_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export BLUZELLE_VALOPER_ADDRESS='${BLUZELLE_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Create validator
Before creating validator please make sure that you have at least 1 bnt (1 bnt is equal to 1000000 ubnt) and your node is synchronized

To check your wallet balance:
```
curiumd query bank balances $BLUZELLE_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
curiumd tx staking create-validator \
  --amount 1000000ubnt \
  --commission-max-change-rate 0.01 \
  --commission-max-rate 0.2 \
  --commission-rate 0.1 \
  --from $WALLET \
  --min-self-delegation 1 \
  --moniker $NODENAME \
  --pubkey $(curiumd tendermint show-validator) \
  --chain-id bluzelle-8 \
  -y
```

# Check Cheatsheet
- https://www.yeksin.net/bluzelle/cheatsheet


