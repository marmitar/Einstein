#!/usr/bin/env swipl
% PROBLEMA: https://vestibular1.com.br/testes/testes-divertidos/desafio-de-einstein/
% SOLUÇÃO: https://vestibular1.com.br/noticia/resposta-do-desafio-de-einstein/

%% Verdadeiro se X aparece ao lado de Y em Lista.
vizinho(X, Y, Lista) :- nextto(X, Y, Lista) ; nextto(Y, X, Lista).
%% Verdadeiro se Item é o elemento no meio em Lista
centro(Item, Lista) :- length(Lista, Tam), Meio is Tam div 2, nth0(Meio, Lista, Item).

% 00) Há cinco casas [...].
regra(=([_, _, _, _, _])).
% 01) O inglês vive na casa vermelha.
regra(member(casa(vermelha, mora: inglês, _, _, _))).
% 02) O sueco tem cachorros como animais de estimação.
regra(member(casa(_, mora: sueco, _, _, tem: cachorros))).
% 03) O dinamarquês bebe chá.
regra(member(casa(_, mora: dinamarquês, bebe: chá, _, _))).
% 04) A casa verde fica a esquerda da casa branca
regra(nextto(casa(verde, _, _, _, _), casa(branca, _, _, _, _))).
% 05) O dono da casa verde bebe café
regra(member(casa(verde, _, bebe: café, _, _))).
% 06) A pessoa que fuma Pall Mall cria pássaros
regra(member(casa(_, _, _, fuma: "Pall Mall", tem: pássaros))).
% 07) O dono da casa amarela fuma Dunhill
regra(member(casa(amarela, _, _, fuma: "Dunhill", _))).
% 08) O homem que vive na casa do centro bebe leite
regra(centro(casa(_, _, bebe: leite, _, _))).
% 09) O norueguês vive na primeira casa
regra(prefix([casa(_, mora: norueguês, _, _, _)])).
% 10) O homem que fuma blends vive ao lado do que tem gatos
regra(vizinho(casa(_, _, _, fuma: "Blend's", _), casa(_, _, _, _, tem: gatos))).
% 11) O homem que cria cavalos vive ao lado do que fuma Dunhill
regra(vizinho(casa(_, _, _, _, tem: cavalos), casa(_, _, _, fuma: "Dunhill", _))).
% 12) O homem que fuma Bluemaster bebe cerveja
regra(member(casa(_, _, bebe: cerveja, fuma: "Blue Master", _))).
% 13) O alemão fuma Prince
regra(member(casa(_, mora: alemão, _, fuma: "Prince", _))).
% 14) O norueguês vive ao lado da casa azul
regra(vizinho(casa(_, mora: norueguês, _, _, _), casa(azul, _, _, _, _))).
% 15) O homem que fuma Blend’s é vizinho do que bebe água
regra(vizinho(casa(_, _, _, fuma: "Blend's", _), casa(_, _, bebe: água, _, _))).
% Pergunta) Qual deles tem um PEIXE [...].
regra(member(casa(_, _, _, _, tem: peixes))).

%% Solução de casas para as regras.
casas(Casas) :- foreach(regra(Regra), call(Regra, Casas)).

:- initialization(main, main).

main :-
    Spec = [
        [opt(nocolor), type(boolean), default(false),
            shortflags([n]), longflags(['no-color']),
            help('Remove a cor para a linha da pergunta.')],
        [opt(oneline), type(boolean), default(false),
            shortflags([o]), longflags(['one-line']),
            help('Imprime apenas a linha da pergunta.')]
    ],
    opt_arguments(Spec, Opts, []),
    (member(nocolor(true), Opts) -> Color = false; Color = true),
    member(oneline(Skip), Opts),
    quadro(Color, Skip).

%% Impime uma linha da tabela.
linha(Casa, casa(Cor, mora: Pessoa, bebe: Bebida, fuma: Cigarro, tem: Animal), Fill) :-
    format("|~*t~w~*t~5+|~*t~w~*t~12+|~*t~w~*t~15+|~*t~w~*t~10+|~*t~w~*t~15+|~*t~w~*t~12+|~n",
        [Fill, Casa, Fill,
        Fill, Cor, Fill,
        Fill, Pessoa, Fill,
        Fill, Bebida, Fill,
        Fill, Cigarro, Fill,
        Fill, Animal, Fill]
    ).
%% Impime uma linha com conteúdo.
linha(Posicao, Casa) :-
    with_output_to(codes([Espaco], []), write(' ')),
    linha(Posicao, Casa, Espaco).
%% Impime uma linha de separação.
linha(fill: Fill) :-
    with_output_to(codes([FillCode], []), write(Fill)),
    linha('', casa('', mora: '', bebe: '', fuma: '', tem: ''), FillCode).

%% Faz a saída pro terminal, se skip: false.
saida(_, skip: true, color: _).
saida(Goal, skip: false, color: false) :- call(Goal).
saida(Goal, skip: false, color: true) :-
    with_output_to(string(Texto), Goal),
    ansi_format([bold, fg(red)], "~w", [Texto]).

%% Monta o quadro com a saída.
quadro(Color, Skip) :-
    casas(Casas),
    saida(linha(fill: '-'), skip: Skip, color: false),
    saida(linha("Casa", casa("Cor", mora: "Nacional.", bebe: "Bebida", fuma: "Cigarro", tem: "Animal")), skip: Skip, color: false),
    saida(linha(fill: '-'), skip: Skip, color: false),
    forall(nth1(Posicao, Casas, Casa),
        Casa = casa(_, _, _, _, tem: peixes)
        -> saida(linha(Posicao, Casa), skip: false, color: Color)
        ; saida(linha(Posicao, Casa), skip: Skip, color: false)
    ),
    saida(linha(fill: '-'), skip: Skip, color: false).
