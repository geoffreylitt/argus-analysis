# Initial setup

data <- read.csv("days.csv", header = TRUE)
data$Date <- as.Date(data$Date) - 1 #looks like a 1 day adjustment is necessary - confirm
data$Day <- weekdays(data$Date)
data$Day <- factor(data$Day, c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
data$Weekend <- (data$Day %in% c("Saturday", "Sunday"))

# Segment the year

graduation <- as.Date("2014-05-01")
workstart <- as.Date("2014-07-07")

school <- subset(data, Date < graduation)
vacation <- subset(data, Date > graduation & Date < workstart)
work <- subset(data, Date > workstart)

# Some density plots for fun
plot(density(school$Steps))
plot(density(vacation$Steps))
plot(density(work$Steps))

# Shapiro test confirms normality necessary for T-test
shapiro.test(school$Steps)
shapiro.test(work$Steps)

# Vacation was clearly more active. school and work more ambiguous
boxplot(school$Steps, vacation$Steps, work$Steps, notch=TRUE)

# school vs work T test returns p-value .22, no difference
t.test(school$Steps, work$Steps)

# During school and vacation, weekday/weekend made very little difference.
# But during work, larger difference
boxplot(Steps~Weekend, data=school)
boxplot(Steps~Weekend, data=vacation)
boxplot(Steps~Weekend, data=work)
t.test(Steps~Weekend, data=school)
t.test(Steps~Weekend, data=vacation)
t.test(Steps~Weekend, data=work)

# The work week is significantly less active than the school week
school_week <- subset(school, Weekend == FALSE)
work_week <- subset(work, Weekend == FALSE)
boxplot(school_week$Steps, work_week$Steps)
t.test(school_week$Steps, work_week$Steps)

# But the work weekend is more active!
school_weekend <- subset(school, Weekend)
work_weekend <- subset(work, Weekend)
boxplot(school_weekend$Steps, work_weekend$Steps)
t.test(school_weekend$Steps, work_weekend$Steps)

# Basic summary of results thus far:
boxplot(school_week$Steps, school_weekend$Steps, work_week$Steps, work_weekend$Steps, notch=TRUE)

boxplot(Steps ~ Day, data=school)
boxplot(Steps ~ Day, data=work)

# Next up: some hour-based analysis...