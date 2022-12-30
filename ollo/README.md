<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/209975508-6f6b55bc-82bb-4b4f-b36c-662efea41476.png">
</p>

# ollo node setup for testnet — ollo-testnet-1

Official documentation:
>- [Validator setup instructions](https://docs.ollo.zone/validators/running_a_node)

Explorer:
>-  https://explorers.yeksin.net/ollo-testnet

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

## Set up your ollo fullnode
### Option 1 (manual)
You can follow [manual guide](https://github.com/yeksin/testnet_manuals/blob/main/ollo/manual_install.md) if you better prefer setting up node manually

### Option 2 (automatic)
You can setup your ollo fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O ollo.sh https://raw.githubusercontent.com/yeksin/testnet_manuals/main/ollo/ollo.sh && chmod +x ollo.sh && ./ollo.sh
```

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```


## Check out our Snapshot and State-sync services to join the network faster.
- ### <a href="https://github.com/yeksin/testnet_manuals/blob/main/ollo/snapshot.md" target="_blank">Snapshot </a>(everyday 20:00 UTC)
- ### <a href="https://github.com/yeksin/testnet_manuals/blob/main/ollo/state-sync.md" target="_blank">State-Sync </a>

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
ollod keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
ollod keys add $WALLET --recover
```

To get current list of wallets
```
ollod keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
OLLO_WALLET_ADDRESS=$(ollod keys show $WALLET -a)
OLLO_VALOPER_ADDRESS=$(ollod keys show $WALLET --bech val -a)
echo 'export OLLO_WALLET_ADDRESS='${OLLO_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export OLLO_VALOPER_ADDRESS='${OLLO_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet
In order to create validator first you need to fund your wallet with testnet tokens. \
You can request testnet tokens from the OLLO testnet faucet in the [OLLO Discord](https://discord.gg/bmDSF7jtZP)
- Get verified
- Get `Testnet Explorers role` in `#roles` channel
- Move to `#testnet-faucet` and request tokens
```
!request YOUR_WALLET_ADDRESS
```

### Create validator
Before creating validator please make sure that you have at least 1 strd (1 strd is equal to 1000000 utollo) and your node is synchronized

To check your wallet balance:
```
ollod query bank balances $OLLO_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
ollod tx staking create-validator \
  --amount 20000000utollo \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(ollod tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $OLLO_CHAIN_ID
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${OLLO_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu ollod -o cat
```

Start service
```
sudo systemctl start ollod
```

Stop service
```
sudo systemctl stop ollod
```

Restart service
```
sudo systemctl restart ollod
```

### Node info
Synchronization info
```
ollod status 2>&1 | jq .SyncInfo
```

Validator info
```
ollod status 2>&1 | jq .ValidatorInfo
```

Node info
```
ollod status 2>&1 | jq .NodeInfo
```

Show node id
```
ollod tendermint show-node-id
```

### Wallet operations
List of wallets
```
ollod keys list
```

Recover wallet
```
ollod keys add $WALLET --recover
```

Delete wallet
```
ollod keys delete $WALLET
```

Get wallet balance
```
ollod query bank balances $OLLO_WALLET_ADDRESS
```

Transfer funds
```
ollod tx bank send $OLLO_WALLET_ADDRESS <TO_OLLO_WALLET_ADDRESS> 10000000utollo
```

### Voting
```
ollod tx gov vote 1 yes --from $WALLET --chain-id=$OLLO_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
ollod tx staking delegate $OLLO_VALOPER_ADDRESS 10000000utollo --from=$WALLET --chain-id=$OLLO_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
ollod tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000utollo --from=$WALLET --chain-id=$OLLO_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
ollod tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$OLLO_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
ollod tx distribution withdraw-rewards $OLLO_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$OLLO_CHAIN_ID
```

### Validator management
Edit validator
```
ollod tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$OLLO_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
ollod tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$OLLO_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop ollod
sudo systemctl disable ollod
sudo rm /etc/systemd/system/ollo* -rf
sudo rm $(which ollod) -rf
sudo rm $HOME/.ollo* -rf
sudo rm $HOME/ollo -rf
sed -i '/OLLO_/d' ~/.bash_profile
```
