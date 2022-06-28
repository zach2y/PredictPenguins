# Coursera: Developing Data Products
# Course Project: Shiny app
# Zachary Yong
# 28 June 2022

library(shiny)
library(palmerpenguins)
library(caret)
library(gbm)
library(randomForest)
library(ggplot2)
library(patchwork)
library(dplyr)

shinyServer(function(input, output) {
        # variable selection
        df <- penguins %>% 
                select(-c(island,sex,year)) %>% 
                filter(complete.cases(.))
        
        # input train
        inputTrain <- reactive({input$numTrain})
        
        # show test percentage
        output$test <- renderUI({
                HTML(paste('Testing:', 100-inputTrain(), '%'))
        })

        train <- reactive({
                set.seed(42)
                inTrain <- createDataPartition(df$species, p = inputTrain()/100)[[1]]
                df[ inTrain,]
        })
        # create testing set
        test <- reactive({
                set.seed(42)
                inTrain <- createDataPartition(df$species, p = inputTrain()/100)[[1]]
                df[-inTrain,]
        })
        
        # fit
        fit <- reactive({
                set.seed(42)
                algoInput <- input$selectAlgo
                control <- trainControl(method="cv", number=5, verboseIter=FALSE)
                metric <- "Accuracy"
                caret::train(species ~ ., method=algoInput, data=train(), metric=metric, trControl=control)
        })
        # confusion matrix
        conf <- reactive({
                predictions <- stats::predict(fit(), test())
                confusionMatrix(predictions, test()$species)
        })
        
        # input measurements
        billLength <- reactive({input$sliderBillLength})
        billDepth <- reactive({input$sliderBillDepth})
        flipperLength <- reactive({input$sliderFlipperLength})
        bodyMass <- reactive({input$sliderBodyMass})
        
        # predict with slider input
        predict <- reactive({
                newdata <- data.frame(bill_length_mm = billLength(),
                                      bill_depth_mm = billDepth(),
                                      flipper_length_mm = flipperLength(),
                                      body_mass_g = bodyMass())
                stats::predict(fit(), newdata = newdata)
        })
        
        output$accuracyIn <- renderText({
                max(fit()$results["Accuracy"])*100
        })
        
        output$accuracyOut <- renderText({
                conf()$overall["Accuracy"]*100
        })
        
        output$error <- renderText({
                100-conf()$overall["Accuracy"]*100
        })
        
        output$predict <- renderText({
                as.character(predict())
        })
        
        output$plot1 <- renderPlot({
                
                g <- ggplot(train(),aes(color = species)) + 
                        scale_color_manual(values = c("darkorange","purple","cyan4")) +
                        theme_minimal()
                
                p1 <- g + geom_point(aes(bill_length_mm, bill_depth_mm)) + 
                        geom_point(aes(x=billLength(), y=billDepth()), color="red", shape=18, size=3) +
                        labs(x = "Bill length (mm)", y = "Bill depth (mm)")
                
                p2 <- g + geom_point(aes(bill_length_mm, flipper_length_mm)) + 
                        geom_point(aes(x=billLength(), y=flipperLength()), color="red", shape=18, size=3) +
                        labs(x = "Bill length (mm)", y = "Flipper length (mm)")
                
                p3 <- g + geom_point(aes(bill_length_mm, body_mass_g)) + 
                        geom_point(aes(x=billLength(), y=bodyMass()), color="red", shape=18, size=3) +
                        labs(x = "Bill length (mm)", y = "Body mass (g)")
                
                p4 <- g + geom_point(aes(bill_depth_mm, flipper_length_mm)) + 
                        geom_point(aes(x=billDepth(), y=flipperLength()), color="red", shape=18, size=3) +
                        labs(x = "Bill depth (mm)", y = "Flipper length (mm)")
                
                p5 <- g + geom_point(aes(bill_depth_mm, body_mass_g)) + 
                        geom_point(aes(x=billDepth(), y=bodyMass()), color="red", shape=18, size=3) +
                        labs(x = "Bill depth (mm)", y = "Body mass (g)")
                
                p6 <- g + geom_point(aes(flipper_length_mm, body_mass_g)) + 
                        geom_point(aes(x=flipperLength(), y=bodyMass()), color="red", shape=18, size=3) +
                        labs(x = "Flipper length (mm)", y = "Body mass (g)")
                
                p1 + p2 + p3 + p4 + p5 + p6 + plot_layout(guides = "collect") & 
                        theme(legend.position = "bottom") & 
                        labs(color="Penguin species", shape="Penguin species")
                
        })
        
})