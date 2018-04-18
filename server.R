#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

options(shiny.sanitize.errors = FALSE)
# Define server logic required to draw a histogram
server = function(input, output) {
  # filter data based on sliderInputs values
  filteredData = reactive({
    subset(data,Passenger_count>=input$range_passenger[1] & Passenger_count<=input$range_passenger[2] & 
             Total_amount>=input$range_fare[1] & Total_amount<=input$range_fare[2] & 
             Trip_distance>=input$range_distance[1] & Trip_distance<=input$range_distance[2] &
             hour_dropoff==input$range_hour & Payment_type %in% input$Payment_type & 
             Trip_type %in% input$Trip_type)
  })
  
  # create color palette. We will color by tippercentage
  colorpalette = reactive({
    colorNumeric('PuOr',data$Tip_ratio)
  })
  
  # generate the map
  output$map = renderLeaflet({
    leaflet(data) %>%
      addTiles(options = providerTileOptions(opacity = .5)) %>% 
      setView(-73.9, 40.7, zoom = 10) #%>%
    #addProviderTiles(providers$CartoDB.Positron) %>%
    #fitBounds(~min(longitude), ~min(latitude), ~max(longitude), ~max(latitude))
  })
  
  # generate an observer object that will overlay circles whenever there is an update on the slider
  observe({
    pal = colorpalette()
    
    leafletProxy("map", data=filteredData()) %>% 
      clearShapes() %>% 
      addCircles(radius = 200, weight = 1, color = "#b7b7b7", fillColor = ~pal(Tip_ratio),
                 fillOpacity = 0.7, popup = ~paste(Tip_amount)) %>% 
      clearControls() %>%
      addLegend(position = "bottomleft",pal = pal, values = ~Tip_ratio, opacity = 0.7, title = 'Tip (%)')
  })
  
}