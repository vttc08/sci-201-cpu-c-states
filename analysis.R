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
check_assumption <- function(dataset) {
    shapiro = shapiro.test(dataset$mean)
    qqPlot(dataset$mean, main='Title')
    text(x = quantile(c7_data$mean, probs = 0.8), y = quantile(c7_data$mean, probs = 0.8), labels = "Text to add", pos = 4)
    return (shapiro)
}
check_assumption(c7_data)
check_assumption(c2_data)
shapiro.test(c7_data$mean)
shapiro.test(c2_data$mean)
leveneTest(mean ~ c.state, data = data)
qqPlot(c7_data$mean)
qqPlot(c2_data$mean)

# Visualize each points

# Run a Simple ANOVA with TukeyHSD
onewayanova = aov(mean ~ as.factor(c.state), data=data)
summary(onewayanova)
plot(lsmeans(onewayanova, ~ as.factor(c.state), data=data), horizontal=F)
plot(TukeyHSD(onewayanova))

# Part 3 Block ANOVA
blockanova = aov(Value ~ as.factor(C.State) + as.factor(Hrs), data=data)
summary(blockanova)
# both wind and treatment are affecting our analysis

plot(lsmeans(blockanova,~ as.factor(C.State)), horizontal = F)
plot(lsmeans(blockanova,~ as.factor(Hrs)), horizontal = F)
# there seem to be a trend downward from row 1 to row 10

describeBy(data$mean, data$c.state, mat = T)
c2 = data$filtered[data$c.state == "C2"]
c7 = data$mean[data$c.state == "C7"]
hist(c7)
wilcox.test(c2, c7)
shapiro.test(c2)
shapiro.test(c7)  
ks.test(c2, "pnorm", mean=mean(c7), sd=sd(c7))

qqnorm(c7)
qqline(c7)

c7_data <- data[data$c.state == "C7", ]
c7_data[order(c7_data$filtered, decreasing = T) , ]
c2_data <- data[data$c.state == "C2", ]
c7_new = c7_data[c7_data$c.state == "C7" & c7_data$mean<25, ]
hist(c7_new)
shapiro.test(c7_new)
qqnorm(c2)
qqline(c7_new)

ancova = aov(mean ~ as.factor(c.state)*cpu, data=data)
summary(ancova)

regr_c2 = lm(mean ~ cpu, data = c2_data)
regr_c7 = lm(mean ~ cpu, data = c7_new)

plot(c2_data$cpu, c2_data$mean, col="red", ylim=c(23,26), xlim=c(0,0.20), xlab = "CPU Usage", ylab="Watts")
points(c7_new$cpu, c7_new$mean, pch=2, col = "#65b2bc")
abline(regr_c2, col="red")
abline(regr_c7, col="#65b2bc")
legend("topleft", legend=c("C2", "C7"), pch=c(1,2), lty=c(1,2), col=c("red","#65b2bc"), bty="n")
