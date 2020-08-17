
# This is the second session covering tidyverse commands.

# From last time, we looked at this cheat sheet: https://rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf 

# Let's quickly reload the two data sets we used last time and clean them up. 
# load mask data
mask_use_wide <- read_delim(file="mask-use-by-county.csv", delim=",")
mask_use_long <- mask_use_wide %>%
  pivot_longer(cols = -COUNTYFP, names_to = "MaskUseResponse", values_to = "MaskUseProportion") %>%
  rename("fips" = COUNTYFP) %>%
  arrange(fips)
# load case count data, filter based on most recent date
cases <- read_delim(file="https://github.com/nytimes/covid-19-data/raw/master/us-counties.csv", delim=",")
cases_latest <- cases %>% filter(date == "2020-08-03") %>%
  dplyr::select(-date) %>%
  arrange(fips)

# These data from last time are all at the county level, which vary considerably by size.

# Let's load in some additional data on population size by county, obtained from www.census.gov.
pop_sizes <- read_delim(file="co-est2019-annres.csv.xz", delim=",")

# Always double check file to make sure it looks alright!
head(pop_sizes) 
nrow(pop_sizes) 
sum(!is.na(pop_sizes$'2019')) # how many counties have size estimates for 2019? it's even closer to the 3142 we expect!
tail(pop_sizes)

# These data are a little messy and need to be cleaned up! Let's do this with tidyverse commands.

# Let's remove rows that we don't need using the slice() function
pop_sizes <- pop_sizes %>% dplyr::slice(2:3143) # this also gets rid of the notes at the bottom

# The 'Geographic Area' column has two pieces of info in it: county and state. Let's split this into 2 separate columnds using the separate() function. 
pop_sizes <- pop_sizes %>% separate(col = 'Geographic Area',
                                    into = c("County", "State"),
                                    sep = ", ")

# Let's get rid of extra characters in the new 'County' column.  We can use the mutate() function along with another function called str_remove(). 
pop_sizes <- pop_sizes %>% 
  mutate(County = str_remove(string = County,pattern = ".")) %>%
  mutate(County = str_remove(string = County,pattern = " County"))

# Let's use only the most recent estimate of county population size using the select() function.
pop_sizes <- pop_sizes %>%
  dplyr::select(County, State, "2019")

# OPTIONAL: we can combine all of our cleaning/filtering commands into one chain of commands to send to others: 
pop_sizes <- read_delim(file="co-est2019-annres.csv", delim=",") %>% 
  dplyr::slice(2:3143) %>%
  separate(col = 'Geographic Area', into = c("County", "State"), sep = ", ") %>%
  mutate(County = str_remove(string = County,pattern = ".")) %>%
  mutate(County = str_remove(string = County,pattern = " County")) %>%
  dplyr::select(County, State, "2019")

# The summary() function gives us a quick peek at these data. NOTE: summary() is very different from the summarize() function that we'll cover below. 
summary(pop_sizes)



# Combining our previous data on case counts with county size
cases_popsize <- inner_join(x=cases_latest, y=pop_sizes, 
                                  by=c("county"="County", "state"="State"))

# Combining these data with mask usage data
cases_popsize_masked <- inner_join(x=cases_popsize, 
                            y=dplyr::select(mask_use_wide, c(COUNTYFP, ALWAYS)),
                            by=c("fips" = "COUNTYFP"))

# Renaming a coupe of columns to something more informative: 
cases_popsize_masked <- cases_popsize_masked %>%
  rename("pop_size" = "2019", "AlwaysMasked" = ALWAYS)

##
# Visualizing data and finding outliers
##

# What is the relationship between the fraction of positive cases and the population size of the county? Do counties with large populations have a higher proportion of case counts? 
# We will make our first plot the the "base" R function plot()
cases_popsize_masked <- cases_popsize_masked %>%
  mutate(FracPos = cases/pop_size)

plot(x=cases_popsize_masked$pop_size,
     y=cases_popsize_masked$FracPos,
     log="x",
     ylab="Fraction of cases",
     xlab="pop size")
# DON'T RUN CORRELATION ANALYSES WITH HETEROSCEDASTICITY


# What are those outliers with high rates of positive cases? What counties/states are these?
cases_popsize_masked %>%
  filter(FracPos > 0.08) %>%
  arrange(desc(FracPos))


# Let's add another column for death rate, and visualize the relationship between the fraction of positive cases and the death rate:
cases_popsize_masked <- cases_popsize_masked %>%
  mutate(FracDeaths = deaths/cases)

plot(x=cases_popsize_masked$FracPos,
     y=cases_popsize_masked$FracDeaths,
     log="",
     xlab="FracCases",
     ylab="FracDeaths")

# What are these counties that have been severely impacted by deaths rates? Is this just noise from small population sizes? 
cases_popsize_masked %>%
  filter(FracDeaths > 0.15) %>%
  arrange(desc(FracDeaths))


##
# group_by() and summarize() functions are extremely easy and powerful
##

# The use of the group_by() and summarize() functions allows us to quickly get extremely informative information from our data. 

# One way to get the mean values for the different mask use frequency categories:
mean(mask_use_wide$NEVER)
mean(mask_use_wide$RARELY)
mean(mask_use_wide$SOMETIMES)
mean(mask_use_wide$FREQUENTLY)
mean(mask_use_wide$ALWAYS)

summary(mask_use_wide)

# Alternatively, we can convert our data into long format (which we did above) and use the group_by() and summarize() functions to quickly do useful analyses:
mask_use_long %>% 
  group_by(MaskUseResponse) %>% 
  summarize(mean(MaskUseProportion))

# Looking at the cheat sheet, you will see summarize can take a variety of functions.


# Instead of analyzing data by county, we can easily switch to a state-level analysis using group_by() and sumamrize()
cases_popsize_masked %>%
  group_by(state) %>%
  summarize(MeanMasked = mean(AlwaysMasked)) %>%
  arrange(desc(MeanMasked))


# Calculating the mean value for a state using counties of very different sizes is bad; mean() treats each county equally, but in reality they vary tremendously in size
# Let's compute a custom weighted mean
cases_popsize_masked %>%
  group_by(state) %>%
  summarize(WeightedMeanMasked = sum(AlwaysMasked*pop_size)/sum(pop_size)) %>%
  arrange(desc(WeightedMeanMasked))


# Did this weighting by county size actually make a difference? Let's store these analyses as 'x' and 'y' and compare them:
x <- cases_popsize_masked %>%
  group_by(state) %>%
  summarize(MeanMasked = mean(AlwaysMasked)) %>%
  arrange(state)

y <- cases_popsize_masked %>%
  group_by(state) %>%
  summarize(WeightedMeanMasked = sum(AlwaysMasked*pop_size)/sum(pop_size)) %>%
  arrange(state)

hist(x$MeanMasked - y$WeightedMeanMasked)

# The histogram suggests smaller counties have, on average, lower values for "AlwaysMasked"? Ploe the variables to verify:
plot(x=cases_popsize_masked$pop_size,
     y=cases_popsize_masked$AlwaysMasked,
     log="x",
     xlab="pop size",
     ylab="AlwaysMasked")

# Summary:
## New tidyverse functions used today:
- slice() to select specific rows by index number
- separate() to take a column with multiple pieces of information and split it into multiple columns
- mutate() with str_remove to get rid of characters or words we don't want, there are many similar functions in the stringr package, which has its own cheat sheet
- select() to
- group_by() to categorize our data by the values in a particular column (here, by state)
- summarize() to calculate simple but very informative statistics, such as mean and variance

