##Step 4

library(effects)
library(carData)
library(ggplot2)
library(dplyr)
library(broom)
library(ggpubr)

#plot the mean prices. As you can see the price in dublin is the highest, and in manchester the lowest.

ggplot(mean_price_cities_euro1, aes(x= city, y=mean_price, color = city)) +
  geom_point() 
ggsave("mean_price.pdf")

#create a table for the mean reviews per city

mean_reviews <- aggregate(private_room$review_scores_rating, list(private_room$city), FUN=mean)
names(mean_reviews)[1]<- "city"
names(mean_reviews)[2]<- "mean_reviews1"

#plot the mean reviews per city. As you can see the highest score is in edinburgh, the lowest is in barcelona

ggplot(mean_reviews, aes(x= city, y=mean_reviews1, color = city)) +geom_point()
ggsave("mean_reviews.pdf")

#combine the mean_price, mean_reviews, mean_availability in one dataframe

combined_mean_data <- cbind(mean_price_cities_euro1, mean_reviews, mean_availability)
combined_mean_data1 <-combined_mean_data[-c(3, 5)]
write.csv(combined_mean_data1, 'combined_mean_data1')

#Check if price and reviews have a relationship

reg1 <- lm(review_scores_rating ~ price, data = private_room)
summary(reg1)

#check if reviews and availability have a relationship

reg2 <- lm(review_scores_rating ~ availability_365, data = private_room)
summary(reg2)

#regression with multiple variables

regression <- lm(review_scores_rating ~ price + availability_365 + short_stay +city, data=private_room)
summary(regression)

#plot of our regression model

pdf("multiple_regression_effects.pdf") 
plot <- plot(allEffects(regression), ylim={c(4.5, 5)})
dev.off()

#Calculate the top10 cities based on the regression

top10<-summary(regression)$coefficients[1,1]+summary(regression)$coefficients[2,1]*combined_mean_data1$mean_price[2:10]+summary(regression)$coefficients[3,1]*combined_mean_data1$mean_availability[2:10]+summary(regression)$coefficients[4,1]+summary(regression)$coefficients[5:13,1] 
top10 <-as.data.frame(top10)

#As Barcelona is the 'base coefficient' we need to add this one seperately

citybarcelona <- summary(regression)$coefficients[1,1]+summary(regression)$coefficients[2,1]*combined_mean_data1$mean_price[1]+summary(regression)$coefficients[3,1]*combined_mean_data1$mean_availability[1]+summary(regression)$coefficients[4,1] 
top10[nrow(top10) + 1,] = citybarcelona

#changing the row names

rownames(top10) <- c("berlin", "copenhagen", "dublin", "edinburgh", "london", "manchester", "munich", "paris", "vienna", "barcelona")

##Step 5
#Create a table for the top 10 student cities in Europe ascending

Top10_student_cities <- matrix(c("Edinburgh", "Manchester", "Munich", "London", "Berlin", "Dublin", "Vienna", "Paris","Barcelona", "Copenhagen"), ncol=1, byrow=TRUE)
colnames(Top10_student_cities) <- c("City")
rownames(Top10_student_cities) <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
Top10_student_cities <- as.table(Top10_student_cities)

#Create a loop for the position of the student cities

for(i in 1:length(Top10_student_cities)) {
  print(paste(Top10_student_cities[i], "is the number",
              i, "student city in Europe to rent out your student room"))
}
