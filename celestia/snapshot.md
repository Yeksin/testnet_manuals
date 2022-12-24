# <img src="https://user-images.githubusercontent.com/110628975/205171502-6b467aee-e032-4c27-ae93-3bdcc63b6ef1.png" width="30" alt=""> Celestia-mocha Snapshot <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/>

## Check block height, snapshot time and file size from this <a href="https://snapshot.yeksin.net/celestia/current_state.txt" target="_blank">FILE </a>

Snapshots are taken automatically each day at **19:00 UTC**

- **pruning**: custom/100/0/10 | **indexer**: null

## Instructions

### Stop the service and reset the data

```
sudo systemctl stop celestia-appd
cp $HOME/.celestia-app/data/priv_validator_state.json $HOME/.celestia-app/priv_validator_state.json.backup
celestia-appd tendermint unsafe-reset-all --home $HOME/.celestia-app --keep-addr-book
rm -rf $HOME/.celestia-app/data
```

### Download snapshot

```
wget https://snapshot.yeksin.net/celestia/data.tar.gz && tar -xvf data.tar.gz -C $HOME/.celestia-app
mv $HOME/.celestia-app/priv_validator_state.json.backup $HOME/.celestia-app/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart celestia-appd
journalctl -u celestia-appd -f --no-hostname -o cat
```
