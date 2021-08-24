############

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
    annotate("text", x=x_next, y=0, label= "x_next", hjust = -0.5, vjust=-2 ,colour = "blue") +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank())
}