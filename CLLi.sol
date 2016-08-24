
/*
file:   CLLi.sol
ver:    0.1.0-alpha
updated:21-Jun-2016
author: Darryl Morris
email:  o0ragman0o AT gmail.com

An example Solidity contract implimenting a data indexing regime using
the libCLLi library.

This contract presents public access function wrappers (API) of the libCLLi
internal functions.


This contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.
<http://www.gnu.org/licenses/>.
*/

import 'LibCLLi.sol';

contract CLLi
{
/* Constants */

    uint constant HEAD = 0; // Lists are circular with static head.
    bool constant PREV = false;
    bool constant NEXT = true;
    
    using LibCLLi for LibCLLi.LinkedList;

    // The circular linked list storage structure
    LibCLLi.LinkedList public list;

    // The result of the last function call
    uint public output;

    function CLLi()  
    {
        list.init(true);
    }
    
    /// @return Returns the node link data as a 3 element array
    function getNode(uint _nodeKey) public constant
        returns (uint[3])
    {
        return list.getNode(_nodeKey);
    }
    
    /// @notice Returns the next or previous node key from a given node key
    /// @param _nodeKey node to step from
    /// @param _dir direction of step. false=previous, true=next
    /// @return node key of neighbour
    function step(uint _nodeKey, bool _dir) public constant
        returns (uint)
    {
        return list.step(_nodeKey, _dir);
    }
    
    /// @notice Inserts a node between to existing nodes
    /// @param _key an existing node key
    /// @param _num the node key/dataIndex to insert
    /// @param _dir The direction links are to be created
    /// @dev _dir == false  Inserts new node BEFORE _nodeKey
    /// @dev _dir == true   Inserts new node AFTER _nodeKey
    function insert(uint _key, uint _num, bool _dir) public returns(uint)
    {
        output = list.insertNewNode(_key, _num, _dir);
        return output;
    }

    /// @notice Deletes a node and its data from the linked list
    /// @param _num The node to be deleted
    /// @return output The value previously stored     
    function remove(uint _num) public returns (uint)
    {
        output = list.remove(_num);
        return output;
    }   

    /// @notice Creates new node 'next' to the head
    /// @param _num index to be stored or used for key
    function push(uint _num) public returns (uint)
    {
        output = list.push(_num);
        return output;
    }
    
    /// @notice Deletes the node 'next' to the head
    /// @return The deleted node dataIndex/key value
    function pop() public returns (uint)
    {
        output = list.pop();
        return output;
    }

    /// @notice Creates new node 'previous' to the head
    /// @param _num index to be stored or used for key
    function pushTail(uint _num) public returns (uint)
    {
        output = list.pushTail(_num);
        return output;
    }
    
    /// @notice Deletes the node 'previous' to the head
    /// @return The deleted node dataIndex/key value
    function popTail() public returns (uint)
    {
        output = list.popTail();
        return output;
    }
}