<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/221374434-add5383a-89b5-4d9e-90c8-023822a43467.png">
</p>

# Arkh node setup for arkh

### Yeksin Services for Arkh: (Snapshots, State-Sync, Addrbook File, Live Peers and Cheatsheet)
- https://www.yeksin.net/arkh


Explorer:
- https://explorers.yeksin.net/arkh

API:
- https://arkh.api.yeksin.net

RPC:
- https://arkh.rpc.yeksin.net

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
cd $HOME && rm -rf arkh-blockchain
git clone https://github.com/vincadian/arkh-blockchain.git && cd arkh-blockchain
git checkout v2.0.0
go install ./...

```

## Create service
```
sudo tee /etc/systemd/system/arkhd.service > /dev/null <<EOF
[Unit]
Description=Arkh Network Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which arkhd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable arkhd

```

## Config app
```
ARKH_PORT=43
echo "export ARKH_CHAIN_ID=arkh" >> $HOME/.bash_profile
echo "export ARKH_PORT=${ARKH_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

arkhd config chain-id $ARKH_CHAIN_ID
arkhd config keyring-backend test
arkhd config node tcp://localhost:${ARKH_PORT}657
arkhd init $NODENAME --chain-id $ARKH_CHAIN_ID

```

## Download genesis and Addrbook (updates every: 1h)
```
wget https://snapshot.yeksin.net/arkh/genesis.json -O $HOME/.arkh/config/genesis.json
wget https://snapshot.yeksin.net/arkh/addrbook.json -O $HOME/.arkh/config/addrbook.json

```

## Set seeds and peers
```
SEEDS="808f01d4a7507bf7478027a08d95c575e1b5fa3c@asc-dataseed.arkhadian.com:26656"
PEERS="889e31730df026e6cec506e26a0791368f8073a2@162.19.236.117:26656,1af8fdecd6e8f9ec1bfcc3288fe46ce45e4df963@144.76.97.251:39656,025336b4f1ce065e795421d7cc25bd361ddd16b2@46.101.144.90:25656,92b035580fdf4fa510d00a7bbccb107c1e611fb3@65.109.92.240:13756,b4f3bd0b9202be699635966978b44e5ea8ab9fba@34.173.89.239:26656,808f01d4a7507bf7478027a08d95c575e1b5fa3c@86.247.125.164:26656,f7b5d20f636fe7c2ec504662834b35b0cc56a742@194.163.165.174:37656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.arkh/config/config.toml

```

## Config pruning, set minimum gas price
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.arkh/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.arkh/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.arkh/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.arkh/config/app.toml

sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0arkh\"/" $HOME/.arkh/config/app.toml

```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${ARKH_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${ARKH_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${ARKH_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${ARKH_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${ARKH_PORT}660\"%" $HOME/.arkh/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${ARKH_PORT}317\"%; s%^address = \":8080\"%address = \":${ARKH_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${ARKH_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${ARKH_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${ARKH_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${ARKH_PORT}546\"%" $HOME/.arkh/config/app.toml

```

## Download Snapshot
```
curl -L https://snapshot.yeksin.net/arkh/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.arkh

```

## Start service
```
sudo systemctl restart arkhd

```

## Check logs
```
sudo journalctl -u arkhd -f -o cat

```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
arkhd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
arkhd keys add $WALLET --recover
```

To get current list of wallets
```
arkhd keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
ARKH_WALLET_ADDRESS=$(arkhd keys show $WALLET -a)
ARKH_VALOPER_ADDRESS=$(arkhd keys show $WALLET --bech val -a)
echo 'export ARKH_WALLET_ADDRESS='${ARKH_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export ARKH_VALOPER_ADDRESS='${ARKH_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Create validator

To check your wallet balance:
```
arkhd query bank balances $ARKH_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
arkhd tx staking create-validator \
  --amount 1000000arkh \
  --commission-max-change-rate 0.01 \
  --commission-max-rate 0.2 \
  --commission-rate 0.1 \
  --from $WALLET \
  --min-self-delegation 1 \
  --moniker $NODENAME \
  --pubkey $(arkhd tendermint show-validator) \
  --chain-id arkh \
  -y
```

# Check Cheatsheet
- https://www.yeksin.net/arkh/cheatsheet


