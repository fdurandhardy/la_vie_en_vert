library(sf)
library(dplyr)
library(leaflet)
library(tidyverse)
library(maps)
library(rAmCharts)
library(shiny)
library(png)
library(markdown)
library(shinydashboard)

CO2 = read_delim("donnees/CO2.csv",delim=";")
Effet_serre = read_delim("donnees/Effet_serre.csv",delim=";")
Conso_electrique = read_delim("donnees/Conso_electrique.csv",delim=";")
Conso_renouvelable = read_delim("donnees/Conso_renouvelable.csv",delim=";")
Energie_fossile = read_delim("donnees/Energie_fossile.csv",delim=";")
Energie_nucleaire = read_delim("donnees/Energie_nucleaire.csv",delim=";")
Energie_renouvelable = read_delim("donnees/Energie_renouvelable.csv",delim=";")
ForestArea = read_delim("donnees/ForestArea.csv",delim=";")
Espece_menace = read_delim("donnees/Espece_menace.csv",delim=";")
Espece_menace[,2:11] = Espece_menace[,2:11] %>% transmute_all(as.integer)
especes_categories = read_delim("donnees/especes_categories.csv",delim=";")
Monde = read_delim("donnees/Monde.csv",delim=";")
Temperature_eau_air = read_delim("donnees/Temperature_eau_air.csv",delim=";")
coordonnees = st_as_sf(map('world', plot = FALSE, fill = TRUE)) %>%
  rename(geometry = geom)
presentation = readLines("donnees/presentation.txt",encoding='UTF-8')
site = readLines("donnees/site.txt",encoding='UTF-8')

Donnees_Bleu = c(CO2,Effet_serre)
Donnees_Vert = c(ForestArea,Espece_menace)
Donnees_reverse = c(Conso_renouvelable,Energie_renouvelable,Espece_menace)


choix_palette = function(var,c){
  if(all(var %in% Donnees_reverse)){
    rvs = TRUE
  }
  else{rvs = FALSE}
  
  if(all(var %in% Donnees_Bleu)){
    palette = colorBin("Blues",domain = log(c))
  }
  else if(all(var %in% Donnees_Vert)){
    palette = colorBin("Greens",reverse = rvs,domain = log(c))
  }
  else{palette = colorBin("Reds",reverse = rvs,domain = log(c))}
}

unites = function(var){
  if(all(var %in% CO2)){unite = "tonnes metriques par habitant"}
  else if (all(var %in% Conso_electrique)){unite="kWh par habitant"}
  else if (all(var %in% Conso_renouvelable)){unite="% "}#de la consommation totale d'énergie
  else if (all(var %in% Effet_serre)){unite="kt"}#of CO2 equivalent
  else if (all(var %in% Energie_fossile)|all(var %in% Energie_nucleaire)|all(var %in% Energie_renouvelable)){unite="%"}#of total
  else{unite="unite(s)"}
  return(unite)
}

carte = function(variable,annee){
  d=inner_join(x=variable,y=coordonnees,by=c("Pays"="ID")) %>%
    select(Pays,annee,geometry)
  c = as.data.frame(d)[,2]
  d = d %>% st_as_sf()
  pal = choix_palette(variable,c)
  unit = unites(variable)
  labels = sprintf(
    "<strong>%s</strong><br/>%g %s",
    as.character(d$Pays),c,unit)%>% 
    lapply(htmltools::HTML)
  map = leaflet(data=d) %>% 
    setView(0,30,1.5) %>% 
    addTiles() %>%
    addPolygons(opacity = 1,
                weight = 2,
                color = "white",
                dashArray = 3,
                fillOpacity = 0.5,
                fillColor = pal(log(c)),
                highlight = highlightOptions(
                  weight = 5,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = .5,
                  bringToFront = TRUE),
                label = labels)
}

rang = function(variable,annee,Nbdebut,Nbfin){
  DataTable = variable%>%
    select(Pays,annee)
  DataTable2 = as.data.frame(DataTable)
  DataTable2 = as_tibble(DataTable2[order(-DataTable[,2]),])
  DataTable = DataTable2 %>%
    mutate(Rang = row_number())%>%
    select(Rang,Pays,annee)
  Tab_rang = amBarplot(x = "Pays", y = annee,data = DataTable[Nbdebut:Nbfin,], horiz = TRUE, zoom = TRUE)
  return(Tab_rang)
}

hist_pile = function(variable){
  annee = colnames(especes_categories)[-c(1,19)]
  data = especes_categories %>% filter(Groupes == variable)
  data = data.frame(annee,
                    "En voie de disparition critique" = as.numeric(data[1,-c(1,19)]),
                    "En voie de disparition" = as.numeric(data[2,-c(1,19)]),
                    "Vulnerable" = as.numeric(data[3,-c(1,19)]),
                    check.names = FALSE
  )
  amBarplot(x = "annee",
            y = colnames(data)[-1],
            data = data,
            stack_type = "regular",
            groups_color = c("#FF3300","#FF6600","#FF9900")) %>%
    setLegend(enabled = TRUE)
}

deforestation = function(Pays){
  donnee = ForestArea %>% select("Annee",Pays)
  donnee$Annee = as.POSIXct(paste(donnee$Annee),format = "%Y")
  donnee %>% 
    amTimeSeries(col_date = "Annee",
                 col_series = Pays,
                 fillAlphas = 0.5,color="green")
}

transpose_conso = function(pays,var){
  year = as.POSIXct(paste(seq(2000,2015)), format = "%Y")
  t = as.numeric(var[var$Pays==pays,2:17])
  df = data.frame(year,t)
  df%>%amTimeSeries('year','t',
                    bullet="bubble",bulletSize=5,linewidth=2,linetype = 5,fillAlphas = 0.5)
}

transpose_energie_pays = function(pays){
  year = as.character(seq(2000,2015))
  fossile = as.numeric(Energie_fossile[Energie_fossile$Pays==pays,2:17])
  nucleaire = as.numeric(Energie_nucleaire[Energie_nucleaire$Pays==pays,2:17])
  renouvelable = as.numeric(Energie_renouvelable[Energie_renouvelable$Pays==pays,2:17])
  autre = rep(100,16)-fossile-nucleaire-renouvelable
  df = data.frame(year,fossile,nucleaire,renouvelable,autre)
  amBarplot(x = "year", y = c("fossile", "nucleaire","renouvelable","autre"),
            data = df,stack_type = "regular",groups_color=c("#663300","#FF6600","#339900","#999999")) %>%
    setLegend(enabled = TRUE)
}

fonction_AE_evolve_world = function(col){
  if (col %in% colnames(Monde)){
    year = as.POSIXct(paste(seq(2000,2015)), format = "%Y")
    variable = as.numeric(t(Monde%>%select(col)))
    df = data.frame(year,variable)
    df%>%amTimeSeries('year',"variable",
                      bullet="bubble",bulletSize=5,linewidth=2,linetype = 5,fillAlphas = 0.5)
  }
  else{
    year = as.POSIXct(paste(seq(1880,2018)), format = "%Y")
    Air = as.numeric(t(Temperature_eau_air%>%select(Terre)))
    Ocean = as.numeric(t(Temperature_eau_air%>%select(Ocean)))
    df = data.frame(year,Air,Ocean)
    df%>%amTimeSeries('year',c("Air","Ocean"),
                      bullet="bubble",bulletSize=5,linewidth=2,linetype = 5,color=c("green","blue"))
  }
}

img_espece = function(espece){
  fichier = normalizePath(file.path('www','images', 'especes menaces',
                                    paste(espece,".jpg", sep='')))
  return(list(src = fichier,
              alt = "probleme d'affichage"))
}  
