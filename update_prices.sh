#!/bin/bash


# if [ $1 == '-u' ] 
# then
      echo "update anagrafica OSM and prezzi alle 8"
      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      rm -f anagrafica_impianti_osm.csv
      rm -f prezzo_alle_8.csv
      wget -O anagrafica_impianti_osm.csv "https://overpass-api.de/api/interpreter?data=%5Bout%3Acsv%28%22ref%3Amise%22%2C%22name%22%2C%3A%3Alat%2C%3A%3Alon%2C%22start%5Fdate%22%2C%22description%22%2C%22operator%22%3Bfalse%3B%22%3B%22%29%5D%3Barea%5B%22name%22%3D%22Friuli%2DVenezia%20Giulia%22%5D%5B%22admin%5Flevel%22%3D%224%22%5D%2D%3E%2Ea%3B%28nwr%5B%22amenity%22%3D%22fuel%22%5D%28area%2Ea%29%3B%29%3Bout%20center%3B%0A"  --no-check-certificate
      wget https://www.mise.gov.it/images/exportCSV/prezzo_alle_8.csv --no-check-certificate
# fi


echo "ref;brand;lat;lon;;;operator;fuel;price;isself;updated" > fuel.csv
echo "ref;brand;lat;lon;;;operator;fuel;price;isself;updated" > benzina.csv
echo "ref;brand;lat;lon;;;operator;fuel;price;isself;updated" > gasolio.csv
echo "ref;brand;lat;lon;;;operator;fuel;price;isself;updated" > gpl.csv
echo "ref;brand;lat;lon;;;operator;fuel;price;isself;updated" > metano.csv

join -t";" <(sort anagrafica_impianti_osm.csv) <(sed 2d prezzo_alle_8.csv | sort) >> fuel.csv
sed -i 's/;1;/;SelfService;/g' fuel.csv
sed -i 's/;0;/;Servito;/g' fuel.csv

cat fuel.csv | grep ";Benzin\|;Blue Super" >> benzina.csv
cat fuel.csv | grep ";Gasol\|;Blue Diesel" >> gasolio.csv
cat fuel.csv | grep ";GPL" >> gpl.csv
cat fuel.csv | grep ";Metano" >> metano.csv
