# <img src="https://user-images.githubusercontent.com/110628975/207869212-823689d2-fa45-47dd-af93-50a8b008bddc.png" width="30" alt=""> Nolus-rila State-Sync <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/>

## State sync snapshots allow other nodes to rapidly join the network without replaying historical blocks, instead downloading and applying a snapshot of the application state at a given height.

- **pruning**: custom/100/0/10 | **indexer**: null


## Instructions

### Stop the service and reset the data

```
sudo systemctl stop nolusd
cp $HOME/.nolus/data/priv_validator_state.json $HOME/.nolus/priv_validator_state.json.backup
nolusd tendermint unsafe-reset-all --home $HOME/.nolus --keep-addr-book
```

### Configure the state sync information

```
SNAP_RPC="https://nolus.rpc.yeksin.net:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

peers="e0aac09f3de68abf583b0e3994228ee8bd19d1eb@nolus.rpc.yeksin.net:45656"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$peers'"|' $HOME/.nolus/config/config.toml

sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.nolus/config/config.toml

mv $HOME/.nolus/priv_validator_state.json.backup $HOME/.nolus/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart nolusd
sudo journalctl -u nolusd -f --no-hostname -o cat
```
