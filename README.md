# Zipline. Inc Take Home
Submitted by Maria Kim

## Summary
This program identifies rows in a CSV file that may represent the same person based on a user selected Matching Type. 

A simple CLI prompts the user for an input file and allows the user to select from the following Matching Types:

- match records with the same email address
- match records with the same phone number
- match records with the same email address OR the same phone number

The program then processes the CSV according to the selection. It outputs the results to a copy of the original CSV file, where each row has a prepended unique id. Thus the unique id will be the same for the rows that the program has determined to represent the same person.

For example, if the user selects to match records with the same email address, the output for the following CSV:
```csv
Email, Phone Number, Name
a@test.com,,Anne
b@test.com,,
a@test.com,,Anne Marie
```
will have the rows with `a@test.com` to have the same Unique ID.
```csv
Unique ID,Email,Phone Number,Name
1,a@test.com,,Anne
2,b@test.com,,
1,a@test.com,,Anne Marie
```
## Union Find Algorithm/Data Structure 
The Union Find algorithm and data structure was implemented and used to group together rows that fit the Matching Type selected. This was done due to address scalability concerns.

For more information, see [Introduction to Disjoint Set (Union-Find Data Structure)](https://www.geeksforgeeks.org/dsa/introduction-to-disjoint-set-data-structure-or-union-find-algorithm/).

## Assumptions:
- Each CSV input file has at least 1 column for email or at least 1 column for phone number
- Assumes CSV has a valid header row
- Assumes emails and phone numbers are either nil or valid, though they may be formatted differently

## Technical Requirements
- Ruby (3.4.7)

This program was written in pure Ruby using only the standard library, thus there are no external dependencies.


## To Run
```console
ruby main.rb
```
## Tests

### To run a single set of tests
```console
ruby -Itest test/main_test.rb
```

### To run all tests

```console
ruby -Itest test/run.rb
```

### Future Enhancements
#### Error Handling
For the purpose of this take home, I did not think it was necessary to add much error handling, but in the real world, errors are everywhere. Here are some of the areas I would add error handling:
##### Reading 
- When there is no Email or Phone Number columns
- When email or email-phone matching type is selected by there is no email column
- When where phone number or email-phone matching type is selected by there is no phone number column
##### Writing
- When the program cannot write to the disk
- When the disk runs out of memory during write

#### Validation
I would also add some validation and ignore or log any emails or phone numbers that do not look valid
