##############################################
getwd()
library(tidyverse)
library(GA)
library(ParBayesianOptimization)
################# BO ################################

bo_12345 <- readRDS("processed_data/bo_12345_401000.Rds")
bo_12345_npv_result <- bo_12345$scoreSummary$Score
bo_12345_npv_result[1:40] <- max(bo_12345_npv_result[1:40])
bo_12345_npv_ite <- bo_12345$scoreSummary$Iteration

for (i in seq(41,50)) {
  
  if (bo_12345_npv_result[i] < bo_12345_npv_result[i-1]){
    
    bo_12345_npv_result[i] <- bo_12345_npv_result[i-1] 
    
  }
  
}

bo_1234 <- readRDS("processed_data/bo_1234_401000.Rds")
bo_1234_npv_result <- bo_1234$scoreSummary$Score
bo_1234_npv_result[1:40] <- max(bo_1234_npv_result[1:40])
bo_1234_npv_ite <- bo_1234$scoreSummary$Iteration

for (i in seq(41,50)) {
  
  if (bo_1234_npv_result[i] < bo_1234_npv_result[i-1]){
    
    bo_1234_npv_result[i] <- bo_1234_npv_result[i-1] 
    
  }
  
}

bo_123 <- readRDS("processed_data/bo_123_401000.Rds")
bo_123_npv_result <- bo_123$scoreSummary$Score
bo_123_npv_result[1:40] <- max(bo_123_npv_result[1:40])
bo_123_npv_ite <- bo_123$scoreSummary$Iteration

for (i in seq(41,50)) {
  
  if (bo_123_npv_result[i] < bo_123_npv_result[i-1]){
    
    bo_123_npv_result[i] <- bo_123_npv_result[i-1] 
    
  }
  
}

#######################BO_50 ############################
bo_123_50 <- readRDS("processed_data/bo_1234_50_10000.Rds")
ss_50 <- bo_123_50$scoreSummary
#ss <- bo_123$scoreSummary

#plot(bo_123_50)
#getBestPars(bo_123_50)

########### GA ######################################

ga_12345 <- readRDS("processed_data/GA_12345.Rds")
ga_12345_npv_result <- rep(ga_12345@summary[,"max"],each=25)
ga_12345_npv_ite <- seq(1,250)

ga_1234 <- readRDS("processed_data/GA_1234.Rds")
ga_1234_npv_result <- rep(ga_1234@summary[,"max"],each=25)
ga_1234_npv_ite <- seq(1,250)

ga_123 <- readRDS("processed_data/GA_123.Rds")
ga_123_npv_result <- rep(ga_123@summary[,"max"],each=25)
ga_123_npv_ite <- seq(1,250)

########### PSO #######################################
#
pso_12345 <- readRDS("processed_data/pso_12345.Rds")
pso_12345_npv_result_i <- rep(0,10)
for (i in 1:10) {
  pso_12345_npv_result_i[i] <- max(-pso_12345$stats$f[[i]])
}

pso_12345_npv_result_i
pso_12345_npv_result <- rep(pso_12345_npv_result_i,each=25)
pso_12345_npv_ite <- seq(1,250)

#
pso_1234 <- readRDS("processed_data/pso_1234.Rds")
pso_1234_npv_result_i <- rep(0,10)
for (i in 1:10) {
  pso_1234_npv_result_i[i] <- max(-pso_1234$stats$f[[i]])
}
pso_1234_npv_result <- rep(pso_1234_npv_result_i,each=25)
pso_1234_npv_ite <- seq(1,250)

#
pso_123 <- readRDS("processed_data/pso_123.Rds")
pso_123_npv_result_i <- rep(0,10)
for (i in 1:10) {
  pso_123_npv_result_i[i] <- max(-pso_123$stats$f[[i]])
}
pso_123_npv_result <- rep(pso_123_npv_result_i,each=25)
pso_123_npv_ite <- seq(1,250)

pso_123$par
#####################################################################

NPV_max_data <- c(bo_12345_npv_result, bo_1234_npv_result, bo_123_npv_result, 
                  ga_12345_npv_result, ga_1234_npv_result, ga_123_npv_result,
                  pso_12345_npv_result, pso_1234_npv_result, pso_123_npv_result)


Reservoir_Simulation_number = c(bo_12345_npv_ite, bo_1234_npv_ite,bo_123_npv_ite, 
                                ga_12345_npv_ite, ga_1234_npv_ite, ga_123_npv_ite,
                                pso_12345_npv_ite, pso_1234_npv_ite,pso_123_npv_ite)


methods_alg <- c(rep("BO",50), rep("BO",50),rep("BO",50),
                 rep("GA",250), rep("GA",250),rep("GA",250),
                 rep("PSO",250), rep("PSO",250),rep("PSO",250))

seed_alg <- c(rep("Repeat1",50), rep("Repeat2",50),rep("Repeat3",50),
                 rep("Repeat1",250), rep("Repeat2",250),rep("Repeat3",250),
                 rep("Repeat1",250), rep("Repeat2",250),rep("Repeat3",250))

comp_data_frame <- tibble(NPV_max= -NPV_max_data, 
                          Reservoir_Simulation = Reservoir_Simulation_number,
                          method=methods_alg,
                          see_number=seed_alg) 

ggplot(comp_data_frame, aes(Reservoir_Simulation, NPV_max, colour=method)) +
  geom_point() +
  facet_grid(cols = vars(see_number)) +
  xlab("Required Number of Reservoir Simulation (forward modeling)") +
  ylab("-Max NPV Reached")


bo_mean <- c(max(bo_12345_npv_result), max(bo_1234_npv_result), max(bo_123_npv_result))
median(bo_mean)

pso_mean <- c(max(pso_12345_npv_result), max(pso_1234_npv_result), max(pso_123_npv_result))
median(pso_mean)

ga_mean <- c(max(ga_12345_npv_result), max(ga_1234_npv_result), mean(ga_123_npv_result))
median(ga_mean)

tibbel_analyze <- tibble(methods= c("Bayesian Optimization", "Particle Swarm Optimization", 
                                    "Genetic Alghorithm Optimization"),
                         Median_max_NPV=c(median(bo_mean),median(pso_mean),median(ga_mean)),
                         required_simulation= c(50, 250,250))


analyze_long <- pivot_longer(tibbel_analyze,-methods,names_to = "new")
ggplot(analyze_long, aes(methods,value)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ new)


library(gt)

colnames(tibbel_analyze) <- c("Opt Methods", "Max NPV (median of three repeataions)", 
                              "Number of Required Simulation")
tibbel_analyze %>% 
  gt() %>% 
  fmt_number(columns = "Max NPV (median of three repeataions)", decimals = 2)
