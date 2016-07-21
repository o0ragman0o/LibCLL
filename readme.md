Circular Double Linked List
---------------------------

An example of a Circular Linked List in Solidity for the Ethereum 
platform.

This implimentation seeks to provide the minimumal API functionality of 
inserting, updateing, removing and stepping. List nodes and data elements can 
be accessed using the accessor functions of public 'list' and 'data' state 
variables.

The UI is expected to impliment more sophisticated functionality such 
as navigation, seek, push, pop, pull, etc. UI implimentations can take forms 
such as a Stack, FIFO, Single and Double Linked list and mapping itterator.

Data is kept in an array while the link nodes store array indecies to the 
ascociated data.

The linked nodes are stored in a seperate mapping with UINT mapping 
keys `next` and `prev` for the purpose of linking nodes, while UINT `dataIdx`
holds the index to the data array.

Of note is the avoindance of '0' values for indecies and pointers.
This is because solidity has no intrinsic 'null' test for uninitiated state 
variables which have an implied value of 0. The head node is always at index 1.

