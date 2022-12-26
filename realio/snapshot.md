# <img src="https://user-images.githubusercontent.com/110628975/206032279-754840e1-56e2-447e-ba51-4977e3e703db.png" width="30" alt=""> Realionetwork_1110-2 Snapshot <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/>

## Check block height, snapshot time and file size from this <a href="https://snapshot.yeksin.net/realio/current_state.txt" target="_blank">FILE </a>

Snapshots are taken automatically each day at **21:00 UTC**

- **pruning**: custom/100/0/10 | **indexer**: null

## Instructions

### Stop the service and reset the data

```
sudo systemctl stop realio-networkd
cp $HOME/.realio-network/data/priv_validator_state.json $HOME/.realio-network/priv_validator_state.json.backup
realio-networkd tendermint unsafe-reset-all --home $HOME/.realio-network --keep-addr-book
rm -rf $HOME/.realio-network/data
```

### Download snapshot

```
wget https://snapshot.yeksin.net/realio/data.tar.gz && tar -xvf data.tar.gz -C $HOME/.realio-network
mv $HOME/.realio-network/priv_validator_state.json.backup $HOME/.realio-network/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart realio-networkd
journalctl -u realio-networkd -f --no-hostname -o cat
```
