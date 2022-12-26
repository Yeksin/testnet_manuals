<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/200304455-120e6b06-2785-4c4f-8fc7-e9ef39dd653e.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/200304348-3539ebf8-e4f7-4b73-a259-35d06c41441e.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/204315172-754216f0-29ab-4dac-a482-c0c20d904f82.png">
</p>

# sge node setup for testnet — sge-testnet-1

Explorer:
>-  https://explorers.yeksin.net/sge-testnet

## Hardware Requirements
Like any Cosmos-SDK chain, the hardware requirements are pretty modest.

### Minimum Hardware Requirements
 - 1.4 GHz CPU
 - 1 GB RAM
 - 25GB of storage (SSD or NVME)

### Recommended Hardware Requirements 
 - 2.0 GHz x2 CPU
 - 2 GB RAM
 - 100GB of storage (SSD or NVME)

## Set up your sge node
### Option 1 (manual)
You can follow [manual guide](https://github.com/yeksin/testnet_manuals/blob/main/sge/manual_install.md) if you better prefer setting up node manually


### Option 2 (automatic)
You can setup your sge fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O sge.sh https://raw.githubusercontent.com/yeksin/testnet_manuals/main/sge/sge.sh && chmod +x sge.sh && ./sge.sh
```

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

## Check out our Snapshot and State-sync services to join the network faster.
- ### <a href="https://github.com/yeksin/testnet_manuals/blob/main/sge/snapshot.md" target="_blank">Snapshot </a>(everyday 19:00 UTC)
- ### <a href="https://github.com/yeksin/testnet_manuals/blob/main/sge/state-sync.md" target="_blank">State-Sync </a>

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
sged keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
sged keys add $WALLET --recover
```

To get current list of wallets
```
sged keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
SGE_WALLET_ADDRESS=$(sged keys show $WALLET -a)
SGE_VALOPER_ADDRESS=$(sged keys show $WALLET --bech val -a)
echo 'export SGE_WALLET_ADDRESS='${SGE_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export SGE_VALOPER_ADDRESS='${SGE_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create validator
Before creating validator please make sure that you have at least 1 tlore (1 tlore is equal to 1000000 usge) and your node is synchronized

To check your wallet balance:
```
sged query bank balances $SGE_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
sged tx staking create-validator \
  --amount 500000000usge \
  --commission-max-change-rate 0.01 \
  --commission-max-rate 0.2 \
  --commission-rate 0.1 \
  --from $WALLET \
  --fees 400000usge \
  --min-self-delegation 1 \
  --moniker $NODENAME \
  --pubkey $(sged tendermint show-validator) \
  --chain-id sge-testnet-1 \
  -y
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${SGE_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu sged -o cat
```

Start service
```
sudo systemctl start sged
```

Stop service
```
sudo systemctl stop sged
```

Restart service
```
sudo systemctl restart sged
```

### Node info
Synchronization info
```
sged status 2>&1 | jq .SyncInfo
```

Validator info
```
sged status 2>&1 | jq .ValidatorInfo
```

Node info
```
sged status 2>&1 | jq .NodeInfo
```

Show node id
```
sged tendermint show-node-id
```

### Wallet operations
List of wallets
```
sged keys list
```

Recover wallet
```
sged keys add $WALLET --recover
```

Delete wallet
```
sged keys delete $WALLET
```

Get wallet balance
```
sged query bank balances $SGE_WALLET_ADDRESS
```

Transfer funds
```
sged tx bank send $SGE_WALLET_ADDRESS <TO_SGE_WALLET_ADDRESS> 10000000usge
```

### Voting
```
sged tx gov vote 1 yes --from $WALLET --chain-id=$SGE_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
sged tx staking delegate $SGE_VALOPER_ADDRESS 10000000usge --from=$WALLET --chain-id=$SGE_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
sged tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000usge --from=$WALLET --chain-id=$SGE_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
sged tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$SGE_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
sged tx distribution withdraw-rewards $SGE_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$SGE_CHAIN_ID
```

### Validator management
Edit validator
```
sged tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$SGE_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
sged tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$SGE_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop sged
sudo systemctl disable sged
sudo rm /etc/systemd/system/sge* -rf
sudo rm $(which sged) -rf
sudo rm $HOME/.sge* -rf
sudo rm $HOME/sge -rf
sed -i '/SGE_/d' ~/.bash_profile
```
