<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/209975880-b906168e-ad18-48ad-b1c8-c5a7ad8332ac.png">
</p>

# Manual node setup
If you want to setup fullnode manually follow the steps below

## Setting up vars
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<YOUR_MONIKER_NAME_GOES_HERE>
```

Save and import variables into system
```
SGE_PORT=51
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export SGE_CHAIN_ID=sge-testnet-1" >> $HOME/.bash_profile
echo "export SGE_PORT=${SGE_PORT}" >> $HOME/.bash_profile
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
cd $HOME && rm -rf sge
git clone https://github.com/sge-network/sge && cd sge
git fetch --tags
git checkout v0.0.3
go mod tidy
make install
```

## Config app
```
sged config chain-id $SGE_CHAIN_ID
sged config keyring-backend test
sged config node tcp://localhost:${SGE_PORT}657
```

## Init app
```
sged init $NODENAME --chain-id $SGE_CHAIN_ID
```

## Download Genesis
```
wget -qO $HOME/.sge/config/genesis.json wget "https://snapshot.yeksin.net/sge/genesis.json"
```
## Download Addrbook (updates every: 1h)
```
wget -qO $HOME/.sge/config/addrbook.json wget "https://snapshot.yeksin.net/sge/addrbook.json"
```

## Set seeds and peers
```
SEEDS=""
PEERS="27f0b281ea7f4c3db01fdb9f4cf7cc910ad240a6@209.34.206.44:26656,5f3196f370fa865bfd3e4a0653dc7853f613aba6@[2a01:4f9:1a:a718::10]:26656,afa90de6a195a4a2993b2501f12a1cd306f01d02@136.243.103.32:60856,dc75f5d2f9458767f39f62bd7eab3f499fdf2761@104.248.236.171:26656,1168931936c638e92ea6d93e2271b3fe5faee6d1@51.91.145.100:26656,8a7d722dba88326ee69fcc23b5b2ac93e36d7ff2@65.108.225.158:17756,445506c736895336e36dd4f8228a60c257b30e61@20.12.75.0:26656,971643c5b9f9d279cfb7ac1b14accd109231236b@65.108.15.170:26656,788bb7ee73c023f70c41360e9014544b12fe23f9@3.15.209.96:26656,26f0965f8cd53f2b3adc26f8ca5e893929b66c15@52.44.14.245:26656,4a3f59e30cde63d00aed8c3d15bef46b34ec2c7f@50.19.180.153:26656,31d742df5a427e241d1a6b1b22813c9cb4888c07@65.21.181.169:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.sge/config/config.toml
```

## Set custom ports
```
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${SGE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${SGE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${SGE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${SGE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${SGE_PORT}660\"%" $HOME/.sge/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${SGE_PORT}317\"%; s%^address = \":8080\"%address = \":${SGE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${SGE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${SGE_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${SGE_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${SGE_PORT}546\"%" $HOME/.sge/config/app.toml
```

## Config pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sge/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sge/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sge/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sge/config/app.toml
```

## Set minimum gas price and timeout commit
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0usge\"/" $HOME/.sge/config/app.toml
```

## Enable prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.sge/config/config.toml
```

## Reset chain data
```
sged tendermint unsafe-reset-all --home $HOME/.sge
```

## Create service
```
sudo tee /etc/systemd/system/sged.service > /dev/null <<EOF
[Unit]
Description=Sge Network node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which sged) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

## Register and start service
```
sudo systemctl daemon-reload
sudo systemctl enable sged
sudo systemctl restart sged && sudo journalctl -u sged -f -o cat
```
