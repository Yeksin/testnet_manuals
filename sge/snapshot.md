# <img src="https://user-images.githubusercontent.com/110628975/209975880-b906168e-ad18-48ad-b1c8-c5a7ad8332ac.png" width="30" alt=""> Sge-testnet-1 Snapshot <img src="https://user-images.githubusercontent.com/110628975/209973852-c4fc58fc-7a88-429b-97e9-47a693d6db9f.png" width="30"/>

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
