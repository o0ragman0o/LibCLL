#Circular Double Linked List Index Library

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

    mapping (uint => <some_type>) mappingToBeIndexed;
    // or
    <some_type>[] arrayToBeIndexed;
}
```

##Storage Structures
The two structs that  are used are the DoubleLinkNode and the LinkedList which
contrains a mapping of DoubleLinkNode.  Mutations to State are most expensive
when inserting a new node and can write upto 7 slots; 4 for links, 1 for
dataIndex, 1 for size and 1 for newNodeKey. When index data is known to be
unique, it can itself be used as the node keys and so dataIndex and newNodeKey
won't need to be written into.

Of note is the avoindance of '0' values for node keys as 0 is the head
index. This also implies that an array being indexed should not store data at
[0].

```
     // Generic double linked list node.
    struct DoubleLinkNode {

        // The index of data to be addressed. If data indecies are unique this
        uint dataIndex;

        // Bool PREV/NEXT link mapping to neighbouring nodes
        mapping (bool => uint) links;
    }
    
    // Generic circular linked list parameters. Head is static index 0.
    // For storage optomisation, there is an assumption the node count will
    // never be greater than 2**64.
    struct LinkedList {

        // Current number of nodes in linked list
        uint64 size;

        // The next key to be used in the nodes mapping if dataIndecies aren't
        // unique. Set to 1 upon initialization to indicate list existence.
        uint64 newNodeKey;

        // If data indecies are known to be unique, they can be used directly as
        // node keys instead of being stored in DoubleLinkNode.dataIndex, saving
        // sstore costs.
        bool uniqueData;

        // auxilary storage slot for arbitrary use.
        uint auxData;

        // The DoubleLinkNode's storage mapping being the core data structure
        // of the linked list
        mapping (uint => DoubleLinkNode) nodes;
    }
```

##Functions
All functions in the library are internal.  Any public access to the linked list
should be wrapped in a public frunction of the utilzing contract.

```
    /// @return Returns the node link data as a 3 element array
    function getNode(uint _nodeKey) public constant returns (uint[3]);
    
    // Returns the next or previous node key from a given node key
    // _nodeKey node to step from
    // _dir direction of step. false=previous, true=next
    // returns node key of neighbour
    function step(uint _nodeKey, bool _dir) public constant returns (uint);
    
    // Inserts a node between to existing nodes
    // _key an existing node key
    // _num the node key/dataIndex to insert
    // _dir == false  Inserts new node BEFORE _nodeKey
    // _dir == true   Inserts new node AFTER _nodeKey
    function insert(uint _key, uint _num, bool _dir) public returns(uint);

    // Deletes a node and its data from the linked list
    // _num The node to be deleted
    // returns output The value previously stored     
    function remove(uint _num) public returns (uint);

    // Creates new node 'next' to the head
    // _num index to be stored or used for key
    function push(uint _num) public returns (uint);
    
    // Deletes the node 'next' to the head
    // returns the deleted node dataIndex/key value
    function pop() public returns (uint);

    // Creates new node 'previous' to the head
    // _num index to be stored or used for key
    function pushTail(uint _num) public returns (uint);
   
    // Deletes the node 'previous' to the head
    // returns the deleted node dataIndex/key value
    function popTail() public returns (uint);
```



