# graylog


This is a docker-compose for 
Graylog
ElasticSearch
Mongodb

ver2_old/Gralog2 - ElasticSearch5 - Mongodb3

ver3/Gralog3 - ElasticSearch6 - Mongodb3

Troubleshooting:


error:
[1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]

solution
sysctl -w vm.max_map_count=262144

Configure Graylog behind a HAPROXY 
https://community.graylog.org/t/problem-with-use-of-tls-and-haproxy/9891/5
