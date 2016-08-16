
######################################
### Define custom themes for plotting 
#######################################
theme_custom <- function(base_size = 14, base_family = "Helvetica"){
  theme_bw(base_size = base_size, base_family = base_family) %+replace%
    theme(
      axis.title = element_text(size = 14),
      legend.key=element_rect(colour=NA, fill =NA),
      legend.text = element_text(size = rel(0.8)),
      legend.title = element_text(size = rel(0.8)),
      strip.text = element_text(size = rel(0.8)),
      panel.background = element_rect(fill = "white", colour = "black"), 
      strip.background = element_rect(fill = 'antiquewhite'),
      plot.title = element_text(size = rel(1.2)),
      panel.border = element_blank()
    )
}