# <img src="https://user-images.githubusercontent.com/110628975/211394335-6e797fe0-efed-4906-9c25-ec56b351b31f.png" width="30" alt=""> Lava-testnet-1 Snapshot <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/>

## Check block height, snapshot time and file size from this <a href="https://snapshot.yeksin.net/lava/current_state.txt" target="_blank">FILE </a>

Snapshots are taken automatically each day at **20:00 UTC**

- **pruning**: custom/100/0/10 | **indexer**: null

## Instructions

### Stop the service and reset the data

```
sudo systemctl stop lavad
cp $HOME/.lava/data/priv_validator_state.json $HOME/.lava/priv_validator_state.json.backup
lavad tendermint unsafe-reset-all --home $HOME/.lava --keep-addr-book
```

### Download snapshot

```
curl -L https://snapshot.yeksin.net/lava/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.lava
mv $HOME/.lava/priv_validator_state.json.backup $HOME/.lava/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart lavad
journalctl -u lavad -f --no-hostname -o cat
```
