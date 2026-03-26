#Jeremy Wu 
#03/02/2025
#Final Project - Milestone 1

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

#Cleaning missing values & NA
colSums(is.na(healthcare))

#Descriptive statistics table
stats <- healthcare %>% 
  select(Age, billing_amount)
summary(stats)

#EDA
unique(healthcare$medical_condition)

emergency_type <- healthcare %>% 
  group_by(admission_type) %>% 
  summarise(avg_bill = mean(billing_amount, na.rm = TRUE), n = n())

#Bargraph for billing amount per admission type
ggplot(emergency_type, aes(x = admission_type, y = avg_bill, fill = admission_type))+
  geom_col()+
  labs(title = "Billing Amount by Type of Admission",
       y = "Average Billing Amount $")+
theme(axis.text.x = element_text(angle = 45, hjust = 1))

#Boxplot Graph illustrating billing amount by medical condition
ggplot(healthcare, aes(x = medical_condition, y = billing_amount, fill = medical_condition))+
  geom_boxplot()+
  labs(title = "Billing Amount by Medical Condition",
       x = "Medical Condition",
       y = "Billing Amount $")+
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#Bar Graph for Gender 
gender <- healthcare %>% 
  group_by(Gender) %>% 
  summarise(count = n())

ggplot(gender, aes(x = Gender, y = count, fill = Gender))+
  geom_col()+
  labs(title = "Number of Patients By Gender")

#Bar graph for total count of test results 
results <- healthcare %>% 
  group_by(test_results) %>% 
  summarise(count = n())

ggplot(results, aes(x = test_results, y = count, fill = test_results))+
  geom_col()+
  coord_flip()+
  labs(title = "Test Results Per Category")+
  theme_minimal()

#Age distribution per medical condition boxplot
ggplot(healthcare, aes(x = medical_condition, y = Age, fill = medical_condition))+
  geom_boxplot()+
  labs(title = "Age distribution per medical condition")+
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#Length of stay density plot
staylength <- healthcare %>%
  mutate(length_of_stay = as.numeric(discharge_date - admission_date))

ggplot(staylength, aes(x = length_of_stay, fill = medical_condition)) +
  geom_density(alpha = 0.6) +
  facet_wrap(~ medical_condition) +
  labs(
    title = "Length of Stay Distribution by Medical Condition",
    x = "Length of Stay (Days)",
    y = "Density"
  ) +
  theme_minimal() +
  theme(legend.position = "none")


