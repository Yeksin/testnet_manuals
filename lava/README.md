<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/211394335-6e797fe0-efed-4906-9c25-ec56b351b31f.png">
</p>

# Lava node setup for lava-testnet-1

Official documentation:
- https://docs.lavanet.xyz/testnet

Explorer:
- https://explorers.yeksin.net/lava-testnet

API:
- https://lava.api.yeksin.net

RPC:
- https://lava.rpc.yeksin.net

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

## Set up your lava node
You can follow [manual guide](https://github.com/yeksin/testnet_manuals/blob/main/lava/manual_install.md) if you better prefer setting up node manually

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
lavad keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
lavad keys add $WALLET --recover
```

To get current list of wallets
```
lavad keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
LAVA_WALLET_ADDRESS=$(lavad keys show $WALLET -a)
LAVA_VALOPER_ADDRESS=$(lavad keys show $WALLET --bech val -a)
echo 'export LAVA_WALLET_ADDRESS='${LAVA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export LAVA_VALOPER_ADDRESS='${LAVA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create validator
Before creating validator please make sure that you have at least 1 tlore (1 tlore is equal to 1000000 ulava) and your node is synchronized

To check your wallet balance:
```
lavad query bank balances $LAVA_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
lavad tx staking create-validator \
  --amount 1000000ulava \
  --commission-max-change-rate 0.01 \
  --commission-max-rate 0.2 \
  --commission-rate 0.1 \
  --from $WALLET \
  --min-self-delegation 1 \
  --moniker $NODENAME \
  --pubkey $(lavad tendermint show-validator) \
  --chain-id lava-testnet-1 \
  -y
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${LAVA_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu lavad -o cat
```

Start service
```
sudo systemctl start lavad
```

Stop service
```
sudo systemctl stop lavad
```

Restart service
```
sudo systemctl restart lavad
```

### Node info
Synchronization info
```
lavad status 2>&1 | jq .SyncInfo
```

Validator info
```
lavad status 2>&1 | jq .ValidatorInfo
```

Node info
```
lavad status 2>&1 | jq .NodeInfo
```

Show node id
```
lavad tendermint show-node-id
```

### Wallet operations
List of wallets
```
lavad keys list
```

Recover wallet
```
lavad keys add $WALLET --recover
```

Delete wallet
```
lavad keys delete $WALLET
```

Get wallet balance
```
lavad query bank balances $LAVA_WALLET_ADDRESS
```

Transfer funds
```
lavad tx bank send $LAVA_WALLET_ADDRESS <TO_LAVA_WALLET_ADDRESS> 10000000ulava
```

### Voting
```
lavad tx gov vote 1 yes --from $WALLET --chain-id=$LAVA_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
lavad tx staking delegate $LAVA_VALOPER_ADDRESS 10000000ulava --from=$WALLET --chain-id=$LAVA_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
lavad tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ulava --from=$WALLET --chain-id=$LAVA_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
lavad tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$LAVA_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
lavad tx distribution withdraw-rewards $LAVA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$LAVA_CHAIN_ID
```

### Validator management
Edit validator
```
lavad tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$LAVA_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
lavad tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$LAVA_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop lavad
sudo systemctl disable lavad
sudo rm /etc/systemd/system/lava* -rf
sudo rm $(which lavad) -rf
sudo rm $HOME/.lava* -rf
sudo rm $HOME/lava -rf
sed -i '/LAVA_/d' ~/.bash_profile
```
