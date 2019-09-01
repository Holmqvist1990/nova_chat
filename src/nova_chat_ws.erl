-module(nova_chat_ws).

-export([init/1,
	 websocket_init/1,
	 websocket_handle/2,
	 websocket_info/2,
	 terminate/3]).

init(Req) ->
    #{bindings := UserMap} = Req,
    {ok, UserMap}.

websocket_init(State) ->
    #{user := User} = State,
    ok = nova_pubsub:online(User, self()),
    {ok, State}.

websocket_handle({text, Message}, State) ->
    Decode = jsone:decode(Message),
    #{user := User} = State,
    #{<<"topic">> := Topic} = Decode,
    ok = nova_pubsub:publish(Topic, jsone:encode(Decode#{<<"user">> => User})),
    {ok, State}.

websocket_info(Payload,State) ->
    {reply, {text, Payload}, State}.

terminate(_, _, State)->
    #{user := User} = State,
    ok = nova_pubsub:offline(User, self()).

 	    