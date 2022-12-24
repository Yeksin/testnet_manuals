# <img src="https://user-images.githubusercontent.com/110628975/207321763-bfed22b3-b58c-45b6-ae4f-6479a1114fad.png" width="30" alt=""> Ollo-testnet-1 Snapshot <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/>

## Check block height, snapshot time and file size from this <a href="https://snapshot.yeksin.net/ollo/current_state.txt" target="_blank">FILE </a>

Snapshots are taken automatically each day at **19:00 UTC**

- **pruning**: custom/100/0/10 | **indexer**: null

## Instructions

### Stop the service and reset the data

```
sudo systemctl stop ollod
cp $HOME/.ollo/data/priv_validator_state.json $HOME/.ollo/priv_validator_state.json.backup
ollod tendermint unsafe-reset-all --home $HOME/.ollo --keep-addr-book
rm -rf $HOME/.ollo/data
```

### Download snapshot

```
wget https://snapshot.yeksin.net/ollo/data.tar.gz && tar -xvf data.tar.gz -C $HOME/.ollo
mv $HOME/.ollo/priv_validator_state.json.backup $HOME/.ollo/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart ollod
journalctl -u ollod -f --no-hostname -o cat
```
