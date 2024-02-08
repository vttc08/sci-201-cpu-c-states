install.packages('car', dependencies = T)
install.packages('sciplot')
install.packages('emmeans')
install.packages('lattice')

library(car)
library(sciplot)
library(emmeans)
library(lattice)
# Installing required packages

# Preparation
setwd('~/Projects/sci-201-cpu-c-states')
data = read.csv('influx-test.csv')

# Run a Simple ANOVA with TukeyHSD
onewayanova = aov(Value ~ as.factor(C.State), data=data)
summary(onewayanova)
plot(lsmeans(onewayanova, ~ as.factor(C.State), data=data), horizontal=F)
plot(TukeyHSD(onewayanova))

# Part 3 Block ANOVA
blockanova = aov(Value ~ as.factor(C.State) + as.factor(Hrs), data=data)
summary(blockanova)
# both wind and treatment are affecting our analysis

plot(lsmeans(blockanova,~ as.factor(C.State)), horizontal = F)
plot(lsmeans(blockanova,~ as.factor(Hrs)), horizontal = F)
# there seem to be a trend downward from row 1 to row 10


