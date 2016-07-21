#Circular Double Linked List

A Solidity library for implimenting a data indexing regime using a circular
linked list.

This library encodes a bidirectional ring storage structure which can provide
lookup, navigation and key/index storage functionality of data indecies which
can be used independantly or in conjuction with a storage array or mapping.

This implimentation seeks to provide the minimumal API functionality of 
inserting, updateing, removing and stepping through indeices.  Additional
functions such as push(), pop(), pushTail(), popTail() can be used to impliment
a First In Last Out (FILO) stack or a First In First Out (FIFO) ring buffer
while the step() function can be used to create an itterater over such as a list
of mapping keys.

##Contributors
Darryl Morris

##Usage
```
import 'https://github.com/o0ragman0o/libCLLi/blob/master/libCLLi.sol';

contract Foo {
	
    using LibCLLi for LibCLLi.LinkedList;

    // The circular linked list storage structure
    LibCLLi.LinkedList public list;

    mapping (uint => <some type>) mappingToBeIndexed;
    // or
    <some type>[] arrayToBeIndexed;
}
```

The linked nodes are stored in a seperate mapping with UINT mapping 
keys `next` and `prev` for the purpose of linking nodes, while UINT `dataIdx`
holds the index to the data array.

Of note is the avoindance of '0' values for indecies and pointers.
This is because solidity has no intrinsic 'null' test for uninitiated state 
variables which have an implied value of 0. The head node is always at index 1.

