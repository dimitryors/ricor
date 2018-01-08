-module(ricor_metrics).
-export([all/0, init/0]).

-export([core_ping/0]).

% -define(ENDPOINTS, [<<"ping">>]).
-define(ENDPOINTS, [<<"ping">>, <<"metrics">>]).
-define(METRIC_CORE_PING, [ricor, core, ping]).

all() ->
 [
    {ricor, ricor_stats()},
    {http, cowboy_exometer:stats(?ENDPOINTS)},
    {node, node_stats()},
    {core, core_stats()}
  ].

core_stats() -> [{ping, unwrap_metric_value(?METRIC_CORE_PING)}].

node_stats() ->
    [{Abs1, Inc1}] = recon:node_stats_list(1, 0),
    [{abs, Abs1}, {inc, Inc1}].

core_ping() -> exometer:update(?METRIC_CORE_PING, 1).

init() ->
    cowboy_exometer:init(?ENDPOINTS),
    exometer:new(?METRIC_CORE_PING, spiral, [{time_span, 60000}]).

ricor_stats() ->
    Stats = riak_core_stat:get_stats(),
    lists:map(fun metric_key_to_string/1, Stats).

metric_key_to_string({K, V}) ->
    StrKeyTokens = lists:map(fun to_string/1, tl(tl(K))),
    StrKey = string:join(StrKeyTokens, "_"),
    BinKey = list_to_binary(StrKey),
    {BinKey, V}.

to_string(V) when is_atom(V) -> atom_to_list(V);
to_string(V) when is_integer(V) -> integer_to_list(V);
to_string(V) when is_binary(V) -> binary_to_list(V);
to_string(V) when is_list(V) -> V.

unwrap_metric_value(Key) ->
    case exometer:get_value(Key) of
        {ok, Val} -> Val;
        Other -> 
            lager:warning("Error getting endpoint value ~p: ~p",
                          [Key, Other]),
            []
    end.