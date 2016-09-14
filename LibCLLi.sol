/*
file:   LibCLLi.sol
ver:    0.2.0-alpha
updated:28-Aug-2016
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

    string constant VERSION = "LibCLLi 0.2.0";
    uint constant NULL = 0;
    uint constant HEAD = NULL;
    bool constant PREV = false;
    bool constant NEXT = true;
    
    struct CLL{
        mapping (uint => mapping (bool => uint)) l;
    }

    // n: node id  d: direction  r: return node id

    function version() public constant returns (string) {
        return VERSION;
    }

    function exists(CLL storage self) internal constant returns (bool) {
        if (self.l[HEAD][NEXT] != NULL || self.l[HEAD][NEXT] != NULL)
            return true;
    }

    function getNode(CLL storage self, uint n)
        internal constant returns (uint[2])
    {
        return [self.l[n][PREV], self.l[n][NEXT]];
    }

    function step(CLL storage self, uint n, bool d)
        internal constant returns (uint)
    {
        return self.l[n][d];
    }

    // For ordered list only
    function seek(CLL storage self, uint n, bool d)
        internal constant returns (uint r)
    {
        r = step(self, HEAD, d);
        while  ((n!=r) && ((n < r) != d)) r = self.l[r][d];
        return;
    }

    function stitch(CLL storage self, uint a, uint b, bool d)  internal {
        self.l[b][!d] = a;
        self.l[a][d] = b;
    }

    function insert (CLL storage self, uint a, uint b, bool d) internal {
        uint c = self.l[a][d];
        stitch (self, a, b, d);
        stitch (self, b, c, d);
    }
    
    function remove(CLL storage self, uint n)  internal returns (uint) {
        if (n == NULL) return;
        stitch(self, self.l[n][PREV], self.l[n][NEXT], NEXT);
        delete self.l[n][PREV];
        delete self.l[n][NEXT];
        return n;
    }

    function push(CLL storage self, uint n, bool d) internal {
        insert(self, HEAD, n, d);
    }
    
    function pop(CLL storage self, bool d) internal returns (uint) {
        return remove(self, step(self, HEAD, d));
    }
}
