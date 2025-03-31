#Install packages
devtools::install_github("NightingaleHealth/ggforestplot")
library(ggforestplot)
install.packages("tidyverse")
library(tidyverse)
install.packages("ggforce")
library(ggforce)

setwd("C:/Users/yungfang/Desktop/Graduate/UNC_MPH_EPI/EPID 992")

#Import dataset
Stra <- read_excel("C:/Users/yungfang/Desktop/Graduate/UNC_MPH_EPI/EPID 992/Book2.xlsx", sheet="Stra_ana")
Ma_Y <- read_excel("C:/Users/yungfang/Desktop/Graduate/UNC_MPH_EPI/EPID 992/Book2.xlsx", sheet="Ma_Y")
Ma_N <- read_excel("C:/Users/yungfang/Desktop/Graduate/UNC_MPH_EPI/EPID 992/Book2.xlsx", sheet="Ma_N")

#For changing the sequence of each exposure groups
df = Stra |> mutate( Rural_urban = factor(Level, levels = c("Nonmetropolitan", "Medium and small metro")), 
                        Cov=factor(Group, levels = c("Overall", "Race/ethnicity", "Insurance status", "Insurance type", "Education","Usual place for medical care")))

#Plot
forestplot(df = df, name = Exposures, estimate = estimate, se = SE, psignif = 0.05, 
             colour = Rural_urban, xlab = "Prevalence differences (95% CI)",
             xtickbreaks = c(-0.20,-0.15,-0.10,-0.05,0.0,0.05,0.10,0.15,0.20))+
  ggforce::facet_col(facets = ~Cov, scales = "free_y", space = "free")+
  theme(legend.title = element_blank())


#Sort reasons by frequency
Ma_Y <- Ma_Y |>
  group_by(Group) |>
  mutate(
    Reasons_N = fct_reorder(Reasons, Count, .desc = FALSE)  # Reordering Reasons
  ) |>
  ungroup()  # Ungroup if necessary

# Create the bar chart and assign to a plot object
Ma_Y_F <- ggplot(Ma_Y, aes(y = Reasons_N, x = Count)) + 
  geom_col() + 
  facet_wrap(~Group, ncol = 1) + 
  geom_text(aes(label = paste0(round(Percentage, 1), "%")), 
            position = position_nudge(x = 0.5), hjust = 0) +
  ylab(NULL)+
  scale_x_continuous(breaks = seq(0, 12000, by = 2000))
Ma_Y_F

ggsave(Ma_Y_F, file=paste('Ma_Y.png'), width = 12, height = 6, dpi = 300, units = "in", device='png')


#Sort reasons by frequency
Ma_N <- Ma_N |>
  group_by(Group) |>
  mutate(
    Reasons_N = fct_reorder(Reasons, Count, .desc = FALSE)  # Reordering Reasons
  ) |>
  ungroup()  # Ungroup if necessary

#Sort reasons by frequency (collapsed)
Ma_N_1 <- Ma_N |>
  group_by(Group) |>
  mutate(
    # Collapse the 'Reasons' factor into a new level 'Others'
    collapsed_reason = fct_collapse(Reasons, 
                                    Others = c("Do not have doctor", "Too old", "Too young", 
                                               "Too painful, unpleasant, embarrassing", "Other reason"))
  ) |>
  # Group by both 'Group' and 'collapsed_reason' to calculate the count_new
  group_by(Group, collapsed_reason) |>
  summarise(
    # Calculate the count for each level within the group
    count_new = sum(Count),  # Sum the counts for each level within the group
    .groups = "drop"  # Drop the grouping after summarizing
  ) |>
  # Re-group by 'Group' for percentage calculation
  group_by(Group) |>
  mutate(
    # Calculate the percentage for each level of collapsed_reason within each group
    percentage_new = round((count_new / sum(count_new)) * 100, 2)  # Calculate percentage and round to 2 decimals
  ) |>
  # Reorder collapsed_reason in descending order of count_new (highest at the top)
  mutate(
    collapsed_reason = fct_reorder(collapsed_reason, count_new, .fun = sum, .desc = FALSE)
  ) |>
  # Move "Others" to the bottom explicitly
  mutate(
    collapsed_reason = fct_relevel(collapsed_reason, "Others", after = length(collapsed_reason))
  ) |>
  ungroup()  # Remove grouping after calculation


Ma_N_1$collapsed_reason <-ordered(Ma_N_1$collapsed_reason, levels=c(
  "Others", "Too expensive/no insurance/cost", "Did not need/know needed this test",
  "Have not had any problem", "Doctor did not order/say needed", 
  "Put it off/did not get around to it", "No reason/never thought about it"))


#Bar chart
Ma_N_F<-ggplot(Ma_N_1, aes(y=collapsed_reason, x=count_new))+geom_col() + 
  facet_wrap(~Group, ncol=1)+ 
  geom_text(aes(label = paste0(round(percentage_new, 1), "%")), position = position_nudge(x = 0.5),hjust=0)+
  ylab(NULL)+
  xlab("Count")
Ma_N_F

ggsave(Ma_N_F, file=paste('Ma_N.png'), width = 12, height = 6, dpi = 300, units = "in", device='png')
