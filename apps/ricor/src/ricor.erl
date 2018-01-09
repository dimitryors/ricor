-module(ricor).
%%
% Second file to change
%%
-include_lib("riak_core/include/riak_core_vnode.hrl").

% 1 Step, add new command to export
-export([
        ping/0,
        get/1,
        put/2
    ]).

-ignore_xref([
        ping/0,
        get/1,
        put/2
    ]).

%% Public API

% 2 Step, add new command to export
ping() ->
    % Register the operation in our metrics
    ricor_metrics:core_ping(),
    % Run ping command
    send_to_one({<<"ping">>, term_to_binary(os:timestamp())}, ping).

get(Key) ->
    ricor_metrics:core_get(),
    send_to_one(Key, {get, Key}).

put(Key, Value) ->
    ricor_metrics:core_put(),
    send_to_one(Key, {put, Key, Value}).


% private functions

send_to_one(Key, Cmd) ->
    % Ask for vnodes that can handle that hashed key
    DocIdx = riak_core_util:chash_key(Key),
    % Ask for a list of vnodes that can handle that hashed key
    PrefList = riak_core_apl:get_primary_apl(DocIdx, 1, ricor),
    % Get the vnode id and ignore the other part
    [{IndexNode, _Type}] = PrefList,
    % Get IndexNode back in the pong response
    riak_core_vnode_master:sync_spawn_command(IndexNode, Cmd, ricor_vnode_master).