# <img src="https://user-images.githubusercontent.com/110628975/209974782-f959bde4-68e2-4a90-9b83-2fdd3fbfdcae.png" width="30" alt=""> Gitopia-janus-testnet-2 Snapshot <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/>

## Check block height, snapshot time and file size from this <a href="https://snapshot.yeksin.net/gitopia/current_state.txt" target="_blank">FILE </a>

Snapshots are taken automatically each day at **20:00 UTC**

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
curl -L https://snapshot.yeksin.net/gitopia/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.gitopia
mv $HOME/.gitopia/priv_validator_state.json.backup $HOME/.gitopia/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart gitopiad
journalctl -u gitopiad -f --no-hostname -o cat
```
