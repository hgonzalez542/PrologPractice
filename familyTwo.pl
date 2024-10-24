parent(john, mary).
parent(john, tom).
parent(susan, mary).
parent(susan, tom).
parent(mary, bob).
parent(mary, alice).
parent(tom, jim).
parent(tom, kate).

female(susan).
female(mary).
female(alice).
female(kate).

male(john).
male(tom).
male(bob).
male(jim).

mother(X, Y) :- parent(X, Y), female(X).
father(X, Y) :- parent(X, Y), male(X).