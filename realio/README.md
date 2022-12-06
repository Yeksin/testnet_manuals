<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/200304455-120e6b06-2785-4c4f-8fc7-e9ef39dd653e.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/200304348-3539ebf8-e4f7-4b73-a259-35d06c41441e.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/206032279-754840e1-56e2-447e-ba51-4977e3e703db.png">
</p>

# realio node setup for testnet — realionetwork_1110-2

Explorer:
>-  https://explorer.yeksin.net/realio

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

## Set up your realio node
### Option 1 (manual)
You can follow [manual guide](https://github.com/yeksinNodes/testnet_manuals/blob/main/realio/manual_install.md) if you better prefer setting up node manually


### Option 2 (automatic)
You can setup your realio fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O realio.sh https://raw.githubusercontent.com/yeksinNodes/testnet_manuals/main/realio/realio.sh && chmod +x realio.sh && ./realio.sh
```

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
realio-networkd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
realio-networkd keys add $WALLET --recover
```

To get current list of wallets
```
realio-networkd keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
REALIO_WALLET_ADDRESS=$(realio-networkd keys show $WALLET -a)
REALIO_VALOPER_ADDRESS=$(realio-networkd keys show $WALLET --bech val -a)
echo 'export REALIO_WALLET_ADDRESS='${REALIO_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export REALIO_VALOPER_ADDRESS='${REALIO_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create validator
Before creating validator please make sure that you have at least 1 tlore (1 tlore is equal to 1000000 ario) and your node is synchronized

To check your wallet balance:
```
realio-networkd query bank balances $REALIO_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
realio-networkd tx staking create-validator \
  --amount 500000000ario \
  --commission-max-change-rate 0.01 \
  --commission-max-rate 0.2 \
  --commission-rate 0.1 \
  --from $WALLET \
  --fees 400000ario \
  --min-self-delegation 1 \
  --moniker $NODENAME \
  --pubkey $(realio-networkd tendermint show-validator) \
  --chain-id realionetwork_1110-2 \
  -y
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${REALIO_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu realio-networkd -o cat
```

Start service
```
sudo systemctl start realio-networkd
```

Stop service
```
sudo systemctl stop realio-networkd
```

Restart service
```
sudo systemctl restart realio-networkd
```

### Node info
Synchronization info
```
realio-networkd status 2>&1 | jq .SyncInfo
```

Validator info
```
realio-networkd status 2>&1 | jq .ValidatorInfo
```

Node info
```
realio-networkd status 2>&1 | jq .NodeInfo
```

Show node id
```
realio-networkd tendermint show-node-id
```

### Wallet operations
List of wallets
```
realio-networkd keys list
```

Recover wallet
```
realio-networkd keys add $WALLET --recover
```

Delete wallet
```
realio-networkd keys delete $WALLET
```

Get wallet balance
```
realio-networkd query bank balances $REALIO_WALLET_ADDRESS
```

Transfer funds
```
realio-networkd tx bank send $REALIO_WALLET_ADDRESS <TO_REALIO_WALLET_ADDRESS> 10000000ario
```

### Voting
```
realio-networkd tx gov vote 1 yes --from $WALLET --chain-id=$REALIO_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
realio-networkd tx staking delegate $REALIO_VALOPER_ADDRESS 10000000ario --from=$WALLET --chain-id=$REALIO_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
realio-networkd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ario --from=$WALLET --chain-id=$REALIO_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
realio-networkd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$REALIO_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
realio-networkd tx distribution withdraw-rewards $REALIO_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$REALIO_CHAIN_ID
```

### Validator management
Edit validator
```
realio-networkd tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$REALIO_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
realio-networkd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$REALIO_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop realio-networkd
sudo systemctl disable realio-networkd
sudo rm /etc/systemd/system/realio-network* -rf
sudo rm $(which realio-networkd) -rf
sudo rm $HOME/.realio-network* -rf
sudo rm $HOME/realio-network -rf
sed -i '/REALIO_/d' ~/.bash_profile
```
