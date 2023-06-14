using Revise
using PTY, Plots, GraphRecipes
setup = rand(1:15, 4)
G = TR.LFSRGraph(TR.LFSR(setup, 4))
plot(G, curves = false, title="$(setup)")