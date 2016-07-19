
library LibCLLi {
/* Constants */

    uint constant NULL = 0;
    uint constant HEAD = NULL; // Lists are circular with static head.
    bool constant PREV = false; // Toward first in
    bool constant NEXT = true; // Away from first in
    
/* Structs */

    // Generic double linked list node.
    struct DoubleLinkNode {
        uint dataIndex; // not used if data elements are unique unless manually updated.
        mapping (bool => uint) links;
    }
    
    // Generic circular linked list parameters. Head is static index 0.
    struct LinkedList {
        uint64 size;  // Number of nodes
        uint64 newNodeKey; // Next free mapping slot
        bool uniqueData; // will save a sstore by using data as key if true
        uint auxData; // auxilary data state variable.
        mapping (uint => DoubleLinkNode) nodes;
    }

/* Functions */
	
    // Initialises circular linked list to a valid state
    function init(LinkedList storage self, bool _uniqueData, bool _reset) 
        internal returns (bool)
    {
        if (self.newNodeKey != NULL && !_reset) return false;
        self.newNodeKey = 1; // can be used for list existence testing
        self.uniqueData = _uniqueData;
		self.nodes[HEAD].links[NEXT] = NULL; // reseting existing
		self.nodes[HEAD].links[PREV] = NULL; // reseting existing
        self.size = 0;
        return true;
    }

    function stitch(LinkedList storage self, uint a, uint b, bool _dir)
    	internal
    {
     	self.nodes[a].links[_dir] = b;
    	self.nodes[b].links[!_dir] = a;
    }
	
    function update(LinkedList storage self, uint _nodeKey, uint _dataIndex)
        internal returns (uint)
    {
        self.nodes[_nodeKey].dataIndex = _dataIndex;
        return _nodeKey;
    }
	
	/// @dev If the list is a set the data index is used as the node key
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

    /// _dir == false  Inserts new node BEFORE _nodeKey
    /// _dir == true   Inserts new node AFTER _nodeKey
    function insert (LinkedList storage self, uint a, uint b, bool _dir)
        internal returns (uint)
    {
        uint c = self.nodes[a].links[_dir];
        stitch (self, a, b, _dir);
        stitch (self, b, c, _dir);
        return b;
    }

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

    function getNode(LinkedList storage self, uint _nodeKey)
        internal constant returns (uint[3])
    {
        return [
            self.nodes[_nodeKey].dataIndex,
            self.nodes[_nodeKey].links[PREV],
            self.nodes[_nodeKey].links[NEXT]];
    }

    function step(LinkedList storage self, uint _nodeKey, bool _dir)
        internal constant returns (uint)
    {
        return self.nodes[_nodeKey].links[_dir];
    }

	// FILO storage
    function push(LinkedList storage self, uint _num)
        internal
        returns (uint)
    {
        return insertNewNode(self, HEAD, _num, NEXT);
    }

    function pop(LinkedList storage self) internal returns (uint)
    {
        return remove(self, step(self, HEAD, NEXT));
    }

	// FIFO storage
    function pushTail(LinkedList storage self, uint _num)
        internal 
        returns (uint)
    {
        return insertNewNode(self, HEAD, _num, PREV);
    }

    function popTail(LinkedList storage self) internal returns (uint)
    {
        return remove(self, step(self, HEAD, PREV));
    }

    
}


contract CLL
{
/* Constants */

    uint constant HEAD = 0; // Lists are circular with static head.
    bool constant PREV = false;
    bool constant NEXT = true;
    
	using LibCLLi for LibCLLi.LinkedList;

	LibCLLi.LinkedList public list;
	uint public output;

	function CLL()	
	{
        list.init(true, false);
	}
	
	function getNode(uint _nodeKey) public constant
		returns (uint[3])
	{
		return list.getNode(_nodeKey);
	}
	
	function step(uint _nodeKey, bool _dir) public constant
		returns (uint)
	{
		return list.step(_nodeKey, _dir);
	}
	
    function insert(uint key, uint num, bool _dir) public returns(uint)
    {
        output = list.insertNewNode(key, num, _dir);
    }

    function remove(uint num) public returns (uint)
    {
        output = list.remove(num);
    }   

    function push(uint num) public returns (uint)
    {
        output = list.push(num);
    }
    
	function pop() public returns (uint)
	{
		output = list.pop();
	}

	function pushTail(uint num) public returns (uint)
    {
        output = list.pushTail(num);
    }
    
	function pull() public returns (uint)
	{
		output = list.popTail();
	}

}