#!/bin/bash 
yum install jq 
yum install rubygem-httpclient 

cat > /usr/local/bin/satellite_report << EOF
ruby /usr/local/bin/generate_report.rb 2>/dev/null 
EOF
chmod a+x /usr/local/bin/satellite_report
cp generate_report.rb /usr/local/bin/generate_report.rb
