# c64-aoc
Let's see how many of the Advent of Code 2020 problems we can solve on a Commodore 64!

Code is written to be assembled with acme.

## Day 01

The input of Day 01 was just a list of numbers that could be expressed in 2 bytes, so the data is stored as a list of !words. The file `input-d01.asm` contains sample input data and shows how to split it into input and input2 to make it easier to address it.

Both part 1 and part 2 will output the answer in hex, and it will need to be converted to decimal to enter the answer in AoC.

TODO: write a routine to convert hex to dec and it will undoubtedly be useful for other days as well.

## Day 03

The input of Day 03 was a list of strings containing "#" or "." characters. The file `input-d03.asm` shows how to input them as PETSCII strings.  Obviously, it would have been more efficient to store them as single bits, but we are trying to do as little pre-processing of the input as possible, and we have plenty of memory to store the raw strings.

Similar to Day 01, the answer is output in hex and will be need to converted to decimal to enter the answer in AoC.
