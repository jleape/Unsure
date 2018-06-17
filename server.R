library(shiny)
library(shinyBS)
library(ggplot2)
library(dplyr)

makeCDF <- function(combinedScenarios, highlightedScenarios) {
  
  renderPlot({
    
    gg <- ggplot(data = combinedScenarios, aes(x=forecast, y=cumProbability)) + 
      geom_point() +
      geom_point(data = highlightedScenarios, aes(x=forecast, y=cumProbability), colour="red", size=3) +
      labs(title='Forecast CDF',
           x='Forecast',
           y='Cumulative Probability') +
      theme_minimal()
    
    return(gg)
  })
}

server <- function(input, output, session) {
  
  values <- reactiveValues()
  
  observeEvent(input$process, {
    
    if (!is.null(input$inputElasticities) && !is.null(input$inputDistributions)) {
      
      # Import elasticities
      inputElasticities <- read.csv(input$inputElasticities$datapath, header = TRUE, fileEncoding = "UTF-8", stringsAsFactors = FALSE)
      names(inputElasticities) = gsub(pattern = "X.U.FEFF.", replacement = "", x = names(inputElasticities))
      inputElasticities <- inputElasticities[order(inputElasticities$id),]
      
      # Update input variable list
      inputVarList <- inputElasticities$id
      names(inputVarList) <- as.character(inputElasticities$name)
      inputVarList <- inputVarList[order(inputElasticities$id)]
      updateSelectInput(session, "selectInputVar",
                           choices = inputVarList
      )
      
      # Calibrate Cobb-Douglas model (NOT CURRENTLY USED)
      numVars <- length(inputElasticities$id)
      cobbDouglas <- 1
      for (i in 1:numVars) {
        x <- inputElasticities$base_value[i]
        e <- inputElasticities$elasticity[i]
        cobbDouglas <- cobbDouglas * x ^ e
      }
      a <- input$baseForecast / cobbDouglas
      
      # Import distributions
      inputDistributions <- read.csv(input$inputDistributions$datapath, header = TRUE, fileEncoding = "UTF-8", stringsAsFactors = FALSE)
      names(inputDistributions) = gsub(pattern = "X.U.FEFF.", replacement = "", x = names(inputDistributions))
      
      # Index individual scenarios
      inputDistributions <- inputDistributions %>% 
        arrange(id, value) %>%
        group_by(id) %>%
        mutate(index1 = row_number())
      
      # Number of scenario per variable
      scenarios <- data.frame(table(inputDistributions$id), stringsAsFactors = FALSE)
      names(scenarios) <- c('id', 'scenarios')
      scenarios$id <- as.numeric(as.character(scenarios$id))
      inputElasticities <- inner_join(inputElasticities, scenarios, by = 'id')
      
      # Create combined scenarios
      scenarioList <- unname(split(inputDistributions$index1, inputDistributions$id))
      combinedScenarios <- expand.grid(scenarioList)
      colnames(combinedScenarios) <- 1:numVars
      combinedScenarios$index2 <- seq_len(nrow(combinedScenarios))
      combinedScenarios$probability <- NA
      combinedScenarios$forecast <- NA
      
      for (i in 1:nrow(combinedScenarios)) {
        combinedProb <- 1
        row_i <- combinedScenarios[combinedScenarios$index2 == i,]
        for (j in 1:numVars) {
          indivScenario <- filter(inputDistributions, id == j & index1 == row_i[1,j])
          combinedProb <- combinedProb * indivScenario$probability
          
          if (j == 1) {
            forecast <- input$baseForecast
          }
          forecast <- forecast * (indivScenario$value / inputElasticities[j,'base_value']) ^ inputElasticities[j,'elasticity']
        }
        combinedScenarios[i, 'probability'] <- combinedProb
        combinedScenarios[i, 'forecast'] <- forecast
      }

      combinedScenarios <- combinedScenarios %>%
        arrange(forecast) %>%
        mutate(cumProbability = cumsum(probability))
      
      output$cdf <- makeCDF(combinedScenarios, combinedScenarios)
      output$table <- renderDataTable(combinedScenarios)
      
      values$inputElasticities <- inputElasticities
      values$inputDistributions <- inputDistributions
      values$combinedScenarios <- combinedScenarios
    }
  })
  
  observeEvent(input$selectInputVar, {

    # Update slider with selected variable's range
    scenarios <- values$inputElasticities[input$selectInputVar, 'scenarios']
    print(values$inputElasticities)
    updateSliderInput(session, 'inputVarSlider', value = 1, min = 1, max = scenarios, step = 1)
  })
  
  observeEvent(input$inputVarSlider, {
    # Dataframe of points to highlight
    highlightedScenarios <- values$combinedScenarios[values$combinedScenarios[, input$selectInputVar] == input$inputVarSlider, ]

    output$cdf <- makeCDF(values$combinedScenarios, highlightedScenarios)
  })
  

  
}