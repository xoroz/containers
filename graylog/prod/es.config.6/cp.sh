#copy all 
#7df8aedf24b:/usr/share/elasticsearch/config/*
P=$(pwd)
D="/usr/share/elasticsearch/config/ingest-geoip/*"
for f in $(docker exec -it 97df8aedf24b bash -c "ls $D"); do
     echo 97df8aedf24b:$f |tee -a list2.txt

     docker cp 97df8aedf24b:${f} $P
done

