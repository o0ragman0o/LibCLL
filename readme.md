#Circular Double Linked List Index Library

A Solidity library for implementing a data indexing regime using a circular linked list.

This library encodes a bidirectional ring storage structure which can provide lookup, navigation and key/index storage functionality of data indices or keys which can be used independently or in conjunction with a storage array or mapping.

This implementation seeks to provide the minimal API functionality of inserting, updating, removing and stepping through indices/keys.  Additional functions such as push(), pop(), pushTail(), popTail() can be used to implement a First In Last Out (FILO) stack or a First In First Out (FIFO) ring buffer while the step() function can be used to create an iterator over such as a list of mapping keys.

##Contributors
Darryl Morris (o0ragman0o)

##Usage
```
import 'https://github.com/o0ragman0o/LibCLLi/LibCLLi.sol';

contract Foo {
    using LibCLLi for LibCLLi.LinkedList;

    // The circular linked list storage structure
    LibCLLi.LinkedList public list;

    mapping (uint => <some_type>) mappingToBeIndexed;
    // or
    <some_type>[] arrayToBeIndexed;
}
```

Note that this library passes struct parameters by reference rather than copying through memory. This requires that all library functions be internal and so are included in the calling contract's bytecode at compile time rather than the contract calling to a predeployed instance upon the blockchain using `DELEGATECALL`.

##Storage Structures
Two structs are used. `DoubleLinkNode` defines a linked list node containing the bidirectional links as `uint` typed mapping keys into `LinkedList::nodes` as well as a `uint` typed index slot which can be used as a lookup into an associated mapping or array.
`LinkedList` a mapping of `DoubleLinkNode`, the current size of the list as `uint64`, a `bool` unique data flag and an `uint` auxiliary data slot.

```
     // Generic double linked list node.
    struct DoubleLinkNode {

        // The index of data to be addressed. If data indices are unique this
        uint dataIndex;

        // Bool PREV/NEXT link mapping to neighbouring nodes
        mapping (bool => uint) links;
    }
    
    // Generic circular linked list parameters. Head is static index 0.
    // For storage optimisation, there is an assumption the node count will
    // never be greater than 2**64.
    struct LinkedList {

        // Current number of nodes in linked list
        uint64 size;

        // The next key to be used in the nodes mapping if data indices aren't
        // unique. Set to 1 upon initialisation to indicate list existence.
        uint64 newNodeKey;

        // If data indices are known to be unique, they can be used directly as
        // node keys instead of being stored in DoubleLinkNode.dataIndex, saving
        // sstore costs.
        bool uniqueData;

        // auxiliary storage slot for arbitrary use.
        uint auxData;

        // The DoubleLinkNode's storage mapping being the core data structure
        // of the linked list
        mapping (uint => DoubleLinkNode) nodes;
    }
```

##Mutations to State
State mutations are most efficient if the lookup indices or keys are known to be unique.  In such a case the keys/indices can be stored as the node links themselves. `DoubleLinkNode::dataIndex` can be ignored and setting `LinkedList::uniqueData` will prevent updates to `LinkedList::newNodeKey`. In such a case, a call to `insert` will write to 5 state slots being 4 links and update to `LinkedList::size`.

The State mutations are most expensive when the key/index data is not unique. In this case node keys and links are governed by `LinkedList::newNodeKey` and lookup indices are stored in `DoubleLinkNode::dataIndex`. Inserting a new node will write to 7 slots, 4 for links, 1 for dataIndex, 1 for size and 1 tin increment LinkedList::newNodeKey.

Zero values are not to be used for keys or data indices as `0` is the key of the linked list's static head node. This implies that array-type[0] or mapping-type[0] should not be used for data storage.


##Functions
All functions in the library are internal.  Any public access to the linked list should be wrapped in a public functions of the utilising contract.

###init
```
function init(LinkedList storage self, bool _uniqueData)
    internal returns (bool);
```
Initializes the circular linked list to an 'existing' state..
`bool _uniqueData` determines if the list stores data indices as link keys (`true`) or
in `DoubleLinkNode::dataIndex` (`false`).

###reset
```
function reset(LinkedList storage self)
    internal returns (bool);
```
Resets a linked list to an initialized state.

###stitch
```
function stitch(LinkedList storage self, uint a, uint b, bool _dir)
    internal;
```
Reciprocally links two nodes `a` and `b` in the before/after direction given in `_dir`.
`_dir == false` `a` is linked previous to `b`
`_dir == true` `a` is linked next to `b`

###update
```
function update(LinkedList storage self, uint _nodeKey, uint _dataIndex)
        internal returns (uint);
```
Updates the value of `DoubleLinkNode::dataIndex`.
`_nodeKey` the node to be updated.
`_dataIndex` the update value to be stored.

###newNode
```
function newNode(LinkedList storage self, uint _dataIndex)
        internal returns (uint nodeKey_);
```
Creates a new unlinked node.
`_dataIndex` value to be stored or used as node key. If `self.uniqueData == true` the value of `_dataIndex` is used as the node key.
Returns `nodekey_` as the value assigned to the new node key. 

###insert
```
function insert (LinkedList storage self, uint a, uint b, bool _dir)
        internal returns (uint);
```
Inserts an existing node between two other existing nodes.
`a` an existing node key.
`b` the node key to insert.
`_dir == false`  Inserts `b` BEFORE `a`.
`_dir == true`   Inserts `b` AFTER `a`.

###insertNewNode
```
function insertNewNode(
        LinkedList storage self,
        uint _nodeKey,
        uint _dataIndex,
        bool _dir
    ) internal returns (uint);
```
Creates and inserts a new node.
`_nodeKey` An existing node key to be inserted beside.
`_dataIndex` the index value to be stored or used for the node key.
`_dir` The direction of the links to be created.
`_dir == false`  Inserts the new node BEFORE `_nodeKey`.
`_dir == true`   Inserts the new node AFTER `_nodeKey`.
Returns the value assigned to the new node key. 

###remove
```
function remove(LinkedList storage self, uint _nodeKey)
        internal returns (uint dataIndex_);
```
Deletes a node and its data from the linked list.
`_nodeKey` The node to be deleted.
Returns `dataIndex_` as data index value stored before removal.

###getNode
```
function getNode(LinkedList storage self, uint _nodeKey)
        internal constant returns (uint[3]);
```
Returns the node data as an array in the form of `[dataIndex, prev, next]`

###indexExists
```
function indexExists(LinkedList storage self, uint _nodeKey)
        internal constant returns (bool);
```
Returns `true` if `self[_nodeKey]` exists.
###step
```
function step(LinkedList storage self, uint _nodeKey, bool _dir)
        internal constant returns (uint);
```
Returns the next or previous node key from a given node key
`_nodeKey` Node key to step from.
`_dir == false` Returns the previous node key.
`_dir == true` Returns the next node key

###push
```
function push(LinkedList storage self, uint _dataIndex)
        internal returns (uint);
```
Creates new node 'next' to the head.
`_dataIndex` index to be stored.
Returns the value of the new node key.

###pop
```
function pop(LinkedList storage self) internal returns (uint);
```
Deletes the node 'next' to the head and returns its dataIndex/key value.

###pushTail
```
function pushTail(LinkedList storage self, uint _dataIndex)
        internal returns (uint);
```
Creates new node 'previous' to the head.
`_dataIndex` index to be stored.
Returns the value of the new node key.

###popTail
```
function popTail(LinkedList storage self) internal returns (uint);
```
Deletes the node 'previous' to the head and returns its dataIndex/key value


## License
All contributions are made under the GPLv3 license. See LICENSE.