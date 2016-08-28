#Circular Double Linked List Index Library

A Solidity library for implimenting a data indexing regime using a circular linked list.

This library encodes a bidirectional ring storage structure which can provide lookup, navigation and key/index storage functionality of data indecies or keys which can be used independantly or in conjuction with a storage array or mapping.

This implimentation seeks to provide the minimumal API functionality of inserting, updating, removing and stepping through indecies/keys.  Additional functions such as push(), pop(), pushTail(), popTail() can be used to impliment a First In Last Out (FILO) stack or a First In First Out (FIFO) ring buffer while the step() function can be used to create an itterater over such as a list of mapping keys.

##Contributors
Darryl Morris (o0ragman0o)

##Usage
```
import 'https://github.com/o0ragman0o/libCLLi/LibCLLi.sol';

contract Foo {
	
    using LibCLLi for LibCLLi.LinkedList;

    // The circular linked list storage structure
    LibCLLi.LinkedList public list;

    mapping (uint => <some_type>) mappingToBeIndexed;
    // or
    <some_type>[] arrayToBeIndexed;
}
```

Note also that this library passes struct parameters by reference rather than copying through memory. This requires that all library functions be internal and so are included in the calling contract's bytecode at compile time rather than the contract calling to a pre-deployed instance upon the blockchain using `DELEGATECALL`.

##Storage Structures
Two structs are used. `DoubleLinkNode` defines a linked list node containing the bidirectional links as mapping keys into `LinkedList::nodes` as well as an index slot which can be used as a lookup into an associated mapping or array.
`LinkedList` contains primarily a mapping of `DoubleLinkNode` and current size of the list.

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

##Mutations to State
State mutations are most efficient if the lookup indecis or keys are known to be unique.  In such a case the keys/indecies can be stored as the node links themselves. `DoubleLinkNode::dataIndex` can be ignored and setting `LinkedList::uniqueData` will prevent updates to `LinkedList::newNodeKey`. In such a case, a call to `insert` will write to 5 state slots, 4 links and update `size`.

The State mutations are most expensive when the key/index data is not unique. In this case node keys and links are governed by `LinkedList::newNodeKey` and lookup indecies are stored in `DoubleLinkNode::dataIndex`. Inserting a new node will write to 7 slots, 4 for links, 1 for dataIndex, 1 for size and 1 for
newNodeKey.

Zero values are not to be used for keys or data indecies as `0` is key of the linked list's static head node.


##Functions
All functions in the library are internal.  Any public access to the linked list should be wrapped in a public function of the utilizing contract.

```function init(LinkedList storage self, bool _uniqueData)
    	internal returns (bool);```
Initializes circular linked list to a valid state..
`bool _uniqueData` determins if the list stores data indecies as link (true) or
in `DoubleLinkNode::dataIndex` (false).

```function reset(LinkedList storage self)
        internal returns (bool);```
Resets a linked list to an initialized state.

```function stitch(LinkedList storage self, uint a, uint b, bool _dir)
    	internal;```
Reciprocally links two nodes `a` and `b` in the before/after direction given in `_dir`.

	
```function update(LinkedList storage self, uint _nodeKey, uint _dataIndex)
        internal returns (uint);```
Updates the value of `DoubleLinkNode.dataIndex`.
`_nodeKey` the node to be updated.
`_dataIndex` the update value to be stored.
	
```function newNode(LinkedList storage self, uint _dataIndex)
        internal returns (uint nodeKey_);```
Creates a new unlinked node.
`_dataIndex` value to be stored or used as node key. If `self.uniqueData == true` `_dataIndex` itself is used as the node key.

```function insert (LinkedList storage self, uint a, uint b, bool _dir)
        internal returns (uint);```
Inserts a node between two existing nodes.
`a` an existing node key.
`b` the node key to insert.
`_dir == false`  Inserts `b` BEFORE `a`.
`_dir == true`   Inserts `b` AFTER `a`.

```function insertNewNode(
        LinkedList storage self,
        uint _nodeKey,
        uint _dataIndex,
        bool _dir
    ) internal returns (uint);```
Creates and inserts a new node.
`_nodeKey` An existing node key to be insterted beside.
`_dataIndex` the index value to be stored or used for the node key.
`_dir` The direction of the links to be created.

```function remove(LinkedList storage self, uint _nodeKey)
        internal returns (uint dataIndex_);```
Deletes a node and its data from the linked list.
`_nodeKey` The node to be deleted.
`dataIndex_` The value previously stored before removal.

```function getNode(LinkedList storage self, uint _nodeKey)
        internal constant returns (uint[3]);```
Returns the node link data as a 3 element array

function indexExists(LinkedList storage self, uint _nodeKey)
        internal constant returns (bool);
To test if a node exists

```function step(LinkedList storage self, uint _nodeKey, bool _dir)
        internal constant returns (uint);```
Returns the next or previous node key from a given node key
`_nodeKey` node to step from
`_dir` direction of step. false=previous, true=next

```function push(LinkedList storage self, uint _dataIndex)
        internal returns (uint);
Creates new node 'next' to the head
`_dataIndex` index to be stored or used for key

```function pop(LinkedList storage self) internal returns (uint);```
Deletes the node 'next' to the head and returns it's dataIndex/key value

```function pushTail(LinkedList storage self, uint _dataIndex)
        internal returns (uint);```
Creates new node 'previous' to the head
`_dataIndex` index to be stored or used for key

```function popTail(LinkedList storage self) internal returns (uint);```
Deletes the node 'previous' to the head and returns its dataIndex/key value


## License
All contributions are made under the GPLv3 license. See LICENSE.