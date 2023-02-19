<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/219962275-78b256db-2fb4-4081-bdd8-78e559ce23c3.png">
</p>

# 8ball node setup for eightball-1

### Yeksin Services for 8ball Protocol: (Snapshots, State-Sync, Addrbook File, Live Peers and Cheatsheet)
- https://www.yeksin.net/8ball

Explorer:
- https://explorers.yeksin.net/8ball

API:
- https://8ball.api.yeksin.net

RPC:
- https://8ball.rpc.yeksin.net

## System Requirements

### Ubuntu 22.04

## Set up your 8Ball node

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
cd $HOME
wget https://8ball.info/8ball.tar.gz
tar -xvzf 8ball.tar.gz

sudo chmod +x 8ball
sudo mv 8ball /usr/local/bin/
rm 8ball.tar.gz

```

## Create service
```
sudo tee /etc/systemd/system/8ball.service > /dev/null <<EOF
[Unit]
Description= 8Ball Network Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which 8ball) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable 8ball

```

## Config app
```
BALL_PORT=40
echo "export BALL_CHAIN_ID=eightball-1" >> $HOME/.bash_profile
echo "export BALL_PORT=${BALL_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

8ball config chain-id $BALL_CHAIN_ID
8ball config keyring-backend test
8ball config node tcp://localhost:${BALL_PORT}657
8ball init $NODENAME --chain-id $BALL_CHAIN_ID

```

## Download genesis and Addrbook (updates every: 1h)
```
wget https://snapshot.yeksin.net/8ball/genesis.json -O $HOME/.8ball/config/genesis.json
wget https://snapshot.yeksin.net/8ball/addrbook.json -O $HOME/.8ball/config/addrbook.json

```

## Set seeds and peers
```
SEEDS=""
PEERS="fca96d0a1d7357afb226a49c4c7d9126118c37e9@one.8ball.info:26656,aa918e17c8066cd3b031f490f0019c1a95afe7e3@two.8ball.info:26656,98b49fea92b266ed8cfb0154028c79f81d16a825@three.8ball.info:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.8ball/config/config.toml

```

## Config pruning, set minimum gas price, enable prometheus and reset chain data
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.8ball/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.8ball/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.8ball/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.8ball/config/app.toml

sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uebl\"/" $HOME/.8ball/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.8ball/config/config.toml

```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${BALL_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${BALL_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${BALL_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${BALL_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${BALL_PORT}660\"%" $HOME/.8ball/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${BALL_PORT}317\"%; s%^address = \":8080\"%address = \":${BALL_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${BALL_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${BALL_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${BALL_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${BALL_PORT}546\"%" $HOME/.8ball/config/app.toml

```

## Download Snapshot
```
curl -L https://snapshot.yeksin.net/8ball/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.8ball

```

## Start service
```
sudo systemctl start 8ball

```

## Check logs
```
sudo journalctl -u 8ball -f -o cat

```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
8ball keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
8ball keys add $WALLET --recover
```

To get current list of wallets
```
8ball keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
BALL_WALLET_ADDRESS=$(8ball keys show $WALLET -a)
BALL_VALOPER_ADDRESS=$(8ball keys show $WALLET --bech val -a)
echo 'export BALL_WALLET_ADDRESS='${BALL_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export BALL_VALOPER_ADDRESS='${BALL_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Create validator
Before creating validator please make sure that you have at least 1 ebl (1 ebl is equal to 1000000 uebl) and your node is synchronized

To check your wallet balance:
```
8ball query bank balances $BALL_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
8ball tx staking create-validator \
  --amount 1000000uebl \
  --commission-max-change-rate 0.01 \
  --commission-max-rate 0.2 \
  --commission-rate 0.1 \
  --from $WALLET \
  --min-self-delegation 1 \
  --moniker $NODENAME \
  --pubkey $(8ball tendermint show-validator) \
  --chain-id eightball-1 \
  -y
```

# Check Cheatsheet
- https://www.yeksin.net/8ball/cheatsheet


