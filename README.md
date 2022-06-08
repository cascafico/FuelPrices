# FuelPrices

Prices are downloaded from italian Ministero dello Sviluppo Economico (MISE).
Fuel stations are downloaded in csv format from Openstreetmap (OSM).

## Prices processing
Via bash, for each fuel type a max price is stored and used to set price intervals to be color-rendered in a map

## Fuel stations processing
On a region or province base, OSM data (amenity=fuel) is being downloaded via overpass query:
  [out:csv("ref:mise","name",::lat,::lon,"ultimo_aggiornamento","descrizione"; false;";")];
  area[name="Friuli-Venezia Giulia"][admin_level=4]->.a;
  ( 
   nwr(area.a)[amenity=fuel];
  );
  out center;

# Notes
To be usable, output map needs updated OSM tag "ref:mise", since this vale links prices to OSM objects.
