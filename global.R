options(shiny.sanitize.errors = FALSE)

y = read.csv("green_tripdata_2015-09.csv")
y = y[y$Fare_amount > 0, ]
## Dimenison of the data
rows = dim(y)[1]
cols = dim(y)[2]


y$hour_pickup = as.factor(substr(y$lpep_pickup_datetime, 12, 13))
y$hour_dropoff = as.factor(substr(y$Lpep_dropoff_datetime, 12, 13))


y$Tip_percentage = paste(round((y$Tip_amount / y$Total_amount) * 100, digits =
                                 2), "%", sep = '')
y$Tip_ratio = y$Tip_amount / y$Total_amount


colnames(y)[8] = 'longitude'
colnames(y)[9] = 'latitude'
data = y
data = data[,c("longitude", "latitude", "hour_dropoff", "Total_amount","Passenger_count","Trip_distance"
               , "Trip_type", "Payment_type", "Tip_ratio", "Tip_amount")]
data = data[data$longitude < 0 & data$latitude > 0,]
sample_row = sample(nrow(data), 10000, replace = FALSE, prob = NULL)
data = data[sample_row,]
data$hour_dropoff = as.numeric(data$hour_dropoff)
