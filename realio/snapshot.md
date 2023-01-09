# <img src="https://user-images.githubusercontent.com/110628975/209976146-cf2d8cbc-475e-4780-8a28-027e74cf6d9a.png" width="30" alt=""> Realionetwork_1110-2 Snapshot <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/>

## Check block height, snapshot time and file size from this <a href="https://snapshot.yeksin.net/realio/current_state.txt" target="_blank">FILE </a>

Snapshots are taken automatically each day at **20:00 UTC**

- **pruning**: custom/100/0/10 | **indexer**: null

## Instructions

### Stop the service and reset the data

```
sudo systemctl stop realio-networkd
cp $HOME/.realio-network/data/priv_validator_state.json $HOME/.realio-network/priv_validator_state.json.backup
realio-networkd tendermint unsafe-reset-all --home $HOME/.realio-network --keep-addr-book
```

### Download snapshot

```
curl -L https://snapshot.yeksin.net/realio/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.realio-network
mv $HOME/.realio-network/priv_validator_state.json.backup $HOME/.realio-network/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart realio-networkd
journalctl -u realio-networkd -f --no-hostname -o cat
```
