oper('+').
oper('-').
oper('*').
oper('/').
oper('^').

% Для проверки операторов введены true предикаты
plus_oper('+').
minus_oper('-').
mltpl_oper('*').
div_oper('/').
pow_oper('^').

% Проверка числа  на четность
is_even(X):- X mod 2 =:= 0.

% Проверка двух элементов на числа
check_nums(A,B):- number(A), number(B).

% Конвертация трех элементов в новый вид: ('-', C) -> ('+', -C) и ('/', C) -> ('*', 1/C)
conv_AC([A,'-',C], Back):- C1 is -C, Back = [A,'+',C1].
conv_AC([A,'/',C], Back):- C1 is 1/C, Back = [A,'*',C1].

% Все арифметические операции операции для трех элементов
calc_2([A, '+', B], Back):- (check_nums(A,B) -> Back is A+B ; false).
calc_2([A, '-', B], Back):- (check_nums(A,B) -> Back is A-B ; false).
calc_2([A, '*', B], Back):- (check_nums(A,B) -> Back is A*B ; false).
calc_2([A, '/', B], Back):- (check_nums(A,B) -> Back is A/B ; false).
calc_2([A, '^', B], Back):- (check_nums(A,B) -> Back is A^B ; false).


% Ситуация для оператора '^'
calc_pow(Input, Input):- length(Input, 1).
calc_pow([A,B,C], Back):- (pow_oper(B) -> calc_2([A,B,C], Ans), Back = [Ans] ; Back = [A,B,C]).
calc_pow(Input, Back):-
	Input = [A,B,C|T],
	calc_pow([C|T], Back_new),
	(pow_oper(B)
		-> Back_new = [Bhead|Btail], calc_2([A,B,Bhead], Ans), Back = [Ans|Btail]
		; Back = [A,B|Back_new]).
/*
% Ситуация для оператора '/'
calc_div(Input, Input):- length(Input, 1).
calc_div([A,B,C], Back):- (div_oper(B) -> calc_2([A,B,C], Ans), Back = [Ans] ; Back = [A,B,C]).
calc_div(Input, Back):-
	Input = [A,B,C|T],
	calc_div([C|T], Back_new),
	(div_oper(B)
		-> Back_new = [Bhead|Btail], calc_2([A,B,Bhead], Ans), Back = [Ans|Btail]
		; Back = [A,B|Back_new]).
*/

% Конвертация делений в умножения
conv_div([A,B,C], Back):- (div_oper(B) -> conv_AC([A,B,C], Ans), Back = Ans ; Back = [A,B,C]).
conv_div(Input, Back):-
	Input = [A,B,C|T],
	conv_div([C|T], Back_new),
	(div_oper(B)
		-> Back_new = [Bhead|Btail], check_nums(A, Bhead), conv_AC([A,'/',Bhead], [A,B1,C1]), Back = [A,B1,C1|Btail]
		; Back = [A,B|Back_new]).

% Ситуация для оператора '*'
calc_mltpl(Input, Input):- length(Input, 1).
calc_mltpl([A,B,C], Back):- (mltpl_oper(B) -> calc_2([A,B,C], Ans), Back = [Ans] ; Back = [A,B,C]).
calc_mltpl(Input, Back):-
	Input = [A,B,C|T],
	calc_mltpl([C|T], Back_new),
	(mltpl_oper(B)
		-> Back_new = [Bhead|Btail], calc_2([A,B,Bhead], Ans), Back = [Ans|Btail]
		; Back = [A,B|Back_new]).

/*
% Ситуация для оператора '-'
calc_minus(Input, Input):- length(Input, 1).
calc_minus([A,B,C], Back):- (minus_oper(B) -> calc_2([A,B,C], Ans), Back = [Ans] ; Back = [A,B,C]).
calc_minus(Input, Back):-
	Input = [A,B,C|T],
	calc_minus([C|T], Back_new),
	(minus_oper(B)
		-> Back_new = [Bhead|Btail], calc_2([A,B,Bhead], Ans), Back = [Ans|Btail]
		; Back = [A,B|Back_new]).
*/

% Конвертация вычитаний в сложение
conv_minus([A,B,C], Back):- (minus_oper(B) -> conv_AC([A,B,C], Ans), Back = Ans ; Back = [A,B,C]).
conv_minus(Input, Back):-
	Input = [A,B,C|T],
	conv_minus([C|T], Back_new),
	(minus_oper(B)
		-> Back_new = [Bhead|Btail], check_nums(A, Bhead), conv_AC([A,'-',Bhead], [A,B1,C1]), Back = [A,B1,C1|Btail]
		; Back = [A,B|Back_new]).

% Ситуация для оператора '+'
calc_plus(Input, Input):- length(Input, 1).
calc_plus([A,B,C], Back):- (plus_oper(B) -> calc_2([A,B,C], Ans), Back = [Ans] ; Back = [A,B,C]).
calc_plus(Input, Back):-
	Input = [A,B,C|T],
	calc_plus([C|T], Back_new),
	(plus_oper(B)
		-> Back_new = [Bhead|Btail], calc_2([A,B,Bhead], Ans), Back = [Ans|Btail]
		; Back = [A,B|Back_new]).


% Расстановка уровней действий
calc_all(List, Ans):-
/* Сначала находятся все степени */
	calc_pow(List, NewList1),
/* Потом преобразование делений в умножения, поскольку работа со списком производится с его конца, а начинать делить с конца списка неправильно */
	conv_div(NewList1, NewList2),
/* Теперь перемножается все, что нужно */
	calc_mltpl(NewList2, NewList3),
/* Далее конвертируются все вычитания в сложения, по такой же причине, как у деления*/
	conv_minus(NewList3, NewList4),
/* И, наконец, сложение */
	calc_plus(NewList4, Ans).


calculate_switch(1, List, Ans):- number(Ans), List = [Ans].
calculate_switch(3, List, Ans):- calc_2(List, Ans).
calculate_switch(_, List, Ans):- calc_all(List, [Ans]).


% Итоговый предикат для нахождения значения выражения
calculate(List, Ans):-
	(compound(List)
		-> (length(List, Len), write('List length is: '), write(Len), nl, not(is_even(Len))
			-> (calculate_switch(Len, List, Ans)
				-> true
				; Ans = 'Bad input, try again!')
			; Ans = 'Bad input, try again!')
		; Ans = 'Bad input, try again!').

% То же самое, просто имя у предиката удобнее
calc(List, Ans):-
	(compound(List)
		-> (length(List, Len), write('List length is: '), write(Len), nl, not(is_even(Len))
			-> (calculate_switch(Len, List, Ans)
				-> true
				; Ans = 'Bad input, try again!')
			; Ans = 'Bad input, try again!')
		; Ans = 'Bad input, try again!').
