/*
file:   LibCLLi.sol
ver:    0.3.0
updated:15-Sep-2016
author: Darryl Morris
email:  o0ragman0o AT gmail.com

A Solidity library for implementing a data indexing regime using
a circular linked list.

This library provisions lookup, navigation and key/index storage
functionality which can be used in conjunction with an array or mapping.

NOTICE: This library uses internal functions only and so cannot be compiled
and deployed independently from its calling contract.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.
<http://www.gnu.org/licenses/>.
*/

pragma solidity ^0.4.0;

library LibCLLi {

    string constant VERSION = "LibCLLi 0.3.0";
    uint constant NULL = 0;
    uint constant HEAD = NULL;
    bool constant PREV = false;
    bool constant NEXT = true;
    
    struct CLL{
        mapping (uint => mapping (bool => uint)) cll;
    }

    // n: node id  d: direction  r: return node id

    function version() internal constant returns (string) {
        return VERSION;
    }

    // Returns true if HEAD has a non-zero link.
    function exists(CLL storage self) internal constant returns (bool) {
        if (self.cll[HEAD][NEXT] != NULL || self.cll[HEAD][NEXT] != NULL)
            return true;
    }

    // Returns the links of a node as and array
    function getNode(CLL storage self, uint n)
        internal  constant returns (uint[2])
    {
        return [self.cll[n][PREV], self.cll[n][NEXT]];
    }

    // Returns the link of a node `n` in direction `d`.
    function step(CLL storage self, uint n, bool d)
        internal  constant returns (uint)
    {
        return self.cll[n][d];
    }

    // Can be used before `insert` to build an ordered list
    // `a` an existing node to search from, e.g. HEAD.
    // `b` value to seek
    // `r` first node beyond `b` in direction `d`
    function seek(CLL storage self, uint a, uint b, bool d)
        internal  constant returns (uint r)
    {
        r = step(self, a, d);
        while  ((b!=r) && ((b < r) != d)) r = self.cll[r][d];
        return;
    }

    // Creates a bidirectional link between two nodes on direction `d`
    function stitch(CLL storage self, uint a, uint b, bool d) internal  {
        self.cll[b][!d] = a;
        self.cll[a][d] = b;
    }

    // Insert node `b` beside and existing node `a` in direction `d`.
    function insert (CLL storage self, uint a, uint b, bool d) internal  {
        uint c = self.cll[a][d];
        stitch (self, a, b, d);
        stitch (self, b, c, d);
    }
    
    function remove(CLL storage self, uint n) internal returns (uint) {
        if (n == NULL) return;
        stitch(self, self.cll[n][PREV], self.cll[n][NEXT], NEXT);
        delete self.cll[n][PREV];
        delete self.cll[n][NEXT];
        return n;
    }

    function push(CLL storage self, uint n, bool d) internal  {
        insert(self, HEAD, n, d);
    }
    
    function pop(CLL storage self, bool d) internal returns (uint) {
        return remove(self, step(self, HEAD, d));
    }
}
