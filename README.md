# map_code_in_R
code for map plotting

## fun with maps ##

There are many reasons to need figures of world or regional maps, the most obvious being distributions of species or collected samples.

R has a world maps package which can be installed in the R shell. Also install the mapdata package.

```
> install.packages("maps")
> install.packages("mapdata")
`

Starting up the library maps with the command produces a comical warning:

```
> library(maps)

 # ATTENTION: maps v3.0 has an updated 'world' map.        #
 # Many country borders and names have changed since 1990. #
 # Type '?world' or 'news(package="maps")'. See README_v3. #
```

Making a world map is easy with the `map()` command in this package, but first make a color palette that not hard on the eyes. I choose a grayscale, but this could be a rainbow, or any other color vector, based on say population or cheese production.

`> grayscale = colorRampPalette(c("#999999","#eeeeee"))(4)`

`> map('world', fill=TRUE, col=grayscale, mar=c(1,1,1,1))`

![test_world_map.png](https://github.com/wrf/map_code_in_R/blob/master/images/test_world_map.png)

I set the margins small to avoid too much white space.

The map allows zooming in by latitude (`ylim`) and longitude (`xlim`), so I can select an arbitrary region like in europe:

`> map('world', ylim=c(30,60), xlim=c(-10,30), fill=TRUE, col=grayscale, mar=c(1,1,1,1))`

![test_europe_map.png](https://github.com/wrf/map_code_in_R/blob/master/images/test_europe_map.png)

The ocean looks bad as white space, so it can be colored blue with `bg`:

`> map('world', ylim=c(40,55), xlim=c(-5,18), fill=TRUE, col=grayscale, mar=c(1,1,1,1), bg="#4466bb")`

Points can be added as well by lat/lon, say for my university in Munich. I extract the color from the Bavarian flag, and use a diamond.

```
> points(11.566,48.133, pch=18, cex=3, col="#0098d4")
> text(11.566,48.633,"LMU")
```

Various people had given me samples to work on, and those locations can be plotted the same way:

```
> slats = c(49.4166,48.783,47.586331,43.2964)
> slons = c(08.716,09.183,9.5988717,5.37)
> citynames = c("Heidelberg", "Stuttgart", "Kressbronn", "Marseille")
> points(slons, slats, pch=19, col="#ee8400", cex=3)
> text(slons+0.5, slats, citynames, pos=4)
```

![test_europe_map_blue_bg_cities.png](https://github.com/wrf/map_code_in_R/blob/master/images/test_europe_map_blue_bg_cities.png)

## finer coloring of countries with real data ##

For just plotting points, the maps function like any other plot where points or lines can be overlaid. However, for coloring by country, the color vector has to be set before creating the map.

In the previous example, this was done with a gray scale, which results in a more or less random gray color for each country, but enough to give contrast. To make something more interesting, the data has to be converted into a color, say as a log of population density or endangered species.

To do this, individual countries have to be assigned a color in the vector. To find out what countries we have, we start by creating a map.

`> dummymap = map("world")`

This will both display the world map with no parameters, and also generate the object dummymap of class "`map`". To get a list of countries, and some lakes, we can look at the attributes to get a list:

```
> attributes(dummymap)
$names
[1] "x"     "y"     "range" "names"

$class
[1] "map"
```

These all have different lengths:

```
> length(dummymap$x)
[1] 12711
> length(dummymap$y)
[1] 12711
> length(dummymap$range)
[1] 4
> length(dummymap$names)
[1] 1679
```

`$names` is the one with a list of all countries, islands, lakes, and some regional divisions. Of around 200 countries in the world, it is clear that some of them have to double up to get to 1679 things. For example, to get a list of everything that is part of the UK:

```
> dummymap$names[grep("UK",dummymap$names)]
 [1] "UK:Isle of Wight"                         
 [2] "UK:Wales:Anglesey"                        
 [3] "UK:Northern Ireland"                      
 [4] "UK:Scotland:Island of Arran"              
 [5] "UK:Scotland:Islay"                        
 [6] "UK:Scotland:Jura"                         
 [7] "UK:Scotland:Isle of Mull"                 
 [8] "UK:Scotland:Coll"                         
 [9] "UK:Scotland:Barra"                        
[10] "UK:Scotland:Ruhm"                         
[11] "UK:Scotland:South Uist"                   
[12] "UK:Scotland:Island of Skye"               
[13] "UK:Scotland:North Uist"                   
[14] "UK:Scotland:Isle of Lewis"                
[15] "UK:Great Britain"                         
[16] "UK:Scotland:Orkney Islands:South Ronaldsay"
[17] "UK:Scotland:Orkney Islands:Hoy"           
[18] "UK:Scotland:Orkney Islands:Mainland"      
[19] "UK:Scotland:Orkney Islands:Sanday"        
[20] "UK:Scotland:Orkney Islands:Westray"       
[21] "UK:Scotland:Shetland Islands:Mainland"    
[22] "UK:Scotland:Shetland Islands:Yell"        
[23] "UK:Scotland:Shetland Islands:Unst"  
```

For a small country, there are indeed a lot of entries. The `grep()` command returns a list of indexes that contain "UK", and these are pulled out of the big list of countries.

In terms of country specific data, I take some from the OECD from 2009 [regarding doctoral degrees by country](http://www.oecd-ilibrary.org/sites/sti_scoreboard-2011-en/02/01/index.html?contentType=/ns/StatisticalPublication,/ns/Chapter&itemId=/content/chapter/sti_scoreboard-2011-12-en&containerItemId=/content/serial/20725345&mimeType=text/html). There may be more recent data, but not for all countries. For simplicity, I download the data and convert just the table to csv, so it can be read easily by R. I made some manual changes to the data (such as removing years by some countries) to make the matching step easier. Because these data concern mostly European countries, I restrict my map:

`> euromap = map("world", fill=TRUE, ylim=c(35,65), xlim=c(-10,35), mar=c(1,1,1,1))`

The result of this is that $names has changed to contain only what is displayed:

```
> length(euromap$names)
[1] 203
```

This is important since the index used by the world map is not the same as a regional map. The countries have to be determined dynamically for each map.

`> phdsbycountry = read.table("~/Documents/oecd_phds_by_country.csv", header=TRUE, sep=",")`

So I choose the 4th column, which is percentage of PhDs awarded to women by country. I converted all #N/A to 0 for the csv, so I will first remove countries that have no data in that column.

`> phdsnoNA = phdsbycountry[phdsbycountry[,4]>0,]`

I then remove any whitespace from the country names and extract the index:

```
> countries = trimws(phdsnoNA[,5])
> euronums = match(countries, euromap$names)
```

I then exclude any entries that did not match by country. For example, United Kingdom and Slovak Republic find nothing, but UK:Great Britain and Slovakia are in the `$names`.

```
> euronumnoNA = euronums[!is.na(euronums)]
> countriesnoNA = countries[!is.na(euronums)]
> fractionwomennoNA = phdsnoNA[!is.na(euronums),4]
```

I want the map to be colorized by percentage of women, but the number of colors depends on the spread. Five or six colors might be suitable to provide reasonable contrast.

```
> range(fractionwomennoNA)
[1] 38 62
```

Since the range is 24, this could be done as a gradient. However, it is visually easier to understand as bins of percentage. I divide the data into 5 partitions of 5, making five colors including the first and last. Here I use yellow to green, since blue to pink is not effective for this dataset.

```
> fwcolors = colorRampPalette(c("#edb700","#15de00"))(5)
> floor((fractionwomennoNA-min(fractionwomennoNA))/5)+1
 [1] 1 3 5 4 2 3 2 2 1 2 2 2 2 1 1 2 1 3 3 3 2 3 2
> colorbyfw = fwcolors[floor((fractionwomennoNA-min(fractionwomennoNA))/5)+1]
```

The floor effectively bins the countries, and adding 1 is needed since these numbers are used to index the colors, and we cannot have an index of 0. The bulk of the countries end up with values of 1, 2 or 3, with only one country each with 4 or 5, Finland and Portugal, respectively.

I next make a blank vector for the colors; all countries are white until given a color. Then I add the colors for each country to the indexes defined by euronumnoNA. Finally, the map is generated.

```
> vecbycountry = rep("#ffffff", length(euromap$names) )
> vecbycountry[euronumnoNA]=colorbyfw

> euromap = map("world", fill=TRUE, ylim=c(35,65), xlim=c(-10,35), mar=c(1,1,1,1), col=vecbycountry, lwd=1.4)
```

![test_europe_map_oecd_phd_by_country.png](https://github.com/wrf/map_code_in_R/blob/master/images/test_europe_map_oecd_phd_by_country.png)

## fixing colors of islands ##

In the previous map, one obvious mistake is that Northern Ireland is not counted as part of the UK, nor any other British Isle. The same is true for Greece, Italy, France, Spain and Denmark.

This can be done the slow way, by going through each country one by one. For instance, the indexes can be retrieved for all countries and islands of the UK with grep. Then those indexes can be assigned whatever color the UK has.

```
> ukisles = grep("UK", euromap$names)
> vecbycountry[ukisles]=colorbyfw[grep("UK",countriesnoNA)]
```

Instead, after creating the blank color vector and assigning colors, I create a loop to go through each country and add any islands the same way.

```
> vecbycountry = rep("#ffffff", length(euromap$names) )
> vecbycountry[euronumnoNA]=colorbyfw
> for (ctry in countriesnoNA){
>    vecbycountry[grep(ctry,euromap$names)] = colorbyfw[ grep(ctry,countriesnoNA)]
> } 
```

The final map looks like this, where all islands correspond to their mainland (incidentally except the UK, which was renamed in the original data table to UK:Great Britain; this is added on for completeness.)

![test_europe_map_oecd_phd_by_country_w_islands.png](https://github.com/wrf/map_code_in_R/blob/master/images/test_europe_map_oecd_phd_by_country_w_islands.png)
