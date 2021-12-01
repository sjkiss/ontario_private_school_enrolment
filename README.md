
# Ontario Private and Public School Enrolment

The purpose of this repository is to provide a single point of access for data on private and public school enrollment in Ontario. It contains:

1. the original datasets reporting [private](https://data.ontario.ca/dataset/private-school-enrolment-by-gender) school and [public](https://data.ontario.ca/dataset/school-enrolment-by-gender) school enrollment from the Ontario Open Data database.  
2.  An R Script that loads each file and performs extremely basic data cleaning tasks. 
  - It converts all variable names to title cases
  - Sets cells with values "<10"" to have a value of 5
  - deletes values with "SP" because these are not defined in the data documentation
  - filters out rows in the public school data-set that are totals
  - Recalculates new enrolments for the private schools from the total male and female enrolments
  - binds the two data sets together into one and saves that file out.
3. A combined dataset that shows public and private school enrollment in Ontario. 

To cite, please kindly cite as follows:
  


The basic graph of interest is ![here](https://github.com/sjkiss/ontario_private_school_enrolment/raw/main/ontario_private_school_enrolment.png) 


I'll commit to updating this repository as data becomes available. If anyone spots any concerns, please contact me or open a pull request. 
