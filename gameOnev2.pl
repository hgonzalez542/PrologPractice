description(valley, 'You are in a pleasant valley, with a trail ahead.').
description(path, 'You are on a path, with ravines on both sides.').
description(cliff, 'You are teetering on the edge of a cliff.').
description(fork, 'You are at a fork in the path (go right or left).').
description(gate, 'You are at the gate, use open to move forward.').
description(maze(_), 'You are in a maze of twisty trails, all alike.').
description(mountaintop, 'You are on the mountaintop.').
description(key_room, 'You are in a room with a key.').
description(key_on_me, 'Now you have the key.').
description(secret_room, 'You are in the secret room containing the Book of Knowledge.').
description(book_on_me, 'You now have the Book of Knowledge.').

report :-
    at(you, X),
    description(X, Y),
    write(Y), nl.

connect(valley, forward, path).
connect(path, right, cliff).
connect(path, left, cliff).
connect(path, forward, fork).
connect(fork, left, maze(0)).
connect(fork, right, gate).
connect(gate, open, mountaintop).
connect(maze(0), left, maze(1)).
connect(maze(0), right, maze(3)).
connect(maze(1), left, maze(0)).
connect(maze(1), right, maze(2)).
connect(maze(2), left, key_room).
connect(key_room, pick_up, key_on_me).
connect(key_on_me, right, gate).
connect(maze(2), right, secret_room).
connect(secret_room, pick_up, book_on_me).
connect(secret_room, left, maze(2)). 
connect(maze(3), left, maze(0)).
connect(maze(3), right, maze(3)).

move(Dir) :-
    at(you, Loc),
    connect(Loc, Dir, Next),
    retract(at(you, Loc)),
    assert(at(you, Next)),
    report,
    !.

move(_) :-
    write('That is not a legal move.\n'),
    report.

forward :- move(forward).
left :- move(left).
right :- move(right).
open :- move(open).
pick_up :- move(pick_up).

drop :- 
    at(you, Loc),
    at(key, Loc),
    retract(at(key, Loc)), 
    write('You dropped the key.\n'), 
    !.

drop :- 
    at(you, Loc),
    at(book, Loc),
    retract(at(book, Loc)), 
    write('You dropped the Book of Knowledge.\n'), 
    !.

drop :-
    write('You have nothing to drop here.\n').

ogre :-
    at(ogre, Loc),
    at(you, Loc),
    write('An ogre sucks your brain out through\n'),
    write('your eyesockets, and you die.\n'),
    retract(at(you, Loc)),
    assert(at(you, done)),
    !.
ogre.

treasure :-
    at(treasure, Loc),
    at(you, Loc),
    at(book_on_me, Loc), % Player must have the book
    write('There is a treasure here.\n'),
    write('Congratulations, you win!\n'),
    retract(at(you, Loc)),
    assert(at(you, done)),
    !.
treasure :-
    at(you, Loc),
    at(treasure, Loc),
    write('You cannot claim the treasure without the Book of Knowledge.\n'),
    !.

cliff :-
    at(you, cliff),
    write('You fall off and die.\n'),
    retract(at(you, cliff)),
    assert(at(you, done)),
    !.
cliff.

gate :-
    at(you, gate),
    at(key_on_me, gate),
    write('You are struck by lightning for trying to pass the gate with the key!\n'),
    retract(at(you, gate)),
    assert(at(you, done)),
    !.
gate.

main :-
    at(you, done),
    write('Thanks for playing.\n'),
    !.

main :-
    write('\n Next move -- '),
    read(Move),
    call(Move),
    ogre,
    treasure,
    cliff,
    gate,
    main.

go :-
    retractall(at(_, _)), /* Clean up from previous runs */
    assert(at(you, valley)),
    assert(at(ogre, maze(3))),
    assert(at(treasure, mountaintop)),
    assert(at(key, key_room)),
    assert(at(book, secret_room)),
    write('This is an adventure game. \n'),
    write('Legal moves are: forward, left, right, open, pick_up, and drop.\n'),
    write('End each move with a period.\n\n'),
    report,
    main.
