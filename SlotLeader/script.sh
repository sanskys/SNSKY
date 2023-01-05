#!/usr/bin/env bash

#cardano-cli leadership query
POOLID=$(cat $NODE_HOME/stakepoolid.txt)
echo "Leadership Query Starting for POOL - $POOLID"
cardano-cli query leadership-schedule --mainnet --stake-pool-id $POOLID --vrf-signing-key-file ${NODE_HOME}/vrf.skey --genesis ${NODE_HOME}/shelley-genesis.json --next > leadership.txt
echo "Leadership Query - Finished"

#Removing first two lines
echo "$(tail -n +3 leadership.txt)" > leadership.txt

#Writing in Grafana CSV format
awk '{print $2,$3","$1","NR}' leadership.txt > slot.csv
sed -i '1 i\Time,Slot,No' slot.csv

#Cleaning up
rm leadership.txt

#Show Result
cat slot.csv
