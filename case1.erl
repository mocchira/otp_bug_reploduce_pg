#!/bin/env escript
%% -*- mode: erlang;erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ft=erlang ts=4 sw=4 et

-define(TEST_FILE_PATH,       "test.dat").
-define(TEST_FILE_SIZE,       8192).

main([]) ->
    io:format(user, "Usage: case1 (read bytes)~n", []);
main([Arg1|_T]) ->
    ReadBytes = list_to_integer(Arg1),
    Data = crypto:rand_bytes(?TEST_FILE_SIZE),
    file:write_file(?TEST_FILE_PATH, Data),
    {ok, IoDev} = file:open(?TEST_FILE_PATH, [read, raw, binary]),
    try
        exec(IoDev, ReadBytes)
    after
        file:close(IoDev)
    end,
    ok.

exec(IoDev, ReadBytes) ->
    Offset = random:uniform(?TEST_FILE_SIZE - 1),
    try
        case file:pread(IoDev, Offset, ReadBytes) of
            {ok, Data} -> {ok, Data};
            eof -> ok;
            {error, Reason} -> 
                io:format(user, "[error] file read error:~p~n", [Reason]),
                exit(Reason)
        end
    after 
        io:format(user, "[info] memory usages:~p~n", [erlang:memory()])
    end.
