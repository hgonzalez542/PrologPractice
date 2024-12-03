description(valley, 'You are in a pleasant valley, with a trail ahead.').
description(path, 'You are on a path, with ravines on both sides.').
description(cliff, 'You are teetering on the edge of a cliff.').
description(fork, 'You are at a fork in the path (go right or left).').
description(gate, 'You are at the gate, use open to move forward.').
description(maze(_), 'You are in a maze of twisty trails, all alike.').
description(mountaintop, 'You are on the mountaintop.').
description(key_room, 'You are in a room with a key.').
description(secret_room, 'You are in the secret room. There is a Book of Knowledge here.').
description(holding_key, 'You are holding the key.').
description(holding_book, 'You are holding the Book of Knowledge.').

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
connect(key_room, right, maze(2)).
connect(key_room, pick_up, holding_key).
connect(maze(2), secret, secret_room).
connect(secret_room, pick_up, holding_book).
connect(maze(2), right, maze(0)).
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
secret :- move(secret).
pick_up :- move(pick_up).
drop :- write('You drop an item.\n').

pick_up_key :-
    at(you, key_room),
    retract(at(key, key_room)),
    assert(at(you, holding_key)),
    write('You pick up the key.\n'),
    move(right).

pick_up_book :-
    write('You pick up the Book of Knowledge.\n'),
    retract(at(book, secret_room)),
    assert(at(you, holding_book)).

put_down_key :-
    at(you, gate),
    at(you, holding_key),
    write('You put down the key.\n'),
    retract(at(you, holding_key)),
    assert(at(key, gate)).

use_key :-
    at(you, gate),
    at(you, holding_key),
    write('You open the gate.\n'),
    retract(at(you, holding_key)),
    retract(at(key, gate)),
    !.

use_key :-
    write('You do not have the key to open the gate.\n').

pass_through_gate :-
    at(you, gate),
    \+ at(you, holding_key),
    write('You pass through the gate.\n'),
    move(forward).

pass_through_gate :-
    at(you, holding_key),
    write('You are struck by lightning for holding the key while passing the gate.\n'),
    retract(at(you, gate)),
    assert(at(you, done)).

treasure :-
    at(treasure, mountaintop),
    at(you, mountaintop),
    at(you, holding_book),
    write('You find the treasure and claim it with the Book of Knowledge! You win!\n'),
    retract(at(you, mountaintop)),
    assert(at(you, done)),
    !.

treasure :-
    at(treasure, mountaintop),
    at(you, mountaintop),
    \+ at(you, holding_book),
    write('You need the Book of Knowledge to claim the treasure.\n').

report :-
    at(you, X),
    description(X, Y),
    write(Y),
    nl.

ogre :-
    at(ogre, Loc),
    at(you, Loc),
    write('An ogre attacks you and you die.\n'),
    retract(at(you, Loc)),
    assert(at(you, done)),
    !.

ogre.

go :-
    retractall(at(_, _)),
    assert(at(you, valley)),
    assert(at(ogre, maze(3))),
    assert(at(key, key_room)),
    assert(at(book, secret_room)),
    assert(at(treasure, mountaintop)),
    write('This is an upgraded adventure game.\n'),
    write('Legal moves are forward, left, right, open, secret, pick_up, and drop.\n'),
    write('End each move with a period.\n\n'),
    report,
    main.

main :-
    at(you, done),
    write('Thanks for playing.\n'),
    !.

main :-
    write('\nNext move -- '),
    read(Move),
    call(Move),
    ogre,
    treasure,
    main.