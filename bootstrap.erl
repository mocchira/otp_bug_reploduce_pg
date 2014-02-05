#!/bin/env escript
%% -*- mode: erlang;erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ft=erlang ts=4 sw=4 et

-define(TEST_FILE_PATH,       "test.dat").
-define(TEST_FILE_SIZE,       8192).
-define(TEST_READ_BLOCK_SIZE, 1024 * 1024 * 1024 * 2).

main([]) ->
    io:format(user, "Usage: ./bootstrap (# of repeat)~n", []);
main([Arg1|_T]) ->
    %% arg1 is # of doing a random read operation
    NumRepeat = list_to_integer(Arg1),
    %% generate a test file
    Data = crypto:rand_bytes(?TEST_FILE_SIZE),
    file:write_file(?TEST_FILE_PATH, Data),
    {ok, IoDev} = file:open(?TEST_FILE_PATH, [read, raw, binary]),
    try
        random_read(NumRepeat, IoDev, <<>>)
    after
        file:close(IoDev)
    end,
    ok.

random_read(0, _, Acc) -> Acc;
random_read(N, IoDev, Acc) ->
    Offset = random:uniform(?TEST_FILE_SIZE - 1),
    NewAcc = case file:pread(IoDev, Offset, ?TEST_READ_BLOCK_SIZE) of
        {ok, Data} -> Data;
        eof -> <<>>;
        {error, Reason} -> 
            io:format(user, "[error] file read error:~p~n", [Reason]),
            Acc
    end,
    case N rem 8 of
        0 -> io:format(user, "[info] memory usages:~p~n", [erlang:memory()]);
        _ -> void
    end,
    random_read(N - 1, IoDev, NewAcc).
