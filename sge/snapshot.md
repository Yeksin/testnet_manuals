# <img src="https://user-images.githubusercontent.com/110628975/204315172-754216f0-29ab-4dac-a482-c0c20d904f82.png" width="30" alt=""> Sge-testnet-1 Snapshot <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/>

## Check block height, snapshot time and file size from this <a href="https://snapshot.yeksin.net/sge/current_state.txt" target="_blank">FILE </a>

Snapshots are taken automatically each day at **19:00 UTC**

- **pruning**: custom/100/0/10 | **indexer**: null

## Instructions

### Stop the service and reset the data

```
sudo systemctl stop sged
cp $HOME/.sge/data/priv_validator_state.json $HOME/.sge/priv_validator_state.json.backup
sged tendermint unsafe-reset-all --home $HOME/.sge --keep-addr-book
rm -rf $HOME/.sge/data
```

### Download snapshot

```
wget https://snapshot.yeksin.net/sge/data.tar.gz && tar -xvf data.tar.gz -C $HOME/.sge
mv $HOME/.sge/priv_validator_state.json.backup $HOME/.sge/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart sged
journalctl -u sged -f --no-hostname -o cat
```
