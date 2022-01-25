AT=$(jq '.[].at' <<< $ASSIGNED | sed  -e 's/.......$//' -e 's/T/ /g' -e 's/"/''/g')
SLOT=$(jq '.[].slotInEpoch' <<< $ASSIGNED)
NO=$(jq '.[].no' <<< $ASSIGNED)

paste <(echo "$AT") <(echo "$SLOT") <(echo "") <(echo "$NO") --delimiters , > temp.csv
awk -F ',' -v OFS=',' '$2 < 50000 { $3 = 50000 }1' temp.csv > slot.csv
rm temp.csv

sed -i '1 i\Time,Slot,Height,No' slot.csv
cat slot.csv
