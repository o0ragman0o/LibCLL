#Circular Double Linked List Index Library

A Solidity library for implimenting a data indexing regime using a circular
linked list.

This library encodes a bidirectional ring storage structure which can provide
lookup, navigation and key/index storage functionality of data indecies or keys
which can be used independantly or in conjuction with a storage array or
mapping.

This implimentation seeks to provide the minimumal API functionality of 
inserting, updateing, removing and stepping through indecies.  Additional
functions such as push(), pop(), pushTail(), popTail() can be used to impliment
a First In Last Out (FILO) stack or a First In First Out (FIFO) ring buffer
while the step() function can be used to create an itterater over such as a list
of mapping keys.

##Contributors
Darryl Morris

##Usage
```
import 'https://github.com/o0ragman0o/libCLLi/blob/master/LibCLLi.sol';

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
contains a mapping of DoubleLinkNode.  Mutations to State are most expensive
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
should be wrapped in a public function of the utilizing contract.

```
    /// @dev Initializes circular linked list to a valid state
    /// @param _uniqueData determins if the list stores dataIndecies as link
    /// keys (false) or in DoubleLinkNode.dataIndex.
    function init(LinkedList storage self, bool _uniqueData)
    	internal returns (bool);

    /// @dev Resets a linked list to an initialized state
    function reset(LinkedList storage self)
        internal returns (bool);

    /// @dev Reciprocally links two nodes a and b in the before/after 
    /// direction given in _dir
    function stitch(LinkedList storage self, uint a, uint b, bool _dir)
    	internal;
	
    /// @dev Updates the value of DoubleLinkNode.dataIndex
    /// @param _nodeKey the node to be updated
    /// @param _dataIndex the update value to be stored
    function update(LinkedList storage self, uint _nodeKey, uint _dataIndex)
        internal returns (uint);
	
    /// @dev Creates a new unlinked node.
    /// @param _dataIndex value to be stored or used as node key.
	/// @dev If self.uniqueData == true _dataIndex itself is used as the node
    /// key
    function newNode(LinkedList storage self, uint _dataIndex)
        internal returns (uint nodeKey_);

    /// @dev Inserts a node between two existing nodes
    /// @param a an existing node key
    /// @param b the node key to insert
    /// @dev _dir == false  Inserts new node BEFORE _nodeKey
    /// @dev _dir == true   Inserts new node AFTER _nodeKey
    function insert (LinkedList storage self, uint a, uint b, bool _dir)
        internal returns (uint);

    /// @dev Creates and inserts a new node
    /// @param _nodeKey An existing node key to be insterted beside
    /// @param _dataIndex the index value to be stored or used for the node
    /// key
    /// @param _dir The direction of the links to be created
    function insertNewNode(
        LinkedList storage self,
        uint _nodeKey,
        uint _dataIndex,
        bool _dir
    ) internal returns (uint);

    /// @dev Deletes a node and its data from the linked list
    /// @param _nodeKey The node to be deleted
    /// @return dataIndex_ The value previously stored     
    function remove(LinkedList storage self, uint _nodeKey)
        internal returns (uint dataIndex_);

    /// @return Returns the node link data as a 3 element array
    function getNode(LinkedList storage self, uint _nodeKey)
        internal constant returns (uint[3]);

    /// @dev To test if a node exists
    function indexExists(LinkedList storage self, uint _nodeKey)
        internal constant returns (bool);

    /// @dev Returns the next or previous node key from a given node key
    /// @param _nodeKey node to step from
    /// @param _dir direction of step. false=previous, true=next
    /// @return node key of neighbour
    function step(LinkedList storage self, uint _nodeKey, bool _dir)
        internal constant returns (uint);

    /// @dev Creates new node 'next' to the head
    /// @param _dataIndex index to be stored or used for key
    function push(LinkedList storage self, uint _dataIndex)
        internal
        returns (uint);

    /// @dev Deletes the node 'next' to the head
    /// @return The deleted node dataIndex/key value
    function pop(LinkedList storage self) internal returns (uint);

    /// @dev Creates new node 'previous' to the head
    /// @param _dataIndex index to be stored or used for key
    function pushTail(LinkedList storage self, uint _dataIndex)
        internal 
        returns (uint);

    /// @dev Deletes the node 'previous' to the head
    /// @return The deleted node dataIndex/key value
    function popTail(LinkedList storage self) internal returns (uint);
```



