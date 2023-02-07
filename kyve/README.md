<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/217306354-adaaa36e-b29e-4a81-802c-782e169eaa84.png">
</p>

# Kyve node setup for kaon-1

### Yeksin Services for Kyve Protocol: (Snapshots, State-Sync, Addrbook File, Live Peers and Cheatsheet)
- https://www.yeksin.net/kyve

Official documentation:
- https://docs.kyve.network

Explorer:
- https://explorers.yeksin.net/kyve-testnet

API:
- https://kyve.api.yeksin.net

RPC:
- https://kyve.rpc.yeksin.net

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

## Set up your kyve node

# Automatic Installation
You can setup your kyve fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O kyve.sh https://raw.githubusercontent.com/yeksin/testnet_manuals/main/kyve/kyve.sh && chmod +x kyve.sh && ./kyve.sh

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
wget https://files.kyve.network/chain/v1.0.0-rc0/kyved_linux_amd64.tar.gz
tar -xvzf kyved_linux_amd64.tar.gz

sudo mv chaind kyved
sudo chmod +x kyved
sudo mv kyved $HOME/go/bin/kyved
rm kyved_linux_amd64.tar.gz

```

## Create service
```
sudo tee /etc/systemd/system/kyved.service > /dev/null <<EOF
[Unit]
Description= Kyve Network Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which kyved) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable kyved

```

## Config app
```
KYVE_PORT=24
echo "export KYVE_CHAIN_ID=kaon-1" >> $HOME/.bash_profile
echo "export KYVE_PORT=${KYVE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

kyved config chain-id $KYVE_CHAIN_ID
kyved config keyring-backend test
kyved config node tcp://localhost:${KYVE_PORT}657
kyved init $NODENAME --chain-id $KYVE_CHAIN_ID

```

## Download genesis and Addrbook (updates every: 1h)
```
wget https://snapshot.yeksin.net/kyve/genesis.json -O $HOME/.kyve/config/genesis.json
wget https://snapshot.yeksin.net/kyve/addrbook.json -O $HOME/.kyve/config/addrbook.json

```

## Set seeds and peers
```
SEEDS=""
PEERS="bc8b5fbb40a1b82dfba591035cb137278a21c57d@52.59.65.9:26656,801fa026c6d9227874eeaeba288eae3b800aad7f@52.29.15.250:26656,78d76da232b5a9a5648baa20b7bd95d7c7b9d249@142.93.161.118:26656,b68e5131552e40b9ee70427879eb34e146ef20df@18.194.131.3:26656,59addee10822d8cfe2c4635a404ab67687357449@141.95.33.158:26651,bbb7a427e04d38c74f574f6f0162e1359b66b330@93.115.25.18:39656,7258cf2c1867cc5b997baa19ff4a3e13681f14f4@68.183.143.17:26656,430845649afaad0a817bdf36da63b6f93bbd8bd1@3.67.29.225:26656,e8c9a0f07bc34fb870daaaef0b3da54dbf9c5a3b@15.235.10.35:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.kyve/config/config.toml

```

## Config pruning, set minimum gas price, enable prometheus and reset chain data
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.kyve/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.kyve/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.kyve/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.kyve/config/app.toml

sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0tkyve\"/" $HOME/.kyve/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.kyve/config/config.toml

```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${KYVE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${KYVE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${KYVE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${KYVE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${KYVE_PORT}660\"%" $HOME/.kyve/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${KYVE_PORT}317\"%; s%^address = \":8080\"%address = \":${KYVE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${KYVE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${KYVE_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${KYVE_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${KYVE_PORT}546\"%" $HOME/.kyve/config/app.toml

```

## Download Snapshot
```
curl -L https://snapshot.yeksin.net/kyve/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.kyve

```

## Start service
```
sudo systemctl start kyved

```

## Check logs
```
sudo journalctl -u kyved -f -o cat

```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
kyved keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
kyved keys add $WALLET --recover
```

To get current list of wallets
```
kyved keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
KYVE_WALLET_ADDRESS=$(kyved keys show $WALLET -a)
KYVE_VALOPER_ADDRESS=$(kyved keys show $WALLET --bech val -a)
echo 'export KYVE_WALLET_ADDRESS='${KYVE_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export KYVE_VALOPER_ADDRESS='${KYVE_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Create validator
Before creating validator please make sure that you have at least 1 tlore (1 tlore is equal to 1000000 tkyve) and your node is synchronized

To check your wallet balance:
```
kyved query bank balances $KYVE_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
kyved tx staking create-validator \
  --amount 1000000tkyve \
  --commission-max-change-rate 0.01 \
  --commission-max-rate 0.2 \
  --commission-rate 0.1 \
  --from $WALLET \
  --min-self-delegation 1 \
  --moniker $NODENAME \
  --pubkey $(kyved tendermint show-validator) \
  --chain-id kaon-1 \
  -y
```

# Check Cheatsheet
- https://www.yeksin.net/kyve/cheatsheet


