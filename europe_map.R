# experimentation with world maps

library(maps)
library(mapdata) # needed for Hires ( hi-res )
grayscale = colorRampPalette(c("#999999","#eeeeee"))(4)

png(filename="~/git/map_code_in_R/images/test_world_map.png", width=800,height=400)
map('world', fill=TRUE, col=grayscale, mar=c(1,1,1,1))
dev.off()

oceancol = "#4466bb"

# make map of europe
png(filename="~/git/map_code_in_R/images/test_europe_map.png", width=600,height=600)
map('world', ylim=c(30,60), xlim=c(-10,30), fill=TRUE, col=grayscale, mar=c(1,1,1,1))
dev.off()

png(filename="~/git/map_code_in_R/images/test_europe_map_blue_bg_cities.png", width=600,height=600)
map('worldHires', ylim=c(40,55), xlim=c(-5,18), fill=TRUE, col=grayscale, mar=c(1,1,1,1), bg=oceancol)
points(11.566,48.133, pch=18, cex=3, col="#0098d4")
text(11.566,48.633,"LMU")
dev.off()

slats = c(49.4166,48.783,47.586331,43.2964)
slons = c(08.716,09.183,9.5988717,5.37)
citynames = c("Heidelberg","Stuttgart","Kressbronn","Marseille")
points(slons, slats, pch=19, col="#ee8400", cex=3)
text(slons+0.5, slats, citynames, pos=4)

# to plot swiss flag on geneva
points(6.15,46.20, pch=15, col="red", cex=3)
points(6.15,46.20, pch=3, col="white", cex=1.1, lwd=4)
# to plot swiss flag on zurich
points(8.55,47.366, pch=15, col="red", cex=3)
points(8.55,47.366, pch=3, col="white", cex=1.1, lwd=4)

dummymap = map("world")
which(dummymap$names=="Russia")
# [1] 1323
whitevec = rep("#ffffff",1679)
whitevec[1323]="green"


# colored world map by index
countries = c("Italy", "Russia", "Germany", "Brazil")
countrynums = match(countries, dummymap$names)
vecbycountry = rep("#ffffff",length(dummymap$names))
vecbycountry[countrynums]="green"

euromap = map("world", ylim=c(30,60), xlim=c(-10,30), mar=c(1,1,1,1))
#countries = c("Italy", "Russia", "Germany", "UK:Great Britain", "UK:Northern Ireland")
ukisles = grep("UK", euromap$names)
euronums = match(countries, euromap$names)
vecbycountry = rep("#ffffff",length(euromap$names) )
vecbycountry[euronums]="green"
lakes = match("Lake Constance", euromap$names)
vecbycountry[lakes]=oceancol
euromap = map("world", fill=TRUE, ylim=c(30,60), xlim=c(-10,30), mar=c(1,1,1,1), col=vecbycountry, bg=oceancol )

# colored europe by OECD phd data
png(filename="~/git/images/test_europe_map_oecd_phd_by_country_w_islands.png", width=600,height=600)
euromap = map("world", ylim=c(35,65), xlim=c(-10,35), mar=c(1,1,1,1))
phdsbycountry = read.table("~/git/map_code_in_R//data/oecd_phds_by_country.csv",header=TRUE,sep=",")
phdsnoNA = phdsbycountry[phdsbycountry[,4]>0,]
countries = trimws(phdsnoNA[,5])
euronums = match(countries,euromap$names)
#euronums = na.omit(euronums)
euronumnoNA = euronums[!is.na(euronums)]
countriesnoNA = countries[!is.na(euronums)]
fractionwomennoNA = phdsnoNA[!is.na(euronums),4]
#fwomencolors = colorRampPalette(c("#edb700","#15cd00"))(max(fractionwomennoNA)-min(fractionwomennoNA)+1)
fwomencolors = colorRampPalette(c("#edb700","#15de00"))(5)
#cbyfwcolored = fwomencolors[(fractionwomennoNA-min(fractionwomennoNA)+1)]
cbyfwcolored = fwomencolors[floor((fractionwomennoNA-min(fractionwomennoNA))/5)+1]
ukisles = grep("UK", euromap$names)
greekisles = grep("Greece", euromap$names)
danishisles = grep("Denmark", euromap$names)
itisles = grep("Italy", euromap$names)
spanishisles = grep("Spain", euromap$names)
frisles = grep("France", euromap$names)
vecbycountry = rep("#ffffff",length(euromap$names) )
vecbycountry[euronumnoNA]=cbyfwcolored
for (ctry in countriesnoNA){
	vecbycountry[grep(ctry, euromap$names)]=cbyfwcolored[grep(ctry,countriesnoNA)]
}

vecbycountry[ukisles]=cbyfwcolored[grep("UK",countriesnoNA)]
vecbycountry[greekisles]=cbyfwcolored[grep("Greece",countriesnoNA)]
vecbycountry[danishisles]=cbyfwcolored[grep("Denmark",countriesnoNA)]
vecbycountry[itisles]=cbyfwcolored[grep("Italy",countriesnoNA)]
vecbycountry[spanishisles]=cbyfwcolored[grep("Spain",countriesnoNA)]
vecbycountry[frisles]=cbyfwcolored[grep("France",countriesnoNA)]
euromap = map("world", fill=TRUE, ylim=c(35,65), xlim=c(-10,35), mar=c(1,1,1,1), col=vecbycountry, lwd=1.4)
dev.off()
