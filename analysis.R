install.packages('car', dependencies = T)
install.packages('sciplot')
install.packages('emmeans')
install.packages('lattice')
install.packages('psych')
install.packages('tidyverse')
install.packages('effectsize')
install.packages('extrafont')

library(car)
library(sciplot)
library(emmeans)
library(lattice)
library(effectsize)
library(psych)
library(dplyr)
library(tidyverse)
library(extrafont)
library(ggplot2)
font_import()
loadfonts(device="win", quiet=TRUE)
# Installing required packages

# Preparation
setwd('~/Projects/sci-201-cpu-c-states')
data = read.csv('influxdb.csv')

# Get Values
c7_data = data[data$c.state == "C7", ]
c2_data = data[data$c.state == "C2", ]

# Checking Assumptions
check_normality <- function(dataset) {
    shapiro <- shapiro.test(dataset)
    qqPlot(dataset, main = shapiro$p)
    return(shapiro)
}

check_normality(c7_data$mean)
check_normality(c2_data$mean)
leveneTest(mean ~ c.state, data = data)

check_shape <- function(dataset, dataset2) {
    par(mfrow=c(1,2))
    hist(dataset)
    hist(dataset2)
    par(mfrow=c(1,1))
}

check_shape(c7_data$mean, c2_data$mean)

# Visualize each points
summary = describeBy(newdata$mean, newdata$c.state, mat = T) # overall stats
plot_points <- function(dataset_c7, dataset_c2) {
    par(bg = "#e8f0f3")
    plot(dataset_c7, col="tomato", pch=20, cex=2, xlim=c(0,30),ylim=c(23, 27), 
         xlab="", ylab="Power Consumption (W)", main="Average Power Consumption of Individual Unit",
         family="Carlito")
    points(dataset_c2, col="dodgerblue", pch=20, cex=2)
    legend(25,27, legend=c("C2","C7"), fill=c("dodgerblue","tomato"))
    par(bg="white")
}

plot_points(c7_data$mean, c2_data$mean)

# Removing Suspicious Datapoint in C7
c7_data_new <- c7_data[c7_data$mean < 25, ]
check_normality(c7_data_new$mean)
var.test(c7_data_new$mean, c2_data$mean)
plot_points(c7_data_new$mean, c2_data$mean)

# Running Basic t-test
t.test(c7_data$mean, c2_data$mean, var.equal = T)
t.test(c7_data_new$mean, c2_data$mean, var.equal = T)

# New Data (dataframe with C2 and filtered C7 data)
newdata <- rbind(c2_data, c7_data_new) # join c7_new and c2_data

# Plot with Mean and StDev
df_mean_std <- newdata %>%
  group_by(c.state) %>%
  summarise_at(vars(mean), list(mean=mean, sd=sd)) %>% 
  as.data.frame()

# GGPlot Custom Template
plot_gg <- function(data, title, lower_ylim, higher_ylim) {
  ggplot(data , aes(x=group1, y=mean, fill=group1)) + 
    geom_bar(stat="identity", width=0.5) +
    scale_fill_manual("legend",values=c("C2"="dodgerblue","C7"="tomato")) + 
    geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=0.3, size=0.8) +
    labs(x = "C-States", y = "Power Consumption (W)", title=title) +
    theme(plot.title = element_text(family="Carlito", size=19),
          axis.title.x = element_text(family="Carlito", size=16),
          axis.title.y = element_text(family="Carlito", size=16),
          axis.text.x = element_text(face="bold", size=15),
          axis.text.y = element_text(face="bold", size=12)
    ) +
    geom_point(size=2) + coord_cartesian(ylim = c(lower_ylim,higher_ylim))
}
plot_gg(summary, "Power Consumption Difference of C2 and C7 ", 23, 26)

# Example Block ANOVA
# =================== NOT RELEVANT
# blockanova = aov(mean ~ as.factor(c.state) + as.factor(hrs), data=newdata)
# summary(blockanova)
# plot(lsmeans(blockanova,~ as.factor(c.state)), horizontal = F)
# plot(lsmeans(blockanova,~ as.factor(hrs)), horizontal = F)

# ANCOVA
# ====== DATA COLLECTION PROBLEM NOT USED
# ancova = aov(mean ~ as.factor(c.state)*cpu, data=data)
# summary(ancova)
# regr_c2 = lm(mean ~ cpu, data = c2_data)
# regr_c7 = lm(mean ~ cpu, data = c7_data)

# plot(c2_data$cpu, c2_data$mean, col="red", ylim=c(23,26), xlim=c(0,0.20), xlab = "CPU Usage", ylab="Watts")
# points(c7_data$cpu, c7_data$mean, pch=2, col = "#65b2bc")
# abline(regr_c2, col="red")
# abline(regr_c7, col="#65b2bc")
# legend("topleft", legend=c("C2", "C7"), pch=c(1,2), lty=c(1,2), col=c("red","#65b2bc"), bty="n")


# Using Filtered Data
check_normality(c7_data_new$filtered)
check_normality(c2_data$filtered)
leveneTest(filtered ~ c.state, data = data)
check_shape(c7_data$filtered, c2_data$filtered)

# Visualize each points
describeBy(newdata$filtered, newdata$c.state, mat = T) # overall stats
plot_points(c7_data_new$filtered, c2_data$filtered)

# Running Basic t-test
t.test(c7_data$filtered, c2_data$filtered, var.equal = T)
wilcox.test(c7_data_new$filtered, c2_data$filtered)
boxplot(c7_data_new$filtered, c2_data$filtered)

# Plotting Filtered Data
summary2 = describeBy(newdata$filtered, newdata$c.state, mat = T)
plot_gg(summary2, "Power Consumption Difference of C2 and C7 (Filtered Data)", 23,26)
