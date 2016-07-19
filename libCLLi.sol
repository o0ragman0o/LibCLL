
library LibCLL {
/* Constants */

    uint constant NULL = 0;
    uint constant HEAD = NULL; // Lists are circular with static head.
    bool constant PREV = false;
    bool constant NEXT = true;
    
/* Structs */

    // Generic double linked list node.
    struct DoubleLinkNode {
        uint dataIndex;
        mapping (bool => uint) links;
    }
    
    // Generic circular linked list parameters. Head is static index 0.
    struct LinkedList {
        uint size;  // Number of nodes
        uint newNodeKey; // Next free mapping slot
        uint auxData; // auxilary data state variable.
        mapping (uint => DoubleLinkNode) nodes;
    }
    
/* Modifiers */

    // To test if mapping keys point to a valid linked list node.
    modifier isValidKey(LinkedList list, uint _nodeKey) { 
        if (list.nodes[_nodeKey].dataIndex == 0) return; 
        _
    }

    // To test if supplied is >0. Does not test is data at index is valid 
    modifier isValidDataIndex(uint _dataIdx) {
        if (_dataIdx == 0) return; 
        _
    }

/* Functions */

    function getNode(LinkedList list, uint _nodeKey)
    	public
        constant
        returns (uint dataIndex_, uint prev_, uint next_)
    {
        dataIndex_ = list.nodes[_nodeKey].dataIndex;
        prev_ = list.nodes[_nodeKey].links[PREV];
        next_ = list.nodes[_nodeKey].links[NEXT];
    }

    function keyExists(LinkedList list, uint _nodeKey)
        public
        constant
        isValidKey(list, _nodeKey)
        returns (bool)
    { 
        return true;
    }

    // Initialises circular linked list to a valid state
    function initLinkedList(LinkedList list, bool _reset) 
        internal
        returns (bool)
    {
        if (list.nodes[HEAD].dataIndex != NULL && !_reset)
        	return false; // List already exisits.
        list.newNodeKey = 1; // key 0 is already head
        list.nodes[HEAD].links[NEXT] = HEAD; // set next link to head
        list.nodes[HEAD].links[PREV] = HEAD; // set previous link to head
        list.nodes[HEAD].dataIndex = 1;
        return true;
    }

    function stitch(LinkedList list, uint a, uint b, bool _dir)
    	internal
    {
     	list.nodes[a].links[_dir] = b;
    	list.nodes[b].links[!_dir] = a;
    }
	
    // Creates a new unlinked node or updates existing node dataIndex
    // `_nodeKey` is arbtrary or auto assigned if 0.
    function update(LinkedList list, uint _nodeKey, uint _dataIndex)
        internal
        returns (uint)
    {
        if (_nodeKey == 0) _nodeKey = list.newNodeKey++;
        if (!keyExists(list, _nodeKey)) list.size++;
        list.nodes[_nodeKey].dataIndex = _dataIndex;
        return _nodeKey;
    }
  
    function newNode(LinkedList list, uint _nodeKey, uint _dataIndex)
        internal
        returns (uint)
    {
            return update(list, _nodeKey, _dataIndex);
    }

    // _dir == false  Inserts new node BEFORE _nodeKey
    // _dir == true   Inserts new node AFTER _nodeKey
    function insert (LinkedList list, uint a, uint b, bool _dir)
        internal
        isValidKey(list, a)
    {
        uint c = list.nodes[a].links[_dir];
        stitch (list, a, b, _dir);
        stitch (list, b, c, _dir);
    }

    function insertNewNode(LinkedList list,
    				uint _nodeKey,
                    uint _newKey,
                    uint _dataIndex,
                    bool _dir)
        internal
        returns (uint b)
    {
    	b = update(list, _newKey, _dataIndex);
    	insert(list, _nodeKey, _newKey, _dir);
    }

	function swap(LinkedList list, uint a, uint b)
		internal
	{
		uint c = list.nodes[a].links[PREV];
		uint d = list.nodes[a].links[NEXT];
		uint e = list.nodes[b].links[PREV];
		uint f = list.nodes[b].links[NEXT];
	
		stitch (list, c, b, NEXT);
		stitch (list, b, d, NEXT);
		stitch (list, e, a, NEXT);
		stitch (list, a, f, NEXT);
	}
           
    function remove(LinkedList list, uint _nodeKey)
        internal
        isValidKey(list, _nodeKey)
        returns (bool)
    {
        uint a = list.nodes[_nodeKey].links[PREV];
        uint b = list.nodes[_nodeKey].links[NEXT];
        stitch(list, a, b, NEXT);
        list.size--;
        // Explicit deletes for mapping elements
        delete list.nodes[_nodeKey].links[PREV];
        delete list.nodes[_nodeKey].links[NEXT];
        delete list.nodes[_nodeKey].dataIndex;
        delete list.nodes[_nodeKey];
        return true;
    }
    
    function step(LinkedList list, uint _nodeKey, bool _dir)
        // get next or previous node key
        isValidKey(list, _nodeKey)
        constant returns (uint)
    {
        return list.nodes[_nodeKey].links[_dir];
    }
}


contract CLL
{
	LibCLL.LinkedList list;
	uint output;
	function CLL()	
	{
        list.nodes[HEAD].links[NEXT] = HEAD; // set next link to head
        list.nodes[HEAD].links[PREV] = HEAD; // set previous link to head
        list.nodes[HEAD].dataIndex = 1;
	}
	
	function push(uint num) public
	{
		insertNewNode(list, HEAD, num, num, PREV);
	}

	function pull() public returns (uint)
	{
		output = step(list, HEAD, NEXT);
		remove(list, output);
		return output;
	}

	function pop() public returns (uint)
	{
		output = step(list, HEAD, PREV);
		remove(list, output);
		return output;
	}

}