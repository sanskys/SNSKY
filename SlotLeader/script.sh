#!/usr/bin/env bash

/usr/local/bin/cncli sync --host 0.0.0.0 --port 6000 --no-service

MYPOOLID=$(cat $NODE_HOME/stakepoolid.txt)
echo "LeaderLog - POOLID $MYPOOLID"

SNAPSHOT=$(/usr/local/bin/cardano-cli query stake-snapshot --stake-pool-id $MYPOOLID --mainnet)
POOL_STAKE=$(jq .poolStakeMark <<< $SNAPSHOT)
ACTIVE_STAKE=$(jq .activeStakeMark <<< $SNAPSHOT)
POOL_STAKE_SET=$(jq .poolStakeSet <<< $SNAPSHOT)
ACTIVE_STAKE_SET=$(jq .activeStakeSet <<< $SNAPSHOT)
TIMEZONE="Etc/UTC"
echo $SNAPSHOT, $POOL_STAKE, $ACTIVE_STAKE, $POOL_STAKE_SET, $ACTIVE_STAKE_SET
MYPOOL=$(/usr/local/bin/cncli leaderlog --pool-id $MYPOOLID --pool-vrf-skey ${NODE_HOME}/vrf.skey --byron-genesis ${NODE_HOME}/mainnet-byron-genesis.json --shelley-genesis ${NODE_HOME}/mainnet-shelley-genesis.json --pool-stake $POOL_STAKE --active-stake $ACTIVE_STAKE --tz $TIMEZONE --ledger-set next)
#MYPOOL=$(/usr/local/bin/cncli leaderlog --pool-id $MYPOOLID --pool-vrf-skey ${NODE_HOME}/vrf.skey --byron-genesis ${NODE_HOME}/mainnet-byron-genesis.json --shelley-genesis ${NODE_HOME}/mainnet-shelley-genesis.json --pool-stake $POOL_STAKE_SET --active-stake $ACTIVE_STAKE_SET --tz $TIMEZONE --ledger-set current)

EPOCH=`jq .epoch <<< $MYPOOL`
SLOTS=0
SLOTS=`jq .epochSlots <<< $MYPOOL`
IDEAL=`jq .epochSlotsIdeal <<< $MYPOOL`
PERFORMANCE=`jq .maxPerformance <<< $MYPOOL`
ASSIGNED=`jq .assignedSlots <<< $MYPOOL`
echo "Epoch: $EPOCH, SLOTS: $SLOTS"

######################################################################################
AT=$(jq '.[].at' <<< $ASSIGNED | sed  -e 's/.......$//' -e 's/T/ /g' -e 's/"/''/g')
SLOT=$(jq '.[].slot' <<< $ASSIGNED)
NO=$(jq '.[].no' <<< $ASSIGNED)

paste <(echo "$AT") <(echo "$SLOT") <(echo "$NO") --delimiters , > slot.csv
sed -i '1 i\Time,Slot,No' slot.csv
cat slot.csv
#######################################################################################
