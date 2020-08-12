# always make sure you're in the correct working directory for loading/saving files!
setwd("./")

# previous workshop: basic R
# today's workshop: tidyverse, a collection of packages
# see cheat sheet here: https://rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf


# At the top of your code, always load required packages, install if necessary

#install.packages("tidyverse")
library(tidyverse)

# within "tidyverse", the data table used is called a "tibble"


# load data using read_delim() function, which crates a tibble.
mask_use <- read_delim(file="https://github.com/nytimes/covid-19-data/raw/bde13b021e99c6b4a63fb66a6144e889cc635e31/mask-use/mask-use-by-county.csv", delim=",")
mask_use


# oftentimes it's useful to perform various sanity checks on your data to make sure they look like you expect
sum(mask_use[1,2:6])
sum(mask_use[2,2:6])
sum(mask_use[3,2:6])

# Data tables: wide format vs long format
# long format is tidy, where every column is a variable, every row is an observation

# mask data looks like it's in WIDE format, let's convert it to LONG format using pivot_longer(), see cheat sheet!
mask_use_long <- pivot_longer(data = mask_use, 
                              cols = -COUNTYFP, 
                              names_to = "MaskUseResponse", 
                              values_to = "MaskUseProportion")

# stringing functions together: pivot_longer() to convert to long format -> rename() to change column name -> arrange() to sort based on column
# option 1: do each operation on a separate line
mask_use_long <- pivot_longer(data = mask_use, cols = -COUNTYFP, names_to = "MaskUseResponse", values_to = "MaskUseProportion")
mask_use_long2 <- rename(mask_use_long, "fips" = COUNTYFP)
mask_use_long3 <- arrange(mask_use_long2, "fips")

# option 2: do all operations on a single line (not preferred method)
mask_use_long <- pivot_longer(data = arrange(rename(mask_use, "fips" = COUNTYFP), "fips"), cols = -"fips", names_to = "MaskUseResponse", values_to = "MaskUseProportion")

# option 3: the tidyverse way using the %>% pipe operator
mask_use_long <- mask_use %>%
  pivot_longer(cols = -COUNTYFP, names_to = "MaskUseResponse", values_to = "MaskUseProportion") %>%
  rename("fips" = COUNTYFP) %>%
  arrange(fips)

# Let's load in case count data, also from NYT github repository
cases <- read_delim(file="https://github.com/nytimes/covid-19-data/raw/ccc8c7988a089fed287a9005e5335d8716d8db57/us-counties.csv", delim=",") %>%
  arrange(fips)

# too much data! let's look at a particular date, August 3rd, by selecting rows using the filter() function
cases_latest <- cases %>% 
  filter(date == "2020-08-03") %>%
  arrange(fips)

# let's combine mask data with case count data! type '?join' in console to see options
# the different functions depend on how we want to treat missing data... do we have missing data? or "NA"s?
cases_latest %>% filter(is.na(fips)) %>%
  nrow
mask_use_long %>% filter(is.na(fips)) %>%
  nrow

cases_NAs <- cases_latest %>% 
  filter(is.na(fips)) %>%
  arrange()

# NYC is missing FIPS number 36061! let's fix this particular cell using mutate() function, which add new columns or modifies existing ones (as we do here)
cases_latest <- cases_latest %>%
    mutate(fips = if_else(county == "New York City", true = "36061", false = fips))

# Now that NYC FIPS data is entered, let's combine the tables with inner_join():
cases_masks <- inner_join(x=cases_latest, y=mask_use_long, by="fips")


# data under "date" column all the same, not informative, and we don't need FIPS codes
# we can remove columns with the select() function
cases_masks <- cases_masks %>% dplyr::select(-date, -fips)

# simple commands to get an idea of what the data look like!

# Which counties use masks most frequently?
cases_masks %>% filter(MaskUseResponse == "ALWAYS") %>%
  arrange(desc(MaskUseProportion), county) %>%
  head(n=20)

# Which counties use masks least frequently?
cases_masks %>% filter(MaskUseResponse == "NEVER") %>%
  arrange(desc(MaskUseProportion), county) %>%
  head(n=10)

# For the counties with the most cases, how frequently are people ALWAYS wearing masks?
cases_masks %>% filter(MaskUseResponse == "ALWAYS") %>%
  arrange(desc(cases), county) %>%
  head(n=10)

# Summary
# Key tidyverse functions used today:
# - read_delim() to read files in and convert them to a tibble, a special kind of data table
# - pivot_longer()/pivot_wider() to convert data between long and wide format
# - rename() to change the names of particular columns
# - arrange() to sort the tibble according to values in particular columns
# - filter() to select particular rows that meet specific conditions
# - mutate(), with if_else() to modify particular cells in a table!
# - select() to select specific columns to keep
