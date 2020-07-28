# Azure-KQL-Queries-Examples

## data_purger.ps1

Given a Workspace ID, a SPN with Purge Data RBAC Role, and the Table Name, you'll be able to remove Logs from a Log Analytics with some operator and value logic you want to choose.

For example, remove all logs based on TimeGenerated that are older (greater) than "2020-07-27T19:18:30.000" (datetime format on UTC).
