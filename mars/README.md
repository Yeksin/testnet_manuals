<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/212442135-e36db0d3-a46a-4fe0-b502-55950ccdfc3e.png">
</p>

# Mars node setup for ares-1

Official documentation:
- https://validatordocs.marsprotocol.io/TfYZfjcaUzFmiAkWDf7P/develop/mars-cli/marsd

Explorer:
- https://explorers.yeksin.net/mars-testnet

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
### Option 1 (manual)
You can follow [manual guide](https://github.com/yeksin/testnet_manuals/blob/main/mars/manual_install.md) if you better prefer setting up node manually


### Option 2 (automatic)
You can setup your mars fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O mars.sh https://raw.githubusercontent.com/yeksin/testnet_manuals/main/mars/mars.sh && chmod +x mars.sh && ./mars.sh
```

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

## Check out our Snapshot and State-sync services to join the network faster.
- ### <a href="https://github.com/yeksin/testnet_manuals/blob/main/mars/snapshot.md" target="_blank">Snapshot </a>(everyday 21:00 UTC)
- ### <a href="https://github.com/yeksin/testnet_manuals/blob/main/mars/state-sync.md" target="_blank">State-Sync </a>

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

### Create validator
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
  --chain-id ares-1 \
  -y
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${MARS_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu marsd -o cat
```

Start service
```
sudo systemctl start marsd
```

Stop service
```
sudo systemctl stop marsd
```

Restart service
```
sudo systemctl restart marsd
```

### Node info
Synchronization info
```
marsd status 2>&1 | jq .SyncInfo
```

Validator info
```
marsd status 2>&1 | jq .ValidatorInfo
```

Node info
```
marsd status 2>&1 | jq .NodeInfo
```

Show node id
```
marsd tendermint show-node-id
```

### Wallet operations
List of wallets
```
marsd keys list
```

Recover wallet
```
marsd keys add $WALLET --recover
```

Delete wallet
```
marsd keys delete $WALLET
```

Get wallet balance
```
marsd query bank balances $MARS_WALLET_ADDRESS
```

Transfer funds
```
marsd tx bank send $MARS_WALLET_ADDRESS <TO_MARS_WALLET_ADDRESS> 1000000umars
```

### Voting
```
marsd tx gov vote 1 yes --from $WALLET --chain-id=$MARS_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
marsd tx staking delegate $MARS_VALOPER_ADDRESS 1000000umars --from=$WALLET --chain-id=$MARS_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
marsd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 1000000umars --from=$WALLET --chain-id=$MARS_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
marsd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$MARS_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
marsd tx distribution withdraw-rewards $MARS_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$MARS_CHAIN_ID
```

### Validator management
Edit validator
```
marsd tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$MARS_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
marsd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$MARS_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop marsd
sudo systemctl disable marsd
sudo rm /etc/systemd/system/mars* -rf
sudo rm $(which marsd) -rf
sudo rm $HOME/.mars* -rf
sudo rm $HOME/hub -rf
sed -i '/MARS_/d' ~/.bash_profile
```
