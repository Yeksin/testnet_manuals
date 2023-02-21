<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/220418605-7a3184ad-9599-4bb3-9a16-b0ca6512bda6.png">
</p>

# Nibiru node setup for nibiru-testnet-2

### Yeksin Services for Nibiru Protocol: (Snapshots, State-Sync, Addrbook File, Live Peers and Cheatsheet)
- https://www.yeksin.net/nibiru

Official documentation:
- https://nibiru.fi/docs

Explorer:
- https://explorers.yeksin.net/nibiru-testnet

API:
- https://nibiru.api.yeksin.net

RPC:
- https://nibiru.rpc.yeksin.net

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

#  Installation

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
cd $HOME && rm -rf nibiru
git clone https://github.com/NibiruChain/nibiru
cd nibiru 
git checkout v0.16.3
make install

```

## Create service
```
sudo tee /etc/systemd/system/nibid.service > /dev/null <<EOF
[Unit]
Description= Nibiru Network Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which nibid) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nibid

```

## Config app
```
NIBIRU_PORT=41
echo "export NIBIRU_CHAIN_ID=nibiru-testnet-2" >> $HOME/.bash_profile
echo "export NIBIRU_PORT=${NIBIRU_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

nibid config chain-id $NIBIRU_CHAIN_ID
nibid config keyring-backend test
nibid config node tcp://localhost:${NIBIRU_PORT}657
nibid init $NODENAME --chain-id $NIBIRU_CHAIN_ID

```

## Download genesis and Addrbook (updates every: 1h)
```
wget https://snapshot.yeksin.net/nibiru/genesis.json -O $HOME/.nibid/config/genesis.json
wget https://snapshot.yeksin.net/nibiru/addrbook.json -O $HOME/.nibid/config/addrbook.json

```

## Set seeds and peers
```
SEEDS="dabcc13d6274f4dd86fd757c5c4a632f5062f817@seed-2.nibiru-testnet-2.nibiru.fi:26656,a5383b33a6086083a179f6de3c51434c5d81c69d@seed-1.nibiru-testnet-2.nibiru.fi:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.nibid/config/config.toml

```

## Config pruning, set minimum gas price, enable prometheus and reset chain data
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.nibid/config/app.toml

sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0unibi\"/" $HOME/.nibid/config/app.toml

```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NIBIRU_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NIBIRU_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NIBIRU_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NIBIRU_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NIBIRU_PORT}660\"%" $HOME/.nibid/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NIBIRU_PORT}317\"%; s%^address = \":8080\"%address = \":${NIBIRU_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NIBIRU_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NIBIRU_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${NIBIRU_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${NIBIRU_PORT}546\"%" $HOME/.nibid/config/app.toml

```

## Download Snapshot
```
curl -L https://snapshot.yeksin.net/nibiru/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.nibid

```

## Start service
```
sudo systemctl start nibid

```

## Check logs
```
sudo journalctl -u nibid -f -o cat

```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
nibid keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
nibid keys add $WALLET --recover
```

To get current list of wallets
```
nibid keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
NIBIRU_WALLET_ADDRESS=$(nibid keys show $WALLET -a)
NIBIRU_VALOPER_ADDRESS=$(nibid keys show $WALLET --bech val -a)
echo 'export NIBIRU_WALLET_ADDRESS='${NIBIRU_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export NIBIRU_VALOPER_ADDRESS='${NIBIRU_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Create validator
Before creating validator please make sure that you have at least 1 tlore (1 tlore is equal to 1000000 unibi) and your node is synchronized

To check your wallet balance:
```
nibid query bank balances $NIBIRU_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
nibid tx staking create-validator \
  --amount 1000000unibi \
  --commission-max-change-rate 0.01 \
  --commission-max-rate 0.2 \
  --commission-rate 0.1 \
  --from $WALLET \
  --min-self-delegation 1 \
  --moniker $NODENAME \
  --pubkey $(nibid tendermint show-validator) \
  --chain-id nibiru-testnet-2 \
  -y
```

# Check Cheatsheet
- https://www.yeksin.net/nibiru/cheatsheet


