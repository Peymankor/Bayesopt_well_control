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
    xlab("x") +
    ylab("f(x)") +
    theme(legend.position="top") 
  
}