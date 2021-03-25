
library(shiny)

server <- function(input, output) {
    
    library(tidytext)
    library(rvest)
    library(dplyr)
    library(ggwordcloud)
    library(ggplot2)
    library(reshape2)
    library(sentimentr)
    library(syuzhet)
    library(igraph)
    library(plotly)
    library(ggfortify)
    
    mydata_f <- reactive({
        URL <- "https://en.wikiquote.org/wiki/"
        auth <-  input$text #"Marx,Lenin,H. P. Lovecraft"
        auth <- gsub(" ","_", auth)
        auth <- strsplit(auth, ",")[[1]]
        
        URL <-lapply(auth, function(x)paste0(URL,x))
        
        
        library(tidytext)
        library(rvest)
        library(dplyr)
        library(ggwordcloud)
        library(ggplot2)
        library(reshape2)
        library(syuzhet)
        library(data.table)
        
        
        # get data
        scrape <- function(URLS){
            read_html(URLS) %>%
                html_nodes(xpath='//li//b')%>%
                html_text() %>%
                data.table()}
        
        
        data_full <- lapply(URL, function(x) scrape(x))
        names(data_full) <- auth
        ff <- rbindlist(data_full, idcol = 'id')
        ff <- as_tibble(ff)
        colnames(ff) <- c("auth","text")
        ff
        
        
    })
    
    
       mydata_app <- reactive({
        
        ff <-mydata_f()
        dats_app <- get_nrc_sentiment(ff$text, language = "english") %>%
            mutate(auth = ff$auth) 
        dats_app
    })
       
       
       mydata_bp <- reactive({
           
           ff <-mydata_app()
           dats_bp <- ff %>%
               tidyr::gather(key, value, - auth) %>%
               group_by(sentiment = key, auth) %>%
               summarise(cnt = sum(value)) %>%
               group_by(auth)
           dats_bp
       })
       
     
       mydata_acp <- reactive ({
           uu <- mydata_app()
           dats_acp <- uu %>%
               group_by(auth) %>%
               summarise_all( list(sum))
           
               n <- dats_acp$auth
           
           # transpose all but the first column (name)
           df <- as.data.frame((dats_acp[,-c(1,10,11)]))
           rownames(df) <- n
           
           df <- scale( df/colSums(df))
           dats_acp
       })  
       
    
    mydata_wc <- reactive({
        
        # get data
        ff <-mydata_f()
        # clean up it!
            dats_wc <- ff %>% unnest_tokens(word, text) %>% anti_join(stop_words) %>%
            group_by(word, auth) %>% summarise(cnt = n()) %>% arrange(-cnt)
        
        # barplot
        dats_wc
        
    })
    
    
    
    output$plot1 <- renderPlotly({
        
        dats <- mydata_bp()
        k <-dats %>%
            mutate(perc = round(cnt/sum(cnt)*100)) %>%
            ungroup() %>%
            filter(!sentiment %in% c("positive","negative")) %>%
            ggplot(aes(x = auth, y = perc,  fill =sentiment)) +
            geom_col(position = "fill",stat ='identity', width = 0.7, ) +
            coord_flip()+ 
            scale_y_continuous(labels=scales::percent)  + 
            scale_fill_brewer(palette="Set2") +
            ylab("words") + xlab("sentiment") +
            theme_light() +
            ggtitle("Sentiments by words.") +
            theme(axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold")) 
        
        ggplotly(k)
        
    })
    
    
    output$plot2 <- renderPlot({
        
        dats <- mydata_wc()
        
        
        # wordcloud, most cited
        dats %>% 
            group_by(auth) %>%
            top_n( n = 10, wt = cnt) %>%
            ggplot(aes(label = word, size = 20, color = cnt )) +
            geom_text_wordcloud_area(rm_outside = TRUE) +
            scale_size_area(max_size = 6) +
            theme_minimal() +
            theme(legend_position =' bottom') +
            scale_color_gradient(
                low = ("#00ccff"),
                high = ("#660000")) +
            facet_wrap(vars(auth)) +
            theme_minimal() +
            ggtitle("Top 10 words written.")
        
        
    })
    
    
    output$plot3 <- renderPlotly({
        
        dats <- mydata_f()
        
        # clean up it!
        
        
        mytext <- get_sentences(dats)
        sent <- sentiment_by(mytext)
        sent$auth <- dats$auth
       k <- ggplot(sent, aes(x = ave_sentiment, group = auth, fill = auth, color = auth)) +
            geom_density(alpha = 0.1) + theme_light() +
            geom_vline(xintercept = 0)
       ggplotly(k)
    })
    

    output$plot4 <- renderPlot({
    
        g4 <- graph( c("user (YOU!)", "input names",
                       "input names", "u.i. send names to Wikiquote",
                       "u.i. send names to Wikiquote", "server retrieves data from Wikiquote",
                       "server retrieves data from Wikiquote", "server manages the data and apply sentiment analysis",
                       "server manages the data and apply sentiment analysis","server sent to u.i. plots and analysis",
                       "server sent to u.i. plots and analysis","results",
                       "results","user (YOU!)" )) 
        
        set.seed(1234)
        plot(g4, edge.arrow.size=.5, vertex.color=c("#e60000","#00ccff","#00b8e6","#00a3cc","#008fb3","#007a99","#006680"), vertex.size=15, 
             edge.arrow.size=0.5, 
             vertex.label.cex=1, 
             vertex.label.font=2,
             
             vertex.shape="circle", 
             vertex.size=0.1, 
             vertex.label.color="black", 
             edge.width=0.5,
             edge.arrow.size = 0.1)
        
    })
    
    output$plot5 <- renderPlotly ({   
        
       d <-  mydata_f() %>% unnest_tokens(word, text) %>% anti_join(stop_words) %>%
        group_by(auth) %>% summarise(words = n()) %>%
        left_join(mydata_f() %>% group_by(auth) %>% summarise(citations = n())) %>%
           ggplot(aes(x = words , y = citations, label = auth )) + 
           geom_point() +
           theme_light() +
           theme(
                 axis.text.x=element_blank(),
                 axis.text.y=element_blank())
       
       ggplotly(d)
})
    
    output$plot6 <- renderPlotly ({   
        
        df <- mydata_acp()
        n <- df$auth
        
        # transpose all but the first column (name)
        df <- as.data.frame((df[,-c(1,10,11)]))
        rownames(df) <- n
        
        df <- scale( df/colSums(df))
        
 
        acp <- prcomp(df)

          d <- autoplot(acp, data = acp,
                      loadings.colour = 'blue',label =TRUE, label.size = 3,
                      loadings = TRUE, loadings.label = TRUE, loadings.label.size  = 3) + theme_light()
        ggplotly(d)

        
    })
    
}

