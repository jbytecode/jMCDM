
function Base.show(io::IO, result::CRITICResult)
    println(io, "Ordering: ")
    println(io, result.ranking)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end


function Base.show(io::IO, result::EDASResult)
    println(io, "Scores:")
    println(io, result.scores)
    println(io, "Ordering: ")
    println(io, result.ranking)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end

function Base.show(io::IO, result::ElectreResult)
    println(io, "Best indices:")
    println(io, result.bestIndex)
end














