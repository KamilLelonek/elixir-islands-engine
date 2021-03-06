# IslandsEngine

[![Build Status](https://travis-ci.org/KamilLelonek/elixir-islands-engine.svg?branch=master)](https://travis-ci.org/KamilLelonek/elixir-islands-engine)

This project is the `Elixir` representation of _The Game of Islands_.

# Description

It’s a **game** for two **players**, and each player has a **board** which consists of a grid of one hundred **coordinates**. The grid is labeled with the letters `a` through `j` going down the left side of the board and the numbers `1` through `10` across the top. We name individual coordinates with a letter-number combination like `a1`, `j5`, `d10`, and so on.

<p align="center">
	<img width="300" src="https://monosnap.com/file/zOHmExv51fY7NxB0Tn5bqLaVLgycTC.png">
</p>

The players cannot see each other’s boards.

The players have matching **sets of islands** of various shapes and sizes which they place on their own boards. The players can move the islands around as much as they like until they say that they are set. After that, the islands must stay where they are for the rest of the Game.


Once both players have set their islands, they take turns guessing coordinates on their opponent’s board, trying to find the islands. For every correct guess, we plant a palm tree on the island at that coordinate. When all the coordinates for an island have palm trees, the island is forested.

The first player to forest all their opponent’s islands is the winner.

# Dependencies

Make sure you have `Elixir` installed. You need to grab two libs:

    Erlang >= 19.3
    Elixir >= 1.4.2

## Ubuntu

You can use Erlang Solution's repositories to install Erlang & Elixir:

    $ wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
    $ sudo dpkg -i erlang-solutions_1.0_all.deb
    $ sudo apt-get update
    $ sudo apt-get install -y esl-erlang
    $ sudo apt-get install -y elixir

## MacOS

To install `Elixir` and `Erlang` you need to use `Homebrew`.
Once you have `brew` command available, you can do:

    brew install erlang elixir

# Components

In the `Game` we defined a couple of components. They are basically structs created in order to play the `Game` and manage a state. They are as follows:

## Coordinate

<p align="center">
	<img width="300" src="https://monosnap.com/file/fIVQmIFoM3NLBBnOEK92pvHUdOQDnF.png">
</p>

`Coordinates` hold the majority of the state we need to play the `Game`. `Coordinates` are the core entities with which we’ll compose the others in Islands. `Coordinate` really only needs to keep track of two things:

- whether the `Coordinate` is part of an `Island` (`in_island`),
- and whether a `Player` has guessed it (`guessed?`).

A new `Coordinate` struct will not be in any `Island`, and neither `Player` will have guessed it. That means the default values should be `:none` for the `:in_island`, and `false` for `:guessed?`.

Moreover, a `Coordinate` won’t need to keep track of which position it occupies on the `Board`. The `Board` itself will take care of that mapping.

## Island

<p align="center">
	<img width="200" src="https://monosnap.com/file/dR8I362i2G6oGU9uW79WwcgDz8kyod.png">
</p>

An `Island` is made of a list of `Coordinates`.

At the beginning of the `Game`, `Players` will not have placed their `Islands` on the `Board`, so the `Islands` won’t have any `Coordinates`.

When a `Player` does place an `Board` on the `Board`, the game will need to associate the `Coordinates` the `Island` occupies on the `Board` with the `Island`. If a `Player` moves an `Island`, the game will need to disassociate it from the `Coordinates` it used to have, and re-associate it with the new ones it lands on.

<p align="center">
	<img width="300" src="https://monosnap.com/file/P7A0Zoj2Qr3fxp5HdHTHyPFglgDiUS.png">
</p>


Besides keeping track of its `Coordinates`, an `Island` needs to be able to tell us whether or not it is forested. An `Island` can decide whether it is forested by asking each of it’s `Coordinates` if it is hit (if they are located in `Island` and guessed). When they are all hit, the `Island` is forested, otherwise not.

## IslandSet

<p align="center">
	<img src="https://monosnap.com/file/0V315siCaadhReY1VNuNm2pqtCq4Gu.png">
</p>

An `IslandSet` will have one each of five different `Island` shapes: an *atoll*, a *dot*, an *l-shape*, an *s-shape*, and a *square*.

	+---+        +        +---+  +------+
	|   |        |        |      |------|
	|   |   +    |        +---+  |------|
	|   |        |            |  |------|
	+---+        +---+    +---+  +------+

	atoll  dot  l-shape  s-shape  square

## Board

<p align="center">
	<img width="300" src="https://monosnap.com/file/sLIVGFDLC8dhyfxEizycTbS7gA4fyk.png">
</p>

A `Board` is made of a map of `Islands` which acts as an organizer. A `Board` is a grid of a hundred named boxes. We hold the state of each named box in a `Coordinate`. We model the `Board` in such a way that we can reference each `Coordinate` by the letter-number name of the box they represent so that we can read and manipulate the state of any box.

`Boards` have many `Coordinates` and a `Coordinate` belong to a `Board`.

<p align="center">
	<img width="300" src="https://monosnap.com/file/fPHCLhUdc3eXWICLs3lV85BMYCU0Zb.png">
</p>

We don’t need to make each `Coordinate` store its name when only the `Board` needs it. We can keep `Coordinates` slim and only add the name in the context that it’s needed, the `Board`. The `Board` will provide a way for the rest of the `Game` to interact with individual `Coordinates` by name. This makes a `Board` the de facto interface for individual `Coordinates`.

## Player

<p align="center">
	<img width="200" src="https://monosnap.com/file/Yo0AEnctC1FwizEEkdQdtcLUeMIY0T.png">
</p>

The `Game` requires two `Players`, and that each `Player` will have a `Board` and a set of `Islands`. A `Player` should also have a `name` to display on screen.

## Summary

We’ve built up a tree structure with a `Player` at the root. One path goes through a `Board` to a map of `Coordinates`. The other goes through an `IslandSet` through a struct of `Islands` to a list of `Coordinates`. Here’s a simplified diagram of that hierarchy:

<p align="center">
	<img width="350" src="https://monosnap.com/file/erbbG77AsbAssGL4dm35UnCE10c9ik.png">
</p>

The interesting thing is that the leaves of both branches of this tree are always `Coordinates`. In other words, any `Coordinate` can simultaneously be part of the `Board` and part of an `Island`. The challenge with a structure like this is keeping `Coordinate` data in synch on both branches of the tree.

If we had chosen to model this tree as a huge, single data structure, every time we updated `Coordinate` data on one branch, we would need to go update it on the other as well. That’s a recipe for bugs if ever there was one. Instead, we broke the huge structure into manageable pieces, and we stored those pieces that can communicate and coordinate.# Rules## States and transitionHere's a representation of the all the states and the direction of the transitions between them.<p align="center">	<img src="https://monosnap.com/file/7xvReF5NO12JNWec9K5ThpP3YYvtUs.png"></p>In the case of Islands, a single player starts a game. This event puts the game in it’s first state, :initialized. When we’re in :initialized, the only permissible action is adding the second player.<p align="center">	<img width="300" src="https://monosnap.com/file/MQzpxtaYhUJZESmCloaugVx8gOxce9.png"></p>Players can move their islands at any time until they set them. Both players are almost certain to set their islands at different times. If `player1` has set their islands but `player2` hasn’t, `player1` should no longer be able to move their islands, but `player2` should still be able to. In order to handle this properly, we need to keep track of whether each player has set their islands individually.The game alternates between players' turns until one player wins. When a player does win, the game is over. Once the game is over, neither player can take any further action. There’s nothing else to do.## Guessing a Coordinate<p align="center">	<img src="https://monosnap.com/file/3MO8nQFlDNwCyKG5oAiJRS5gLBYGxg.png"></p>Guessing coordinates is the most important action in the game of Islands. It seems simple, but there’s a lot going on. We need to find a path from the player doing the guessing to a specific coordinate on their opponent’s board. We’ve got to mark that coordinate as guessed and return whether it’s a hit or a miss. A guess requires a player and a coordinate.<p align="center">	<img width="300" src="https://monosnap.com/file/4z6B0CoitApx3sMTToyfO53m53Gnjg.png"></p>The state will transition back and forth between one player’s turn and the other until one of them wins. Once both players have set their islands, the game is in `player1` turn. When it’s the first player's turn, that player may guess a coordinate, and that player may win the game. No other events are permissible.<p align="center">	<img width="400" src="https://monosnap.com/file/QcvAeOS840akY8naJvoFtS6nfhxvDj.png"></p># Game`Game` is the entry point to our application. It coordinates the entire communication between the rest of the components.<p align="center">	<img src="https://monosnap.com/file/WrYTVMHYMnA3wXAqq1NonI9pB3co6y.png"></p>If want to add a second player (the first one is already set when starting a game), the `Game` has to call `Rules` and, in case of a positive response `:ok`, it sets the name of the second `Player`.<p align="center">	<img src="https://monosnap.com/file/G3oeaDqK67xDAhkgxdbzp9MGQPsstJ.png"></p>Let's tackle setting island coordinates next. This follows the same pattern as adding a player. We tell the `Rules` a `Player` wants to set `Coordinates` of an `Island` and, when success is returned, we pass the `Coordinates` to the `Player`.<p align="center">	<img src="https://monosnap.com/file/rSxrtPfR6OAb5SceBXmT3pP5dYKZJF.png"></p>The `Game` itself doesn't handle setting `Islands`. We just need to notify `Rules` about that.<p align="center">	<img src="https://monosnap.com/file/d8jUz9ymj37U4Qi2022BfTyytsgg6c.png"></p>Guessing the `Coordinates` is as simple as calling the `Rules` and checking the received response. Later on we can either notify about an error or forward guessing the given `Coordinate` to a particular `Player`.# TestingTo run the entire test suite execute:    mix test

You should see something like this:

	➜  islands_engine git:(master) ✗ mix test
	....................

	Finished in 0.2 seconds
	20 tests, 0 failures

The number may vary depending on the amount of tests currently written. Anyway, it means that all tests passed.
