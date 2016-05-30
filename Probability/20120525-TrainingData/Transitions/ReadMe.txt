The transition probabilities are encoded as a 6x6 sparse matrix for a given force axis. 

Note that the direction matters, so we have six files, one for each axis. 

The rows and columns correspond to the LLBs in the following order:

FX
CT
PS
PL
SH
AL

Note that in the .xls files the diagonals are equal to zero. In actuality, if the current state is equal to the previous state, that transition probability will always be 1.