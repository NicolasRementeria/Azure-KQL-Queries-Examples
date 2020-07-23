# Calculate SLO, %Pass and Remaining Error Budget

For this query to work, the  table must contain an aggregation of the availability of the product.

Could be Heartbeat, could be the total transactions of an App Service (where the Error Rate can be calculated being 200 an success and >= 500 as Failure), or in this case, there is an automation that as a result prints in the table, over the status_s column, a Running as a success, and non-Running as failure.

```
let secondsInPeriod =  toreal(now()/1000);
let targetslo = 0.97;
<Table> 
| where serverName_s has_any ("VM1", "VM2", "VM3")
| extend value = iff(status_s == "Running", 1, 0)
| summarize avg(value), healthyCount=countif(status_s == "Running"), totalCount=count() by serverName_s, bin(TimeGenerated, 10m)
| summarize Pass=sum(healthyCount), Total=sum(totalCount), SLO=targetslo * 100, Availability = sum(avg_value)/count() * 100, RemainingErrorBudget = iff(targetslo < sum(avg_value)/count(), secondsInPeriod * (sum(avg_value)/count() - targetslo), toreal(0)) by serverName_s
| project Target = serverName_s, Pass, Total, SLO, Availability, RemainingErrorBudget
```

- We take secondsInPeriod as a generic variable to contains a 24hs date into seconds.
- The target SLO can be changed as requeriment for the app.
- servername_s column can contain any number of linked VMs to this LAW
- Create a column named "value" that contains a 1 if the log row shows a Running, if not will contain a 0
- Create buckets of 10min per datapoint per VM, with the healthy counts and total counts of this period. 

  - For example, a bad bucket:

  ![alt text](https://github.com/NicolasRementeria/Azure-KQL-Queries-Examples/blob/master/Pictures/SLO_ex_1_a.png "SLO Example 1 A")

  We see here a number of failures. 

  The Total Count shows the number of tests made on this bucket of 10min. The Healthy Count shows how many Running were found on this bucket, and avg_value is the average.

  The ideal scenario would be that avg_value is 1. If it's less, the Error Budget will be impacted.

- We create a summarization per VM, where:
  - Target = VM name
  - Pass = Number of Healthy count
  - Total = Number of total count
  - SLO = It's the % designed to reach
  - Availability = It's the current % of SLO reached
  - RemainingErrorBudget: This vary depending on the period of time measured by TimeRange from Log Analytics.

![alt text](https://github.com/NicolasRementeria/Azure-KQL-Queries-Examples/blob/master/Pictures/SLO_ex_1_b.png "SLO Example 1 B")

In this scenario, we are taking only the last hour, to check if the SLO target was achieved.

![alt text](https://github.com/NicolasRementeria/Azure-KQL-Queries-Examples/blob/master/Pictures/SLO_ex_1_c.png "SLO Example 1 C")

And here we take the last 7 days.

![alt text](https://github.com/NicolasRementeria/Azure-KQL-Queries-Examples/blob/master/Pictures/SLO_ex_1_d.png "SLO Example 1 D")

We even can graph this on Grafana, coloring the Pass/Fail and transforming the RemainingErrorBudget into remaining time until the Error Budget is reached.

```

Grafana tweaks into the query:
let secondsInPeriod = ($__to - $__from)/1000;
let targetslo = 0.97;
<TABLE>
| where $__timeFilter(TimeGenerated) 
| where serverName_s has_any ($vm)
| extend value = iff(status_s == "Running", 1, 0)
| summarize avg(value), healthyCount=countif(status_s == "Running"), totalCount=count() by serverName_s, bin(TimeGenerated, 10m)
| summarize Pass=sum(healthyCount), Total=sum(totalCount), SLO=targetslo * 100, availability = sum(avg_value)/count() * 100, RemainingErrorBudget = iff(targetslo < sum(avg_value)/count(), secondsInPeriod * (sum(avg_value)/count() - targetslo), toreal(0)) by serverName_s
| project Target= serverName_s, Pass, Total, SLO, Availability=availability, RemainingErrorBudget
```
