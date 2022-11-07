<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/200304455-120e6b06-2785-4c4f-8fc7-e9ef39dd653e.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/200304348-3539ebf8-e4f7-4b73-a259-35d06c41441e.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/200305031-f2e42669-5ff7-48fd-abea-2be06d9a24d3.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/200304822-abdb3101-6f4d-4301-af78-3b57f0077715.png">
</p>

# okp4 node setup for testnet — okp4-nemeton

Official documentation:
>- [Validator setup instructions](https://docs.okp4.network/docs/nodes/run-node)

Explorer:
>-  https://explorer.yeksin.net/okp4

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

## Set up your okp4 fullnode
### Option 1 (manual)
You can follow [manual guide](https://github.com/yeksinNodes/testnet_manuals/blob/main/okp4/manual_install.md) if you better prefer setting up node manually

### Option 2 (automatic)
You can setup your okp4 fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O okp4.sh https://raw.githubusercontent.com/yeksinNodes/testnet_manuals/main/okp4/okp4.sh && chmod +x okp4.sh && ./okp4.sh
```
Wait for the installation to complete. After that execute the following command:
```
source $HOME/.bash_profile
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
okp4d keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
okp4d keys add $WALLET --recover
```

To get current list of wallets
```
okp4d keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
OKP4_WALLET_ADDRESS=$(okp4d keys show $WALLET -a)
OKP4_VALOPER_ADDRESS=$(okp4d keys show $WALLET --bech val -a)
echo 'export OKP4_WALLET_ADDRESS='${OKP4_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export OKP4_VALOPER_ADDRESS='${OKP4_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet
Navigate to https://faucet.okp4.network and paste your wallet address

### Create validator
Before creating validator please make sure that you have at least 1 know (1 know is equal to 1000000 uknow) and your node is synchronized

To check your wallet balance:
```
okp4d query bank balances $OKP4_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
okp4d tx staking create-validator \
  --amount 2000000uknow \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(okp4d tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $OKP4_CHAIN_ID
```
## Get currently connected peer list with ids
```
curl -sS http://localhost:${OKP4_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu okp4d -o cat
```

Start service
```
sudo systemctl start okp4d
```

Stop service
```
sudo systemctl stop okp4d
```

Restart service
```
sudo systemctl restart okp4d
```

### Node info
Synchronization info
```
okp4d status 2>&1 | jq .SyncInfo
```

Validator info
```
okp4d status 2>&1 | jq .ValidatorInfo
```

Node info
```
okp4d status 2>&1 | jq .NodeInfo
```

Show node id
```
okp4d tendermint show-node-id
```

### Wallet operations
List of wallets
```
okp4d keys list
```

Recover wallet
```
okp4d keys add $WALLET --recover
```

Delete wallet
```
okp4d keys delete $WALLET
```

Get wallet balance
```
okp4d query bank balances $OKP4_WALLET_ADDRESS
```

Transfer funds
```
okp4d tx bank send $OKP4_WALLET_ADDRESS <TO_OKP4_WALLET_ADDRESS> 10000000uknow
```

### Voting
```
okp4d tx gov vote 1 yes --from $WALLET --chain-id=$OKP4_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
okp4d tx staking delegate $OKP4_VALOPER_ADDRESS 10000000uknow --from=$WALLET --chain-id=$OKP4_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
okp4d tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000uknow --from=$WALLET --chain-id=$OKP4_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
okp4d tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$OKP4_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
okp4d tx distribution withdraw-rewards $OKP4_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$OKP4_CHAIN_ID
```

### Validator management
Edit validator
```
okp4d tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$OKP4_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
okp4d tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$OKP4_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop okp4d
sudo systemctl disable okp4d
sudo rm /etc/systemd/system/okp4* -rf
sudo rm $(which okp4d) -rf
sudo rm $HOME/.okp4d* -rf
sudo rm $HOME/okp4 -rf
sed -i '/OKP4_/d' ~/.bash_profile
```
