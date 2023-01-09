# <img src="https://user-images.githubusercontent.com/110628975/209975177-fca87e8c-63df-4393-b4cd-4ee7fc8b28c2.png" width="30" alt=""> Humans-testnet-1 State-Sync <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/>

## State sync snapshots allow other nodes to rapidly join the network without replaying historical blocks, instead downloading and applying a snapshot of the application state at a given height.

- **pruning**: custom/100/0/10 | **indexer**: null


## Instructions

### Stop the service and reset the data

```
sudo systemctl stop humansd
cp $HOME/.humans/data/priv_validator_state.json $HOME/.humans/priv_validator_state.json.backup
humansd tendermint unsafe-reset-all --home $HOME/.humans --keep-addr-book
```

### Configure the state sync information

```
SNAP_RPC="https://humans.rpc.yeksin.net:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

peers="398a13b3aff8d7608df7bb2fea73ad2939cbe623@humans.rpc.yeksin.net:44656"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$peers'"|' $HOME/.humans/config/config.toml

sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.humans/config/config.toml

mv $HOME/.humans/priv_validator_state.json.backup $HOME/.humans/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart humansd
sudo journalctl -u humansd -f --no-hostname -o cat
```
