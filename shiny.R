# Libraries
library(DBI)
library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)
library(stringr)
library(treemapify)
library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(leaflet)

# PostgreSQL database connection
con <- dbConnect(RPostgres::Postgres(),
                 dbname = "postgres",
                 host = "localhost",
                 port = 5432,
                 user = "postgres",
                 password = "root");

# Tables
u <- dbReadTable(conn = con, name = "user")
g <- dbReadTable(conn = con, name = "giveaway")
i <- dbReadTable(conn = con, name = "item")
ic <- dbReadTable(conn = con, name = "item_category")
t <- dbReadTable(conn = con, name = "token")
tr <- dbReadTable(conn = con, name = "transaction")
w <- dbReadTable(conn = con, name = "wallet")

# User interface
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "Dashboard"),
  dashboardSidebar(
    menuItem("User", tabName = "User"),
    menuItem("Giveaway", tabName = "Giveaway"),
    menuItem("Item", tabName = "Item"),
    menuItem("Item Category", tabName = "ItemCategory"),
    menuItem("Token", tabName = "Token"),
    menuItem("Transaction", tabName = "Transaction"),
    menuItem("Wallet", tabName = "Wallet")
    ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "User", h2("User"),
              fluidRow(
                box(title = "Filters",
                    selectInput("u_country", h3("Select a country"), unique(u$country),
                                selected = c(unique(u$country)), multiple = TRUE),
                    selectInput("u_status", h3("Select a status"), unique(u$status),
                                selected = c(unique(u$status)), multiple = TRUE),
                    selectInput("u_sex", h3("Select a sex"), unique(u$sex),
                                selected = c(unique(u$sex)), multiple = TRUE)
                ),
                box(title = "Users per status", plotlyOutput("plot_u_status")),
                box(title = "Users per sex", plotlyOutput("plot_u_sex")),
                box(title = "User seniority in years", tableOutput("tbl_u_seniority")),
                box(title = "Total number of users", infoBoxOutput("info_u_total")),
                box(title = "User with min transactions", infoBoxOutput("info_u_mintr")),
                box(title = "User with max transactions", infoBoxOutput("info_u_maxtr"))
                )
              ),
      tabItem(tabName = "Giveaway", h2("Giveaway"), 
              fluidRow(
                box(title = "Filters",
                    selectInput("g_criteria", h3("Select a criteria"), unique(g$criteria), 
                                selected = unique(g$criteria), multiple = TRUE),
                    selectInput("g_winners", h3("Select a number of winners"), unique(g$number_of_winners),
                                selected = unique(g$number_of_winners), multiple = TRUE)
                    ),
                box(title = "Distribution by number of winners", plotlyOutput("plot_g_winners")),
                box(title = "Giveaway seniority in months", tableOutput("tbl_g_seniority"))
                )
              ),
      tabItem(tabName = "Item", h2("Item"),
              fluidRow(
                box(title = "Filters",
                    checkboxGroupInput("i_isnew", h3("Select one or more"),
                                       choices = list("New Items" = TRUE, "Old Items" = FALSE),
                                       selected = c(TRUE, FALSE))
                    ),
                box(title = "Percent of new items", tableOutput("tbl_i_isnew")),
                box(title = "Number of items", infoBoxOutput("info_i_total"))
                )
              ),
      tabItem(tabName = "ItemCategory", h2("Item Category"),
              fluidRow(
                box(title = "Filters",
                    selectInput("ic_name", h3("Select a name"), unique(ic$name), 
                                selected = unique(ic$name), multiple = TRUE)
                    ),
                box(title = "Count of item category", plotlyOutput("plot_ic_count")),
                box(title = "Top 3 item category", tableOutput("tbl_ic_top"))
                )  
              ),
      tabItem(tabName = "Token", h2("Token"),
              fluidRow(
                box(title = "Filters",
                    selectInput("t_name", h3("Select a name"), unique(t$name), 
                                selected = unique(t$name), multiple = TRUE),
                    sliderInput("t_value", h3("Select a value"), 
                                min = min(t$value), max = max(t$value), step = 1,
                                value = c(min(t$value), max(t$value)))
                    ),
                box(title = "Count of tokens", plotlyOutput("plot_t_count")),
                box(title = "Proportion of tokens", plotlyOutput("plot_t_proportion"))
                )
              ),
      tabItem(tabName = "Transaction", h2("Transaction"),
              fluidRow(
                box(title = "Filters",
                    dateRangeInput("date_range", "Date Range", 
                                   start = min(tr$createdat), end = max(tr$createdat))
                    ),
                box(title = "Distribution by type", plotlyOutput("plot_tr_type")),
                box(title = "Transaction type by days of the week", plotlyOutput("plot_tr_days")),
                box(title = "User with most transactions", tableOutput("tbl_tr_mostuser"))
                )
              ),
      tabItem(tabName = "Wallet", h2("Wallet"),
              fluidRow(
                box(title = "Wallet seniority in days", tableOutput("tbl_w_seniority"))
                )
              )
      )
    )
  )

# Server
server <- function(input, output) {

# User
  u_data <- reactive({
    u %>% 
      filter(country %in% input$u_country,
             status %in% input$u_status,
             sex %in% input$u_sex)
  })
  output$plot_u_status <- renderPlotly({
    u_data () %>%
      ggplot(aes(x = status)) +
      geom_histogram(stat = "count", fill = "#0b910b") +
      labs(x = "Status", y = "Count")
  })
  output$plot_u_sex <- renderPlotly({
    u_data () %>%
      ggplot(aes(x = sex)) +
      geom_histogram(stat = "count", fill = "#0b910b") +
      labs(x = "Sex", y = "Count")
  })
  output$tbl_u_seniority <- renderTable({
    u_data () %>%
      mutate(senior = trunc((createdat %--% today()) / years(1))) %>%
      summarise(younger = min(senior),
                avg = round(mean(senior), 0),
                older = max(senior))
  })
  output$info_u_total <- renderInfoBox({
    infoBox("Total", nrow(u), icon = icon("user"))
  })
  output$info_u_mintr <- renderTable({
    users <- u$id
    total_transactions <- sapply(users, function(user) sum(tr$user_id == user))
    min_user <- users[which.min(total_transactions)]
    min_transactions <- total_transactions[which.min(total_transactions)]
    data.frame(User = min_user, TotalTransactions = min_transactions)
  })
  output$info_u_maxtr <- renderTable({
    users <- u$id
    total_transactions <- sapply(users, function(user) sum(tr$user_id == user))
    max_user <- users[which.max(total_transactions)]
    max_transactions <- total_transactions[which.max(total_transactions)]
    data.frame(User = max_user, TotalTransactions = max_transactions)
  })
  
# Giveaway
  g_data <- reactive({
    g %>%
      filter(criteria %in% input$g_criteria,
             number_of_winners %in% input$g_winners)
  })
  output$plot_g_winners <- renderPlotly({
    g_data () %>%
      ggplot(aes(x = number_of_winners)) +
      geom_histogram(stat = "count", fill = "#0b910b") +
      labs(x = "Number of winners", y = "Count")
  })
  output$tbl_g_seniority <- renderTable({
    result <- g_data() %>%
      mutate(senior = trunc((createdat %--% today()) / months(1))) %>%
      summarise(younger = min(senior), 
                avg = round(mean(senior), 0), 
                older = max(senior))
  })
  
# Item
  i_data <- reactive({
    i %>%
      filter(is_new %in% input$i_isnew)
  })
  output$tbl_i_isnew <- renderTable({
    i_data () %>%
      count(is_new) %>%
      mutate(percent = (n/sum(n)) * 100)
  })
  output$info_i_total <- renderInfoBox({
    total <- length(unique(i$id))
    infoBox("Total", total)
  })

# Item Category
  ic_data <- reactive({
    ic %>% 
      filter(name %in% input$ic_name)
  })
  output$plot_ic_count <- renderPlotly({
    ic_data () %>%
      ggplot(aes(x = name)) +
      geom_histogram(stat = "count", fill = "#0b910b") +
      labs(x = "Name", y = "Count")
  })
  output$tbl_ic_top <- renderTable({
    top_3_categories <- ic_data() %>%
      group_by(name) %>%
      summarize(count = n()) %>%
      arrange(desc(count)) %>%
      head(3)
    return(top_3_categories)
  })
  
# Token
  t_data <- reactive({
    t %>%
      filter(name %in% input$t_name,
             value >= input$t_value[1] & value <= input$t_value[2])
  })
  output$plot_t_count <- renderPlotly({
    t_data () %>%
      ggplot(aes(x = name)) +
      geom_histogram(stat = "count", fill = "#0b910b") +
      labs(x = "Name", y = "Count")
  })
  output$plot_t_proportion <- renderPlotly({
    t_data () %>%
      ggplot(aes(x = name)) +
      geom_bar(aes(y = after_stat(count)/sum(after_stat(count))), fill = "#0b910b") +
      scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
      labs(x = "Name", y = "Proportion")
  })

# Transaction
  tr_data <- reactive({
    data <- tr
    data <- data[data$createdat >= input$date_range[1] & data$createdat <= input$date_range[2], ]
    data$createdat <- as.Date(data$createdat)
    return(data)
  })
  output$plot_tr_type <- renderPlotly({
    tr_data() %>%
      ggplot(aes(x = type)) +
      geom_histogram(stat = "count", fill = "#0b910b") +
      labs(x = "Type", y = "Count")
  })
  output$plot_tr_days <- renderPlotly({
    tr$createdat <- as.Date(tr$createdat)
    tr$day_of_week <- weekdays(tr$createdat)
    type_by_day <- table(tr$day_of_week, tr$type)
    type_by_day <- as.data.frame(type_by_day)
    plot_ly(type_by_day, x = ~Var1, y = ~Freq, color = ~Var2, type = "bar",
            colors = c("#00FF00", "#00CC00", "#009900", "#006600")) %>%
      layout(xaxis = list(title = "Day"), yaxis = list(title = "Count"))
  })
  output$tbl_tr_mostuser <- renderTable({
    transaction_counts <- table(tr_data()$user_id)
    user_transactions <- data.frame(Users = names(transaction_counts), Transactions = as.vector(transaction_counts))
    user_transactions <- user_transactions[order(user_transactions$Transactions, decreasing = TRUE), ]
    user_transactions
  })

# Wallet
  output$tbl_w_seniority <- renderTable({
    w_data <- w
    w_data$createdat <- as.POSIXct(w_data$createdat, format = "%Y-%m-%d %I:%M:%S %p")
    w_data$days <- as.integer(difftime(Sys.time(), w_data$createdat, units = "days"))
    w_data %>%
      select(id, days)
  })
  
}

shinyApp(ui, server)