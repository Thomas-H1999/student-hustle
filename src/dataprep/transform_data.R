#step 3
library(tidyverse)
library(assertive)
library(dplyr)
library(readr)

#Read csv
downloaded_data <- read.csv("downloaded_data.csv")

#Select the data we need to use for our research

student_data <- downloaded_data %>%
  select("name", "host_listings_count", "neighbourhood_group_cleansed", "city", "property_type", "price", "availability_365", "maximum_nights", "number_of_reviews", "review_scores_rating")

#calculate the average number of reviews, filter above the average of number of reviews, filter availability above 0 and filter the number of listings is 1.

max(student_data$number_of_reviews)
min(student_data$number_of_reviews)
mean(student_data$number_of_reviews)

filtered_data <- student_data %>%
  filter(host_listings_count == 1, number_of_reviews >23, availability_365 >0)

#There are several numbers of private rooms, find the different types of private rooms (24 different types of private rooms)

table(filtered_data$property_type)
private_room <- filtered_data %>% filter(grepl('Private room in bungalow|Private room in cabin|Private room in casa particular|Private room in castle|Private room in chalet Private room|Private room in condominium (condo)|Private room in cottage|Private room in floor|Private room in guest suite|Private room in guesthouse|Private room in hostel|Private room in houseboat|Private room in loft|Private room in rental unit|Private room in residential home|Private room in serviced apartment|Private room in tiny house|Private room in townhouse|Private room in treehouse|Private room in villa', property_type))

#Check if the variables are numeric

is.numeric(private_room$host_listings_count)
is.numeric(private_room$price)
is.numeric(private_room$availability_365)
is.numeric(private_room$number_of_reviews)
is.numeric(private_room$review_scores_rating)
class(private_room$price)
assert_is_numeric(private_room$price)    

#Remove dollar sign from prive to convert as nummeric

private_room$price = as.numeric(gsub("\\$", "", private_room$price))
is.numeric(private_room$price)

#Finding duplicates

duplicated(private_room)
sum(duplicated(private_room))

#Deleting NA values in Price

private_room <- private_room[!is.na(private_room$price), ]

#create a dummy for short stay 
short_stay <- ifelse(private_room$maximum_nights <= 2, 1, 0)
private_room <- data.frame(private_room,
                           short_stay)

#Calculate the mean prices per city

mean_price_cities <- aggregate(private_room$price, list(private_room$city), FUN=mean)
names(mean_price_cities)[1]<- "city"
names(mean_price_cities)[2]<- "mean_price"

#calculate the mean availability per city
mean_availability <- aggregate(private_room$availability_365, list(private_room$city), FUN=mean)
names(mean_availability) [1]<- "city"
names(mean_availability) [2]<- "mean_availability"

#Change the currency from DKK to euro

mean_price_cities_euro <- mean_price_cities %>%
  mutate(mean_price = case_when(city == 'copenhagen' ~ mean_price * 0.10,
                                TRUE ~ as.numeric(mean_price)))

#Change pound to dollar

mean_price_cities_euro1 <- mean_price_cities_euro %>%
  mutate(mean_price = case_when(city == 'london' ~ mean_price / 1.19,
    TRUE ~ as.numeric(mean_price))) %>%
      mutate(mean_price = case_when(city == 'manchester' ~ mean_price / 1.19,
        TRUE ~ as.numeric(mean_price))) %>%
          mutate(mean_price = case_when(city == 'edinburgh' ~ mean_price / 1.19,
            TRUE ~ as.numeric(mean_price)))


dir.create('../../gen')
dir.create('../../gen/dataprep')
dir.create('../../gen/dataprep/input')
write.csv(filtered_data, "../../gen/data-preparation/input/merged_data.csv" row.names = FALSE)
write.csv(private_room, 'private_room.csv')
write.csv(mean_price_cities_euro1, 'mean_price_cities_euro1.csv')

