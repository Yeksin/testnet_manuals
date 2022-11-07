<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/200304455-120e6b06-2785-4c4f-8fc7-e9ef39dd653e.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/200304348-3539ebf8-e4f7-4b73-a259-35d06c41441e.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/200358773-5fd56781-edd0-4c76-964a-f5dc595b4254.png">
</p>

# nibiru node setup for testnet — nibiru-testnet-1

Official documentation:
>- [Validator setup instructions](https://docs.nibiru.fi/run-nodes/testnet/)

Explorer:
>-  https://explorer.yeksin.net/nibiru

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

## Set up your nibiru fullnode

### Option 1 (manual)
You can follow [manual guide](https://github.com/yeksinNodes/testnet_manuals/blob/main/nibiru/manual_install.md) if you better prefer setting up node manually

### Option 2 (automatic)
You can setup your nibiru fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O nibiru.sh https://raw.githubusercontent.com/yeksinNodes/testnet_manuals/main/nibiru/nibiru.sh && chmod +x nibiru.sh && ./nibiru.sh
```

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

### State-Sync with Nodejumper.io

You can state sync your node in minutes by running commands below
```
sudo systemctl stop nibid

cp $HOME/.nibid/data/priv_validator_state.json $HOME/.nibid/priv_validator_state.json.backup
nibid tendermint unsafe-reset-all --home $HOME/.nibid --keep-addr-book

SNAP_RPC="https://nibiru-testnet.nodejumper.io:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

peers="b32bb87364a52df3efcbe9eacc178c96b35c823a@nibiru-testnet.nodejumper.io:27656"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$peers'"|' $HOME/.nibid/config/config.toml

sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.nibid/config/config.toml

mv $HOME/.nibid/priv_validator_state.json.backup $HOME/.nibid/data/priv_validator_state.json

sudo systemctl restart nibid
```

### Update block time parameters
```
CONFIG_TOML="$HOME/.nibid/config/config.toml"
sed -i 's/timeout_propose =.*/timeout_propose = "100ms"/g' $CONFIG_TOML
sed -i 's/timeout_propose_delta =.*/timeout_propose_delta = "500ms"/g' $CONFIG_TOML
sed -i 's/timeout_prevote =.*/timeout_prevote = "100ms"/g' $CONFIG_TOML
sed -i 's/timeout_prevote_delta =.*/timeout_prevote_delta = "500ms"/g' $CONFIG_TOML
sed -i 's/timeout_precommit =.*/timeout_precommit = "100ms"/g' $CONFIG_TOML
sed -i 's/timeout_precommit_delta =.*/timeout_precommit_delta = "500ms"/g' $CONFIG_TOML
sed -i 's/timeout_commit =.*/timeout_commit = "1s"/g' $CONFIG_TOML
sed -i 's/skip_timeout_commit =.*/skip_timeout_commit = false/g' $CONFIG_TOML
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
nibid keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
nibid keys add $WALLET --recover
```

To get current list of wallets
```
nibid keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
NIBIRU_WALLET_ADDRESS=$(nibid keys show $WALLET -a)
NIBIRU_VALOPER_ADDRESS=$(nibid keys show $WALLET --bech val -a)
echo 'export NIBIRU_WALLET_ADDRESS='${NIBIRU_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export NIBIRU_VALOPER_ADDRESS='${NIBIRU_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Fund your wallet
In order to create validator first you need to fund your wallet with testnet tokens.
```
curl -X POST -d '{"address": "'"$NIBIRU_WALLET_ADDRESS"'", "coins": ["10000000unibi","100000000000unusd"]}' https://faucet.testnet-1.nibiru.fi/
```

### Create validator
Before creating validator please make sure that you have at least 1 nibi (1 nibi is equal to 1000000 unibi) and your node is synchronized

To check your wallet balance:
```
nibid query bank balances $NIBIRU_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
nibid tx staking create-validator \
  --amount 2000000unibi \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(nibid tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $NIBIRU_CHAIN_ID
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${NIBIRU_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu nibid -o cat
```

Start service
```
sudo systemctl start nibid
```

Stop service
```
sudo systemctl stop nibid
```

Restart service
```
sudo systemctl restart nibid
```

### Node info
Synchronization info
```
nibid status 2>&1 | jq .SyncInfo
```

Validator info
```
nibid status 2>&1 | jq .ValidatorInfo
```

Node info
```
nibid status 2>&1 | jq .NodeInfo
```

Show node id
```
nibid tendermint show-node-id
```

### Wallet operations
List of wallets
```
nibid keys list
```

Recover wallet
```
nibid keys add $WALLET --recover
```

Delete wallet
```
nibid keys delete $WALLET
```

Get wallet balance
```
nibid query bank balances $NIBIRU_WALLET_ADDRESS
```

Transfer funds
```
nibid tx bank send $NIBIRU_WALLET_ADDRESS <TO_NIBIRU_WALLET_ADDRESS> 10000000unibi
```

### Voting
```
nibid tx gov vote 1 yes --from $WALLET --chain-id=$NIBIRU_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
nibid tx staking delegate $NIBIRU_VALOPER_ADDRESS 10000000unibi --from=$WALLET --chain-id=$NIBIRU_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
nibid tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000unibi --from=$WALLET --chain-id=$NIBIRU_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
nibid tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$NIBIRU_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
nibid tx distribution withdraw-rewards $NIBIRU_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$NIBIRU_CHAIN_ID
```

### Validator management
Edit validator
```
nibid tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$NIBIRU_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
nibid tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$NIBIRU_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop nibid
sudo systemctl disable nibid
sudo rm /etc/systemd/system/nibi* -rf
sudo rm $(which nibid) -rf
sudo rm $HOME/.nibid* -rf
sudo rm $HOME/nibiru -rf
sed -i '/NIBIRU_/d' ~/.bash_profile
```
