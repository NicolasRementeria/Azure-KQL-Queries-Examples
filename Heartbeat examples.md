```
let interval = 1m;
Heartbeat 
| where Computer == "vmName"
| summarize heartbeats_per_bucket = count() by bin(TimeGenerated, interval), Computer
| project TimeGenerated, Availability = heartbeats_per_bucket
| sort by TimeGenerated asc
```

In this scenario, we'll be taking a single VM and getting its availability.

![alt text](https://github.com/NicolasRementeria/Azure-KQL-Queries-Examples/blob/master/Pictures/Heartbeat_ex_1.png "Heartbeat Example 1")