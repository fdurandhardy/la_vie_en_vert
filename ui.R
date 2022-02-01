# Compose dashboard header ---------------------------------------------------
header = dashboardHeader(title="La vie en vert")

# Compose dashboard sidebar --------------------------------------------------
sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem("Accueil", tabName = "home", icon = icon("home")),
    menuItem("Air-Eau",icon = icon("cloud"),
             menuSubItem("Carte",tabName="AE_map",icon = icon("globe-americas")),
             menuSubItem("Evolution",tabName="AE_evolve",icon = icon("line-chart"))
             ),
    menuItem("Faune-Flore",icon = icon("leaf"),
             menuSubItem("Deforestation",tabName="FF_map",icon = icon("tree")),
             menuSubItem("Especes menacees",tabName="FF_evolve",icon = icon("paw"))
             ),
    menuItem("Energie",icon = icon("industry"),
             menuSubItem("Carte",tabName="energie_map",icon = icon("globe-asia")),
             menuSubItem("Evolution",tabName="energie_evolve",icon = icon("line-chart"))
             ),
    menuItem("Informations",icon = icon("info"),
             menuSubItem("Donnees & Sources",tabName="data",icon = icon("database")),
             menuSubItem("Contact",tabName="contact",icon = icon("info-circle"))
             )
    )
  )

# Compose dashboard body --------------------------------------------------
body = dashboardBody(
  tabItems(
    tabItem(tabName = "home",
            fluidRow(class = "myRow1", align="center",
              column(width=12,img(src="images/fresque.png",width = 1500,height = 200))
            ),
            fluidRow(align="bottom",
              column(width=6,
                     fluidRow(box(width=12,strong("Qui sommes nous ?"),hr(), status = "primary", solidHeader = TRUE,  textOutput("presentation"),hr())),
                     fluidRow(box(width=12,strong("Pourquoi cette application ?"),hr(), status = "primary", solidHeader = TRUE, textOutput("site"),hr()))),
              column(width=6,img(src="images/ours2.png",width = 600,height = 395))
            ),
            tags$head(tags$style("
            .myRow1{height:220px;}"
            ))
    ),
    
    tabItem(tabName = "AE_map",
            fluidRow(h3(strong(textOutput("Titre_AE"))),h4(textOutput("ssTitre_AE")),br(),leafletOutput("cartographie_AE",width = "100%"),align="center"),
            fluidRow(column(width=5,sliderInput(inputId="annee_AE",label="Annee",
                                                min=2000, max=2014, value=2008, step=1,sep="")),
                     column(width=4,radioButtons(inputId="var_AE",label="Indicateur",
                                                 choices = c("CO2"="CO2",
                                                             "Effet de serre"="Effet_serre"),
                                                 selected="CO2")),
                     column(width=3,sliderInput(inputId = "Nb_rang_AE", "Selectionner la plage de rang",
                                                min = 1, max = 210, value = c(1, 10), step = 1, dragRange = TRUE))),
            fluidRow(amChartsOutput("rang_AE"))
    ),
    
    tabItem(tabName = "AE_evolve",
            fluidRow(h3(strong(textOutput("Titre_AE_evolve"))),br(),align="center"),            
            fluidRow(sidebarPanel(width=3,
                                  radioButtons(inputId="varAE_evolve_world",label="Choisir un indicateur :",
                                               choices = c("CO2"="CO2",
                                                           "Effet de serre"="Effet_serre",
                                                           "Niveau de la mer"="Niveau_de_mer",
                                                           "Glaciers"="Glaciers",
                                                           "Anomalies de température"="Temperature_eau_air"),
                                               selected="Temperature_eau_air")),
                     mainPanel(width=9,
                               amChartsOutput("AE_evolve_world"))),
            fluidRow(h3(strong(textOutput("Titre_AE_evolve_pays"))),br(),align="center"), 
            fluidRow(sidebarPanel(width=3,
                                  radioButtons(inputId="varAE_evolve_pays",label="Choisir un indicateur :",
                                               choices = c("CO2"="CO2",
                                                           "Effet de serre"="Effet_serre"),
                                               selected="CO2"),
                                  selectInput(inputId = "pays_AE_evolve", label = "Choisir un pays :",
                                              choices = CO2$Pays, width = 200,selected="France")),
                     mainPanel(width=9,
                               amChartsOutput("AE_evolve_pays")))
    ),
    
    tabItem(tabName = "FF_map",
            fluidRow(align ="center",h3(strong("Evolution de la surface forestière (% du territoire)")),br()),
            fluidRow(class="myRow_FF1",
                     sidebarPanel(width=3,
                                  h4("Choisir du pays :"),
                                  hr(),
                                  selectInput(inputId = "pays_FF",
                                              label = "Pays :",
                                              choices = colnames(ForestArea)[-1],
                                              selected = "World",
                                              multiple = FALSE)
                     ),
                     mainPanel(width=9,
                                  amChartsOutput("FF_foret"))
            ),
            fluidRow(class="myRow_FF2",
              column(width=1),
              column(width=10, align="center", "La déforestation est le phénomène de réduction des surfaces de forêt. On parle de déforestation lorsque des surfaces de forêt sont définitivement perdues (ou au moins perdues sur le long terme) au profit d’autres usages comme l’agriculture, l’urbanisation ou les activités minières. Dans le monde, la perte des surfaces forestières, la déforestation est causée par de multiples facteurs, certains humains et d’autres naturels. Parmi les facteurs naturels on trouve notamment les incendies de forêt, les maladies pouvant affecter les arbres ou les parasites.Mais ce sont surtout les activités humaines qui sont responsables de la déforestation au niveau mondial. D’après le rapport sur l’Etat Mondial des Forêts publié par la FAO en 2016, près de 80% de la déforestation mondiale est causée par l’agriculture, les 20% restants se répartissant entre la construction d’infrastructures (routes, barrages) d’abord, puis les activités minières et enfin l’urbanisation.",br())
            ),
            fluidRow(align="center",
                     column(width=12,img(src="images/deforestation.png",width = 1450,height = 255),align="center")
            ),
            tags$head(tags$style("
                                 .myRow_FF1{height:420px;}
                                 .myRow_FF2{height:150px;}"
            ))
            
    ),
    
    tabItem(tabName = "FF_evolve",
            tabsetPanel(
              tabPanel("Géographie",
                       fluidRow(align ="center",
                                h3(strong("Quantité d'espèces en péril, en voie de disparition et en voie de disparition critique")),
                                br()),
                       fluidRow(class="myRow_FF3",
                                sidebarPanel(width=3,
                                             h4("Choisir une espèce :"),
                                             hr(),
                                             radioButtons(inputId="espece_FF",label="Especes",
                                                          choices = names(Espece_menace[2:10]),
                                                          selected="Mammifères")),
                                mainPanel(width=9,
                                          leafletOutput("cartographie_FF",width = "100%"))),
                       fluidRow(h3(strong("Nombre moyen d'espèce menacée dans un pays par continent")),align="center"),
                       fluidRow(tableOutput("moyenne_FF"),align="center"),
                       tags$head(tags$style(".myRow_FF3{height:410px;}"))
                       ),
              tabPanel("Evolution du niveau de menace",
                       fluidRow(align ="center",
                                h3(strong("Répartition du niveau de menace selon les années")),
                                br()),
                       fluidRow(
                         sidebarPanel(width=4,
                                      radioButtons(inputId="input_FF",
                                                           label="Choix de l'espèce :",
                                                           selected="Mammiferes",
                                                           choices = c("Mammifères" = "Mammiferes",
                                                                       "Oiseaux" = "Oiseaux",
                                                                       "Reptiles" = "Reptiles",
                                                                       "Amphibiens" = "Amphibiens",
                                                                       "Poissons" = "Poissons",
                                                                       "Mollusques" = "Mollusques",
                                                                       "Autres invertébrés" = "Autres_invertebres",
                                                                       "Plantes" = "Plantes",
                                                                       "Champignons et protistes" = "Champignons et protistes")
                                                   ),
                                      textOutput("img_source"),
                                      imageOutput("img_espece")
                                      ),
                         mainPanel(width=8,
                                   amChartsOutput("barplot_FF")
                                   )
                         )
                       )
            )),
    
    tabItem(tabName = "energie_map",
            fluidRow(h3(strong(textOutput("Titre_energie"))),br(),leafletOutput("cartographie_energie",width = "100%"),align="center"),
            fluidRow(column(width=5,sliderInput(inputId="annee_energie",label="Annee",
                                                min=2000, max=2012, value=2015, step=1,sep="")),
                     column(width=4,radioButtons(inputId="var_energie",label="Indicateur",
                                                 choices = c("Consommation electrique"="Conso_electrique",
                                                             "Consommation renouvelable"="Conso_renouvelable",
                                                             "Energie fossile"="Energie_fossile",
                                                             "Energie nucleaire"="Energie_nucleaire",
                                                             "Energie renouvelable"="Energie_renouvelable"),
                                                 selected="Conso_electrique")),
                     column(width=3,sliderInput(inputId = "Nb_rang_energie", "Selectionner la plage de rang",
                                                min = 1, max = 210, value = c(1, 10), step = 1, dragRange = TRUE))),
            fluidRow(amChartsOutput("rang_energie"))
    ),
    
    tabItem(tabName = "energie_evolve",
            fluidRow(h3(strong(textOutput("Titre_energie_2"))),br(),align="center"),
            fluidRow(sidebarPanel(width=3,
                                  radioButtons(inputId="var_conso_energie",label="Choisir une consommation :",
                                               choices = c("Electrique"="Conso_electrique",
                                                           "Energie renouvelable"="Conso_renouvelable"),
                                               selected="Conso_electrique"),
                                  selectInput(inputId = "conso_country_energie", label = "Choisir un pays :",
                                              selected = "France",
                                              choices = Conso_electrique$Pays, width = 200)),
                     mainPanel(width=9,
                               amChartsOutput("conso_pays_energie"))),
            fluidRow(h3(strong("Répartition des sources de production d'electricite (% de la production totale)")),br(),align="center"),
            fluidRow(sidebarPanel(width=3,
                                  selectInput(inputId = "country_energie", label = "Choisir un pays :",
                                              selected = "France",
                                              choices = Energie_fossile$Pays, width = 200)),
                     mainPanel(width=9,
                               amChartsOutput("pays_energie")))
    ),
    
    tabItem(tabName = "data",
            fluidRow(h3(strong("Tables de données et sources")),align="center"),
            selectInput(inputId="tableau",label="Données",selected="CO2",
                        choices = c("CO2"="CO2",
                                    "Effet de serre"="Effet_serre",
                                    "Especes menacees"="Espece_menace",
                                    "Zone de fôret"="ForestArea",
                                    "Niveau de menace des especes"="especes_categories",
                                    "Consommation electrique"="Conso_electrique",
                                    "Consommation renouvelable"="Conso_renouvelable",
                                    "Energie fossile"="Energie_fossile",
                                    "Energie nucleaire"="Energie_nucleaire"
                        )
            ),
            dataTableOutput("table"),
            uiOutput("url")
    ),
    
    tabItem(tabName = "contact",
            strong("Merci d'avoir parcouru notre site. Voici nos mails si vous avez des questions ou si vous voulez effectuer un don."),
            hr(),
            "DURAND-HARDY François : francois.durand-hardy@etudiant.univ-rennes2.fr",
            br(),
            "DABOUDET Claire : claire.daboudet@etudiant.univ-rennes2.fr",
            br(),
            "MAREAU Alexis : alexis.mareau@etudiant.univ-rennes2.fr"
    )
  ),
tags$head(
  tags$style("
            h3 {color: black;
        font-family: cursive;
        font-size: 20px;
        font-type: italic;
      }

    "))
)
dashboardPage(header, sidebar, body, skin = "green")