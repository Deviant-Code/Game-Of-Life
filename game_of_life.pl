% Conway's Game of Life, written in Prolog
% Written by Jesse Ericksen
% Western Washington University


% Runs Conway's Game Of Life
% Allows for any number of generations and any size
game(Gens,Size) :- 
	printGeneration(0),
	originBoard(Size,Board),
	generations(Board,Gens,Size,1).

% Wrapper for Generation 0
originBoard(Size,Board) :-
	buildBoard(Size,Size,Board),
	print_board(Board).

% Wrapper For Printing Subsequent Generations
generations(_,0,_,_).
generations(Board, Total_Gens, Size, GenNum):-
	Total_Gens > 0,
	printGeneration(GenNum),
	generationBoard(Board,Size,Size,New),
	print_board(New),
	New_Total is Total_Gens - 1, NextGenNum is GenNum + 1,
	generations(New, New_Total, Size,NextGenNum).

print_board([]).
print_board([Row|Rows]):-
  printRow(Row),nl,
  print_board(Rows).

printRow([]).
printRow([Val|List]):-
	write(Val),
	printRow(List).

%________________Generation Zero Methods___________________%
%    Build a randomized board (100x100) of 1's and 0's     %

%Builds Origin Board of Random State
buildBoard(0,_,[]).
buildBoard(RowCount,Size,Board):-
	RowCount > 0,
	Index is RowCount-1,
	buildRow(Size,Row),
	Board = [Row|Remainder],
	buildBoard(Index,Size,Remainder).

buildRow(0,[]).
buildRow(ColumnCount,Row) :-
	ColumnCount > 0, 
	Index is ColumnCount-1,
	random(0, 2, Rand),
	Row = [Rand|Remainder],
	buildRow(Index,Remainder).

%___________________GENERATION(X) METHODS___________________%
% Check Neighboring Cells and Adjust Game Board Accordingly %

printGeneration(I):-
	print_board([[],['***Generation ',I,'***'],[]]).

% Applies a new generation to a (N X N) Grid of any size
generationBoard(Board,0,_,Board).
generationBoard(Board, X, Size, New):-
	X > 0,
	RowIndex is X-1,
	generationRow(Board,RowIndex,Size,Board,NewUpdate),
	generationBoard(NewUpdate,RowIndex,Size,New).

% Applys new generation to a single row in grid
% CASE: Active Neighbors >= 5 
generationRow(Board,_,0,_,Board).
generationRow(UpdateBoard,X,Y,Board,New) :-
	Y > 0,
	Y1 is Y-1, 
	countActiveNeighbors(Board,X,Y1,Count),
	(Count > 4), 
	setCell(UpdateBoard,X,Y1,1, NewUpdate),
	generationRow(NewUpdate,X,Y1,Board, New).

% CASE: Active Neighbors < 5
generationRow(UpdateBoard,X,Y,Board, New) :-
    Y > 0, 
	Y1 is Y-1, 
	countActiveNeighbors(Board,X,Y1,Count),
	(Count < 5), 
	setCell(UpdateBoard,X,Y1,0,NewUpdate),
	generationRow(NewUpdate,X,Y1,Board, New).

countActiveNeighbors(Board,R1,C1,Count):- 
	R2 is R1-1, R3 is R1+1, % Neighboring Rows
	C2 is C1-1, C3 is C1+1, % Neighboring Columns
	getCell(Board,R1,C1,V1),getCell(Board,R1,C2,V2),getCell(Board,R1,C3,V3),
	getCell(Board,R2,C1,V4),getCell(Board,R2,C2,V5),getCell(Board,R2,C3,V6),
	getCell(Board,R3,C1,V7),getCell(Board,R3,C2,V8),getCell(Board,R3,C3,V9),
	Count is V1 + V2 + V3 + V4 + V5 + V6 + V7 + V8 + V9.

%________________Cell Getters and Setters___________________%

setCell(Board, RowIndex, ColumnIndex, Value, NewGrid):-
	nth0(RowIndex, Board, ChangeRow), % Obtains Row of Cell
	setCellInRow(ChangeRow,ColumnIndex,Value,NewRow),
	insertRow(Board,RowIndex,NewRow,NewGrid).

% Replaces element in a single dimensional list given index
setCellInRow([_|List], 0, Value, [Value|List]).
setCellInRow([H|List], Index, Value, [H|NewList]):-
	Index > 0,
	NI is Index -1,
	setCellInRow(List,NI,Value,NewList).

%Inserts a row into game board
insertRow([_|Board], 0, NewRow, [NewRow|Board]).
insertRow([H|Board], Index, NewRow, [H|NewBoard]):-
	Index > 0,
	NI is Index -1,
	insertRow(Board, NI,NewRow,NewBoard).

getCell(Board,RowIndex,ColumnIndex,Cell):-
	(RowIndex >= 0, ColumnIndex >= 0),
	nth0(RowIndex, Board, Row),
	nth0(ColumnIndex, Row, Cell).

%Override if cell is outside of grid
getCell(Board,RowIndex,ColumnIndex,Cell):-
	length(Board, L),
	(RowIndex < 0; ColumnIndex < 0; RowIndex >= L; ColumnIndex >= L),
	Cell is 0.

nth0(0, [Head|_], Head) :- !.
nth0(N, [_|Tail], Elem) :-
    nonvar(N),
    M is N-1,
    nth0(M, Tail, Elem).