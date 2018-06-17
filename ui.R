
inputVarList <- c(
  'x1' = 1,
  'x2' = 2,
  'x3' = 3
)

ui <- fluidPage(
  
  titlePanel("Unsure"),
  
  sidebarLayout(
    
    sidebarPanel(
      h3('Input'),
      numericInput('baseForecast', 'Base Forecast',
                   value = 1),
      fileInput('inputElasticities', 'Elasticities',
                accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
      fileInput('inputDistributions', 'Distributions',
                accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
      actionButton('process', 'Process'),
      hr(),
      h3('Explorer'),
      selectInput('selectInputVar', 'Input Variable',
                              choices = inputVarList),
      sliderInput('inputVarSlider', 'Value Slider', min = 1,
                  max = 4, value = 1, step = 1),
      hr(),
      h3('Output'),
      downloadButton('download_scenarios', 'Scenarios')
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("CDF",
                 plotOutput('cdf')
                 ),
        tabPanel("Stats",
                 dataTableOutput('table')
                 )
        )
      )
    )
)
        