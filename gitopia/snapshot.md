# <img src="https://user-images.githubusercontent.com/110628975/201440389-b24f41a1-43f0-42a9-94bf-39ec96cc1157.png" width="30" alt=""> Gitopia-janus-testnet-2 Snapshot <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/>

## Check block height, snapshot time and file size from this <a href="https://snapshot.yeksin.net/gitopia/current_state.txt" target="_blank">FILE </a>

Snapshots are taken automatically each day at **19:00 UTC**

- **pruning**: custom/100/0/10 | **indexer**: null

## Instructions

### Stop the service and reset the data

```
sudo systemctl stop gitopiad
cp $HOME/.gitopia/data/priv_validator_state.json $HOME/.gitopia/priv_validator_state.json.backup
gitopiad tendermint unsafe-reset-all --home $HOME/.gitopia --keep-addr-book
rm -rf $HOME/.gitopia/data
```

### Download snapshot

```
wget https://snapshot.yeksin.net/gitopia/data.tar.gz && tar -xvf data.tar.gz -C $HOME/.gitopia
mv $HOME/.gitopia/priv_validator_state.json.backup $HOME/.gitopia/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart gitopiad
journalctl -u gitopiad -f --no-hostname -o cat
```
