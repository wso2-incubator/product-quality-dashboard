#!/bin/bash

#oldstr="wso2internaldev-engineering-dashboard.wso2apps.com"
#newstr=$hostname
#echo newstr
#find . -type f \( -name "carbon.xml" -o -name "designer.json"  \)  -exec sed -i'' -e 's|'"$oldstr"'|'"$newstr"'|' {} +

grep -rl 'wso2internaldev-engineering-dashboard.wso2apps.com' /wso2/wso2das-3.1.0 | xargs sed -i 's/wso2internaldev-engineering-dashboard.wso2apps.com/'"$hostname"'/g'
grep -rl '192.168.56.2:9092' /wso2/wso2das-3.1.0 | xargs sed -i 's/192.168.56.2:9092/'"$balhostname"'/g'
echo "Setting environment parameters completed."
sh /wso2/wso2das-3.1.0/bin/wso2server.sh -dashboardNode


