#!/bin/bash
chain_id=`curl http://localhost:80/v1 | jq .chain_id`
cat << EOF | curl --data-binary @- http://localhost:9091/metrics/job/aptos_chain_id
  aptos_chain_id $chain_id
EOF
