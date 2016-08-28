/*
file:   LibCLLi.sol
ver:    0.1.0-alpha
updated:23-Aug-2016
author: Darryl Morris
email:  o0ragman0o AT gmail.com

A Solidity library for implimenting a data indexing regime using
a circular linked list.

This library provisions lookup, navigation and key/index storage
functionality which can be used in conjuction with an array or mapping.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.
<http://www.gnu.org/licenses/>.
*/


library LibCLLi {
/* Constants */

    uint constant NULL = 0;
    uint constant HEAD = NULL; // Lists are circular with static head.
    bool constant PREV = false; // CCW from head
    bool constant NEXT = true; // CW from head
    
/* Structs */

    // Generic double linked list node.
    struct DoubleLinkNode {

        // The index of data to be addressed (optional if indecies are unique)
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

/* Functions Public */

    // In order to pass LinkedList structs by reference and not copied, all
    // LibCLLi functions are internal. This also means that library bytecode
    // will be compiled into the calling contract's bytecode rather than the
    // contract using DELEGATECALL to library code stored on the Blockchain.
    // Public access to this library functions is required should be through the
    // calling contracts own public functions.

/* Functions Internal */
	
    /// @dev Initializes circular linked list to a valid state
    /// @param _uniqueData determins if the list stores dataIndecies as link
    /// keys (false) or in DoubleLinkNode.dataIndex.
    function init(LinkedList storage self, bool _uniqueData) 
        internal returns (bool)
    {
        if (self.newNodeKey != NULL) return false;
        self.newNodeKey = 1; // can be used for list existence testing
        self.uniqueData = _uniqueData;
        return true;
    }

    /// @dev Resets a linked list to an initialized state
    function reset(LinkedList storage self)
        internal returns (bool)
    {
        self.newNodeKey = 1; // can also be used for list existence testing
        self.nodes[HEAD].links[NEXT] = NULL; // reseting existing
        self.nodes[HEAD].links[PREV] = NULL; // reseting existing
        self.size = 0;
        return true;
    }


    /// @dev Reciprocally links two nodes a and b in the before/after 
    /// direction given in _dir
    function stitch(LinkedList storage self, uint a, uint b, bool _dir)
    	internal
    {
     	self.nodes[a].links[_dir] = b;
    	self.nodes[b].links[!_dir] = a;
    }
	
    /// @dev Updates the value of DoubleLinkNode.dataIndex
    /// @param _nodeKey the node to be updated
    /// @param _dataIndex the update value to be stored
    function update(LinkedList storage self, uint _nodeKey, uint _dataIndex)
        internal returns (uint)
    {
        self.nodes[_nodeKey].dataIndex = _dataIndex;
        return _nodeKey;
    }
	
    /// @dev Creates a new unlinked node.
    /// @param _dataIndex value to be stored or used as node key.
	/// @dev If self.uniqueData == true _dataIndex itself is used as the node
    /// key
    function newNode(LinkedList storage self, uint _dataIndex)
        internal returns (uint nodeKey_)
    {
        nodeKey_ = _dataIndex;
        if (!self.uniqueData) {
            nodeKey_ = self.newNodeKey++;
            self.nodes[nodeKey_].dataIndex = _dataIndex;
        }
        self.size++;
        return nodeKey_;
    }

    /// @dev Inserts a node between to existing nodes
    /// @param a an existing node key
    /// @param b the node key to insert
    /// @param _dir The direction links are to be created
    /// @dev _dir == false  Inserts new node BEFORE _nodeKey
    /// @dev _dir == true   Inserts new node AFTER _nodeKey
    function insert (LinkedList storage self, uint a, uint b, bool _dir)
        internal returns (uint)
    {
        uint c = self.nodes[a].links[_dir];
        stitch (self, a, b, _dir);
        stitch (self, b, c, _dir);
        return b;
    }

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
    )
        internal returns (uint)
    {
        uint newKey = newNode(self, _dataIndex);
        return insert(self, _nodeKey, newKey, _dir);
    }
    
    /// @dev Deletes a node and its data from the linked list
    /// @param _nodeKey The node to be deleted
    /// @return dataIndex_ The value previously stored     
    function remove(LinkedList storage self, uint _nodeKey)
        internal returns (uint dataIndex_)
    {
        if (_nodeKey == NULL) return;
        dataIndex_ = _nodeKey; 
        if (!self.uniqueData) dataIndex_ = self.nodes[_nodeKey].dataIndex;
        uint a = self.nodes[_nodeKey].links[PREV];
        uint b = self.nodes[_nodeKey].links[NEXT];
        stitch(self, a, b, NEXT);
        self.size--;
        // Explicit deletes for mapping elements
        delete self.nodes[_nodeKey].links[PREV];
        delete self.nodes[_nodeKey].links[NEXT];
        delete self.nodes[_nodeKey].dataIndex;
        return;
    }

    /// @return Returns the node link data as a 3 element array
    function getNode(LinkedList storage self, uint _nodeKey)
        internal constant returns (uint[3])
    {
        return [
            self.nodes[_nodeKey].dataIndex,
            self.nodes[_nodeKey].links[PREV],
            self.nodes[_nodeKey].links[NEXT]];
    }

    /// @dev To test if a node exists
    function indexExists(LinkedList storage self, uint _nodeKey)
        internal constant returns (bool)
    {
        if (self.newNodeKey > 0) return true;
    }

    /// @dev Returns the next or previous node key from a given node key
    /// @param _nodeKey node to step from
    /// @param _dir direction of step. false=previous, true=next
    /// @return node key of neighbour
    function step(LinkedList storage self, uint _nodeKey, bool _dir)
        internal constant returns (uint)
    {
        return self.nodes[_nodeKey].links[_dir];
    }

    /// @dev Creates new node 'next' to the head
    /// @param _dataIndex index to be stored or used for key
    function push(LinkedList storage self, uint _dataIndex)
        internal
        returns (uint)
    {
        return insertNewNode(self, HEAD, _dataIndex, NEXT);
    }

    /// @dev Deletes the node 'next' to the head
    /// @return The deleted node dataIndex/key value
    function pop(LinkedList storage self) internal returns (uint)
    {
        return remove(self, step(self, HEAD, NEXT));
    }

    /// @dev Creates new node 'previous' to the head
    /// @param _dataIndex index to be stored or used for key
    function pushTail(LinkedList storage self, uint _dataIndex)
        internal 
        returns (uint)
    {
        return insertNewNode(self, HEAD, _dataIndex, PREV);
    }

    /// @dev Deletes the node 'previous' to the head
    /// @return The deleted node dataIndex/key value
    function popTail(LinkedList storage self) internal returns (uint)
    {
        return remove(self, step(self, HEAD, PREV));
    }

    /// @dev Directional FILO storage can be enacted by 
    /// push() followed by pop() or pushTail() followed by popTail() 

    /// @dev Directional FIFO storage can be enacted by
    /// push() followed by popTail() or pushTail() followed by pop()    
}


