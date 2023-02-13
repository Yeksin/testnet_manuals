<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/200304455-120e6b06-2785-4c4f-8fc7-e9ef39dd653e.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/200304348-3539ebf8-e4f7-4b73-a259-35d06c41441e.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/204880127-32a167db-5282-4a8c-915b-d68f9f1a2cfd.png">
</p>

# loyal node setup for testnet — loyal-1

Official documentation:
>- [Validator setup instructions](https://docs.joinloyal.io/validators/)

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

## Set up your loyal fullnode
You can follow [manual guide](https://github.com/yeksinNodes/testnet_manuals/blob/main/loyal/manual_install.md) if you better prefer setting up node manually

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
loyald keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
loyald keys add $WALLET --recover
```

To get current list of wallets
```
loyald keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
LOYAL_WALLET_ADDRESS=$(loyald keys show $WALLET -a)
LOYAL_VALOPER_ADDRESS=$(loyald keys show $WALLET --bech val -a)
echo 'export LOYAL_WALLET_ADDRESS='${LOYAL_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export LOYAL_VALOPER_ADDRESS='${LOYAL_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create validator
Before creating validator please make sure that you have at least 1 lyl (1 lyl is equal to 1000000 ulyl) and your node is synchronized

To check your wallet balance:
```
loyald query bank balances $LOYAL_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
loyald tx staking create-validator \
  --amount 1000000ulyl \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(loyald tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $LOYAL_CHAIN_ID
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${LOYAL_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu loyald -o cat
```

Start service
```
sudo systemctl start loyald
```

Stop service
```
sudo systemctl stop loyald
```

Restart service
```
sudo systemctl restart loyald
```

### Node info
Synchronization info
```
loyald status 2>&1 | jq .SyncInfo
```

Validator info
```
loyald status 2>&1 | jq .ValidatorInfo
```

Node info
```
loyald status 2>&1 | jq .NodeInfo
```

Show node id
```
loyald tendermint show-node-id
```

### Wallet operations
List of wallets
```
loyald keys list
```

Recover wallet
```
loyald keys add $WALLET --recover
```

Delete wallet
```
loyald keys delete $WALLET
```

Get wallet balance
```
loyald query bank balances $LOYAL_WALLET_ADDRESS
```

Transfer funds
```
loyald tx bank send $LOYAL_WALLET_ADDRESS <TO_LOYAL_WALLET_ADDRESS> 10000000ulyl
```

### Voting
```
loyald tx gov vote 1 yes --from $WALLET --chain-id=$LOYAL_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
loyald tx staking delegate $LOYAL_VALOPER_ADDRESS 10000000ulyl --from=$WALLET --chain-id=$LOYAL_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
loyald tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ulyl --from=$WALLET --chain-id=$LOYAL_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
loyald tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$LOYAL_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
loyald tx distribution withdraw-rewards $LOYAL_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$LOYAL_CHAIN_ID
```

### Validator management
Edit validator
```
loyald tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$LOYAL_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
loyald tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$LOYAL_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop loyald
sudo systemctl disable loyald
sudo rm /etc/systemd/system/loyald* -rf
sudo rm $(which loyald) -rf
sudo rm $HOME/.loyal* -rf
sudo rm $HOME/loyal -rf
sed -i '/LOYAL_/d' ~/.bash_profile
```
