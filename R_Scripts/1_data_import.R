#Data Import
getwd()
library(here)
library(tidyverse)
library(readxl)
library(janitor)
#List files
files.list<-list.files(here("Data"))
#Add the working directory using here() and "data" to each file name. 
files.list<-map(files.list, function(x) paste(here(), "data", x, sep="/"))
#check 
files.list
#Use map to loop over each file and read it in 
enrolment<-map(files.list, read_excel) 
#Check names
enrolment %>% 
map(., names)
#One problem pops up; one file uses lower case. 
#Solution is to use janitor::clean_names to convert all variable names to title case
enrolment %>% 
map(., clean_names, case="title") %>% 
  #bind_rows and store
  bind_rows()->enrolment
#After visual inspection there are lots of cases where the data stores <10
#Reasonable to replace these values with 5
enrolment %>% 
  #Using across to do the same function across several columns, in this case columngs 5:10
  #str_replace_all is handy to replace <10 with 5
mutate(across(.cols=5:10, function(x) str_replace_all(x, '<10', '5'))) ->enrolment
#The number columns are still character columns
enrolment %>% 
  #Repeat across to convert to as.numeric
  mutate(across(.cols=5:10, as.numeric))->enrolment
#ERror pops up here that some character values cannot be converted
#After visual inspection there are some values of SP
#No data documentation as to what that is, but it seems like these values were stored mostly in the pre-calculated total columns
#Perhaps we can just recalculate our own totals
enrolment %>% 
  #Calculate own totals from constitutent elements
  mutate(total=sum(`Elementary Male Enrolment`+`Elementary Female Enrolment`+`Secondary Male Enrolment`+`Secondary Female Enrolment`, na.rm=T))->enrolment
#Write out the combined file
write.csv(enrolment, file=here("data/ontario_private_school_enrolment_total.csv"))
