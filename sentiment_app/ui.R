# libraries for U.I.----
library(shiny)
library(shinydashboard)
library(plotly)


# U.I.----
ui <- dashboardPage(skin = "black",
    
    # header ----               
    dashboardHeader(title = "Sentiment analysis"),
    
    # sidebar ----
    dashboardSidebar( 
    # sidebar menu ----
        sidebarMenu(
         menuItem("Start here!"       , tabName = "infos", icon = icon("th"),badgeLabel = "new", badgeColor = "green"),
         menuItem("Wordclouds"        , tabName = "wordclouds", icon = icon("dashboard"),badgeLabel = "new", badgeColor = "green"), 
         menuItem("Sentiment analysis", tabName = "stoca", icon = icon("dashboard"),badgeLabel = "new", badgeColor = "green"))
    ),
    
    # body dash ----
    dashboardBody(
        # tabs  ----
        tabItems(
          # tab info ----
                tabItem(tabName = "infos"
                        , h2("infos and starting!")
                        , h5("Here you can find how this app works and start your analysis.",br(),
                                "This app make some simple sentiment analysis on the citations of
                                 (or about) authors and themes, fetching them from the bold parts in
                                 wikiquote.org, following their ToS."),
                # fluid 1 ----
                        fluidRow(  
                    # box info and start ----
                            box(title = "Let's start (and some infos)"
                                , status = "info", solidHeader = TRUE,
                                "Write some (or one!) arguments and/or authors, commas between them, and 
                                spaces if they've a complex name. Example: Darwin,Lovecraft,Poe - try to copy those!-. 
                                Without this, the app will not work. Remember: it can take few seconds to render
                                the outputs, try with a single input the first time. ",br()," N.D. Some queries
                                cannot be satisfied, due the different structures of the pages, sorry. Take care of case.",
                                br(),"Data from wikiquote.org, following its ToS.",
                                textInput("text", "Write here:", value = "Darwin,H. P. Lovecraft,Plato,Poe, Oscar Wilde,Marx,Gandhi"),
                                           height = 600),
                    # how it works ----
                             box(title = "How this app works"
                                , status = "info"
                                , solidHeader = TRUE
                                , plotOutput("plot4", height = 500),height = 600)
                                    )
                          
                            ),
                
         # tab wordcloud ----
            tabItem(tabName = "wordclouds"
                , h2("wordclouds of your queries")
                , h5("Here you can find the wordclouds, i.e. the top n cited token
                     words of each author/theme. Sometimes some words can overlap.",
                     br(),"This output can give a glimpse of the themes of the citation."),
                # fluid 1 ----
                    fluidRow(
                    # 
                    box(
                                  title = "Wordcloud"
                                 , status = "info", solidHeader = TRUE
                                 ,"Top 10 words by search. The cloud could give more than 10 words,
                                  if some words have the same ranking. Dark red words are
                                  the most cited, clear blue the less cited overall. 
                                 It can take some seconds to render.")),
                # fluid 2 ----                   
                     fluidRow( 
                    # wordcloud ----
                        box(width = 12,
                            status = "info",
                            solidHeader = TRUE,
                            plotOutput("plot2", height = 550)))
            ),
            
         # sentiment analysis tab ----
            tabItem(tabName = "stoca", 
            h2("Sentiment analysis")
            ,h5("Here you can find some number about the queries, the sentiments
            associated. Hoover on plots to get insights and options. "),
                # fluid 1 ----
                    fluidRow(
                    # scatter ----
                              box(width = 6,title = "Tokens and citation by query"
                                  , status = "info", solidHeader = TRUE
                                         ,"Tokens are important words whom have meanings (es. death, life, love...), and citation are the phrases scraped. "
                                         ,plotlyOutput("plot5",height = 300), height = 400),
                             box(width = 6,title = "Sentiments by query"
                                 , status = "info", solidHeader = TRUE
                             ,"Here the percentage of sentiment calculated on words on the queries."
                             ,plotlyOutput ("plot1",height = 300),height = 400),
                    # acp biplot ----
                             box(width = 12,title = 'PCA biplot'
                                 , status = "info", solidHeader = TRUE
                                 ,"This is a biplot for PCA.Depending on them queries, results may be more or less
                                 interesting. It works with 2+ queries."
                                 ,plotlyOutput("plot6",height = 300),height = 400))
            )
     
        )
    )
)
