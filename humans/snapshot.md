# <img src="https://user-images.githubusercontent.com/110628975/209975177-fca87e8c-63df-4393-b4cd-4ee7fc8b28c2.png" width="30" alt=""> Humans-testnet-1 Snapshot <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/>

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
curl -L https://snapshot.yeksin.net/humans/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.humans
mv $HOME/.humans/priv_validator_state.json.backup $HOME/.humans/data/priv_validator_state.json
```

### Restart the service and check the log

```
sudo systemctl restart humansd
journalctl -u humansd -f --no-hostname -o cat
```
