
# Addressing Aojie's commnets


#############################################################################
############################ Change plot difinit ###########################

bo_12345 <- readRDS("processed_data/bo_12345_401000.Rds")
#
bo_1234 <- readRDS("processed_data/bo_1234_401000.Rds")
#
bo_123 <- readRDS("processed_data/bo_123_401000.Rds")

#########################################################################

library(latex2exp)
library(patchwork)
library(gridExtra)
library(tidyverse)
library(kableExtra)

#########################################################################

opt_type <- c(rep("LHS Sampling",40),rep("Bayesian Opt",10))

initiaization_1 <- c(rep("1st Initialization", 50)) 
initiaization_2 <- c(rep("2nd Initialization", 50))
initiaization_3 <- c(rep("3rd Initialization", 50))

#######################################################

#bo_123_with_init 

bo_123_with_init_lhs <- bo_123$scoreSummary[1:50,] %>% 
  add_column(Sampling_Scheme = opt_type) %>%
  add_column(Initialization = initiaization_1) %>% 
  select(Iteration, Score, Sampling_Scheme, Initialization) %>% 
  filter(Iteration < 41 ) %>%
  arrange(Score) %>% 
  add_column(sample_number = c(1:40))

bo_123_with_init_bo <- bo_123$scoreSummary[1:50,] %>% 
  add_column(Sampling_Scheme = opt_type) %>%
  add_column(Initialization = initiaization_1) %>% 
  select(Iteration, Score, Sampling_Scheme, Initialization) %>% 
  filter(Iteration > 40 ) %>% 
  add_column(sample_number = c(41:50))


data_123_with_init_ordered <- rbind(bo_123_with_init_lhs, bo_123_with_init_bo)

###########################################################
#bo_1234_with_init 

bo_1234_with_init_lhs <- bo_1234$scoreSummary[1:50,] %>% 
  add_column(Sampling_Scheme = opt_type) %>%
  add_column(Initialization = initiaization_2) %>% 
  select(Iteration, Score, Sampling_Scheme, Initialization) %>% 
  filter(Iteration < 41 ) %>%
  arrange(Score) %>% 
  add_column(sample_number = c(1:40))

bo_1234_with_init_bo <- bo_1234$scoreSummary[1:50,] %>% 
  add_column(Sampling_Scheme = opt_type) %>%
  add_column(Initialization = initiaization_2) %>% 
  select(Iteration, Score, Sampling_Scheme, Initialization) %>% 
  filter(Iteration > 40 ) %>% 
  add_column(sample_number = c(41:50))


data_1234_with_init_ordered <- rbind(bo_1234_with_init_lhs, bo_1234_with_init_bo)

####################################################################

#bo_12345_with_init 

bo_12345_with_init_lhs <- bo_12345$scoreSummary[1:50,] %>% 
  add_column(Sampling_Scheme = opt_type) %>%
  add_column(Initialization = initiaization_3) %>% 
  select(Iteration, Score, Sampling_Scheme, Initialization) %>% 
  filter(Iteration < 41 ) %>%
  arrange(Score) %>% 
  add_column(sample_number = c(1:40))

bo_12345_with_init_bo <- bo_12345$scoreSummary[1:50,] %>% 
  add_column(Sampling_Scheme = opt_type) %>%
  add_column(Initialization = initiaization_3) %>% 
  select(Iteration, Score, Sampling_Scheme, Initialization) %>% 
  filter(Iteration > 40 ) %>% 
  add_column(sample_number = c(41:50))


data_12345_with_init_ordered <- rbind(bo_12345_with_init_lhs, bo_12345_with_init_bo)

################################################################

data_with_init <- rbind(data_123_with_init_ordered, data_1234_with_init_ordered, 
                        data_12345_with_init_ordered)


data_with_init
##################################################################  
data_with_init %>% 
  ggplot(aes(sample_number, Score)) +
  geom_point(aes(colour = factor(Sampling_Scheme), 
                 shape=factor(Initialization)), size = 2) +
  scale_shape_manual(values=c(3, 5, 8)) +
  scale_color_manual(values = c("red", "blue")) +
  #theme(legend.position = "none") +
  labs(x = TeX("Number of ENPV Evaluations")) + 
  ylab("ENPV (in million$)") +
  scale_x_continuous(limits = c(1, 50),breaks = seq(0,50,5)) +
  scale_y_continuous(limits = c(27, 38),breaks = seq(27,38)) +
  theme(legend.position = "bottom") +
  guides(col=guide_legend(""),
         shape=guide_legend(""))
  
ggsave("difinit-2.pdf", dpi = 600, width = 8, height = 6)

##################################################################################
############################ Change plot utilitycurve ###########################

bo_123$scoreSummary %>% 
  filter(acqOptimum == TRUE) %>% 
  ggplot(aes(Epoch, gpUtility)) +
  geom_point(size=3, color="yellow", shape=23, fill="firebrick") +
  geom_line(linetype="dashed") +
  scale_x_continuous(limits = c(1, 10),breaks = seq(1,10,1)) +
  xlab("Iteration") +
  labs(y = TeX("Maximum Utility"))

ggsave("utilitycurve-2.pdf", dpi = 600, width = 8, height = 6)


###############################################################################
###################################### chnage plot lhssampling ################

bo_123$scoreSummary[1:40,] %>% 
  arrange(Score) %>% 
  ggplot(aes(Iteration, Score)) +
  geom_point(colour = "blue", size = 3)+
  xlab("Sample Number") + ylab("Expected NPV (in $MM)") +
  scale_x_continuous(limits = c(1, 40),breaks = seq(0,40,2))+
  scale_y_continuous(limits = c(28, 38),breaks = seq(28,38)) +
  geom_hline(aes(yintercept = max(bo_123$scoreSummary[1:40,]$Score))) +
  geom_text(aes(10, max(bo_123$scoreSummary[1:40,]$Score), 
                label = "Maximum ENPV among control values in LHS (35.65)", 
                vjust = - 1, fontface="italic"), fontface="italic", size=4, data = data.frame()) +
  labs(x = TeX("Number of ENPV Evaluations")) +
  labs(y = "ENPV (in million $)")

ggsave("lhssampling-2.pdf", dpi = 600, width = 8, height = 6)


###########################################################################
############################## Change plot lhsbayesop-1 ##################



opt_type <- c(rep("LHS Sampling",40),rep("Bayesian Opt",10))

bo_123$scoreSummary[1:50,] %>% 
  add_column(Sampling_Scheme = opt_type) %>% 
  ggplot(aes(Iteration, Score, colour = Sampling_Scheme)) +
  geom_point(size = 3)+
  labs(x = TeX("Number of ENPV Evaluations")) +
  ylab("Expected NPV (in million $)") +
  scale_x_continuous(limits = c(1, 50),breaks = seq(0,50,5))+
  scale_y_continuous(limits = c(28, 37),breaks = seq(28,37)) +
  scale_color_manual(values = c("red", "blue")) +
  geom_hline(aes(yintercept = max(bo_123$scoreSummary[1:40,]$Score)), alpha=0.4, 
             linetype = "dashed") +
  annotate("text", x=20, y=max(bo_123$scoreSummary[1:40,]$Score), 
           label=("Maximum ENPV among control values in LHS (35.65)"), size=4, color="blue", vjust = - 1, fontface="italic") +
  geom_hline(aes(yintercept = max(bo_123$scoreSummary[1:50,]$Score)), alpha=0.4, 
             linetype = "dashed") +
  annotate("text", x=30, y=max(bo_123$scoreSummary[1:50,]$Score), 
           label=("Maximum ENPV among BO iterations (36.85)"), size=4, color="red", vjust = - 1, fontface="italic") +
  theme(legend.position = "none")

ggsave("lhsbayesop-2.pdf", dpi = 600, width = 8, height = 6)


###########################################################################
############################## Change plot diffu-1-1 ##################

library(ParBayesianOptimization)
u_best_123 <- getBestPars(bo_123)
u_best_1234 <- getBestPars(bo_1234)
u_best_12345 <- getBestPars(bo_12345)

###########

list_best_u <- list(u_best_123,u_best_1234,u_best_12345)
df_list_best_u <- data.frame(matrix(unlist(list_best_u), byrow = F, nrow = 8))
df_list_best_u$inj <- c("Inj1","Inj2","Inj3","Inj4","Inj5","Inj6","Inj7","Inj8")
df_list_best_longer <- df_list_best_u %>% 
  pivot_longer(-inj,names_to = "", values_to = "Injection_Rate")


###########

p1 <- ggplot(data=df_list_best_longer, aes(x=inj, y=Injection_Rate, fill=Replication)) +
  geom_bar(width = 0.4, stat="identity", position=position_dodge()) +
  coord_cartesian(ylim = c(5, 75)) +
  scale_color_manual(labels = c("BO Run #1", "BO Run #2", "BO Run #3"),
                     values = c("red", "blue", "green"),
                     aesthetics = "fill") +
  theme(legend.position = "top") +
  theme(legend.title = element_text(colour="black", size=7, 
                                    face="bold")) +
  theme(legend.text = element_text(size=6)) +
  theme(legend.key.size = unit(0.2, 'cm')) +
  labs(y = TeX("Injection Rate, $m^3/day$"), x= "Injector") +
  guides(fill=guide_legend(""))

ggsave("diffu-2.pdf", dpi = 600, width = 8, height = 6)


# df_new <- df_list_best_longer %>% 
#   group_by(inj) %>%
#   mutate(upper = mean(Injection_Rate) + sd(Injection_Rate), 
#          lower = mean(Injection_Rate) - sd(Injection_Rate))
# 
# 
# p2 <- ggplot(df_new, aes(x = inj, y = Injection_Rate)) +
#   stat_summary(fun = mean, geom = "bar", position = position_dodge(width = .9),size = 3) + 
#   geom_errorbar(aes(ymin = lower, ymax = upper),
#                 width = .2,                    # Width of the error bars
#                 position = position_dodge(.9),
#                 color='#E69F00') +
#   coord_cartesian(ylim = c(5, 100)) +
#   labs(y = TeX("Injection Rate, $m^3/D$"))
# 
# p1

###############################################################################
############################## Change plot onepetroanalysis-1 ##################

library(tidyverse)
library(lubridate)

paper_count_df_indyear <- readRDS("processed_data/data_paper_counts.RDS")

paper_count_df_indyear_seperate_year <- paper_count_df_indyear %>% 
  mutate(year = year(Year)) %>% 
  filter(year>1999)

ggplot(data=paper_count_df_indyear_seperate_year, aes(year,Papers_Per_YEAR)) +
  geom_bar(stat="identity", fill="darkblue", color="red") +
  geom_text(aes(label = Papers_Per_YEAR), vjust = -0.2, size = 5,
            position = position_dodge(0.9)) +
  scale_x_continuous(breaks = seq(2000,2020,2), limits = c(1999,2021)) +
  ylab("Number of Published Papers") +
  xlab("Year") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("onepetroanalysis-2.pdf", dpi = 600, width = 8, height = 6)



################################ Finding exact value of comparison #############
##############################################################################


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

comp_data_frame <- tibble(NPV_max= NPV_max_data, 
                          Reservoir_Simulation = Reservoir_Simulation_number,
                          method=methods_alg,
                          see_number=seed_alg) 



# sorting algorithm based o
comp_data_frame_50sample <- comp_data_frame %>% 
  group_by(method) %>% 
  filter(Reservoir_Simulation<51 & Reservoir_Simulation>0)


ss <- comp_data_frame_50sample %>% 
  group_by(method,see_number) %>% 
  slice(which.max(NPV_max))

ss
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

#############################################################
################# Changes of x and fx to u and fu##############

one_d_fun <- function(x) {
  y <- (1-1/2*((sin(12*x)/(1+x))+(2*cos(7*x)*x^5)+0.7))
  return(y)
}

xmin <- optimize(one_d_fun, c(0, 1), tol = 0.0001, maximum = TRUE)

library(DiceKriging)
library(mvtnorm)
library(tidyverse)

library(tibble)
library(kableExtra)

library(tidyverse)
library(latex2exp)

library(patchwork)
library(gridExtra)
library(tidyverse)

library(ParBayesianOptimization)

x_domain <- seq(0,1,0.01)
y_domain <- one_d_fun(x_domain)

data_domain <- tibble(x=x_domain, y= y_domain)

df_text <- data.frame(
  x = 0.39,
  y = 0,
  text = c("bottom-left")
)
ggplot(data_domain, aes(x,y)) +
  geom_point() +
  geom_vline(xintercept = 0.390, linetype="dotted", 
             color = "blue", size=1.5) +
  annotate("text", x=0.32, y=0, label= "u_M", hjust = 0, vjust=+1 ,colour = "blue") +
  ylim(0,1.04) +
  xlab("u") +
  ylab("J(u)")

ggsave("onedplot-2.pdf", width = 8, height = 5, dpi = 600)

XX <- c(0.05,0.2,0.5,0.6,0.95)

YY <- one_d_fun(XX)

obs_data_medium <- tibble(x=XX, y= YY)

# plot the initial X
ggplot(data=obs_data_medium) +
  geom_point(aes(x=x,y=y),fill="green", color="yellow",shape=23, size=4) +
  xlab("u") +
  ylab("J(u)")

ggsave("initial-d-2.pdf", width = 8, height = 5, dpi = 600)



set.seed(123)
# ######################################################
# one_d_fun <- function(x) {
#   y <- (1-1/2*((sin(12*x)/(1+x))+(2*cos(7*x)*x^5)+0.7))
#   return(y)
# }
# #################################################
# 
# xmin <- optimize(one_d_fun, c(0, 1), tol = 0.0001, maximum = TRUE)
#########################################################

x_domain <- seq(0,1,0.01)
y_domain <- one_d_fun(x_domain)
#y_domain <- max(y_domain) - min(y_domain)
data_domain <- tibble(x=x_domain, y= y_domain)
#data_domain

#r <- max(vec) - min(vec)
#vec <- (vec - min(vec))/r
#########################################################
obs_data_return <- function(x) {
  y_norm <- one_d_fun(x)
  #y_norm = y-mean(y)
  df <- data.frame(x,y_norm)
}
#################################

km_model <- function(obs_data, predict_x) {
  
  model <- km(~0, design = data.frame(x=obs_data$x), response = obs_data$y_norm, multistart = 100, 
              control =list(trace=FALSE))
  paste0(model@covariance@range.val)
  p.SK <- predict(model, newdata=data.frame(x=predict_x), type="SK",cov.compute = TRUE)
  return(list(predict_list=p.SK,cov_par=model@covariance@range.val))
}

###################################


source("plot_funcs/plot_post_indi.R")
source("plot_funcs/plot_post.R")
source("plot_funcs/utility_cal_plot_ind.R")
source("plot_funcs/utility_cal_plot.R")


utility_cal <- function(predict_list, x_predict,obs_data,eps) {
  
  y_max <- max(obs_data$y_norm)
  
  z <- (predict_list$mean - y_max - eps) / (predict_list$sd)
  
  utility <- (predict_list$mean - y_max - eps) * pnorm(z) + (predict_list$sd) * dnorm(z)
  
  new_x <- x_predict[which(utility==max(utility))] 
  
  return(new_x)
}




plot_post <- function(predict_list,x_predict,obs_data) {
  
  mv_sample <- mvtnorm::rmvnorm(100, predict_list$mean, predict_list$cov)
  ss <- t(mv_sample)
  
  dat <-data.frame(x=x_predict, ss) %>% 
    pivot_longer(-x, names_to = "rep", values_to = "value") %>% 
    mutate(rep=as.numeric(as.factor(rep)))
  
  data_gp <- data.frame(x=x_predict,upper95=predict_list$upper95,
                        lower95=predict_list$lower95, mean_curve=predict_list$mean)
  
  
  ggplot(dat,aes(x=x,y=value)) + 
    geom_line(aes(group=as.factor(rep), color="blue"), alpha=0.7) +
    #scale_colour_manual("",values = cols) +
    scale_color_manual("", values = c("black","blue", "red"), 
                       labels=c("True Function", "Sample from the posterior","Mean Value")) +#REPLICATES +
    geom_ribbon(data = data_gp, 
                aes(x, 
                    y = mean_curve, 
                    ymin = lower95, 
                    ymax = upper95,
                    fill="grey"), alpha = 0.6, show.legend = T) +
    scale_fill_manual("",values="gray", labels="95% CI") +
    geom_line(dat = data_gp, aes(x=x,y=mean_curve, color="red"), size=1) + #MEAN
    geom_point(data=obs_data,aes(x=x,y=y_norm),fill="green", color="yellow",shape=23, size=2) +
    geom_line(data=data_domain,aes(x=x_domain,y=y_domain, color="black"),size=1, alpha=0.7) +
    scale_y_continuous(lim=c(-0.5,1.2)) +
    scale_x_continuous(lim=c(0,1)) +
    theme(legend.position="none") +
    theme(legend.text=element_text(size=4)) +
    theme(text = element_text(size=6)) +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank())
  #theme(legend.position="top")
  
}

##################################################################

utility_cal <- function(predict_list, x_predict,obs_data,eps) {
  
  y_max <- max(obs_data$y_norm)
  
  z <- (predict_list$mean - y_max - eps) / (predict_list$sd)
  
  utility <- (predict_list$mean - y_max - eps) * pnorm(z) + (predict_list$sd) * dnorm(z)
  
  new_x <- x_predict[which(utility==max(utility))] 
  
  return(new_x)
}

########################################################################


utility_cal_plot <- function(predict_list, x_predict,obs_data,eps,x_next) {
  
  y_max <- max(obs_data$y_norm)
  z <- (predict_list$mean - y_max - eps) / (predict_list$sd)
  
  utility <- (predict_list$mean - y_max - eps) * pnorm(z) + (predict_list$sd) * dnorm(z)
  
  data_utility <- data.frame(x=x_predict, utility=utility)
  
  ggplot(data_utility,aes(x,utility)) +
    geom_line() +
    scale_y_continuous(position = "right") +
    theme(text = element_text(size=6)) +
    geom_vline(xintercept = x_next, linetype="dotted", 
               color = "blue", size=0.5) +
    annotate("text", x=x_next, y=0, label= "u_next", hjust = -0.5, vjust=-2 ,colour = "blue") +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank())
}

###############################################



plot_post_indi <- function(predict_list,x_predict,obs_data) {
  
  
  mv_sample <- mvtnorm::rmvnorm(100, predict_list$mean, predict_list$cov)
  ss <- t(mv_sample)
  
  dat <-data.frame(x=x_predict, ss) %>% 
    pivot_longer(-x, names_to = "rep", values_to = "value") %>% 
    mutate(rep=as.numeric(as.factor(rep)))
  
  data_gp <- data.frame(x=x_predict,upper95=predict_list$upper95,
                        lower95=predict_list$lower95, mean_curve=predict_list$mean)
  
  
  ggplot(dat,aes(x=x,y=value)) + 
    geom_line(aes(group=as.factor(rep), color="blue"), alpha=0.7) +
    #scale_colour_manual("",values = cols) +
    scale_color_manual("", values = c("black","blue", "red"), 
                       labels=c("True Function","Sample from the posterior","Mean Value")) +#REPLICATES +
    geom_ribbon(data = data_gp, 
                aes(x, 
                    y = mean_curve, 
                    ymin = lower95, 
                    ymax = upper95,
                    fill="grey"), alpha = 0.6, show.legend = T) +
    scale_fill_manual("",values="gray", labels="95% CI") +
    geom_line(dat = data_gp, aes(x=x,y=mean_curve, color="red"), size=1) + #MEAN
    geom_point(data=obs_data,aes(x=x,y=y_norm),fill="green", color="yellow",shape=23, size=2) +
    geom_line(data=data_domain,aes(x=x_domain,y=y_domain, color="black"),size=1, alpha=0.7) +
    scale_y_continuous(lim=c(-0.5,1.25)) +
    scale_x_continuous(lim=c(0,1)) +
    xlab("u") +
    ylab("J(u)") +
    theme(legend.position="top") 
  
}

utility_cal_plot_ind <- function(predict_list, x_predict,obs_data,eps,x_next) {
  
  y_max <- max(obs_data$y_norm)
  z <- (predict_list$mean - y_max - eps) / (predict_list$sd)
  
  utility <- (predict_list$mean - y_max - eps) * pnorm(z) + (predict_list$sd) * dnorm(z)
  
  data_utility <- data.frame(x=x_predict, utility=utility)
  
  ggplot(data_utility,aes(x,utility)) +
    geom_line() +
    geom_vline(xintercept = x_next, linetype="dotted", 
               color = "blue", size=1) +
    annotate("text", x=x_next, y=0, label= "u_next", hjust = 1.2, vjust=-1 ,colour = "blue") +
    xlab("u") +
    ylab("AcqFunc(u)") 
  
}



set.seed(123)
x <- c(0.05,0.2,0.5,0.6,0.95)
obs_data <- obs_data_return(x)
x_predict <- seq(0,1,0.005)

predict_list <- km_model(obs_data,x_predict)
posterior_1 <- plot_post_indi(predict_list$predict_list,x_predict,obs_data)


new_x_point1 <- utility_cal(predict_list$predict_list,x_predict,obs_data,0.1)
utility_1 <- utility_cal_plot_ind(predict_list$predict_list,x_predict,obs_data,0.1, new_x_point1)

posterior_1 /
  utility_1


ggsave("exampleshow-2.pdf", width = 10, height = 6, dpi = 600)


x <- c(0.05,0.15,0.2,0.5,0.6,0.95)
obs_data <- obs_data_return(x)
x_predict <- seq(0,1,0.005)

predict_list <- km_model(obs_data,x_predict)
posterior_1 <- plot_post(predict_list$predict_list,x_predict,obs_data)

new_x_point1 <- utility_cal(predict_list$predict_list,x_predict,obs_data,0.1)
utility_1 <- utility_cal_plot(predict_list$predict_list,x_predict,obs_data,0.1, new_x_point1)
#utility_1
#################

x2 <- c(0.05,0.15,0.2,0.5,0.6,0.95,new_x_point1)
obs_data2 <- obs_data_return(x2)
x_predict <- seq(0,1,0.005)

predict_list2 <- km_model(obs_data2,x_predict)
posterior_2 <- plot_post(predict_list2$predict_list,x_predict,obs_data2)
new_x_point2 <- utility_cal(predict_list2$predict_list,x_predict,obs_data2,0.1)
utility_2 <- utility_cal_plot(predict_list2$predict_list,x_predict,obs_data2,0.1, new_x_point2)

###################

x3 <- c(0.05,0.15,0.2,0.5,0.6,0.95,new_x_point1,new_x_point2)
obs_data3 <- obs_data_return(x3)
x_predict <- seq(0,1,0.005)

predict_list3 <- km_model(obs_data3,x_predict)
posterior_3 <- plot_post(predict_list3$predict_list,x_predict,obs_data3)

new_x_point3 <- utility_cal(predict_list3$predict_list,x_predict,obs_data3,0.1)
utility_3 <- utility_cal_plot(predict_list3$predict_list,x_predict,obs_data3,0.1, new_x_point3)

##################

# (posterior_1 + utility_1) / 
# (posterior_2 + utility_2) / 
# (posterior_3 + utility_3) 
#plot_layout(ncol = 2)


library(gridExtra)
g <- grid.arrange(posterior_1, utility_1, posterior_2, utility_2, posterior_3, utility_3, ncol=2,
             widths = c(6, 4))  

ggsave("allinone2.pdf", g, width = 10, height = 10, dpi = 600)
