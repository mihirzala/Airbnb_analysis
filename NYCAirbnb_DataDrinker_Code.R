---
title: "Exploration of NYC Airbnb"
author: "Data Drinkers"
output: html_document
---
```{r}
#install.packages("tidytext")
```

```{r}
my_packages <- c("tidyverse","ggplot2","dplyr", "tidytext", "glue", "scales")
lapply(my_packages, require, character.only = TRUE)
```

# Filtering the data to remove out of scope / redundant attributes
```{r}
listings <- read_csv('listings.csv')
listings_sel <- listings[c('id', 'last_scraped', 'name', 'host_id', 'host_name', 'host_since', 'host_location', 'host_about','host_response_time','host_response_rate','host_acceptance_rate', 'host_is_superhost', 'host_has_profile_pic', 'host_identity_verified', 'neighbourhood_cleansed', 'neighbourhood_group_cleansed', 'latitude', 'longitude', 'property_type', 'room_type', 'accommodates', 'bathrooms_text', 'bedrooms', 'beds', 'amenities', 'price', 'minimum_nights','maximum_nights','minimum_minimum_nights','has_availability', 'first_review', 'last_review', 'number_of_reviews','number_of_reviews_ltm','number_of_reviews_l30d','reviews_per_month','review_scores_rating', 'review_scores_accuracy', 'review_scores_cleanliness', 'review_scores_checkin', 'review_scores_communication', 'review_scores_location', 'review_scores_value', 'instant_bookable','host_listings_count','calculated_host_listings_count')]
write.csv(listings_sel,"listings_trimmed_cols.csv", row.names = FALSE)

```

# Removing special characters and recalculating columns
## Host_Response_Rate and Host_Acceptance_Rate is converted to numeric data type
## Price is converted to numeric data type
```{r}
listings_sel$host_response_rate = as.numeric(gsub("%", "", listings_sel$host_response_rate))
listings_sel$host_acceptance_rate = as.numeric(gsub("%", "", listings_sel$host_acceptance_rate))
listings_sel$price = as.numeric(gsub("\\$", "", listings_sel$price))
```

##Removed 31 records where host_is_superhost = NA 
```{r}
listings_sel = listings_sel%>% filter(!is.na(host_is_superhost))
```

#Final Data Summary
```{r}
dim(listings_sel)
write.csv(listings_sel,"listings_sel.csv", row.names = FALSE)
```

#Distribution of Hosts Vs. Superhosts
```{r}
total_SH = listings_sel%>% filter(!is.na(host_is_superhost)) %>% group_by(host_is_superhost) %>% summarise(n = n())

total_SH = total_SH %>% 
  arrange(desc(host_is_superhost)) %>%
  mutate(prop = n / sum(total_SH$n) *100) %>%
  mutate(prop= round(prop, digits = 2)) %>%
  mutate(ypos = cumsum(prop)- 0.5*prop )
  
total_SH
```

```{r}
ggplot(total_SH, aes(x="", y=prop, fill=host_is_superhost))+ geom_bar(width = 1, stat = "identity")
```

```{r}
ggplot(total_SH, aes(x="", y=prop, fill=host_is_superhost))+ geom_bar(width = 1, stat = "identity") + 
  coord_polar("y", start=0) +
  theme_void() +
  geom_text(aes(y=ypos, label = prop), color = "white") +
  scale_fill_brewer(palette="Set1")
```

# Criteria1-  Respond to guests within 24 hours and maintain a response rate 90% or higher
```{r}
time_SH = listings_sel%>% filter(!is.na(host_response_time)) %>% filter(!is.na(host_response_rate))
summary(time_SH)
```
```{r}
ggplot(time_SH, aes(y=host_response_time, x=host_response_rate, color=host_is_superhost))+ geom_point(na.rm = TRUE)
```

# Criteria2- 4.8 or higher overall ratings  
```{r}
ggplot(time_SH, aes(y=host_id, x=review_scores_rating, color=host_is_superhost))+ geom_point(na.rm = TRUE)
```

#Alexs data preprocessing 
```{r}
ABNB_data <- read.csv(file = "listings_sel.csv", na = c(" ","","na","NA", "N/A"))
ABNB_data$host_is_superhost[which(ABNB_data$host_is_superhost == "t")] = TRUE
ABNB_data$host_is_superhost[which(ABNB_data$host_is_superhost == "f")] = FALSE
#count of listing per borough 
ABNB_data %>% select(neighbourhood_cleansed) %>% unique()
ABNB_data %>% group_by(neighbourhood_group_cleansed) %>% count(name="totalcount")
```

#superhosted out of the listing 
```{r}
ABNB_data %>% select(neighbourhood_group_cleansed,host_is_superhost)%>%group_by(neighbourhood_group_cleansed) %>% summarise(SuperHosted = sum(host_is_superhost == TRUE,na.rm = TRUE), TotalListing = n())

```

#grouping by superhost listing count 
```{r}
ABNB_data %>% group_by(neighbourhood_group_cleansed,host_is_superhost) %>% summarize(TotalListing = n())
```

#without N/A 
```{r}
playdata <- ABNB_data %>% mutate(host_is_superhost=replace_na(host_is_superhost,FALSE))
playdata %>% group_by(neighbourhood_group_cleansed,host_is_superhost) %>% summarize(TotalListing = n())

```


#complete summary of borough listing with superhost status 
```{r}

playdata$price <- as.numeric(substring(playdata$price,2))
experiment_data <- playdata %>% group_by(neighbourhood_group_cleansed,host_is_superhost) %>% summarize(TotalListing = n(), AvgReviewsPerMonth = mean(reviews_per_month,na.rm=TRUE), avgrating = mean(review_scores_rating, na.rm = TRUE), medianminnights = median(minimum_minimum_nights, na.rm=TRUE), avgprice = median(price, na.rm = TRUE), EstRevenueMonth = AvgReviewsPerMonth*(medianminnights*avgprice))
experiment_data

```

#graph of revenue with superhost and different borough
```{r}
ggplot(experiment_data,aes(x=neighbourhood_group_cleansed,y=EstRevenueMonth, fill=host_is_superhost)) + geom_bar(position = "dodge", stat="identity") + xlab("Borough") + ylab("Estimated Revenue") + scale_fill_discrete(name="Superhost") 
```

#graph of listing bar graph fillin with superhost color fill 
```{r}
ggplot(experiment_data, aes(TotalListing,color=neighbourhood_group_cleansed)) + geom_histogram()
ggplot(playdata,aes(x=neighbourhood_group_cleansed, fill=host_is_superhost)) + geom_histogram(stat="count") + ylab("Total Number of Listing") + xlab("boroughs") + scale_fill_discrete(name ="SuperHost")
```

```{r}
ggplot(playdata, aes(x=host_is_superhost,y=price)) + geom_violin() + facet_wrap(. ~ neighbourhood_group_cleansed)
```

```{r}
ggplot(playdata, aes(x=host_is_superhost, y=reviews_per_month)) + geom_violin()+ facet_grid(. ~ neighbourhood_group_cleansed) + ylim(c(0,25))

```

#superhost mapping in NYC
```{r}
ggplot(playdata, aes(x=longitude,y=latitude,color=host_is_superhost)) + geom_point() + scale_color_discrete(name ="SuperHost")
```  

#NYC mapping pricing 
```{r}
ggplot(playdata, aes(longitude,latitude)) + geom_point(aes(color=price)) + scale_color_gradient(low="green",high="red")
```

```{r} 
playdata %>% group_by()
ggplot(playdata, aes(host_listings_count, fill=host_is_superhost)) + geom_histogram() + xlim(10,100) + ylab("Host") + xlab("Host Listing Count") + scale_fill_discrete(name ="SuperHost") + labs(title="SuperHost Distribution in Multi-Listing Host")

```

```{r} 
sel <- playdata %>% filter(minimum_nights>=30)
ggplot(sel,aes(x=neighbourhood_group_cleansed, fill=host_is_superhost)) + geom_histogram(stat="count") + ylab("Listings with 30 days minimum stay") + xlab("boroughs") + scale_fill_discrete(name ="SuperHost")
``` 

```{r}
Percentage_of_superhost <- playdata %>% group_by(neighbourhood_group_cleansed) %>% mutate(totallisting = n()) %>% filter(host_is_superhost==TRUE) %>% summarise(filteredcount = n(),totallisting) 
Percentage_of_superhost <- unique(Percentage_of_superhost)
Percentage_of_superhost <- rename(Percentage_of_superhost, Boroughs = neighbourhood_group_cleansed, Superhost_Listing = filteredcount, Total_Listing = totallisting)
Percentage_of_superhost <- Percentage_of_superhost %>% summarise(Superhost_Percentage = (Superhost_Listing/Total_Listing)*100)
Percentage_of_superhost
```

#Aayush Exploration
```{r}
if(!is.element("DAAG", installed.packages()[,1])){
  packageurl <- "https://cran.r-project.org/src/contrib/Archive/DAAG/DAAG_1.22.tar.gz"
  install.packages("latticeExtra")
  install.packages(packageurl, repos=NULL, type="source")
}
```

```{r}
amenities<-read_csv("amenities.csv")
airbnb_data <- read.csv(file = "listings_sel.csv", na = c(" ","","na","NA", "N/A"))
airbnb_data$host_is_superhost[which(ABNB_data$host_is_superhost == "t")] = TRUE
airbnb_data$host_is_superhost[which(ABNB_data$host_is_superhost == "f")] = FALSE
#only for superhost
airbnb_data <- airbnb_data %>% filter(host_is_superhost == TRUE)
c(unique(airbnb_data['room_type']))
glue("Min price:{min(airbnb_data$price)}| Max price:{max(airbnb_data$price)}")
```
```{r}
freq_neighbor <- data.frame(cbind(Frequency = table(airbnb_data$neighbourhood_group_cleansed), Percent = prop.table(table(airbnb_data$neighbourhood_group_cleansed)) * 100))
freq_neighbor <- freq_neighbor[order(freq_neighbor$Frequency),]
freq_neighbor
```
```{r}
freq_area <- data.frame(cbind(Frequency = table(airbnb_data$neighbourhood_cleansed), 
Percent = prop.table(table(airbnb_data$neighbourhood_cleansed)) * 100))
freq_area <- freq_area[order(freq_area$Frequency),]
freq_area
```
```{r}
freq_area<-tail(freq_area, n = 10)
freq_area   #a histogram
```

```{r}
freq_room_type <- data.frame(cbind(Frequency = table(airbnb_data$room_type), Percent = prop.table(table(airbnb_data$room_type)) * 100))
freq_room_type <- freq_room_type[order(freq_room_type$Frequency),]
freq_room_type  # histogram
```

```{r}
listings <-  airbnb_data %>% 
  group_by(neighbourhood_group_cleansed, room_type) %>% 
  summarize(Freq = n())



total_listings <-  airbnb_data %>% 
  filter(room_type %in% c("Private room","Entire home/apt","Entire home/apt")) %>% 
  group_by(neighbourhood_group_cleansed) %>% 
  summarize(sum = n())

property_ratio <- merge (listings, total_listings, by="neighbourhood_group_cleansed")

property_ratio <- property_ratio %>% 
  mutate(ratio = Freq/sum)

ggplot(property_ratio, aes(x=neighbourhood_group_cleansed, y = ratio, fill = room_type)) +
  geom_bar(position = "dodge", stat="identity") + 
  xlab("Borough") + ylab ("Count") +
  scale_fill_discrete(name = "Property Type") + 
  scale_y_continuous(labels = scales::percent) +
  ggtitle("Types of listings available:",
          subtitle = "% of listing type in each borough ") +
          theme(plot.title = element_text(face = "bold", size = 14) ) +
          theme(plot.subtitle = element_text(face = "bold", color = "grey35", hjust = 0.5)) +
          theme(plot.caption = element_text(color = "grey68"))+scale_color_gradient(low="#d3cbcb", high="#852eaa")+
          scale_fill_manual("Property Type", values=c("#e06f69","#357b8a", "#7db5b8", "#59c6f3", "#f6c458")) +
          xlab("Neighborhood") + ylab("Percentage")
```

```{r}
avg_price_area<-airbnb_data %>% 
  filter(!(is.na(neighbourhood_cleansed))) %>% 
  filter(!(neighbourhood_cleansed == "Unknown")) %>% 
  group_by(neighbourhood_cleansed) %>% 
  summarise(mean_price = mean(price, na.rm = TRUE))
avg_price_area


```

```{r}
avg_price_area<-avg_price_area[order(avg_price_area$mean_price),]
avg_price_area
```

```{r}
expensive_areas<-tail(avg_price_area, n=10)
expensive_areas
```

```{r}

expensive_areas %>% 
  filter(!(is.na(neighbourhood_cleansed))) %>% 
  filter(!(neighbourhood_cleansed == "Unknown")) %>% 
  group_by(neighbourhood_cleansed) %>% 
  ggplot(aes(x = reorder(neighbourhood_cleansed, mean_price), y = mean_price, fill = neighbourhood_cleansed)) +
  geom_col(stat ="identity", color = "black", fill="#004486") +
  coord_flip() +
  theme_minimal() +
  labs(x = "Neighbourhood  ", y = "Price") +
  geom_text(aes(label = round(mean_price,digit = 2)), hjust = 2.0, color = "white", size = 3) +
  ggtitle("AVG Price comparison for each neighbourhood", subtitle = "Price vs Neighbourhood  ") + 
  xlab("Neighbourhood") + 
  ylab("AVG Price") +
  theme(legend.position = "none",
        plot.title = element_text(color = "black", size = 14, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(color = "black", hjust = 0.5),
        axis.title.y = element_text(),
        axis.title.x = element_text(),
        axis.ticks = element_blank())
```


```{r}
airbnb_data %>% 
  filter(!(is.na(neighbourhood_group_cleansed))) %>% 
  filter(!(neighbourhood_group_cleansed == "Unknown")) %>% 
  group_by(neighbourhood_group_cleansed) %>% 
  summarise(mean_price = mean(price, na.rm = TRUE)) %>% 
  ggplot(aes(x = reorder(neighbourhood_group_cleansed, mean_price), y = mean_price, fill = neighbourhood_group_cleansed)) +
  geom_col(stat ="identity", color = "black", fill="#004486") +
  coord_flip() +
  theme_minimal() +
  labs(x = "Boroughs  ", y = "Price") +
  geom_text(aes(label = round(mean_price,digit = 2)), hjust = 2.0, color = "white", size = 3) +
  ggtitle("AVG Price comparison for each boroughs", subtitle = "Price vs Boroughs  ") + 
  xlab("Boroughs") + 
  ylab("AVG Price") +
  theme(legend.position = "none",
        plot.title = element_text(color = "black", size = 14, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(color = "black", hjust = 0.5),
        axis.title.y = element_text(),
        axis.title.x = element_text(),
        axis.ticks = element_blank())
```


```{r}
airbnb_data %>% 
  filter(!(is.na(room_type))) %>% 
  filter(!(room_type == "Unknown")) %>% 
  group_by(room_type) %>% 
  summarise(mean_price = mean(price, na.rm = TRUE)) %>% 
  ggplot(aes(x = reorder(room_type, mean_price), y = mean_price, fill = room_type)) +
  geom_col(stat ="identity", color = "black", fill="#004486") +
  coord_flip() +
  theme_minimal() +
  labs(x = "Room Type", y = "Price") +
  geom_text(aes(label = round(mean_price,digit = 2)), hjust = 2.0, color = "white", size = 3) +
  ggtitle("AVG Price comparison with all Room Types", subtitle = "Price vs Room Type") + 
  xlab("Room Type") + 
  ylab("AVG Price") +
  theme(legend.position = "none",
        plot.title = element_text(color = "black", size = 14, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(color = "black", hjust = 0.5),
        axis.title.y = element_text(),
        axis.title.x = element_text(),
        axis.ticks = element_blank())
```

```{r}
review_words <- amenities %>%
  unnest_tokens(word, amenities) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "^[a-z']+$"))

#plot the graph
top_amenities <- review_words %>%
  group_by(word) %>%
  summarise(count = n()) %>%
  top_n(n = 10, wt = count) %>%
  ggplot() +
  geom_bar(mapping = aes(x=reorder(word, count), y=count),
           stat="identity", fill = "#004486") +
  coord_flip() +
  labs(title="Top 10 Amenities offered",
       y="Word count", x="Amenities") +
  theme_minimal()

print(top_amenities)

```

#mihir exploration
```{r}
Airbnb = read.csv('listings_sel.csv')
#only for superhost
Airbnb <- Airbnb %>% filter(host_is_superhost == TRUE)
Airbnb %>% filter(price < 100) %>% select(neighbourhood_group_cleansed, price)
```
```{r}
one_bed <- Airbnb %>% filter(beds >= 1 & beds <= 3 & price <= 700)  %>% select(beds, price, neighbourhood_group_cleansed)
one_bed

```

```{r}
ggplot(one_bed, aes(x = beds, y = price)) + facet_wrap(.~ neighbourhood_group_cleansed) + geom_boxplot() + theme(text = element_text(size = 20)) 
```


```{r}
price_airbnb <- Airbnb[Airbnb$room_type == "Private room",]
price_airbnb %>% select(neighbourhood_group_cleansed, room_type, price)
```
```{r}

ggplot(price_airbnb,aes(neighbourhood_group_cleansed,price)) +
   geom_jitter(aes(color= price_airbnb$price)) +
   geom_boxplot(alpha=0.5) +
   scale_y_log10()+
   labs(title = "Private rooms Price by Neighbourhood", x= "Neighbourhood Group", y= "Price", col = "Price", ps = 100) +
   theme(plot.title = element_text(hjust = 0.5))
```
```{r}
Airbnb %>% filter(neighbourhood_group_cleansed == "Manhattan")
```
```{r}
all_bed <- Airbnb %>% filter(beds <= 3 & bathrooms_text == "2 baths", neighbourhood_group_cleansed == "Manhattan" ) %>% select(price, beds, room_type, bathrooms_text, neighbourhood_group_cleansed)
all_bed
```
```{r}
new_df = Airbnb %>% filter(price <= 100 & beds == 2) %>% select(neighbourhood_group_cleansed, price, beds, room_type)
new_df
```

#This garph shows, this types of rooms can accommodate most people.
```{r}
ggplot(data=Airbnb, aes(x=accommodates,y=room_type, color = neighbourhood_group_cleansed))+
  geom_violin()+
  theme_bw()
```
```{r}
A <- Airbnb[order(Airbnb$price, decreasing =T),]
AirbnbM_B <- A [A$neighbourhood_group== "Manhattan" | A$neighbourhood_group== "Brooklyn", ]
head(AirbnbM_B)
```
```{r}
host <- Airbnb[match(unique(Airbnb$host_id), Airbnb$host_id), ]
host <- host[order(host$number_of_reviews, decreasing = T), ]
host <- host[1:30, ]
host
```

a. Staten Island and Bronx are not included in top 30 number of reviews
b. ‘Miss Dy’ from Queens is the highest with more than 600 number of reviews and price of her listing is below 100
c. Second place is occupied by ‘J.E’ at Brooklyn with 655 number of review and price below 100 USD
d. Third place is occupied by ‘Martin’ from brooklyn as well with 596 number of review and price below 100 USD
e. Price around 300 USD is located at Manhattan with host name is ‘Seith’ and 467 number of reviews
```{r}
ggplot(host,aes(host_name,number_of_reviews), number_of_reviews)+
   geom_col(fill ="green")+
   facet_grid(rows = vars(neighbourhood_group_cleansed), scales = "free_y") +
   geom_point(aes(col=price))+
   geom_text(aes(label= comma(host$number_of_reviews)), hjust=-0.4, size = 3)+
   labs( title = "Host Name with Reviews", x="Host Name", y= "Reviews")+
   coord_flip()
```

