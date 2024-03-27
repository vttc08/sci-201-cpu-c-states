install.packages('car', dependencies = T)
install.packages('sciplot')
install.packages('emmeans')
install.packages('lattice')
install.packages('psych')
install.packages('tidyverse')
install.packages('effectsize')

library(car)
library(sciplot)
library(emmeans)
library(lattice)
library(effectsize)
library(psych)
library(tidyverse)
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
describeBy(data$mean, data$c.state, mat = T) # overall stats
plot_points <- function(dataset_c7, dataset_c2) {
    plot(dataset_c7, col="red", pch=20, cex=3, xlim=c(0,30),ylim=c(23, 27))
    points(dataset_c2, col="blue", pch=20, cex=3)
}

plot_points(c7_data$mean, c2_data$mean)

# Removing Suspicious Datapoint in C7
c7_data_new <- c7_data[c7_data$mean < 25, ]
check_normality(c7_data_new)
var.test(c7_data_new$mean, c2_data$mean)
plot_points(c7_data_new$mean, c2_data$mean)

# Running Basic t-test
t.test(c7_data$mean, c2_data$mean, var.equal = T)
t.test(c7_data_new$mean, c2_data$mean, var.equal = T)
boxplot(c7_data$mean, c2_data$mean)

# Example Block ANOVA
newdata <- rbind(c2_data, c7_data_new) # join c7_new and c2_data
blockanova = aov(mean ~ as.factor(c.state) + as.factor(hrs), data=newdata)
summary(blockanova)
plot(lsmeans(blockanova,~ as.factor(c.state)), horizontal = F)
plot(lsmeans(blockanova,~ as.factor(hrs)), horizontal = F)

# ANCOVA
ancova = aov(mean ~ as.factor(c.state)*cpu, data=data)
summary(ancova)
regr_c2 = lm(mean ~ cpu, data = c2_data)
regr_c7 = lm(mean ~ cpu, data = c7_data)

plot(c2_data$cpu, c2_data$mean, col="red", ylim=c(23,26), xlim=c(0,0.20), xlab = "CPU Usage", ylab="Watts")
points(c7_data$cpu, c7_data$mean, pch=2, col = "#65b2bc")
abline(regr_c2, col="red")
abline(regr_c7, col="#65b2bc")
legend("topleft", legend=c("C2", "C7"), pch=c(1,2), lty=c(1,2), col=c("red","#65b2bc"), bty="n")

# Using Filtered Data
check_normality(c7_data_new$filtered)
check_normality(c2_data$filtered)
leveneTest(filtered ~ c.state, data = data)
check_shape(c7_data$filtered, c2_data$filtered)

# Visualize each points
describeBy(data$filtered, data$c.state, mat = T) # overall stats
plot_points(c7_data$filtered, c2_data$filtered)

# Running Basic t-test
t.test(c7_data$filtered, c2_data$filtered, var.equal = T)
boxplot(c7_data_new$filtered, c2_data$filtered)
