# Beambridge #

https://github.com/mathieul/beambridge

Fork of Erlectricity by Scott Fleckenstein, Tom Preston-Werner (http://github.com/mojombo/erlectricity).

The original erlectricity gem doesn't seem to be supported and updated anymore,
no commit in 4 years, a pull request pending for the last 3 years.

So I've forked the repository origin of the pending pull request and did cherry pick
most of the pull request commits. And I had to rename the gem so I could publish it.

Development Status: port for 1.9.3, 2.0.x, 2.1.x in progress


Description
-----------

Beambridge allows a Ruby program to receive and respond to Erlang messages
sent over the Erlang binary protocol.


Install
-------

$ gem install beambridge


The Simplest Example
--------------------

### Ruby side (echo.rb)

    require 'beambridge'

    receive do |f|
      f.when([:echo, String]) do |text|
        f.send!([:result, "You said: #{text}"])
        f.receive_loop
      end
    end

### Erlang side (echo.erl)

    -module(echo).
    -export([test/0]).

    test() ->
      Cmd = "ruby echo.rb",
      Port = open_port({spawn, Cmd}, [{packet, 4}, nouse_stdio, exit_status, binary]),
      Payload = term_to_binary({echo, <<"hello world!">>}),
      port_command(Port, Payload),
      receive
        {Port, {data, Data}} ->
          {result, Text} = binary_to_term(Data),
          io:format("~p~n", [Text])
      end.


Data Type Conversions and Matching
----------------------------------

    % Port is the port opened via open_port({spawn, Cmd}, [{packet, 4}, ...])
    % Message is the Erlang term to encode and send to the port
    send(Port, Message) ->
      port_command(Port, term_to_binary(Message)).

    # Each triplet below represents:
    # (line 1) the Erlang call
    # (line 2) the Ruby matcher
    # (line 3) the Ruby output

    send(Port, test).
    f.when(:test) { p :ok }
    # :ok

    send(Port, {atom, symbol}).
    f.when([:atom, Symbol]) { |sym| p sym }
    # :symbol

    send(Port, {number, 1}).
    f.when([:number, Fixnum]) { |num| p num }
    # 1

    send(Port, {string, <<"foo">>}).
    f.when([:string, String]) { |str| p str }
    # "foo"

    send(Port, {array, [1,2,3]}).
    f.when([:array, Array]) { |arr| p arr }
    # [1, 2, 3]

    send(Port, {array, [<<"abc">>, <<"def">>]}).
    f.when([:array, Array]) { |arr| p arr }
    # ["abc", "def"]

    send(Port, {hash, [{key,val}]}).
    f.when([:hash, Erl.hash]) { |hash| p hash }
    # {:key=>:val}

    send(Port, {object, {1,{2},3,<<"four">>}}).
    f.when([:object, Any]) { |any| p any }
    # [1, [2], 3, "four"]


Contribute
----------

If you'd like to hack on Beambridge, start by forking my repo on GitHub:

https://github.com/mathieul/beambridge

To get all of the dependencies, install the gem first. The best way to get
your changes merged back into core is as follows:

1. Clone down your fork
1. Create a topic branch to contain your change
1. Hack away
1. Add tests and make sure everything still passes by running `rake`
1. If you are adding new functionality, document it in the README.md
1. Do not change the version number, I will do that on my end
1. If necessary, rebase your commits into logical chunks, without errors
1. Push the branch up to GitHub
1. Send me (mojombo) a pull request for your branch


Copyright
---------

Copyright (c) 2009 Scott Fleckenstein and Tom Preston-Werner. See LICENSE for details.
