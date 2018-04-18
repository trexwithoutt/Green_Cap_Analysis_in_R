#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(shinydashboard)

header = dashboardHeader(
  title = "NYC Green Cab"
)
# create the body
body = dashboardBody(
  fluidRow(
    column(width = 6,
           box(width = NULL, solidHeader = TRUE,
               leafletOutput("map", height = 500)
           )
    ),
    # create sliders
    column(6,
           fluidRow(
             column(6,h5("Demo visualization of New York Green Cab pickups on September 2, 2015."))
           ),
           fluidRow(
             column(6,sliderInput("range_passenger",label = "Passengers",
                                  value = range(data$Passenger_count), 
                                  min = min(data$Passenger_count), 
                                  max = max(data$Passenger_count), 
                                  step = 1))
           ),
           fluidRow(
             column(6,sliderInput("range_fare",label = "Fare Amount",
                                  value = range(data$Total_amount), 
                                  min = min(data$Total_amount), 
                                  max = max(data$Total_amount), 
                                  pre = '$'))
           ),
           fluidRow(
             column(6,sliderInput("range_distance",label = "Distance",
                                  value = range(data$Trip_distance), 
                                  min = min(data$Trip_distance), 
                                  max = max(data$Trip_distance), 
                                  post = 'miles'))
           ),
           fluidRow(
             column(6,sliderInput("range_hour",label = "Hour past midnight",
                                  value = min(data$hour_dropoff), 
                                  min = min(data$hour_dropoff), 
                                  max = max(data$hour_dropoff),
                                  animate = TRUE,
                                  step = 1))
           ),
           fluidRow(
             column(3,checkboxGroupInput("Payment_type",label = "Payment Mode",
                                         choices = list("Credit Card"=1, "Cash"=2),
                                         selected = c(1,2))),
             column(3,checkboxGroupInput("Trip_type",label = "Trip Type",
                                         choices = list("Street-Hail"=1, "Dispatch"=2),
                                         selected = c(1,2)))
           )
    )
  )
)

# Put together all UI constructors
ui = shinyUI(dashboardPage(header,
                            dashboardSidebar(disable = TRUE),
                            body)
)