#!/bin/bash
sudo zgrep -h "TraceStartLeadershipCheck" /var/log/syslog | awk '{print $3, $(NF)}' > missedSlots
sed 's/[:,] */ /g' missedSlots > missedSlots1
awk '{if (NF == 15) print $1":"$2":"$3, $(NF-2); else print $1":"$2":"$3, $(NF-6);}' missedSlots1 > missedSlots
rm missedSlots1

((num = $(awk 'NR==1{print $NF}' missedSlots)))
((last = $(awk 'END{print $NF}' missedSlots)))
((first = num))
((miss = 0))
((hit = 0))
echo "firstSlot: $num"
echo "lastSlot:  $last"
echo ""
echo "miss: TimeStamp      SlotExpected       SlotSeen      SlotsMissed"
echo "================================================================="

while read -r line1 line2 remainder
 do
        if [[  "$num" -eq "$line2"  ]]
                then
                        ((num += 1))
                else
                        ((slots = line2 - num))
                        echo "miss: $line1       $num           $line2      $slots"
                        ((miss += line2 - num))
                        ((num = line2 + 1))
        fi
        ((hit += 1))
done < missedSlots
rm missedSlots
((total = num - first))
((num -= 1))

echo ""
echo "lastSlotCheck: $num"
echo "totalSlots: $total"
echo "hitSlots: $hit"
echo "missSlots: $miss"
