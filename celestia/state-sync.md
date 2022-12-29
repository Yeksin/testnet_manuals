# <img src="https://user-images.githubusercontent.com/110628975/209973850-513712ef-57dd-4328-8e1d-e0a2d8d4f136.png" width="30" alt=""> Celestia-mocha State-Sync <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/>

## State sync snapshots allow other nodes to rapidly join the network without replaying historical blocks, instead downloading and applying a snapshot of the application state at a given height.

- **pruning**: custom/100/0/10 | **indexer**: null


## Instructions

### Stop the service and reset the data

```
sudo systemctl stop celestia-appd
cp $HOME/.celestia-app/data/priv_validator_state.json $HOME/.celestia-app/priv_validator_state.json.backup
celestia-appd tendermint unsafe-reset-all --home $HOME/.celestia-app --keep-addr-book
rm -rf $HOME/.celestia-app/data
```

### Configure the state sync information

```
SNAP_RPC="https://celestia.rpc.yeksin.net:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

peers="e0aac09f3de68abf583b0e3994228ee8bd19d1eb@rpc.yeksin.net:22656"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$peers'"|' $HOME/.celestia-app/config/config.toml

sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.celestia-app/config/config.toml

mv $HOME/.celestia-app/priv_validator_state.json.backup $HOME/.celestia-app/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart celestia-appd
sudo journalctl -u celestia-appd -f --no-hostname -o cat
```
