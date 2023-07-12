#!/bin/bash

echo ""
echo ""
echo "update anagrafica OSM and prezzi alle 8"
echo ""
echo ""

rm -f anagrafica_impianti_osm.csv
rm -f prezzo_alle_8.csv
wget -O anagrafica_impianti_osm.csv "https://overpass-api.de/api/interpreter?data=%5Bout%3Acsv%28%22ref%3Amise%22%2C%22name%22%2C%3A%3Alat%2C%3A%3Alon%2C%22start%5Fdate%22%2C%22description%22%2C%22operator%22%3Bfalse%3B%22%3B%22%29%5D%3Barea%5B%22name%22%3D%22Friuli%2DVenezia%20Giulia%22%5D%5B%22admin%5Flevel%22%3D%224%22%5D%2D%3E%2Ea%3B%28nwr%5B%22amenity%22%3D%22fuel%22%5D%28area%2Ea%29%3B%29%3Bout%20center%3B%0A"  --no-check-certificate
# wget "https://overpass-api.de/api/interpreter?data=%5Bout%3Acsv%28%22ref%3Amise%22%2C%22name%22%2C%3A%3Alat%2C%3A%3Alon%2C%22start%5Fdate%22%2C%22description%22%2C%22operator%22%3Bfalse%3B%22%3B%22%29%5D%3Barea%5B%22short_name%22%3D%22VE%22%5D%5B%22admin%5Flevel%22%3D%226%22%5D%2D%3E%2Ea%3B%28nwr%5B%22amenity%22%3D%22fuel%22%5D%28area%2Ea%29%3B%29%3Bout%20center%3B%0A"  --no-check-certificate -O - >> anagrafica_impianti_osm.csv
wget https://www.mise.gov.it/images/exportCSV/prezzo_alle_8.csv --no-check-certificate

DOWNLOAD_DATE=`head -1 prezzo_alle_8.csv | awk -F' ' '{print $3}'`

## begin filter prices from date ##

#date --date="14 days ago" +'%Y%m%d'
#20220609

STARTDATE=`date --date="7 days ago" +'%Y%m%d'`

# truncate hour and minute and remove first line ("Estrazione del")
# awk -i inplace -F " " 'NR>1 {  print $1 }' prezzo_alle_8.csv
#awk -i inplace -F " " ' {  print $1 }' prezzo_alle_8.csv
sed -i -r "s/ [0-9]+:[0-9]+:[0-9]+$//g" prezzo_alle_8.csv

# 31782;Benzina;1.299;0;22/02/2022
# 38188;Benzina;1.599;1;04/06/2022
# 4726;Benzina;1.879;0;16/11/2021 


# date military format
awk -i inplace  -F";" '{ split($5,d,/\//); print $1";"$2";"$3";"$4";"d[3]d[2]d[1] }' prezzo_alle_8.csv
# sed -i '1 i\idImpianto;descCarburante;prezzo;isSelf;dtComu'  prezzo_alle_8.csv

# only prices from STARTDATE (7 days ago)
awk -i inplace -F';' -v da=$STARTDATE ' $5 > da ' prezzo_alle_8.csv 

# idImpianto;descCarburante;prezzo;isSelf;dtComu
# 41125;Benzina;1.549;1;20220615
# 43517;Benzina;1.389;1;20220613
# 26612;Benzina;1.489;0;20220614

## end filter prices from date ##


echo "ref;brand;lat;lon;;;operator;fuel;price;isself;updated" > fuel.csv
echo "ref;brand;lat;lon;;;operator;fuel;price;isself;updated" > benzina.csv
echo "ref;brand;lat;lon;;;operator;fuel;price;isself;updated" > gasolio.csv
echo "ref;brand;lat;lon;;;operator;fuel;price;isself;updated" > gpl.csv
echo "ref;brand;lat;lon;;;operator;fuel;price;isself;updated" > metano.csv

join -t";" <(sort anagrafica_impianti_osm.csv) <(sed 2d prezzo_alle_8.csv | sort) >> fuel.csv
sed -i 's/;1;/;SelfService;/g' fuel.csv
sed -i 's/;0;/;Servito;/g' fuel.csv

# Frequenza
# Benzina 34489
# Gasolio 34440
# GPL 4494
# Metano 1494

#cat fuel.csv | grep ";Benzin\|;Blue Super" >> benzina.csv
cat fuel.csv | grep ";Benzina;" >> benzina.csv
max=`awk  '($9+0 > price+0 || price == "") && $1+0 > 0 { price = $9 } END { print price } ' FS=";" benzina.csv`
awk -i inplace -v max=$max ' {printf "%s;%02d\n",$0,10*$9/max} '  FS=";" benzina.csv

#cat fuel.csv | grep ";Gasol\|;Blue Diesel" >> gasolio.csv
cat fuel.csv | grep ";Gasolio;" >> gasolio.csv
max=`awk  '($9+0 > price+0 || price == "") && $1+0 > 0 { price = $9 } END { print price } ' FS=";" gasolio.csv`
awk -i inplace -v max=$max ' {printf "%s;%02d\n",$0,10*$9/max} '  FS=";" gasolio.csv

cat fuel.csv | grep ";GPL;" >> gpl.csv
max=`awk  '($9+0 > price+0 || price == "") && $1+0 > 0 { price = $9 } END { print price } ' FS=";" gpl.csv`
awk -i inplace -v max=$max ' {printf "%s;%02d\n",$0,10*$9/max} '  FS=";" gpl.csv


cat fuel.csv | grep ";Metano;" >> metano.csv
max=`awk  '($9+0 > price+0 || price == "") && $1+0 > 0 { price = $9 } END { print price } ' FS=";" metano.csv`
awk -i inplace -v max=$max ' {printf "%s;%02d\n",$0,10*$9/max} '  FS=";" metano.csv
