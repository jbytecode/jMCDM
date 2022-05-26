module Game 

export game 


import ..MCDMMethod, ..MCDMResult, ..MCDMSetting
using ..Utilities 

using DataFrames
using JuMP
using GLPK


struct GameResult <: MCDMResult
    row_player_probabilities::Array{Float64,1}
    value::Float64
end

"""
        game(decisionMatrix; verbose = false)

    Solve the zero-sum game.

# Arguments:
 - `decisionMatrix::Array{Float,2}`: n × m matrix of gain values for row player. 
 - `verbose::Bool`: Logical value indicating whether the optimization logs are shown or not. Default is false. 

# Description 
game() solves zero-sum games using a gain matrix designed for the row player. The game matrix has n rows 
and m columns for n and m strategies of row and column players, respectively. 

# Output 
- `::GameResult`: GameResult object that holds mixed strategy probabilities for row player and the value of game.
If a pure strategy exists for the row player, than the propabilities vector is a one-hat vector.

# Examples
```julia-repl
julia> # Rock & Paper & Scissors game
julia> mat = [0 -1 1; 1 0 -1; -1 1 0]
3×3 Array{Int64,2}:
  0  -1   1
  1   0  -1
 -1   1   0

julia> dm = makeDecisionMatrix(mat)
3×3 DataFrame
 Row │ Crt1     Crt2     Crt3    
     │ Float64  Float64  Float64 
─────┼───────────────────────────
   1 │     0.0     -1.0      1.0
   2 │     1.0      0.0     -1.0
   3 │    -1.0      1.0      0.0

julia> result = game(dm);

julia> result.row_player_probabilities
3-element Array{Float64,1}:
 0.3333333333333333
 0.33333333333333337
 0.3333333333333333

julia> result.value
0.0

```

# References
Zhou, Hai-Jun. "The rock–paper–scissors game." Contemporary Physics 57.2 (2016): 151-163.
"""
function game(decisionMatrix::DataFrame; verbose::Bool=false)::GameResult
    
    return game(Matrix(decisionMatrix), verbose = verbose)

end



function game(decisionMatrix::Matrix{<: Real}; verbose::Bool=false)::GameResult
    
    newDecisionMatrix = copy(decisionMatrix)
    
    nrow, ncol = size(decisionMatrix)

    minmat = minimum(decisionMatrix)

    modified = false

    if minmat < 0
        modified = true
        newDecisionMatrix = decisionMatrix .- minmat    
    end

    dm = newDecisionMatrix

    model = Model(GLPK.Optimizer);
    MOI.set(model, MOI.Silent(), !verbose)


    @variable(model, x[1:nrow])
    @variable(model, g)
    @objective(model, Max, g)

    for i in 1:ncol
        @constraint(model, sum(x[1:nrow] .* dm[:, i]) >= g)
    end

    for i in 1:nrow
        @constraint(model, x[i] >= 0)
    end

    @constraint(model, sum(x) == 1.0)

    if verbose
        @info model 
    end 
    
    optimize!(model);

    values = JuMP.value.(x)

    gamevalue = JuMP.value(g) #objective_value(model)
    
    if modified
        gamevalue -= abs(minmat)
    end

    result = GameResult(
        values,
        gamevalue
    )
    
    return result

end

end # end of module game 