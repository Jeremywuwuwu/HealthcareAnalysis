#Jeremy Wu 
#03/02/2025
#Final Project - Milestone 2

library(dplyr)
library(tidyverse)

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
         test_results = `Test Results`
         )

#Clean hospital column
healthcare$Hospital <- gsub("-", "", healthcare$Hospital)
healthcare$Hospital <- gsub(",", "", healthcare$Hospital)
healthcare$Hospital <- gsub("\\s*and\\s*$", "", healthcare$Hospital, ignore.case = TRUE)
healthcare$Hospital <- gsub("^\\s*and\\s*", "", healthcare$Hospital, ignore.case = TRUE)
healthcare$Hospital <- trimws(healthcare$Hospital)

#Inferential Statistics 

#1 One sample t-test for age
summary(healthcare$Age)
t.test(healthcare$Age, mu = 51.5)

#1 One sample t-test for billing amount 
summary(healthcare$billing_amount)
t.test(healthcare$billing_amount, mu = 25539)

#2 ANOVA test whether medication type affects billing amount 
#H₀: Mean billing amount is the same across all 5 medication types
#H₁: At least one medication type has a significantly different mean billing amount
#Confidence interval is set at 95% here, the standard interval due to the circumstances (not life and death situation so confidence interval doesn't need to be 99%, but can't be too low or results are not meaningful)
#significance level = 0.05 

medication <- aov(billing_amount ~ Medication, data = healthcare)
summary(medication)

#3 Linear Regression Model for age and billing amount 
# H₀: Age does not significantly predict billing amount (β = 0)
# H₁: Age significantly predicts billing amount (β ≠ 0)
# Significance level: α = 0.05

lm_result <- lm(billing_amount ~ Age, data = healthcare)
summary(lm_result) 

#4 two sample t test for test results vs billing amount
result_filtered <- healthcare[healthcare$test_results %in% c("Normal", "Abnormal"), ]
normal <- result_filtered$billing_amount[result_filtered$test_results == "Normal"]
abnormal <- result_filtered$billing_amount[result_filtered$test_results == "Abnormal"]

t.test(abnormal, normal, alternative = "two.sided")
