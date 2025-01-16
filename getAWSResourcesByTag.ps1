# Define tag key and value
$tagKey = "ProjectCode"
$tagValue = "101"

# Query AWS resources with the specified tag key and value
aws resourcegroupstaggingapi get-resources `
    --tag-filters Key=$tagKey,Values=$tagValue `
    --output json | ConvertFrom-Json | Select-Object -ExpandProperty ResourceTagMappingList
