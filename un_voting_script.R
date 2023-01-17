library(dplyr)
library(ggplot2)
library(unvotes)

head(un_votes)

head(un_roll_calls)

head(un_roll_call_issues)
count(un_roll_call_issues, issue, sort=TRUE)

# Join votes and roll call datasets
joined_votes <- un_votes %>%
  inner_join(un_roll_calls, by = "rcid")
joined_votes

# Recode 'vote' column as no = 0, yes = 1, abstain = 2
joined_votes <- joined_votes %>%
  mutate(vote = recode(vote,
                       no = 0,
                       yes = 1,
                       abstain = 2))
joined_votes

# Calculate total and fraction of 'yes' votes
joined_votes %>%
  summarize(total = n(),
            percent_yes = mean(vote == 1))

library(lubridate)

# Summarize by year
joined_votes %>%
  group_by(year = year(date)) %>%
  summarize(total = n(),
            percent_yes = mean(vote == 1))

# Summarize by country
by_country2 <- joined_votes %>%
  group_by(country) %>%
  summarize(total = n(),
            percent_yes = mean(vote == 1))
by_country2

# Sort in ascending order of percent_yes
by_country2 %>% arrange(percent_yes)

# Sort in descending order
by_country2 %>% arrange(desc(percent_yes))

# Filter out countries with fewer than 100 votes
by_country2 <- by_country2 %>%
  arrange(percent_yes) %>%
  filter(total > 99)

# Check
by_country2 %>% arrange(total)

# Summarize by year
by_year2 <- joined_votes %>%
  group_by(year = year(date)) %>%
  summarize(total = n(),
            percent_yes = mean(vote == 1))

# Create line plot
ggplot(by_year2, aes(x=year, y=percent_yes)) +
  geom_line() + 
  labs(x="Year", y="Percentage of Yes Votes",
       title="Overall Voting by Year in UNGA") +
  scale_x_continuous(breaks = seq(1940, 2020, by = 5)) +
  scale_y_continuous(breaks = seq(0, 1, by = 0.05)) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

# Create scatter plot with smoothing curve
ggplot(by_year2, aes(year, percent_yes)) +
  geom_point() + geom_smooth() + 
  labs(x="Year", y="Percentage of Yes Votes",
       title="Overall Voting by Year in UNGA") +
  scale_x_continuous(breaks = seq(1940, 2020, by = 5)) +
  scale_y_continuous(breaks = seq(0, 1, by = 0.05)) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

# Group by year and country
by_year_country2 <- joined_votes %>%
  group_by(year = year(date), country) %>%
  summarize(total = n(),
            percent_yes = mean(vote == 1))
by_year_country2

# Only UK data
UK_by_year2 <- by_year_country2 %>%
  filter(country == "United Kingdom")
UK_by_year2

# Line plot of percent_yes over time for UK only
ggplot(UK_by_year2, aes(year, percent_yes)) +
  geom_line(aes(group=1), color = "red") + 
  labs(x="Year", y="Percentage of Yes Votes",
       title="United Kingdom - UNGA Votes") +
  scale_x_continuous(breaks = seq(1940, 2020, by = 5)) +
  scale_y_continuous(breaks = seq(0, 1, by = 0.05)) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

# Filter for the UK and France
UK_FR_by_year2 <- by_year_country2 %>%
  filter(country %in% c("United Kingdom", "France"))
# UK_FR_by_year2

# Plot
ggplot(UK_FR_by_year2, aes(year, percent_yes, color=country)) +
  geom_line() +
  labs(x="Year", y="Percentage of Yes Votes", color="Country",
       title="United Kingdom and France - UNGA Votes") +
  scale_color_manual(values = c("goldenrod", "red")) +
  scale_x_continuous(breaks = seq(1940, 2020, by = 5)) +
  scale_y_continuous(breaks = seq(0, 1, by = 0.05)) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

# Comparing four countries (US, UK, France, India)
countries2 <- c("United States", "United Kingdom",
                "France", "India")
filtered_4_countries2 <- by_year_country2 %>%
  filter(country %in% countries2)
filtered_4_countries2

# Line plot of % yes in four countries
ggplot(filtered_4_countries2, aes(year, percent_yes, color=country)) +
  geom_line() +
  labs(x="Year", y="Percentage of Yes Votes", color="Country",
       title="Multinational Comparison - UNGA Votes") +
  scale_color_manual(values = c("goldenrod", "chartreuse3", "red", "dodgerblue4")) +
  scale_x_continuous(breaks = seq(1940, 2020, by = 5)) +
  scale_y_continuous(breaks = seq(0, 1, by = 0.05)) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

# Comparing 6 countries (US, UK, France, Japan, Brazil, India)
countries3 <- c("United States", "United Kingdom",
                "France", "Japan", "Brazil", "India")
filtered_6_countries2 <- by_year_country2 %>%
  filter(country %in% countries3)
filtered_6_countries2

# Line plot of % yes over time faceted by country
ggplot(filtered_6_countries2, aes(year, percent_yes, color=country)) +
  geom_line() +
  labs(x="Year", y="Percentage of Yes Votes") +
  scale_color_manual(values = c("seagreen2", "goldenrod", "chartreuse3", "orchid2", "red", "dodgerblue4")) +
  scale_x_continuous(breaks = seq(1940, 2020, by = 10)) +
  # scale_y_continuous(breaks = seq(0, 1, by = 0.5)) +
  theme(legend.position = "none") +
  facet_wrap(~ country)
# + facet_wrap(~ country, scales = "free_y") # for free y-axis

# Calculate percentage of yes votes from the US by year
US_by_year2 <- by_year_country2 %>%
  filter(country == "United States")
US_by_year2

# Perform a linear regression of percent_yes by year
US_fit2 <- lm(percent_yes ~ year, US_by_year2)
US_fit2

# Perform summary() on the US_fit2 object
summary(US_fit2)

library(broom)

# Fit model for the UK
UK_by_year2 <- by_year_country2 %>% filter(country=="United Kingdom")
# UK_by_year
UK_fit2 <- lm(percent_yes ~ year, UK_by_year2)
# UK_fit

# Create US_tidied and UK_tidied
US_tidied2 <- tidy(US_fit2)
# US_tidied2
UK_tidied2 <- tidy(UK_fit2)
# UK_tidied2

# Combine the two tidied models
bind_rows(US_tidied2, UK_tidied2)

library(tidyr)

# Nest all columns besides country
nested2 <- by_year_country2 %>% nest(-country)
nested2
nested2$data[[1]] # Afghanistan's voting history (percent_yes)

# Unnest to return to original form
by_year_country2 %>%
  nest(-country) %>% unnest(data)

library(purrr)

# Perform a linear regression on each item in the data column, add another
# mutate that applies tidy() to each model, unnest the tidied column
country_coefficients2 <- by_year_country2 %>%
  nest(-country) %>%
  mutate(model = map(data, ~ lm(percent_yes ~ year, data = .)),
         tidied = map(model, tidy)) %>%
  unnest(tidied)
country_coefficients2

# Filter for only slope terms (year, i.e. not intercept), 
# perform p-value correction, filter for significant values
filtered_countries2 <- country_coefficients2 %>% 
  filter(term=="year") %>%
  mutate(p.adjusted = p.adjust(p.value)) %>%
  filter(p.adjusted < 0.05)
filtered_countries2

# Sort for the countries increasing most quickly
filtered_countries2 %>% arrange(estimate)

# Sort for the countries decreasing most quickly
filtered_countries2 %>% arrange(desc(estimate))

# Peek at the issues each vote related to
head(un_roll_call_issues)

# Join together joined_votes, un_roll_call_issues based on the 'rcid' column
votes_combined <- joined_votes %>%
  inner_join(un_roll_call_issues, by = "rcid")
votes_combined

# Clean up votes_combined: create variable 'year'; drop variables 'importantvote', 
# 'country_code', 'amend', 'para', 'short', 'descr', 'date'; 
# rename variable 'short_name' as 'issue_abrv'; recode 'Palestinian conflict'
# as 'Israeli-Palestinian conflict'
clean_votes <- votes_combined %>% 
  mutate(year = session + 1945) %>%
  select(c(rcid, session, year, country, vote, unres, 
           issue_abrv = short_name, issue)) %>%
  mutate(issue = recode(issue, "Palestinian conflict" = "Israeli-Palestinian conflict"))
clean_votes

# Filter for votes related to nuclear weapons and nuclear material (nu)
clean_votes %>% filter(issue_abrv=="nu")

# Filter, then summarize by year for US votes on nuclear weapons/material ('nu')
US_nu_by_year2 <- clean_votes %>% 
  filter(country == "United States", issue_abrv == "nu") %>%
  group_by(year) %>%
  summarize(percent_yes = mean(vote == 1))
US_nu_by_year2

# Graph the percent of US 'yes' votes over time
ggplot(US_nu_by_year2, aes(year, percent_yes)) +
  geom_line(aes(group=1), color = "dodgerblue4") + 
  labs(x="Year", y="Percentage of Yes Votes",
       title="United States - Votes on Nuclear Weapons/Material") +
  scale_x_continuous(breaks = seq(1940, 2020, by = 5)) +
  scale_y_continuous(breaks = seq(0, 1, by = 0.05)) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

by_country_year_issue <- clean_votes %>%
  group_by(country, year, issue) %>%
  summarize(total = n(), percent_yes = mean(vote == 1)) %>%
  ungroup()
by_country_year_issue

# Filter by_country_year_topic for just the US
US_by_country_year_issue <- by_country_year_issue %>%
  filter(country == "United States")
US_by_country_year_issue

# Plot % yes over time for the US, faceting by topic
ggplot(US_by_country_year_issue, aes(year, percent_yes)) + 
  geom_line(aes(group=1), color = "dodgerblue4") + 
  labs(x="Year", y="Percentage of Yes Votes",
       title="United States - UNGA Votes by Issue") +
  scale_x_continuous(breaks = seq(1940, 2020, by = 5)) +
  scale_y_continuous(breaks = seq(0, 1, by = 0.05)) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
  facet_wrap(~ issue)

# Filter by_country_year_topic for just the US and the UK
US_UK_by_country_year_issue <- by_country_year_issue %>%
  filter(country %in% c("United Kingdom", "United States"))
US_UK_by_country_year_issue2

# Plot % yes over time for the US and UK, faceting by topic
ggplot(US_UK_by_country_year_issue, aes(year, percent_yes, color=country)) + 
  geom_line() + 
  labs(x="Year", y="Percentage of Yes Votes", color="Country",
       title="U.S. and U.K. - UNGA Votes by Issue") +
  scale_color_manual(values = c("red", "dodgerblue4")) +
  scale_x_continuous(breaks = seq(1940, 2020, by = 5)) +
  scale_y_continuous(breaks = seq(0, 1, by = 0.05)) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
  facet_wrap(~ issue)

# Fit model on the by_country_year_issue dataset
country_issue_coefficients <- by_country_year_issue %>%
  nest(-country, -issue) %>%
  mutate(model = map(data, ~ lm(percent_yes ~ year, data = .)),
         tidied = map(model, tidy)) %>%
  unnest(tidied)
country_issue_coefficients

# Filter to only include slope terms, adjust p-values, filter for significant values
country_issue_filtered <- country_issue_coefficients %>%
  filter(term=="year") %>%
  mutate(p.adjusted = p.adjust(p.value)) %>%
  filter(p.adjusted < 0.05)
country_issue_filtered

# Identify country with the steepest downward trend in percent_yes
country_issue_filtered %>% arrange(estimate) # Vanuatu, re: Isr-Pal conflict

# Filter data for only Vanuatu's votes
vanuatu_by_country_year_issue <- by_country_year_issue %>% filter(country == "Vanuatu")
vanuatu_by_country_year_issue

# Plot of percentage 'yes' over time, faceted by topic
ggplot(vanuatu_by_country_year_issue, aes(year, percent_yes)) + 
  geom_line(aes(group=1), color = "seagreen4") + 
  labs(x="Year", y="Percentage of Yes Votes",
       title="Vanuatu - UNGA Votes by Issue") +
  scale_x_continuous(breaks = seq(1940, 2020, by = 5)) +
  scale_y_continuous(breaks = seq(0, 1, by = 0.05)) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
  facet_wrap(~ issue)
