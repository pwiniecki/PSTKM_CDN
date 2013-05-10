#Model for 'CDN allocation copies' problem

#sets
#-------------------------------------------------------------------------------------
set K;              #index of nodes with group of clients
set N;              #nodes
set E;              #edges
set O;              #objects

#parameters
#-------------------------------------------------------------------------------------
param d {K,O};      #demands for object o
param t {K,O} symbolic;     #destination nodes
param r {N,K} binary;       #1 if node n is ancestor of node k, 0 otherwise

param a {N,E} binary;       #1 if edge begins in vertex, 0 otherwise
param b {N,E} binary;       #1 if edge ends in vertex, 0 otherwise

param c {E};        #cost of using an edge
param Hmax;         #available capacity for allocation object in proxy servers

#variables
#-------------------------------------------------------------------------------------
var f {N,O} binary;         #1 if object saved at node k, 0 otherwise
var x {E,K,O};              #value of the demand realised over edge for object

#goal function
#-------------------------------------------------------------------------------------
#The function minimizes cost of routing
#By saving copies at CDN proxies we minimizing all traffic from all demands
#with all objects
minimize goal:
    sum{e in E}
    sum{k in K}
    sum{o in O}
        (x[e,k,o]*c[e]);
        
#constraints
#-------------------------------------------------------------------------------------
subject to c0 {e in E, k in K, o in O}:
    x[e,k,o]>=0;

subject to c1a {k in K, o in O, n in N: n!=t[k,o]}:
(if (r[n,k]==1 and f[n,o]==1) then
sum{e in E}
    (a[n,e]*x[e,k,o]) -
sum{e in E}
    (b[n,e]*x[e,k,o]) =
                 d[k,o]*(1-f[k,o]));

subject to c1b {k in K, o in O, n in N: n!=t[k,o]}:
(if (r[n,k]!=1 or f[n,o]!=1) then
sum{e in E}
    (a[n,e]*x[e,k,o]) -
sum{e in E}
    (b[n,e]*x[e,k,o]) =
                 0);
                            
subject to c1c {k in K, o in O, n in N: n==t[k,o]}:
sum{e in E}
    (a[n,e]*x[e,k,o]) -
sum{e in E}
    (b[n,e]*x[e,k,o]) =
                            -d[k,o]*(1-f[k,o]);
                            
subject to c2:
sum{k in K}
sum{o in O}
    f[k,o] <= Hmax;

subject to c3 {k in K, o in O}:
sum{n in N}
    r[n,k]*f[n,o] <= 1;

subject to c4 {o in O}:
    f[1,o]=1;