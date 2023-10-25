# library(shinylive)
# shinylive::export(appdir = "app", destdir = "docs")

library(shinydashboard)
library(datasets)
library(tidyverse)
# library(lubridate)
library(zoo)
library(stringr)

ui <- dashboardPage(
  dashboardHeader(
    title = "Netflix Plots"
  ),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      box(
        width = 3,
        h2("Anleitung"),
        "1. Besuche", HTML("<a href='https://www.netflix.com/YourAccount'>Netflix Account</a>") , br(),br(),
        "2. Klicke dort auf [Dein Profil] und kontrolliere, dass die Sprache auf Deutsch eingestellt ist", br(),br(),
        "3. Klicke anschließend [Titelverlauf], scrolle herunter und klicke unten rechts auf [Alle herunterladen]", br(),br(),
        "4. Kehre auf diese Website zurück und lade oben die heruntergeladene [.csv] Datei hoch",br(),br(),
        fileInput('file1', 'Lade hier die Netflixhistory hoch',
                  accept = c('text/csv', 'text/comma-separated-values', 'text/plain', '.csv'))
      ),
      box(
        title = "Top 10 Serien",
        status = "primary",
        solidHeader = TRUE,
        width = 3,
        plotOutput('plot_top10')
      ),
      box(
        title = "Aktivität pro Monat",
        status = "danger",
        solidHeader = TRUE,
        width = 3,
        plotOutput('plot_months')
      ),
      box(
        title = "Aktivität pro Wochentag",
        status = "success",
        solidHeader = TRUE,
        width = 3,
        plotOutput('plot_weekdays')
      )
    ),
    fluidRow(
      box(
        title = "Heatmap der Tagesaktivität",
        status = "info",
        solidHeader = TRUE,
        width = 6,
        plotOutput('plot_heatmap')
      ),
      box(
        title = "Streams pro Tag",
        status = "warning",
        solidHeader = TRUE,
        width = 6,
        plotOutput('plot_timeline')
      )
    )
  )
)




server <- shinyServer(function(input, output, session) {
  
  data <- reactive({ 
    req(input$file1)
    inFile <- input$file1 
    
    df <- read.csv(inFile$datapath)
    df$Date <- dmy(df$Date)
    
    df <- separate(data=df, col = Title, into = c("title", "staffel", "episode"), sep = ': ')
    
    df <- df[!is.na(df$staffel),]
    df <- df[!is.na(df$episode),]
    
    return(df)
  })
  
  
  ### Plots ###
  output$plot_top10 <- renderPlot({
    df <- data()
    
    marathon <- df %>%
      count(title, Date)
    #  marathon <- marathon[marathon$n >= 6,]
    marathon <- marathon[order(marathon$Date),]
    marathon_sorted <- marathon %>% group_by(title) %>% 
      summarise(n = sum(n)) %>% arrange(desc(n))
    
    marathon_sorted_plot <- marathon_sorted %>% 
      top_n(10) %>%
      ggplot(aes(x = reorder(title, n), y = n)) +
      geom_col(fill = "#0097d6") +
      coord_flip() +
      ggtitle("Top 10 Serien", "geschaute Episoden") +
      labs(x = "Serien", y = "geschaute Episoden") +
      theme_minimal()
    
    marathon_sorted_plot
  })
  
  output$plot_timeline <- renderPlot({
    df <- data()
    
    netflix_per_time <- df %>% count(Date) %>% arrange(desc(n))
    range <- range(pretty(df$Date))
    netflix_per_time_plot <- ggplot(aes(x = Date, y = n, color = n), data = netflix_per_time) +
      geom_col(color = c("#FFB90F")) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
      ggtitle("Streams pro Tag", "Anzahl der pro Tag gestreamten Netflix Serien/Filme") +
      labs(x = "Zeit", y = "geschaute Episoden/Filme") +
      scale_x_date(date_labels = "%m %Y", breaks = seq(as.Date(range[1]), as.Date(range[2]), by = "2 months"))
    
    netflix_per_time_plot
    
  })
  
  output$plot_heatmap <- renderPlot({
    df <- data()
    
    netflix_per_day <- df %>% count(Date) %>% arrange(desc(n))
    
    netflix_per_day <- netflix_per_day[order(netflix_per_day$Date),]
    netflix_per_day$diasemana <- wday(netflix_per_day$Date)
    netflix_per_day$diasemanaF <- weekdays(netflix_per_day$Date, abbreviate = T)
    netflix_per_day$mesF <- months(netflix_per_day$Date, abbreviate = T)
    
    netflix_per_day$diasemanaF <-factor(netflix_per_day$diasemana, levels = rev(1:7), labels = rev(c("Mo","Di","Mi","Do","Fr","Sa","So")),ordered = TRUE)
    netflix_per_day$mesF <- factor(month(netflix_per_day$Date),levels = as.character(1:12), labels = c("Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"),ordered = TRUE)
    netflix_per_day$añomes <- factor(as.yearmon(netflix_per_day$Date)) 
    netflix_per_day$semana <- as.numeric(format(netflix_per_day$Date,"%W"))
    netflix_per_day$semanames <- ceiling(day(netflix_per_day$Date) / 7)
    netflix_per_day_calendario <- ggplot(netflix_per_day, aes(semanames, diasemanaF, fill = netflix_per_day$n)) + 
      geom_tile(colour = "white") + 
      facet_grid(year(netflix_per_day$Date) ~ mesF) + 
      scale_fill_gradient(low = "#FFD000", high = "#FF1919") + 
      ggtitle("Aktivität pro Tag", "Heatmap der Tagesaktivität") +
      labs(x = "Woche des Monats", y = "Wochentag") +
      labs(fill = "Episodenanzahl")
    
    netflix_per_day_calendario
  })
  
  output$plot_weekdays <- renderPlot({
    df <- data()
    
    netflix_per_day <- df %>% count(Date) %>% arrange(desc(n))
    #
    netflix_per_day <- netflix_per_day[order(netflix_per_day$Date),]
    netflix_per_day$diasemana <- wday(netflix_per_day$Date)
    netflix_per_day$diasemanaF <- weekdays(netflix_per_day$Date, abbreviate = T)
    netflix_per_day$mesF <- months(netflix_per_day$Date, abbreviate = T)
    #
    netflix_per_day$diasemanaF <-factor(netflix_per_day$diasemana, levels = rev(1:7), labels = rev(c("Mo","Di","Mi","Do","Fr","Sa","So")),ordered = TRUE)
    netflix_per_day$mesF <- factor(month(netflix_per_day$Date),levels = as.character(1:12), labels = c("Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"),ordered = TRUE)
    netflix_per_day$añomes <- factor(as.yearmon(netflix_per_day$Date)) 
    netflix_per_day$semana <- as.numeric(format(netflix_per_day$Date,"%W"))
    netflix_per_day$semanames <- ceiling(day(netflix_per_day$Date) / 7)
    #
    vista_dia <- netflix_per_day %>% count(diasemanaF)
    vista_dia_plot <- vista_dia %>% 
      ggplot(aes(diasemanaF, n)) +
      geom_col(fill = "#5b59d6") +
      coord_polar()  +
      theme_minimal() +
      theme(axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.y = element_blank(),
            axis.text.x = element_text(face = "bold"),
            plot.title = element_text(size = 16, face = "bold")) +
      ggtitle("Aktivität pro Wochentag")
    
    vista_dia_plot
    
  })
  
  output$plot_months <- renderPlot({
    df <- data()
    
    netflix_per_day <- df %>% count(Date) %>% arrange(desc(n))
    #
    netflix_per_day <- netflix_per_day[order(netflix_per_day$Date),]
    netflix_per_day$diasemana <- wday(netflix_per_day$Date)
    netflix_per_day$diasemanaF <- weekdays(netflix_per_day$Date, abbreviate = T)
    netflix_per_day$mesF <- months(netflix_per_day$Date, abbreviate = T)
    #
    netflix_per_day$diasemanaF <-factor(netflix_per_day$diasemana, levels = rev(1:7), labels = rev(c("Mo","Di","Mi","Do","Fr","Sa","So")),ordered = TRUE)
    netflix_per_day$mesF <- factor(month(netflix_per_day$Date),levels = as.character(1:12), labels = c("Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"),ordered = TRUE)
    netflix_per_day$añomes <- factor(as.yearmon(netflix_per_day$Date)) 
    netflix_per_day$semana <- as.numeric(format(netflix_per_day$Date,"%W"))
    netflix_per_day$semanames <- ceiling(day(netflix_per_day$Date) / 7)
    #
    vista_mes <- netflix_per_day %>% count(mesF)
    vista_mes_plot <- vista_mes %>% 
      ggplot(aes(mesF, n)) +
      geom_col(fill = "#808000") +
      coord_polar()  +
      theme_minimal() +
      theme(axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.y = element_blank(),
            axis.text.x = element_text(face = "bold"),
            plot.title = element_text(size = 18, face = "bold")) +
      ggtitle("Aktivität pro Monat") 
    
    vista_mes_plot
    
    
  })
})


shinyApp(ui, server)