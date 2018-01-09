-module(ricor_metrics).

%%
% First file to change
%%
-export([all/0, init/0]).
% 5 step
-export([
        core_ping/0,
        core_put/0,
        core_get/0,
        core_delete/0
    ]).

% -define(ENDPOINTS, [<<"ping">>]).
-define(ENDPOINTS, [<<"ping">>, <<"metrics">>]).
% 1 step
-define(METRIC_CORE_PING, [ricor, core, ping]).
-define(METRIC_CORE_PUT, [ricor, core, put]).
-define(METRIC_CORE_GET, [ricor, core, get]).
-define(METRIC_CORE_DELETE, [ricor, core, delete]).

all() ->
 [
    {ricor, ricor_stats()},
    {http, cowboy_exometer:stats(?ENDPOINTS)},
    {node, node_stats()},
    {core, core_stats()}
  ].

core_stats() -> [
        % 2 step
        {ping, unwrap_metric_value(?METRIC_CORE_PING)},
        {put, unwrap_metric_value(?METRIC_CORE_PUT)},
        {get, unwrap_metric_value(?METRIC_CORE_GET)},
        {delete, unwrap_metric_value(?METRIC_CORE_DELETE)}
    ].

node_stats() ->
    [{Abs1, Inc1}] = recon:node_stats_list(1, 0),
    [{abs, Abs1}, {inc, Inc1}].

% 3 step
core_ping() -> exometer:update(?METRIC_CORE_PING, 1).
core_put() -> exometer:update(?METRIC_CORE_PUT, 1).
core_get() -> exometer:update(?METRIC_CORE_GET, 1).
core_delete() -> exometer:update(?METRIC_CORE_DELETE, 1).
  

init() ->
    cowboy_exometer:init(?ENDPOINTS),
    % 4 step
    exometer:new(?METRIC_CORE_PING, spiral, [{time_span, 60000}]),
    exometer:new(?METRIC_CORE_PUT, spiral, [{time_span, 60000}]),
    exometer:new(?METRIC_CORE_GET, spiral, [{time_span, 60000}]),
    exometer:new(?METRIC_CORE_DELETE, spiral, [{time_span, 60000}]).


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