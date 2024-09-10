#Ping Test
param(
[string]$vm1_name
)

Test-NetConnection $vm1_name -InformationLevel Quiet
