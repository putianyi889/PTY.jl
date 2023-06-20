using PTY
using PTY.TR: Z2RowMat, Z2ColMat, CombLogic


#=
The default 7-segment display is

  １１
２    ３
２    ３
  ４４
５    ６
５    ６
  ７７
=#

display_states = transpose(Z2ColMat(
   [1 1 1 0 1 1 1; # 0
    0 0 1 0 0 1 0; # 1
    1 0 1 1 1 0 1; # 2
    1 0 1 1 0 1 1; # 3
    0 1 1 1 0 1 0; # 4
    1 1 0 1 0 1 1; # 5
    1 1 0 1 1 1 1; # 6
    1 0 1 0 0 1 0; # 7
    1 1 1 1 1 1 1; # 8
    1 1 1 1 0 1 1] # 9
)) # Note that in practice, a number can be regarded as the default state and there only need to be 9 results to display.

#=
The custom wiring is

    a a
bcd     efg
bcd     efg
 cd c c  fg
  d      fg
  d      fg
    g g   g
=#

display_plan = transpose(Z2ColMat(
   [1 0 0 0 0 0 0; # a -> #1
    0 1 0 0 0 0 0; # b -> #2
    0 1 0 1 0 0 0; # c -> #2,4
    0 1 0 0 1 0 0; # d -> #2,5
    0 0 1 0 0 0 0; # e -> #3
    0 0 1 0 0 1 0; # f -> #3,6
    0 0 1 0 0 1 1] # g -> #3,6,7
))

wire_states = display_plan \ display_states # wire states for each number

#=
Now we need to connect the wires to gates. The plan is

Gate 1  2  3  4  5  6  7
Wire a ab abc d efg fg g
=#

gate_plan = Z2RowMat(
   [1 1 1 0 0 0 0; # a -> #1,2,3
    0 1 1 0 0 0 0; # b -> #2,3
    0 0 1 0 0 0 0; # c -> #3
    0 0 0 1 0 0 0; # d -> #4
    0 0 0 0 1 0 0; # e -> #5
    0 0 0 0 1 1 0; # f -> #5,6
    0 0 0 0 1 1 1] # g -> #5,6,7
)

gate_states = gate_plan \ wire_states # gate states for each number

#=
Now we search for valid logics for each gate.
=#
inputs = 16:25
lists = [CombLogic(3, inputs, gate_states[k, :]) for k in 1:7]