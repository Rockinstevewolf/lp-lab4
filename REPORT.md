#№ Отчет по лабораторной работе №4
## по курсу "Логическое программирование"

## Обработка естественного языка

### студент: Баранников С.А.

## Результат проверки

| Преподаватель     | Дата         |  Оценка       |
|-------------------|--------------|---------------|
| Сошников Д.В. |              |               |
| Левинская М.А.|   16/12      |      3        |

> *Комментарии проверяющих (обратите внимание, что более подробные комментарии возможны непосредственно в репозитории по тексту программы)*


## Введение

Какие подходы обычно применяются для обработки естественных и искусственных языков?

Наиболее распространенным методом, на мой взгляд, является определение некоего "алфавита" для вида данных, с котором требуется работать, то есть определить атомарные элементы, при обращении к которым мы будем получать обратно true.

Почему Prolog оказывается удобным языком для решения таких задач?

Насколько я понял, как раз основной методикой работы с данными в Prolog зачастую является определение начальных предикатов, работающих с минимальным объемом данных, чтобы на этом построить основное решение.

## Задание

3. Реализовать синтаксический анализатор арифметического выражения и вычислить его числовое значение. В выражении допустимы операции `+, -, *, /, степень ^`. Учитывать приоритеты операций.

**Запрос:**
```Prolog
?- calculate([5,+,3,^,2],X).
X = 14.
```

## Принцип решения

Итак, сначала определим операции, связанные с минимально возможным количеством элементов списка:
```Prolog
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
```
Далее применим данные предикаты внутри более сложных:
```Prolog
% Ситуация для оператора '^'
calc_pow(Input, Input):- length(Input, 1).
calc_pow([A,B,C], Back):- (pow_oper(B) -> calc_2([A,B,C], Ans), Back = [Ans] ; Back = [A,B,C]).
calc_pow(Input, Back):-
	Input = [A,B,C|T],
	calc_pow([C|T], Back_new),
	(pow_oper(B)
		-> Back_new = [Bhead|Btail], calc_2([A,B,Bhead], Ans), Back = [Ans|Btail]
		; Back = [A,B|Back_new]).

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
```
Для прохождения по списку используется хвостовая рекурсия, с вызовом рекурсии до совершения простейших действий с элементами списка, т.е. любая обработка происходит с конца.
Таким образом, отдельно определены операции степени, умножения и суммы везде, где они встречаются в списке справа-налево, поэтому в процессе решения также требуется сконвертировать разности в суммы и деления в умножения чисел, что реализовано таким же образом.

И, наконец, определим порядок операций, switch состояния, а также проверку на исключения и соберем программы в один общий предикат `calculate/2` или же `calc/2`:
```Prolog
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
```
## Результаты

```Prolog
?- calc([asdasd],X).
List length is: 1
X = 'Bad input, try again!'.

?- calc([asdasd],X).
List length is: 1
X = 'Bad input, try again!'.

?- calc([6,+,adf],X).
List length is: 3
X = 'Bad input, try again!'.

?- calc([],X).
X = 'Bad input, try again!'.

?- calc([6,+,adf],X).
List length is: 3
X = 'Bad input, try again!'.

?- calc([asdasd],X).
List length is: 1
X = 'Bad input, try again!'.

?- calculate([1000000000,a,f],X).
List length is: 3
X = 'Bad input, try again!'.

?- calculate([1000000000,*,5],X).
List length is: 3
X = 5000000000.

?- calculate([10,*,5,^,6,-,15,+,30,/,5,/,3,-,2,-,4,+,25,^,2,*,10],X).
List length is: 23
X = 162481.0.

?- calculate([1000000000,*,5],X).
List length is: 3
X = 5000000000.

?- calculate([10,*,5,^,6,-,15,+,30,/,5,/,3,-,2,-,4,+,25,^,2,*,10],X).
List length is: 23
X = 162481.0.

?- calculate([10,*,5,^,6,-,15,+,30,/,5,/,3,-,asdf,-,4,+,25,^,2,*,10],X).
List length is: 23
X = 'Bad input, try again!'.

?- calculate([10,*,5,^,6,-,15,+,30,/,5,/,3,asdf,6,-,4,+,25,^,2,*,10],X).
List length is: 23
X = 'Bad input, try again!'.

?- calculate([5,+,3,^,2],X).
List length is: 5
X = 14.
```

## Выводы

Очень интересная лабораторная работа и, особенно, задание. В данной лабораторной работе я получил возможность применить все прежде накопленные знания от предыдущих работ.
Мой метод работы с арифметическим выражением идет посредством продуманной заранее логики решения действий, в то время как создание дерева может упростить работу с выражением

- Удобным ли оказывается Пролог для решения задач грамматического разбора? Почему?

Как раз именно Prolog является, на мой взгляд, самым удобным языком для решения такого типа задач, поскольку он работает на основе правдивых и ложных утверждений и такое устройство позволяет определить истинностные утверждения, которые ни с чем не спутаешь, а так же определить методы по их обработке.
