# c64-aoc
Let's see how many of the Advent of Code 2020 problems we can solve on a Commodore 64!

Code is written to be assembled with acme.

## Day 01

The input of Day 01 was just a list of numbers that could be expressed in 2 bytes, so the data is stored as a list of !words. The file `input-d01.asm` contains sample input data and shows how to split it into input and input2 to make it easier to address it.

For both part 01 and 02, the leading 0s will need to be removed beore entering the answer in AoC.


## Day 02
Day 2's input is a list of strings that contain alphanumeric and symbol characters. The file `input-d02.asm` shows how to get acme to treat them as PETSCII strings. Add a `!` character at the end, and that tells the program that it is done parsing the input. 

Only part 1 has been solved so far. Similar to Day 01, leading 0s will need to be removed beore entering the answer in AoC.

## Day 03

The input of Day 03 was a list of strings containing "#" or "." characters. The file `input-d03.asm` shows how to input them as PETSCII strings.  Obviously, it would have been more efficient to store them as single bits, but we are trying to do as little pre-processing of the input as possible, and we have plenty of memory to store the raw strings.

Similar to the other days, the leading 0s will need to be removed beore entering the answer in AoC.

## TODO

Update the print answer routine to remove leading 0s
