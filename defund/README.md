<p style="font-size:14px" align="right">
<a href="https://t.me/yekssin" target="_blank">Telegram <img src="https://user-images.githubusercontent.com/110628975/209973847-b0af2837-c6cc-4468-94dc-1282dedccf8b.png" width="30"/></a>
<a href="https://discordapp.com/users/418099630765637642" target="_blank">Discord <img src="https://user-images.githubusercontent.com/110628975/209973851-bbd41a58-84bd-42ef-a936-01782db1fec5.png" width="30"/></a>
<a href="https://yeksin.net/" target="_blank">Website <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/110628975/209974636-d4f7418b-4ee4-4a00-898d-9f04ddb31eb4.png">
</p>

# defund node setup for testnet — defund-private-3

Official documentation:
>- [Validator setup instructions](https://github.com/defund-labs/testnet/blob/main/defund-private-3/README.md)

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

## Set up your defund fullnode
### Option 1 (manual)
You can follow [manual guide](https://github.com/yeksinNodes/testnet_manuals/blob/main/defund/manual_install.md) if you better prefer setting up node manually

### Option 2 (automatic)
You can setup your defund fullnode in few minutes by using automated script below. It will prompt you to input your validator node name!
```
wget -O defund.sh https://raw.githubusercontent.com/yeksinNodes/testnet_manuals/main/defund/defund.sh && chmod +x defund.sh && ./defund.sh
```

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```
### State sync with Nodejumper
```
sudo systemctl stop defundd

cp $HOME/.defund/data/priv_validator_state.json $HOME/.defund/priv_validator_state.json.backup
defundd tendermint unsafe-reset-all --home $HOME/.defund --keep-addr-book

SNAP_RPC="https://defund-testnet.nodejumper.io:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

peers="6366ac3af3995ecbc48c13ce9564aef0c7a6d7df@defund-testnet.nodejumper.io:28656"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$peers'"|' $HOME/.defund/config/config.toml

sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.defund/config/config.toml

mv $HOME/.defund/priv_validator_state.json.backup $HOME/.defund/data/priv_validator_state.json

sudo systemctl restart defundd
sudo journalctl -u defundd -f --no-hostname -o cat
```
### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
defundd keys add $WALLET
```

(OPTIONAL) To recover your wallet using seed phrase
```
defundd keys add $WALLET --recover
```

To get current list of wallets
```
defundd keys list
```

### Save wallet info
Add wallet and valoper address into variables 
```
DEFUND_WALLET_ADDRESS=$(defundd keys show $WALLET -a)
DEFUND_VALOPER_ADDRESS=$(defundd keys show $WALLET --bech val -a)
echo 'export DEFUND_WALLET_ADDRESS='${DEFUND_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export DEFUND_VALOPER_ADDRESS='${DEFUND_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Create validator
Before creating validator please make sure that you have at least 1 fetf (1 fetf is equal to 1000000 ufetf) and your node is synchronized

To check your wallet balance:
```
defundd query bank balances $DEFUND_WALLET_ADDRESS
```
> If your wallet does not show any balance than probably your node is still syncing. Please wait until it finish to synchronize and then continue 

To create your validator run command below
```
defundd tx staking create-validator \
  --amount 2000000ufetf \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(defundd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $DEFUND_CHAIN_ID
```

## Get currently connected peer list with ids
```
curl -sS http://localhost:${DEFUND_PORT}657/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu defundd -o cat
```

Start service
```
sudo systemctl start defundd
```

Stop service
```
sudo systemctl stop defundd
```

Restart service
```
sudo systemctl restart defundd
```

### Node info
Synchronization info
```
defundd status 2>&1 | jq .SyncInfo
```

Validator info
```
defundd status 2>&1 | jq .ValidatorInfo
```

Node info
```
defundd status 2>&1 | jq .NodeInfo
```

Show node id
```
defundd tendermint show-node-id
```

### Wallet operations
List of wallets
```
defundd keys list
```

Recover wallet
```
defundd keys add $WALLET --recover
```

Delete wallet
```
defundd keys delete $WALLET
```

Get wallet balance
```
defundd query bank balances $DEFUND_WALLET_ADDRESS
```

Transfer funds
```
defundd tx bank send $DEFUND_WALLET_ADDRESS <TO_DEFUND_WALLET_ADDRESS> 10000000ufetf
```

### Voting
```
defundd tx gov vote 1 yes --from $WALLET --chain-id=$DEFUND_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
defundd tx staking delegate $DEFUND_VALOPER_ADDRESS 10000000ufetf --from=$WALLET --chain-id=$DEFUND_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
defundd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ufetf --from=$WALLET --chain-id=$DEFUND_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
defundd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$DEFUND_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
defundd tx distribution withdraw-rewards $DEFUND_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$DEFUND_CHAIN_ID
```

### Validator management
Edit validator
```
defundd tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$DEFUND_CHAIN_ID \
  --from=$WALLET
```

Unjail validator
```
defundd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$DEFUND_CHAIN_ID \
  --gas=auto
```

### Delete node
This commands will completely remove node from server. Use at your own risk!
```
sudo systemctl stop defundd
sudo systemctl disable defundd
sudo rm /etc/systemd/system/defund* -rf
sudo rm $(which defundd) -rf
sudo rm $HOME/.defund* -rf
sudo rm $HOME/defund -rf
sed -i '/DEFUND_/d' ~/.bash_profile
```
