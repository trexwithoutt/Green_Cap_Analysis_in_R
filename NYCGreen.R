
library(shiny)
library(leaflet)
library(shinydashboard)

header <- shinydashboard::dashboardHeader(
  title = "NYC Green Cab"
)
# create the body
body <- shinydashboard::dashboardBody(
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
ui <- dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)

# build the server
server <- function(input, output) {
  # filter data based on sliderInputs values
  filteredData <- reactive({
    subset(data,Passenger_count>=input$range_passenger[1] & Passenger_count<=input$range_passenger[2] & 
             Total_amount>=input$range_fare[1] & Total_amount<=input$range_fare[2] & 
             Trip_distance>=input$range_distance[1] & Trip_distance<=input$range_distance[2] &
             hour_dropoff==input$range_hour & Payment_type %in% input$Payment_type & 
             Trip_type %in% input$Trip_type)
  })
  
  # create color palette. We will color by tippercentage
  colorpalette <- reactive({
    colorNumeric('PuOr',data$Tip_ratio)
  })
  
  # generate the map
  output$map <- renderLeaflet({
    leaflet(data) %>%
      addTiles(options = providerTileOptions(opacity = .5)) %>% 
      setView(-73.9, 40.7, zoom = 10) #%>%
  })
  
  # generate an observer object that will overlay circles whenever there is an update on the slider
  observe({
    pal <- colorpalette()
    
    leafletProxy("map", data=filteredData()) %>% 
      clearShapes() %>% 
      addCircles(radius = 200, weight = 1, color = "#b7b7b7", fillColor = ~pal(Tip_ratio),
                 fillOpacity = 0.7, popup = ~paste(Tip_amount)) %>% 
      clearControls() %>%
      addLegend(position = "bottomleft",pal = pal, values = ~Tip_ratio, opacity = 0.7, title = 'Tip (%)')
  })
  
}

# run the application
shinyApp(ui,server)