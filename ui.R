# Coursera: Developing Data Products
# Course Project: Shiny app
# Zachary Yong
# 28 June 2022

library(shiny)

shinyUI(fluidPage(
        
        titlePanel(h3("Predict penguin species from the bill, flipper and body mass measurements"),
                   windowTitle = "Predict Penguin"),
        
        tabsetPanel(
                tabPanel("Main",
                         sidebarLayout(
                                 sidebarPanel(
                                         selectInput("selectAlgo", "Select algorithm",
                                                     c("k-Nearest Neighbors" = "knn",
                                                       "Classification Tree" = "rpart",
                                                       "Random Forest" = "rf",
                                                       "Stochastic Gradient Boosting" = "gbm")),
                                         numericInput("numTrain", "Set Training % (0-100)", value = 75, min=0, max=100),
                                         uiOutput("test"),
                                         h5(strong("Select measurements for prediction:")),
                                         sliderInput("sliderBillLength", "Bill Length (mm)", 32, 60, value = 44, step=1),
                                         sliderInput("sliderBillDepth", "Bill Depth (mm)", 13, 22, value = 17, step=1),
                                         sliderInput("sliderFlipperLength", "Flipper Length (mm)", 172, 231, value = 200, step=1),
                                         sliderInput("sliderBodyMass", "Body Mass (g)", 2700, 6300, value = 4200, step=10)
                                         ),
                                 mainPanel(
                                         plotOutput("plot1"),
                                         h4("Predicted species:"),
                                         textOutput("predict"),
                                         h4("In-sample accuracy:"),
                                         textOutput("accuracyIn"),
                                         h4("Out-of-sample accuracy:"),
                                         textOutput("accuracyOut"),
                                         h4("Out-of-sample error:"),
                                         textOutput("error")
                                         )
                                 )
                         ),
                tabPanel("Documentation", 
                         h4("How to use this app:"),
                         h5("1) Select algorithm."),
                         h5("2) Select percentage for training set."),
                         h5("3) Use slider to input measurements of a penguin."),
                         div(style = "margin-top: 20px;"),
                         h4("Results:"),
                         h5("1) Scatter plots showing relationship between each measurement."),
                         h6("- The red diamond on the plot shows the input measurements."),
                         h5("2) The species predicted by the algorithm, the in-sample accuracy, the out-of-sample accuracy and the out-of-sample error."),
                         div(style = "margin-top: 20px;"),
                         h4("More information about penguins dataset:"),
                         tags$a(href = "https://allisonhorst.github.io/palmerpenguins/", h5("Palmer Penguins")),
                         div(style = "margin-top: 20px;"),
                         h4("Notes:"),
                         h5("- Cross-validation with 5-folds")
                         )
                )
))
