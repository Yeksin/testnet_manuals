
# <img src="https://user-images.githubusercontent.com/110628975/207869212-823689d2-fa45-47dd-af93-50a8b008bddc.png" width="30" alt=""> Nolus-rila Snapshot <img src="https://user-images.githubusercontent.com/110628975/200305287-749a5db9-d46c-4951-a1ec-cb2852d7af1d.png" width="30"/>

## Check block height, snapshot time and file size from this <a href="https://snapshot.yeksin.net/nolus/current_state.txt" target="_blank">FILE </a>

Snapshots are taken automatically each day at **20:00 UTC**

- **pruning**: custom/100/0/10 | **indexer**: null

## Instructions

### Stop the service and reset the data

```
sudo systemctl stop nolusd
cp $HOME/.nolus/data/priv_validator_state.json $HOME/.nolus/priv_validator_state.json.backup
nolusd tendermint unsafe-reset-all --home $HOME/.nolus --keep-addr-book
```

### Download snapshot

```
curl -L https://snapshot.yeksin.net/nolus/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.nolus
mv $HOME/.nolus/priv_validator_state.json.backup $HOME/.nolus/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart nolusd
journalctl -u nolusd -f --no-hostname -o cat
```
