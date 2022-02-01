function(input, output, session) {
  var_AE = reactive({
    x = get(input$var_AE)
  })
  
  varAE_evolve_pays = reactive({
    x = get(input$varAE_evolve_pays)
  })
  
  # varAE_evolve_world = reactive({
  #   x = get(input$varAE_evolve_world)
  # })
  
  var_energie = reactive({
    x = get(input$var_energie)
  })
  
  var_conso_energie = reactive({
    x = get(input$var_conso_energie)
  })
  
  tableau = reactive({
    x = get(input$tableau)
  })
  
  
  output$presentation <- renderText({ 
    presentation
  })
  
  output$site <- renderText({ 
    site
  })
  
  output$association <- renderAmCharts({ 
    amHist(x=association$Année,y=association$Don,type=c("l"),ylab="Total des dons",xlab="Année")
  })
  
  
  output$Titre_AE <- renderText({
    var_AE = var_AE()
    if (all(var_AE %in% CO2)){
      "Cartographie et rang : emissions de CO2 (tonnes metriques par habitant)"
    }
    
    else {
      "Cartographie et rang : emissions totales de gaz à effet de serre (kt d’équivalent CO2)"
    }
  })
  
  output$ssTitre_AE <- renderText({
    var_AE = var_AE()
    if (all(var_AE %in% CO2)){
      "Les émissions de dioxyde de carbone sont celles qui émanent lors de la combustion de combustibles fossiles et de la fabrication de ciment. Elles comprennent les émissions de dioxyde de carbone produites lors de la consommation de combustibles solides, liquides et gazeux et de torchage."
    }
    
    else {
      "Un gaz à effet de serre est une substance gazeuse qui a la caractéristique d'absorber le rayonnement infrarouge produit par la Terre. Les gaz à effet de serre sont considérés comme l'une des causes du réchauffement climatique. Des GES sont naturellement présents dans l'atmosphère mais on retrouve aussi de nombreux GES industriels."
    }
  })
  
  output$cartographie_AE <- renderLeaflet({
    var <- var_AE()
    carte(var,paste("A",input$annee_AE,sep=""))
  })
  
  output$rang_AE = renderAmCharts({
    var = var_AE()
    rang(var,paste("A",input$annee_AE,sep=""),input$Nb_rang_AE[1],input$Nb_rang_AE[2])
  })
  
  output$Titre_AE_evolve <- renderText({
    if (input$varAE_evolve_world == "CO2"){
      "Evolution des émissions de CO2 dans le monde (tonnes métriques par habitant)"
    }
    else if (input$varAE_evolve_world == "Effet_serre"){
      "Evolution des émissions totales de gaz à effet de serre dans le monde (kt équivalent CO2)"
    }
    else if (input$varAE_evolve_world == "Niveau_de_mer"){
      "Evolution du niveau de la mer dans le monde (mm eau équivalent, par rapport à l'année 1992)"
    }
    else if (input$varAE_evolve_world == "Glaciers"){
      "Evolution des glacies"
    }
    else {
      "Evolution des anomalies de température dans le monde (degre celsius)"
    }
  })
  
  output$AE_evolve_world = renderAmCharts({
    fonction_AE_evolve_world(input$varAE_evolve_world)
  })
  
  output$Titre_AE_evolve_pays <- renderText({
    if (input$varAE_evolve_pays == "CO2"){
      "Evolution des émissions de CO2 par pays (tonnes métriques par habitant)"
    }
    else{
      "Evolution des émissions totales de gaz à effet de serre par pays (kt équivalent CO2)"
    }
  })
  
  output$AE_evolve_pays = renderAmCharts({
    var = varAE_evolve_pays()
    transpose_conso(input$pays_AE_evolve,var)
  })
  
  
  output$FF_foret = renderAmCharts({
    deforestation(input$pays_FF)
  })
  
  output$cartographie_FF <- renderLeaflet({
    carte(Espece_menace,input$espece_FF)
  })
  
  output$moyenne_FF <- renderTable({
    d = Espece_menace[,-1] %>% group_by(Continent) %>% summarise_all(mean)
  })
  
  output$barplot_FF = renderAmCharts({
    hist_pile(input$input_FF)
  })
  
  output$img_espece = renderImage({
    img_espece(input$input_FF)
  }, deleteFile = FALSE)
  
  output$img_source = renderText({
    sources = list("Mammifères" = "yetiblog.org",
                   "Oiseaux" = "WWF France",
                   "Reptiles" = "WWF France",
                   "Amphibiens" = "imitateur.centerblog.net",
                   "Poissons" = "WWF france",
                   "Mollusques" = "eee.mnhn.fr",
                   "Autres_invertebres" = "Wapiti, Magazine",
                   "Plantes" = "WWF France",
                   "Champignons et protistes" = "bozar88.deviantart.com")
    paste("source de l'image : ",sources[[input$input_FF]],sep = "")
  })
  
  
  output$Titre_energie <- renderText({
    var_energie = var_energie()
    if (all(var_energie %in% Conso_electrique)){
      "Cartographie et rang : consommation d’électricité (KWh par habitant)"
    }
    else if (all(var_energie %in% Conso_renouvelable)){
      "Cartographie et rang : consommation d’énergies renouvelables (% de la consommation totale d’énergie)"
    }
    else if (all(var_energie %in% Energie_fossile)){
      "Cartographie et rang : production d'électricité à partir des sources en pétrole, gaz et charbon (% du total)"
    }
    else if (all(var_energie %in% Energie_nucleaire)){
      "Cartographie et rang : production d’électricité à partir de sources nucléaires (% du total)"
    }
    else{
      "Cartographie et rang : Production d’électricité à partir de sources d’énergie renouvelables, hors énergie hydroélectrique (% du total)"
    }
  })
  
  output$rang_energie = renderAmCharts({
    var = var_energie()
    rang(var,paste("A",input$annee_energie,sep=""),input$Nb_rang_energie[1],input$Nb_rang_energie[2])
  })
  
  output$cartographie_energie <- renderLeaflet({
    var <- var_energie()
    carte(var,paste("A",input$annee_energie,sep=""))
  })

  output$Titre_energie_2 <- renderText({
    var = var_conso_energie()
    if (all(var %in% Conso_electrique)){
      "Evolution de la consommation d’électricité (KWh par habitant)"
    }
    else {
      "Evolution de la consommation d’énergies renouvelables (% de la consommation totale d’énergie)"
    }
  })
  
  output$conso_pays_energie = renderAmCharts({
    var = var_conso_energie()
    transpose_conso(input$conso_country_energie,var)
  })
  
  output$pays_energie = renderAmCharts({
    transpose_energie_pays(input$country_energie)
  })
  
  
  output$table <- renderDataTable({
    tableau <- tableau()
    tableau
  })
  
  output$url <- renderUI({
    tableau <- tableau()
    if (all(tableau %in% CO2)){
      h <- a("https://donnees.banquemondiale.org/indicateur/en.atm.co2e.pc",href="https://donnees.banquemondiale.org/indicateur/en.atm.co2e.pc")
    }
    else if (all(tableau %in% Effet_serre)){
      h <- a("https://donnees.banquemondiale.org/indicateur/en.atm.ghgt.kt.ce?view=chart",href="https://donnees.banquemondiale.org/indicateur/en.atm.ghgt.kt.ce?view=chart")
    }
    else if (all(tableau %in% ForestArea)){
      h <- a("https://donnees.banquemondiale.org/indicateur/ag.lnd.frst.zs",href="https://donnees.banquemondiale.org/indicateur/ag.lnd.frst.zs")
    }
    else if (all(tableau %in% especes_categories) | all(tableau %in% Espece_menace)){
      h <- a("https://www.iucnredlist.org/resources/summary-statistics#Summary%20Tables",href="https://www.iucnredlist.org/resources/summary-statistics#Summary%20Tables")
    }
    else if (all(tableau %in% Conso_electrique)){
      h <- a("https://donnees.banquemondiale.org/indicateur/eg.use.elec.kh.pc",href="https://donnees.banquemondiale.org/indicateur/eg.use.elec.kh.pc")
    }
    else if (all(tableau %in% Conso_renouvelable)){
      h <- a("https://donnees.banquemondiale.org/indicateur/eg.fec.rnew.zs",href="https://donnees.banquemondiale.org/indicateur/eg.fec.rnew.zs")
    }
    else if (all(tableau %in% Energie_fossile)){
      h <- a("https://donnees.banquemondiale.org/indicateur/eg.elc.fosl.zs",href="https://donnees.banquemondiale.org/indicateur/eg.elc.fosl.zs")
    }
    else if (all(tableau %in% Energie_renouvelable)){
      h <- a("https://donnees.banquemondiale.org/indicateur/EG.ELC.RNWX.ZS",href="https://donnees.banquemondiale.org/indicateur/EG.ELC.RNWX.ZS")
    }
    else{
      h <- a("https://donnees.banquemondiale.org/indicateur/eg.elc.nucl.zs",href="https://donnees.banquemondiale.org/indicateur/eg.elc.nucl.zs")
    }
    tagList("Source : ", h)
    })
  
  
  output$home <- renderImage({
    return(list(
      src="ecologie.png",
      contentType= "www/image/png",
      alt = "ecologie"
    ))
  },
  deleteFile=FALSE)
}