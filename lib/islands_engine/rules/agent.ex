defmodule IslandsEngine.Rules.Agent do
  @behaviour :gen_statem

  alias IslandsEngine.Rules

  # BOILERPLATE FUNCTIONS
  def start_link,
    do: :gen_statem.start_link(__MODULE__, :initialized, [])

  def callback_mode,
    do: :state_functions

  def code_change(_vsn, state_name, state, _extra),
    do: {:ok, state_name, state}

  def terminate(_reason, _state, _data),
    do: :nothing

  # With :gen_statem, the beginning state comes caller_pid the return of init/1.
  # This event puts the game in it’s first state, :initialized.
  # In the case of Islands, a single player starts a game.
  # Once we’re in :initialized, the only permissible action is adding the second player.
  def init(_),
    do: {:ok, :initialized, %Rules{}}

  # CALLBACKS
  # The return tuple is really composed of two parts:

  # The first three elements specify how to handle the state and state data.
  # We’re saying that the next state should be the same as the current state, :initialized,
  # and that we’re returning the state data as is.

  # The second part of the return is a three element tuple representing the reply to the caller.
  # The name of the current state is what we’re here for.
  # Out of that reply tuple, the caller will only receive the the current state, the atom :initialized.

  # We can use the following alternatives here:

  # 1. We could remove reply tuple and manually reply to the caller instead.
  # def initialized({:call, caller_pid}, :show_current_state, state) do
  #   :gen_statem.reply(caller_pid, :initialized)
  #   {:next_state, :initialized, state}
  # end

  # 2. We don’t want to transition to a new state, we could use the :keep_state atom instead.
  # def initialized({:call, caller_pid}, :show_current_state, state),
  #   do: :keep_state, state, {:reply, caller_pid, :initialized}

  # 3. We’re not changing the state data either, we can use :keep_state_and_data instead.
  # def initialized({:call, caller_pid}, :show_current_state, _state),
  #   do: {:keep_state_and_data, {:reply, caller_pid, :initialized}}
  def initialized({:call, caller_pid}, :show_current_state, state),
    do: {:next_state, :initialized, state, {:reply, caller_pid, :initialized}}

  # Adding a player is the only event we allow in the :initialized state
  # The return tuple sends :ok back to the caller, meaning the event is permissible.
  # It also specifies :players_set as the next state.
  def initialized({:call, caller_pid}, :add_player, state),
    do: {:next_state, :players_set, state, {:reply, caller_pid, :ok}}

  # The "catchall" clause to return an error for any events
  # besides the ones we explicitly say are ok.
  def initialized({:call, caller_pid}, _, _state),
    do: {:keep_state_and_data, {:reply, caller_pid, :error}}

  # A callback to show the current state when we’re in :players_set.
  def players_set({:call, caller_pid}, :show_current_state, _state),
    do: {:keep_state_and_data, {:reply, caller_pid, :players_set}}

  def players_set({:call, caller_pid}, {:move_island, player}, state) do
    state
    |> Map.get(player)
    |> do_players_set(caller_pid)
  end

  def players_set({:call, caller_pid}, {:set_islands, player}, state) do
    state
    |> Map.put(player, :islands_set)
    |> set_islands_reply(caller_pid)
  end

  def players_set({:call, caller_pid}, _, _state),
    do: {:keep_state_and_data, {:reply, caller_pid, :error}}

  defp do_players_set(:islands_not_set, caller_pid),
    do: {:keep_state_and_data, {:reply, caller_pid, :ok}}
  defp do_players_set(:islands_set, caller_pid),
    do: {:keep_state_and_data, {:reply, caller_pid, :error}}

  defp set_islands_reply(%{player1: :islands_set, player2: :islands_set} = state, caller_pid),
    do: {:next_state, :player1_turn, state, {:reply, caller_pid, :ok}}
  defp set_islands_reply(state, caller_pid),
    do: {:keep_state, state, {:reply, caller_pid, :ok}}

  def player1_turn({:call, caller_pid}, :show_current_state, _state),
    do: {:keep_state_and_data, {:reply, caller_pid, :player1_turn}}

  def player1_turn({:call, caller_pid}, {:guess_coordinate, :player1}, state),
    do: {:next_state, :player2_turn, state, {:reply, caller_pid, :ok}}

  def player1_turn({:call, caller_pid}, :win, state),
    do: {:next_state, :game_over, state, {:reply, caller_pid, :ok}}

  def player1_turn({:call, caller_pid}, _, _state),
    do: {:keep_state_and_data, {:reply, caller_pid, :error}}

  def player2_turn({:call, caller_pid}, :show_current_state, _state),
    do: {:keep_state_and_data, {:reply, caller_pid, :player2_turn}}

  def player2_turn({:call, caller_pid}, {:guess_coordinate, :player2}, state),
    do: {:next_state, :player1_turn, state, {:reply, caller_pid, :ok}}

  def player2_turn({:call, caller_pid}, :win, state),
    do: {:next_state, :game_over, state, {:reply, caller_pid, :ok}}

  def player2_turn(_event, _caller_pid, state),
    do: {:reply, {:error, :action_out_of_sequence}, :player2_turn, state}

  def game_over({:call, caller_pid}, :show_current_state, _state),
    do: {:keep_state_and_data, {:reply, caller_pid, :game_over}}

  # API FUNCTIONS
  def show_current_state(fsm),
    do: :gen_statem.call(fsm, :show_current_state)

  def add_player(fsm),
    do: :gen_statem.call(fsm, :add_player)

  def move_island(fsm, player)
  when is_atom(player),
    do: :gen_statem.call(fsm, {:move_island, player})

  def set_islands(fsm, player)
  when is_atom(player),
    do: :gen_statem.call(fsm, {:set_islands, player})

  def guess_coordinate(fsm, player)
  when is_atom(player),
    do: :gen_statem.call(fsm, {:guess_coordinate, player})

  def win(fsm),
    do: :gen_statem.call(fsm, :win)
end
