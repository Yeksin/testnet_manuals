<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/200304455-120e6b06-2785-4c4f-8fc7-e9ef39dd653e.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/200304348-3539ebf8-e4f7-4b73-a259-35d06c41441e.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/207869212-823689d2-fa45-47dd-af93-50a8b008bddc.png">
</p>

# nolus node setup for testnet — nolus-rila

Website:
- https://nolus.io

Official documentation:
- [Validator setup instructions](https://docs-nolus-protocol.notion.site/Run-a-Validator-3b2657bc68ca4eb3a24078a2ccbb7680)

Explorer:
-  https://explorers.yeksin.net/nolus-testnet

API:
- https://nolus.api.yeksin.net

RPC:
- https://nolus.rpc.yeksin.net

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

## Set up your nolus fullnode
### Option 1 (manual)
You can follow [manual guide](https://github.com/yeksin/testnet_manuals/blob/main/nolus/manual_install.md) if you better prefer setting up node manually

### Option 2 (automatic)
You can setup your nolus fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O nolus.sh https://raw.githubusercontent.com/yeksin/testnet_manuals/main/nolus/nolus.sh && chmod +x nolus.sh && ./nolus.sh
```

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

## Check out our Snapshot and State-sync services to join the network faster.
- ### <a href="https://github.com/yeksin/testnet_manuals/blob/main/nolus/snapshot.md" target="_blank">Snapshot </a>(everyday 20:00 UTC)
- ### <a href="https://github.com/yeksin/testnet_manuals/blob/main/nolus/state-sync.md" target="_blank">State-Sync </a>

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
nolusd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
nolusd keys add $WALLET --recover
```

To get current list of wallets
```
nolusd keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
NOLUS_WALLET_ADDRESS=$(nolusd keys show $WALLET -a)
NOLUS_VALOPER_ADDRESS=$(nolusd keys show $WALLET --bech val -a)
echo 'export NOLUS_WALLET_ADDRESS='${NOLUS_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export NOLUS_VALOPER_ADDRESS='${NOLUS_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create validator
Before creating validator please make sure that you have at least 1 NLS (1 NLS is equal to 1000000 unls) and your node is synchronized

To check your wallet balance:
```
nolusd query bank balances $NOLUS_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
nolusd tx staking create-validator \
  --amount 9000000unls \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.1" \
  --min-self-delegation "1" \
  --pubkey  $(nolusd tendermint show-validator) \
  --moniker $NODENAME \
  --gas-prices 0.0042unls \
  --chain-id $NOLUS_CHAIN_ID
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${NOLUS_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu nolusd -o cat
```

Start service
```
sudo systemctl start nolusd
```

Stop service
```
sudo systemctl stop nolusd
```

Restart service
```
sudo systemctl restart nolusd
```

### Node info
Synchronization info
```
nolusd status 2>&1 | jq .SyncInfo
```

Validator info
```
nolusd status 2>&1 | jq .ValidatorInfo
```

Node info
```
nolusd status 2>&1 | jq .NodeInfo
```

Show node id
```
nolusd tendermint show-node-id
```

### Wallet operations
List of wallets
```
nolusd keys list
```

Recover wallet
```
nolusd keys add $WALLET --recover
```

Delete wallet
```
nolusd keys delete $WALLET
```

Get wallet balance
```
nolusd query bank balances $NOLUS_WALLET_ADDRESS
```

Transfer funds
```
nolusd tx bank send $NOLUS_WALLET_ADDRESS <TO_NOLUS_WALLET_ADDRESS> 10000000unls
```

### Voting
```
nolusd tx gov vote 1 yes --from $WALLET --chain-id=$NOLUS_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
nolusd tx staking delegate $NOLUS_VALOPER_ADDRESS 10000000unls --from=$WALLET --chain-id=$NOLUS_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
nolusd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000unls --from=$WALLET --chain-id=$NOLUS_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
nolusd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$NOLUS_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
nolusd tx distribution withdraw-rewards $NOLUS_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$NOLUS_CHAIN_ID
```

### Validator management
Edit validator
```
nolusd tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$NOLUS_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
nolusd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$NOLUS_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop nolusd
sudo systemctl disable nolusd
sudo rm /etc/systemd/system/nolus* -rf
sudo rm $(which nolusd) -rf
sudo rm $HOME/.nolus* -rf
sudo rm $HOME/nolus -rf
sed -i '/NOLUS_/d' ~/.bash_profile
```
