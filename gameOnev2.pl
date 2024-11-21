description(valley, 'You are in a pleasant valley, with a trail ahead.').
description(path, 'You are on a path, with ravines on both sides.').
description(cliff, 'You are teetering on the edge of a cliff.').
description(fork, 'You are at a fork in the path (go right or left).').
description(gate, 'You are at a gate; use "open" to move forward.').
description(maze(_), 'You are in a maze of twisty trails, all alike.').
description(mountaintop, 'You are on the mountaintop.').
description(key_room, 'You are in a room with a key.').
description(secret_room, 'You are in a secret room containing the Book of Knowledge.'). % (a) Secret room description added.
description(book_on_me, 'You now have the Book of Knowledge.').
description(key_on_me, 'You now have the key.').

report :-
    at(you, X),
    description(X, Desc),
    write(Desc), nl.

connect(valley, forward, path).
connect(path, right, cliff).
connect(path, left, cliff).
connect(path, forward, fork).
connect(fork, left, maze(0)).
connect(fork, right, gate).
connect(gate, open, mountaintop) :- fail_gate_check. % (c) Gate check for holding key added.
connect(maze(0), left, maze(1)).
connect(maze(0), right, maze(3)).
connect(maze(1), left, maze(0)).
connect(maze(1), right, maze(2)).
connect(maze(2), left, key_room).
connect(key_room, pick_up, key_on_me).
connect(maze(2), right, secret_room). % (a) Connection to secret room added.
connect(secret_room, pick_up, book_on_me). % (b) Book of Knowledge in secret room.

% Ensure player has Book of Knowledge before winning treasure.
connect(mountaintop, forward, treasure) :- at(you, book_on_me). 

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

fail_gate_check :-
    at(you, gate),
    at(you, key_on_me),
    write('Lightning strikes! You are killed for trying to pass the gate while holding the key.\n'),
    retract(at(you, gate)),
    assert(at(you, done)),
    !, fail. % (c) Prevent player from moving if struck by lightning.
fail_gate_check :-
    true. % Allow movement if player is not holding the key.

drop :-
    at(you, key_on_me),
    retract(at(you, key_on_me)),
    assert(at(key, gate)),
    write('You have dropped the key.\n'),
    report,
    !.
drop :-
    at(you, book_on_me),
    retract(at(you, book_on_me)),
    assert(at(book, gate)),
    write('You have dropped the Book of Knowledge.\n'),
    report,
    !.
drop :-
    write('You are not holding anything to drop.\n'),
    report.

forward :- move(forward).
left :- move(left).
right :- move(right).
open :- move(open).
pick_up :- move(pick_up).
drop :- drop.

ogre :-
    at(ogre, Loc),
    at(you, Loc),
    write('An ogre sucks your brain out through your eye sockets, and you die.\n'),
    retract(at(you, Loc)),
    assert(at(you, done)),
    !.
ogre.

cliff :-
    at(you, cliff),
    write('You fall off and die.\n'),
    retract(at(you, cliff)),
    assert(at(you, done)),
    !.
cliff.

treasure :-
    at(treasure, Loc),
    at(you, Loc),
    \+ at(you, book_on_me), % (d) Check if player lacks the Book of Knowledge.
    write('You reach the treasure, but you lack the Book of Knowledge! You lose.\n'),
    retract(at(you, Loc)),
    assert(at(you, done)),
    !.
treasure :-
    at(treasure, Loc),
    at(you, Loc),
    at(you, book_on_me), % (d) Check if player has the Book of Knowledge.
    write('There is a treasure here.\n'),
    write('Congratulations, you win!\n'),
    retract(at(you, Loc)),
    assert(at(you, done)),
    !.
treasure.

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
    cliff,
    main.

go :-
    retractall(at(_, _)), /* clean up from previous runs */
    assert(at(you, valley)),
    assert(at(ogre, maze(3))),
    assert(at(treasure, mountaintop)),
    write('This is an adventure game.\n'),
    write('Legal moves are left, right, forward, open, pick_up, and drop.\n'),
    write('End each move with a period.\n\n'),
    report,
    main.
