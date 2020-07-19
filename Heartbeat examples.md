### Example 1, Single VM Availability

```
let interval = 1m;
Heartbeat 
| where Computer == "vmName"
| summarize heartbeats_per_bucket = count() by bin(TimeGenerated, interval), Computer
| project TimeGenerated, Availability = heartbeats_per_bucket
| sort by TimeGenerated asc
```

In this scenario, we'll be taking a single VM and getting its availability.

![alt text](https://github.com/NicolasRementeria/Azure-KQL-Queries-Examples/blob/master/Pictures/Heartbeat_ex_1_a.png "Heartbeat Example 1 A")

![alt text](https://github.com/NicolasRementeria/Azure-KQL-Queries-Examples/blob/master/Pictures/Heartbeat_ex_1_b.png "Heartbeat Example 1 B")

With this query we'll quickly notice where is a gap on Availability on the VM. 

In this practical scenario, there is a visible gap on our VM between 12PM and 6:00 PM on July 17th.

### Example 2, multiple VM Availability

```
let interval = 5m;
Heartbeat 
| where Computer has_any("VM1", "VM2", "VM3")
| summarize heartbeats_per_bucket = count() by bin(TimeGenerated, interval), Computer
| project TimeGenerated, Availability = heartbeats_per_bucket, Computer
| sort by TimeGenerated asc
| render timechart
```

In this scenario, we are take multiple VMs associated with this Log Analytics.

![alt text](https://github.com/NicolasRementeria/Azure-KQL-Queries-Examples/blob/master/Pictures/Heartbeat_ex_2_a.png "Heartbeat Example 2 A")
