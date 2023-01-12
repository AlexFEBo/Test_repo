# Required libraries loading

library(tidyverse)
library(smplot2)
library(cowplot)
library(fs)
library(here)
library(shiny)

# Setting up Here package

here::i_am("Simple_plot_time_series.Rproj")

# Read all datafiles

## Create object with the path to the data
data_path <- paste(here("data", "raw_data"), list.files(here("data", "raw_data")), sep = "/")

## Creates a list of tibble (representing the dataframes to be read)
df_input <- map(data_path, readxl::read_excel)

## Naming the dataframe according to the names of the original files
names(df_input) <- str_replace(list.files(here("data", "raw_data")), pattern = ".xlsx", replacement = "")

## Merge the two dataframes in a single one
merged_df <- bind_rows(df_input, .id = 'condition')


# Tidy the data

## Tidy

merged_df <- pivot_longer(merged_df, 
                          cols = -c(condition, "Time (sec)"),
                          names_to = "Sample",
                          values_to = "Value")
#At this stage all data in the tibbles are <dbl> (numerical with decimal)


# Format the data

df_tidy <- merged_df

### Test "all in one" formula 
#### Replaces space (" ") by underscore ("_")
#### Renames 'Time (sec)' by Time
#### Deletes the rows with NA values
#### Removes the " signs
#### Saves the formatted dataframe

formatted_tidy_df <- tidy_df %>%
  mutate_if(is.character, str_replace_all, " ", "_") %>%
  rename(Time = 'Time (sec)') %>%
  drop_na() %>%
  mutate(across(everything(), ~ map_chr(.x, ~ gsub("\"", "", .x)))) %>%
  write.csv(file.path(here("data", "processed_data"), "formatted_tidy_df.csv"), row.names = FALSE)