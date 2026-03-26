#Jeremy Wu
#Final Project Delivery
#03/23/2026

library(dplyr)
library(tidyverse)
library(ggplot2)

healthcare <- read_csv("healthcare.csv")

#Data Cleaning 
nrow(healthcare)
healthcare$Name <- str_to_lower(tolower(healthcare$Name))
healthcare$Name <- gsub("^(mrs\\.|ms\\.|mr\\.|dr\\.)\\s+", "", healthcare$Name, ignore.case = TRUE)
healthcare$Name <- trimws(healthcare$Name)
healthcare$`Billing Amount` <- round(healthcare$`Billing Amount`, 0)

healthcare <- healthcare %>%
  rename(blood_type = 'Blood Type',
         medical_condition = 'Medical Condition',
         admission_date = `Date of Admission`,
         insurance = `Insurance Provider`,
         billing_amount = `Billing Amount`,
         room_number = `Room Number`,
         admission_type = `Admission Type`,
         discharge_date = `Discharge Date`,
         test_results = `Test Results`)

healthcare$Hospital <- gsub("-", "", healthcare$Hospital)
healthcare$Hospital <- gsub(",", "", healthcare$Hospital)
healthcare$Hospital <- gsub("\\s*and\\s*$", "", healthcare$Hospital, ignore.case = TRUE)
healthcare$Hospital <- gsub("^\\s*and\\s*", "", healthcare$Hospital, ignore.case = TRUE)
healthcare$Hospital <- trimws(healthcare$Hospital)

#1 linear regression model for length of stay and insurance provider
unique(healthcare$insurance)
healthcare <- healthcare %>%
  mutate(length_of_stay = as.numeric(discharge_date - admission_date))

insurance <- lm(length_of_stay ~ insurance, data = healthcare)
summary(insurance)


#2 multinomial logistic regression on how gender, medical condition, blood type, and age potentially influences the test result
library(nnet)
healthcare$test_results <- relevel(factor(healthcare$test_results), ref = "Normal")
multi_model <- multinom(test_results ~ Gender + medical_condition + blood_type + Age, data = healthcare)
summary(multi_model)

#show p values
z <- summary(multi_model)$coefficients / summary(multi_model)$standard.errors
p_values <- (1 - pnorm(abs(z), 0, 1)) * 2
print(p_values)

#3 linear regression line - scatter plot for length of stay and billing amount
last_model <- lm(billing_amount ~ length_of_stay, data = healthcare)
summary(last_model)

ggplot(healthcare, aes(x = length_of_stay, y = billing_amount))+
  geom_point(alpha = 0.4, color = "#2c3e50", size = 1.5)+
  geom_smooth(method = "lm", color = "green", se = TRUE, linewidth = 1)

#4 ANOVA testing - boxplot representing how admission type correlates to length of stay 
#H₀: Mean length of stay is the same across all 3 admission types
#H₁: At least one admission type has a significantly different mean length of stay

admission_model <- aov(length_of_stay ~ admission_type, data = healthcare)
summary(admission_model)

ggplot(healthcare, aes(x = admission_type, y = length_of_stay, fill = admission_type))+
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.2)+
  labs(
    title = "Does Admission Type Affect Length of Stay?",
    subtitle = "ANOVA Test",
    x = "Admission Type",
    Y = "Length of Stay (days)")+
  theme_minimal(base_size = 13)+
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "none"
  )

