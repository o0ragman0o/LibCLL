#Circular Double Linked List Index Library

A Solidity library for implementing a data indexing regime using a circular linked list.

This library encodes a bidirectional ring storage structure which can provide lookup, navigation and key/index storage functionality of data indices or keys which can be used independently or in conjunction with a storage array or mapping.

This implementation seeks to provide the minimal API functionality of inserting, removing and stepping through a unique set of indices/keys. Functions such as push(), pop() can be used to implement a First In Last Out (FILO) stack or a First In First Out (FIFO) ring buffer while the step() function can be used to create an iterator over such as a list of mapping keys.

##Contributors
Darryl Morris (o0ragman0o)

##Usage
```
import 'LibCLLi.sol';

contract Foo {
    using LibCLLi for LibCLLi.CLL;

    // The circular linked list storage structure
    LibCLLi.CLL public list;

    mapping (uint => <some_type>) mappingToBeIndexed;
    // or
    <some_type>[] arrayToBeIndexed;
}
```

Note that this library passes struct parameters by reference rather than copying through memory. This requires that all library functions be internal and so are included in the calling contract's bytecode at compile time rather than the contract calling to a predeployed instance upon the blockchain using `DELEGATECALL`.

##Storage Structures

`LinkedList` is a nested mapping with the first key being the node index (uint) and the second being the bidirectional link (bool) to a neighbouring node. Key `0` implies the head so writes to `LinkedList.l[0]` or manually linking to Linklist.l[0] (e.g. ll[var1][false] = 0;) are to be avoided by the calling contract. 

```
    struct CLL{
        mapping (uint => mapping (bool => uint)) l;
    }
```

##Mutations to State
The bidirectional links consist of two State slots (2x uint256) which are written to by the function `stitch()`.
`insert()` calls `stitch()` twice for a total of 4 state mutations.
`remove` calls `stitch()` once and deletes two slots.

##Functions
All functions in the library are internal. Any public access to the linked list should be wrapped in a public functions of the utilising contract.

###exists
```
function exists(CLL storage self) internal constant returns (bool)
```
Returns the existential state of the list itself.
`true` HEAD links to non-zero node.
`false` HEAD links to zero.

###stitch
```
function stitch(CLL storage self, uint a, uint b, bool d)  internal
```
Reciprocally links two nodes `a` and `b` in the before/after direction given in `d`.
`d == false` Link `a` previous to `b`.
`d == true` Link `a` next from `b`.

###insert
```
function insert (CLL storage self, uint a, uint b, bool d) internal
```
Inserts a node between two existing nodes.
`a` an existing node key.
`b` the node key to insert.
`d == false`  Insert `b` BEFORE `a`. 
`d == true`   Insert `b` AFTER `a`.

###remove
```
function remove(CLL storage self, uint n)  internal returns (uint)
```
Deletes a node from the linked list and returns its value.
`n` The node to be deleted.

###getNode
```
function getNode(CLL storage self, uint n) internal constant returns (uint[2])
```
Returns the bidirectional link as a uint[2] array in the form of `[PREV, NEXT]`

###step
```
function step(CLL storage self, uint n, bool d) internal constant returns (uint)
```
Returns the next or previous node key from a given node key.
`n` Node key to step from.
`d == false` Returns the previous node key.
`d == true` Returns the next node key.

###seek
```
function seek(CLL storage self, uint n, bool d) internal constant returns (uint)
```
Seeks and returns the next or previous node greater or less than `n` in an *ordered list* in direction `d` from the Head.
This function can be used before insert() in order to build an orderd list.
`n` Node key to seek. Does not need to be an existing node.
`d == false` Seek in decending order.
`d == true` Seek in ascending order.

###push
```
function push(CLL storage self, uint n, bool d) internal
```
Creates a new node 'previous' or 'next' to the head.
`n` Node key to push.
`d == false` Returns the previous node key.
`d == true` Returns the next node key.

###pop
```
function pop(CLL storage self, bool d) internal returns (uint)
```
Deletes the node 'previous' or 'next' to the head and returns its value.
`d == false` Returns the previous node key.
`d == true` Returns the next node key.

##Use Cases

TODO

## License
All contributions are made under the GPLv3 license. See LICENSE.