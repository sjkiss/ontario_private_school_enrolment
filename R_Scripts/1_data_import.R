
####Package management
to.install<-c('here', 'tidyverse', 'readxl', 'janitor')
new.packages <- to.install[!(to.install %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(here)
library(tidyverse)
library(readxl)
library(janitor)
#### Private School Data####
#List files
files.list<-list.files(here("data", "private_schools"), pattern="xlsx")
#Add the working directory using here() and "data" to each file name. 
files.list<-map(files.list, function(x) paste(here(), "data", "private_schools", x, sep="/"))
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
names(enrolment)
enrolment %>% 
  #Calculate own totals from constitutent elements elementary male enrolment, elementary female enrolment, secondary male enrolment and secondary female enrolment
rowwise()%>%
  mutate(`Enrolment`=sum(c_across(cols=5:8), na.rm=T))->enrolment

#Create a new variable called Board to not whether a row comes from private schools or public schools
#All these come from private schools
enrolment%>%
  mutate(`Board`="Private")->enrolment
enrolment$Board
#Write out the combined file
write.csv(enrolment, file=here("data/private_schools/ontario_private_school_enrolment_total.csv"))

#### Public School Data
public_school_files<-list.files(here("data/public_schools"), pattern="xlsx")
#Add the working directory using here() and "data" to each file name. 
public_school_files<-map(public_school_files, function(x) paste(here(), "data", "public_schools", x, sep="/"))
#check 
public_school_files

#Use map to loop over each file and read it in 
public_school_enrolment<-map(public_school_files, read_excel) 
#Check names
public_school_enrolment %>% 
  map(., names)
enrolment
#Collapse the list items into a dataframe creating an id variable called id
public_school_enrolment%>%
 bind_rows(., .id="id")%>%
  #Turn that id variable into an Academic Year variable
mutate(`Academic Year`=case_when(
    id==1 ~ "2014-2015",
    id==2 ~ "2015-2016",
    id==3 ~ "2016-2017",
    id==4 ~ "2017-2018",
    id==5 ~ "2018-2019",
    id==6 ~ "2019-2020"
  )
  )->public_school_enrolment
names(public_school_enrolment)


#Convert public enrolment numbers to numbers
public_school_enrolment$Enrolment
#Some values also have <10. 
#Set these to be five
public_school_enrolment %>% 
  #Using across to do the same function across several columns, in this case columngs 5:10
  #str_replace_all is handy to replace <10 with 5
  mutate(Enrolment=str_replace_all(Enrolment, '<10', '5'),
         Enrolment=str_replace_all(Enrolment, ',', '')) ->public_school_enrolment
names(public_school_enrolment)

#Exclude Total Rowsw which were discovered at this stage because of forced coercion to NAs and suspiciously large numbers
public_school_enrolment %>% 
  filter(!is.na(`School Number`))->public_school_enrolment

public_school_enrolment %>% 
  filter(., as.numeric(Enrolment)> 2000) 

public_school_enrolment$Enrolment<-as.numeric(public_school_enrolment$Enrolment)
table(public_school_enrolment$`Board Name`)
class(public_school_enrolment$`Board Name`)
?str_detect
table(str_detect(public_school_enrolment$`Board Name`, "\\bDSB"))
public_school_enrolment %>% 
  mutate(Board=case_when(
str_detect(`School Type`, "Catholic|Protestant")~'Separate',
str_detect(`School Type`, "Public")~'Public'))->public_school_enrolment

table(public_school_enrolment$`School Type`)
#### 
names(enrolment)
names(public_school_enrolment)
enrolment %>% 
  select(`School Number`, `School Name`, `School Level`, `Board`, `Enrolment`, `Academic Year`)->enrolment
public_school_enrolment %>% 
  select(`School Number`, `School Name`, `School Level`, `Board`, `Enrolment`, `Academic Year`)->public_school_enrolment

#bind the public school rows to the private school rows 
public_school_enrolment %>% 
  bind_rows(., enrolment)->ontario_enrolment

#Write out the file
write_csv(ontario_enrolment, file=here("data", "ontario_enrolment.csv"))
#### Draw the Grap[h]
ontario_enrolment%>%
  group_by(`Board`, `Academic Year`) %>%
  summarize(n=sum(Enrolment, na.rm=T)) %>% 
  group_by(`Academic Year`) %>% 
  mutate(Percent=n/sum(n)*100) %>% 
  filter(Board=="Private") %>% 
  ggplot(., aes(x=`Academic Year`, y=Percent))+geom_col()+theme_minimal()+labs(title=str_wrap("Share of Ontario students enrolled in private schools, 2014-2020", 50))+facet_grid(~Board)+geom_text(aes(x=`Academic Year`, y=Percent, label=round(Percent, 1)), nudge_y=0.2)
ggsave(filename=here("Plots", "ontario_private_school_enrolment.png"), width=5, height=5)

ontario_enrolment%>%
  group_by(`Board`, `Academic Year`) %>%
  summarize(n=sum(Enrolment, na.rm=T)) %>% 
  group_by(`Academic Year`) %>% 
  mutate(Percent=n/sum(n)*100) %>% 
  # filter(Board=="Private") %>% 
  ggplot(., aes(x=`Academic Year`, y=Percent))+geom_col()+theme_minimal()+labs(title="Share of Ontario students enrolled in private, public and separate schools, 2014-2020")+facet_grid(~Board)+geom_text(aes(x=`Academic Year`, y=Percent, label=round(Percent, 1)), nudge_y=3)+theme(axis.text.x = element_text(angle=90, hjust=1))
ggsave(filename=here("Plots", "ontario_separate_public_private_school_enrolment.png"), width=10, height=6)





