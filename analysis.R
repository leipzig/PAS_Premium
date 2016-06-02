library(leaflet)
library(RColorBrewer)
require(lubridate)
require(dplyr)
library(rgdal)
library(leaflet)
library(htmlwidgets)
library(webshot)
#http://www.westphillylocal.com/2011/05/11/in-catchment-or-not-penn-alexander-will-be-forced-to-turn-new-students-away/

if(! 'inputfile' %in% ls() ){inputfile<-"intermediates/results_extended.txt"}
read.table(inputfile,header=TRUE,sep = "\t",stringsAsFactors = FALSE,quote = "") %>% filter(sale_price > 100 & sale_price < 2000000) %>% filter(sqft>0 & sqft<5000) %>% distinct() -> aprops




aprops$type<-"RESIDENCE"
aprops[str_detect(aprops$description,"^APT"),"type"]<-"APT_BLDG"
aprops[str_detect(aprops$description,"CONDO"),"type"]<-"RESIDENCE"
aprops[str_detect(aprops$description,"CONV.APT"),"type"]<-"RENTAL"
aprops[str_detect(aprops$description,"(STORE|HOTEL|REST)"),"type"]<-"COMMERCIAL"
aprops[str_detect(aprops$description,"VACANT LAND"),"type"]<-"LAND"
aprops %>% filter(type != "LAND" & type != "COMMERCIAL" & type != 'APT_BLDG') -> props
colors<-brewer.pal(8, "Set1")
props$color<-sapply(props$catchment_side,function(x){ifelse(x=='inside',colors[1],colors[2])})
getinsideoutside<-function(acct){
  x<-props[props$account_number==acct,"catchment_side"][1]
  return(ifelse(x=='inside',colors[1],colors[2]))
}



# parcels in university city
ucshapes <- readOGR("data/shapefiles/Parcels_UniversityCity.shp",layer = "Parcels_UniversityCity",verbose = TRUE)
# get on common ground
propshapes<-subset(ucshapes,ucshapes$BRT_ID %in% props$account_number)
props<-subset(props,props$account_number %in% ucshapes$BRT_ID)
prop_xy <- spTransform(propshapes, CRS("+proj=longlat +datum=WGS84"))
save(prop_xy,file="prop_xy.RData")

#cluster
dists<-dist(ldply(prop_xy@polygons,function(x){c(x@labpt[1],x@labpt[2])}))
hc <- hclust(dists)
clust <- cutree(hc, 8)
prop_xy$clust<-clust

#apply clusters to the props
clustlookup<-prop_xy$clust
names(clustlookup)<-prop_xy$BRT_ID
props$clust<-sapply(props$account_number,function(x){clustlookup[[as.character(x)]]})
props$clust<-as.factor(props$clust)

# the Penn Alexander shapefile
passhape <- readOGR("data/shapefiles/pennalexandercatchment_poly.shp",layer="pennalexandercatchment_poly",verbose=TRUE)

mainmap <- leaflet() %>%
  addTiles() %>%
  addPolygons(data = prop_xy, color = sapply(prop_xy$BRT_ID,getinsideoutside),popup=prop_xy$ADDRESS) %>%
  addPolygons(data = passhape)
mainmap
saveWidget(mainmap, "temp.html", selfcontained = FALSE)
webshot("temp.html", file = "intermediates/mainmap.png",cliprect = "viewport")



clustmap <- leaflet() %>%
  addTiles() %>%
  addPolygons(data = prop_xy, color = colors[prop_xy$clust])
clustmap
saveWidget(clustmap, "temp.html", selfcontained = FALSE)
webshot("temp.html", file = "intermediates/clustmap.png",cliprect = "viewport")



#
props %>% group_by(catchment_side) %>% summarize(mean_price=mean(sale_price))

# not significant
t.test(props %>% filter(catchment_side == 'inside') %>% select(sale_price), props %>% filter(catchment_side == 'outside') %>% select(sale_price))

#these are too early for unix time
props[props$property_id=='8450000512',"sale_date"]<-'1959-02-06'
props[props$property_id=='8859000110',"sale_date"]<-'1964-01-15'
props[props$property_id=='5138004624',"sale_date"]<-'1966-01-28'
props[props$property_id=='5138004638',"sale_date"]<-'1960-10-31'
props[props$property_id=='7396004627',"sale_date"]<-'1965-09-24'
props[props$property_id=='4914004633',"sale_date"]<-'1966-06-17'
props[props$property_id=='4914004743',"sale_date"]<-'1961-06-23'

#four-fers
#http://property.phila.gov/?o=APARTMENTS%20AT%20PENN%20INC
props[props$property_id=='15620040352',"sale_price"]<-152500
props[props$property_id=='1562004035',"sale_price"]<-152500
props[props$sale_date=='2011-11-14',"sale_price"]<-1760000/4

props$sale_date<-as.Date(props$sale_date)

#before 1980 pretty sparse...and useless
props %>% filter(sale_date>=as.Date('1980-01-01')) -> props

case_shiller<-read.csv("data/references/cities-month.csv")
case_shiller$year<-year(case_shiller$Date)
case_shiller$month<-month(case_shiller$Date)
getcaseshiller<-function(ayear,amonth){
  if(ayear<1987){return(63)}
  if(ayear>2015){return(188)}
  x<-subset(case_shiller,year==ayear & month==amonth)
  return(x$National.US[1])
}
props$caseshiller<-apply(props,1,function(y){getcaseshiller(year(y['sale_date']),month(y['sale_date']))})


# adjust for inflation
monthly_cpi <-
  read.csv("data/references/CPIAUCSL.csv", header = TRUE)
monthly_cpi$cpi_year <- year(monthly_cpi$DATE)
yearly_cpi <- monthly_cpi %>% group_by(cpi_year) %>% summarize(cpi = mean(VALUE))
yearly_cpi$adj_factor <- yearly_cpi$cpi/yearly_cpi$cpi[yearly_cpi$cpi_year == 2016]
adjustforinflation<-function(year){
  return(sapply(year,function(x){as.numeric(yearly_cpi[yearly_cpi$cpi_year==x,"adj_factor"][1])}))
}


# add categorical variables
props$adj_price<-props$sale_price/adjustforinflation(year(props$sale_date))
props$adj_price_sqft<-props$adj_price/props$sqft
props$block<-paste((as.integer(str_match(props$full_address,"^(\\d+)\\S* (.+)")[,2]) %% 100)*100,str_match(props$full_address,"^(\\d+)\\S* (.+)")[,3])
props$pas_era <- year(props$sale_date)>=2001
props$lottery <-year(props$sale_date)>=2011 & year(props$sale_date)<=2014
props$in_catchment<-as.logical(props$catchment_side=='inside')
props$decade<-year(props$sale_date) - (year(props$sale_date) %% 10)

save(props, prop_xy, file="intermediates/properties.RData",compress=TRUE)
