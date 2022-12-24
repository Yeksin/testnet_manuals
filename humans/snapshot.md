# <img src="https://user-images.githubusercontent.com/110628975/207418559-7dbc2397-9df8-4e34-b9fc-7f2365c3ed09.png" width="30" alt=""> Humans-testnet-1 Snapshot <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/>

## Check block height, snapshot time and file size from this <a href="https://snapshot.yeksin.net/humans/current_state.txt" target="_blank">FILE </a>

Snapshots are taken automatically each day at **19:00 UTC**

- **pruning**: custom/100/0/10 | **indexer**: null

## Instructions

### Stop the service and reset the data

```
sudo systemctl stop humansd
cp $HOME/.humans/data/priv_validator_state.json $HOME/.humans/priv_validator_state.json.backup
humansd tendermint unsafe-reset-all --home $HOME/.humans --keep-addr-book
rm -rf $HOME/.humans/data
```

### Download snapshot

```
wget https://snapshot.yeksin.net/humans/data.tar.gz && tar -xvf data.tar.gz -C $HOME/.humans
mv $HOME/.humans/priv_validator_state.json.backup $HOME/.humans/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart humansd
journalctl -u humansd -f --no-hostname -o cat
```
