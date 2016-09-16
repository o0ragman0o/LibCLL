/*
file:   CLLi_Examples.sol
ver:    0.3.0
updated:16-Sep-2016
author: Darryl Morris
email:  o0ragman0o AT gmail.com

Some usage examples for a Solidity contract implementing the LibCLLi library.

This contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.
<http://www.gnu.org/licenses/>.
*/

pragma solidity ^0.4.0;

import 'LibCLLi.sol';

contract CLLi_Examples
{
/* Constants */

    uint constant HEAD = 0; // Lists are circular with static head.
    bool constant PREV = false;
    bool constant NEXT = true;
    uint constant MAXNUM = uint(-1); // 2**256 - 1
    
    // Allows us to use library functions as if they were members of the type.
    using LibCLLi for LibCLLi.CLL;

    // The circular linked list state variable.
    LibCLLi.CLL list;

 
    // As a Stack (FILO - first in, last out)
    function push(uint n) {
        list.push(n, NEXT); //pushes next to head
    }
    
    function pop() returns (uint) {
        return list.pop(NEXT); // pops next from head
    }
    
    // As a ring buffer (FIFO - first in, first out)
    function write(uint n) {
        list.push(n,PREV); // pushes previous to head
    }
    
    function read() returns (uint) {
        list.pop(NEXT); // pops next to head
    }
    
    // As an ordered list
    function initOrdered() {
        list.insert(HEAD, MAXNUM, PREV);
    }

    function ordered(uint n) {
        uint m = list.seek(HEAD, n, NEXT); // Find first number larger than n
        list.insert(m, n, PREV); // insert n before m
    }
    
    // As a mapping key store or lookup
    mapping (uint => address) map;
    
    function insert(uint id, address addr) {
        map[id] = addr;
        ordered(id); // from ordered list example
        }

    // As an iterator
    uint i;
    function next() returns (uint) {
        i = list.step(i, NEXT);
        return i;
    }
    
    function nextAddress() returns (address) {
        return map[next()];
    }
    
    // Get number of elements in list
    function sizeOf() returns (uint size_) {
        uint i = list.step(HEAD, NEXT);
        while (i != HEAD) {
            i = list.step(i, NEXT);
            size_++;
        }
    }
    
    // A soft reset can be quick but does not release state variables.
    function softReset() {
        list.remove(HEAD);
    }
    
    // A hard reset can clear all state variables but is prone to gas limits
    // for large lists and so may fail.
    function hardReset() returns (bool) {
        uint i = list.pop(NEXT);
        while (i != HEAD) i = list.pop(NEXT);
        return true;
    }
}