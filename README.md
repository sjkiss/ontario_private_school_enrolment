# Ontario Private School Enrolment

This repository contains the individual data files taken from this Ontario Data repository [](https://data.ontario.ca/dataset/private-school-enrolment-by-gender). The contents include:

1. The original, unmodified data files, stored as excel files in the `Data` subfolder.
2. An R Script that loads each file and performs extremely basic data cleaning tasks. 
  - It converts all variable names to title cases
  - Sets cells with values "<10"" to have a value of 5
  - deletes values with "SP" because these are not defined in the data documentation
  - filters out rows in the public school data-set that are totals
  - Recalculates new enrolments for the private schools from the total male and female enrolments
  - binds the two data sets together into one and saves that file out. 