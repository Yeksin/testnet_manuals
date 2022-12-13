<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/200304455-120e6b06-2785-4c4f-8fc7-e9ef39dd653e.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/200304348-3539ebf8-e4f7-4b73-a259-35d06c41441e.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/207418559-7dbc2397-9df8-4e34-b9fc-7f2365c3ed09.png">
</p>

# humans node setup for testnet — testnet-1

Explorer:
>-  https://explorer.yeksin.net/humans

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

## Set up your humans node
### Option 1 (manual)
You can follow [manual guide](https://github.com/yeksinNodes/testnet_manuals/blob/main/humans/manual_install.md) if you better prefer setting up node manually


### Option 2 (automatic)
You can setup your humans fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O humans.sh https://raw.githubusercontent.com/yeksinNodes/testnet_manuals/main/humans/humans.sh && chmod +x humans.sh && ./humans.sh
```

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
humansd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
humansd keys add $WALLET --recover
```

To get current list of wallets
```
humansd keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
HUMANS_WALLET_ADDRESS=$(humansd keys show $WALLET -a)
HUMANS_VALOPER_ADDRESS=$(humansd keys show $WALLET --bech val -a)
echo 'export HUMANS_WALLET_ADDRESS='${HUMANS_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export HUMANS_VALOPER_ADDRESS='${HUMANS_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create validator
Before creating validator please make sure that you have at least 1 tlore (1 tlore is equal to 1000000 uheart) and your node is synchronized

To check your wallet balance:
```
humansd query bank balances $HUMANS_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
humansd tx staking create-validator \
  --amount 1000000uheart \
  --commission-max-change-rate 0.01 \
  --commission-max-rate 0.2 \
  --commission-rate 0.1 \
  --from $WALLET \
  --min-self-delegation 1 \
  --moniker $NODENAME \
  --pubkey $(humansd tendermint show-validator) \
  --chain-id testnet-1 \
  -y
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${HUMANS_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu humansd -o cat
```

Start service
```
sudo systemctl start humansd
```

Stop service
```
sudo systemctl stop humansd
```

Restart service
```
sudo systemctl restart humansd
```

### Node info
Synchronization info
```
humansd status 2>&1 | jq .SyncInfo
```

Validator info
```
humansd status 2>&1 | jq .ValidatorInfo
```

Node info
```
humansd status 2>&1 | jq .NodeInfo
```

Show node id
```
humansd tendermint show-node-id
```

### Wallet operations
List of wallets
```
humansd keys list
```

Recover wallet
```
humansd keys add $WALLET --recover
```

Delete wallet
```
humansd keys delete $WALLET
```

Get wallet balance
```
humansd query bank balances $HUMANS_WALLET_ADDRESS
```

Transfer funds
```
humansd tx bank send $HUMANS_WALLET_ADDRESS <TO_HUMANS_WALLET_ADDRESS> 10000000uheart
```

### Voting
```
humansd tx gov vote 1 yes --from $WALLET --chain-id=$HUMANS_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
humansd tx staking delegate $HUMANS_VALOPER_ADDRESS 10000000uheart --from=$WALLET --chain-id=$HUMANS_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
humansd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000uheart --from=$WALLET --chain-id=$HUMANS_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
humansd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$HUMANS_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
humansd tx distribution withdraw-rewards $HUMANS_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$HUMANS_CHAIN_ID
```

### Validator management
Edit validator
```
humansd tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$HUMANS_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
humansd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$HUMANS_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop humansd
sudo systemctl disable humansd
sudo rm /etc/systemd/system/humans* -rf
sudo rm $(which humansd) -rf
sudo rm $HOME/.humans* -rf
sudo rm $HOME/humans -rf
sed -i '/HUMANS_/d' ~/.bash_profile
```
