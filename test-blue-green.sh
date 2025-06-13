#!/bin/bash

echo "Testing blue-green deployment with continuous requests..."

# Initial status
echo "Initial status: Requests should go to BLUE deployment"
echo ""

# Keep making requests every 2 seconds
while true; do
  echo "Main service:"
  curl -s http://my-app.local/ | grep version
  
  echo "Blue service:"
  curl -s http://my-app.local/blue | grep version
  
  echo "Green service:"
  curl -s http://my-app.local/green | grep version
  
  echo "----------------------------"
  sleep 2
done
