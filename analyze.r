library(ggplot2)
library(scales)
library(ggthemes)

# Initial setup

data <- read.csv("days.csv", header = TRUE)
data$Date <- as.Date(data$Date) - 1 #looks like a 1 day adjustment is necessary - confirm
data$Day <- weekdays(data$Date)
data$Day <- factor(data$Day, c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
data$Weekend <- (data$Day %in% c("Saturday", "Sunday"))
data$Month <- as.numeric(format(data$Date, "%m"))

# Histogram of steps distribution
g1 <- ggplot(data, aes(x=Steps))
g1 <- g1 + geom_histogram(fill = "#555555", color="#eeeeee", breaks=seq(0, 25000, by=2000))
g1 <- g1 + geom_histogram(data=subset(data, Steps > 10000), fill = "#60C629", color="#eeeeee", breaks=seq(0, 25000, by=2000))
g1 <- g1 + theme_fivethirtyeight(base_size=15)
g1 <- g1 + ggtitle("Distribution of daily steps")
g1 <- g1 + annotate("text", x=18000, y=30, label="26% of days had over 10,000 steps")
g1

# Steps throughout the year by month
monthly <- aggregate(Steps ~ Month, data, mean)
g2 <- ggplot(data=monthly, aes(x=Month, y=Steps)) + geom_line()
g2 <- g2 + scale_x_discrete(labels=c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))
g2 <- g2 + scale_y_continuous(limits=c(0,13000))
g2 <- g2 + geom_rect(alpha=0.01, aes(xmin=4.8, xmax=6.2, ymin=0, ymax=13000))
g2 <- g2 + theme_fivethirtyeight(base_size=15)
g2 <- g2 + ggtitle("Average daily steps by month")
g2 <- g2 + annotate("text", x=2.5, y=3000, label = "School")
g2 <- g2 + annotate("text", x=5.5, y=3000, label = "Vacation")
g2 <- g2 + annotate("text", x=9, y=3000, label = "Work")
g2

weekends <- subset(data, Weekend)
plot(weekends$Date, weekends$Steps)

# Segment the year

graduation <- as.Date("2014-05-01")
workstart <- as.Date("2014-07-07")

school <- subset(data, Date < graduation)
vacation <- subset(data, Date > graduation & Date < workstart)
work <- subset(data, Date > workstart)

# Shapiro test confirms normality necessary for T-test
shapiro.test(school$Steps)
shapiro.test(work$Steps)

# Vacation was clearly more active. school and work more ambiguous
boxplot(school$Steps, work$Steps, notch=TRUE)

# school vs work T test returns p-value .22, no difference
t.test(school$Steps, work$Steps)

# The work week is significantly less active than the school week
# But the work weekend is more active!
school_week <- subset(school, Weekend == FALSE)
work_week <- subset(work, Weekend == FALSE)
t.test(school_week$Steps, work_week$Steps)
school_weekend <- subset(school, Weekend)
work_weekend <- subset(work, Weekend)
t.test(school_weekend$Steps, work_weekend$Steps)

# Boxplot showing weekdays/weekends for school and work
mar.default <- c(5, 4, 4, 2) + 0.1
par(mar=mar.default + c(-2, 4, -2, 0))
par(bg=rgb(240, 240, 240, max=255))
boxplot(work_weekend$Steps, work_week$Steps, school_weekend$Steps, school_week$Steps, las=1, family="Helvetica", outline=FALSE, notch=TRUE, horizontal=TRUE, names=c("Work weekends", "Work weekdays", "School weekends", "School weekdays"), main="Weekdays vs. Weekends")

# Next up: some hour-based analysis...

# Initial setup
hourly <- read.csv("hours.csv", header = TRUE)
hourly$Date <- as.Date(hourly$Date) #looks like a 1 day adjustment is necessary - confirm
hourly$Day <- weekdays(hourly$Date)
hourly$Day <- factor(hourly$Day, c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
hourly$Weekend <- (hourly$Day %in% c("Saturday", "Sunday"))
hourly$Hour <- factor(hourly$Hour, levels=c(6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 0, 1, 2, 3, 4, 5))

graduation <- as.Date("2014-05-01")
workstart <- as.Date("2014-07-07")

school_hourly <- subset(hourly, Date < graduation)
vacation_hourly <- subset(hourly, Date > graduation & Date < workstart)
work_hourly <- subset(hourly, Date > workstart)

school_week_hourly <- subset(school_hourly, Weekend == FALSE)
work_week_hourly <- subset(work_hourly, Weekend == FALSE)
school_weekend_hourly <- subset(school_hourly, Weekend)
work_weekend_hourly <- subset(work_hourly, Weekend)

work_rhythm <- aggregate(Steps ~ Hour, work_week_hourly, mean)
school_rhythm <- aggregate(Steps ~ Hour, school_week_hourly, mean)
work_weekend_rhythm <- aggregate(Steps ~ Hour, work_weekend_hourly, mean)
school_weekend_rhythm <- aggregate(Steps ~ Hour, school_weekend_hourly, mean)

g3 <- ggplot(data=school_rhythm, aes(x=Hour, y=Steps)) + geom_area(aes(group=1, fill="School"), color="#333333",alpha=0.3)
g3 <- g3 + geom_area(aes(group=1, fill="Work"), data = work_rhythm, color="#333333", alpha=0.3)
g3 <- g3 + ggtitle("Daily rhythms")
g3 <- g3 + xlab("\nHour of day") + ylab("Steps/hour\n")
g3 <- g3 + theme_fivethirtyeight(base_size=15) + theme(axis.title=element_text()) + theme(axis.title.y=element_text(angle = 90))
g3 <- g3 + scale_fill_manual("", breaks=c("School", "Work"), values=c("red", "#6ec7ff")) + theme(legend.title=element_blank())
g3

