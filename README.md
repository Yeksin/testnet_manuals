<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/200304455-120e6b06-2785-4c4f-8fc7-e9ef39dd653e.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/200304348-3539ebf8-e4f7-4b73-a259-35d06c41441e.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/205171502-6b467aee-e032-4c27-ae93-3bdcc63b6ef1.png">
</p>


# Celestia node setup for testnet — mocha

Official documentation:
- https://docs.celestia.org/nodes/overview

Yeksin Explorer:
- https://explorers.yeksin.net/celestia-testnet

API:
- https://celestia.api.yeksin.net

RPC:
- https://celestia.rpc.yeksin.net

## Hardware requirements
- Memory: 8 GB RAM
- CPU: Quad-Core
- Disk: 250 GB SSD Storage
- Bandwidth: 1 Gbps for Download/100 Mbps for Upload

## Set up your celestia fullnode
### Option 1 (manual)
You can follow [manual guide](https://github.com/yeksinNodes/testnet_manuals/blob/main/celestia/manual_install.md) if you better prefer setting up node manually

### Option 2 (automatic)
You can setup your celestia fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O celestia.sh https://raw.githubusercontent.com/yeksinNodes/testnet_manuals/main/celestia/celestia.sh && chmod +x celestia.sh && ./celestia.sh
```

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

### (OPTIONAL) Use Snapshot by kjnodes
```
systemctl stop celestia-appd
cp $HOME/.celestia-app/data/priv_validator_state.json $HOME/.celestia-app/priv_validator_state.json.backup
```

```
cd $HOME
rm -rf ~/.celestia-app/data
curl -L https://snapshots.kjnodes.com/celestia-testnet/snapshot_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.celestia-app
```

```
mv $HOME/.celestia-app/priv_validator_state.json.backup $HOME/.celestia-app/data/priv_validator_state.json
```
```
systemctl restart celestia-appd && journalctl -fu celestia-appd -o cat
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
celestia-appd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
celestia-appd keys add $WALLET --recover
```

To get current list of wallets
```
celestia-appd keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
CELESTIA_WALLET_ADDRESS=$(celestia-appd keys show $WALLET -a)
CELESTIA_VALOPER_ADDRESS=$(celestia-appd keys show $WALLET --bech val -a)
echo 'export CELESTIA_WALLET_ADDRESS='${CELESTIA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export CELESTIA_VALOPER_ADDRESS='${CELESTIA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet
In order to create validator first you need to fund your wallet with testnet tokens.
To top up your wallet join [celestia discord server](https://discord.gg/neBFH8Se) and navigate to:
- **#faucet** to request test tokens

To request a faucet grant:
```
$request <YOUR_WALLET_ADDRESS>
```

To check wallet balance:
```
$balance <YOUR_WALLET_ADDRESS>
```

### Create validator
Before creating validator please make sure that you have at least 1 tia (1 tia is equal to 1000000 utia) and your node is synchronized

To check your wallet balance:
```
celestia-appd query bank balances $CELESTIA_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
celestia-appd tx staking create-validator \
--amount=1000000utia \
--pubkey=$(celestia-appd tendermint show-validator) \
--moniker="YOUR_MONIKER_NAME" \
--identity="YOUR_KEYBASE_ID" \
--details="YOUR_DETAILS" \
--website="YOUR_WEBSITE_URL"
--evm-address="YOUR_EVM_ADDRESS" \
--orchestrator-address="YOUR_ORCHESTRATOR_ADDRESS" \
--chain-id=mocha \
--commission-rate=0.05 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas-adjustment=1.4 \
--gas=auto \
--fees=1000utia \
-y
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${CELESTIA_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu celestia-appd -o cat
```

Start service
```
sudo systemctl start celestia-appd
```

Stop service
```
sudo systemctl stop celestia-appd
```

Restart service
```
sudo systemctl restart celestia-appd
```

### Node info
Synchronization info
```
celestia-appd status 2>&1 | jq .SyncInfo
```

Validator info
```
celestia-appd status 2>&1 | jq .ValidatorInfo
```

Node info
```
celestia-appd status 2>&1 | jq .NodeInfo
```

Show node id
```
celestia-appd tendermint show-node-id
```

### Wallet operations
List of wallets
```
celestia-appd keys list
```

Recover wallet
```
celestia-appd keys add $WALLET --recover
```

Delete wallet
```
celestia-appd keys delete $WALLET
```

Get wallet balance
```
celestia-appd query bank balances $CELESTIA_WALLET_ADDRESS
```

Transfer funds
```
celestia-appd tx bank send $CELESTIA_WALLET_ADDRESS <TO_CELESTIA_WALLET_ADDRESS> 10000000utia
```

### Voting
```
celestia-appd tx gov vote 1 yes --from $WALLET --chain-id=$CELESTIA_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
celestia-appd tx staking delegate $CELESTIA_VALOPER_ADDRESS 10000000utia --from=$WALLET --chain-id=$CELESTIA_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
celestia-appd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000utia --from=$WALLET --chain-id=$CELESTIA_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
celestia-appd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CELESTIA_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
celestia-appd tx distribution withdraw-rewards $CELESTIA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CELESTIA_CHAIN_ID
```

### Validator management
Edit validator
```
celestia-appd tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$CELESTIA_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
celestia-appd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CELESTIA_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop celestia-appd
sudo systemctl disable celestia-appd
sudo rm /etc/systemd/system/celestia* -rf
sudo rm $(which celestia-appd) -rf
sudo rm $HOME/.celestia-app* -rf
sudo rm $HOME/celestia -rf
sed -i '/CELESTIA_/d' ~/.bash_profile
```
