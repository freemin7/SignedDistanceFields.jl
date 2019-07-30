##TODO: Add softmax

struct RepQ{T <: SDF} <: SDF
    Victim::T
    resid::Float64
end

function to_code(Sdf::RepQ)
    SF = to_code(Sdf.Victim)
    entry = gensym()
    mapped = gensym()
    prepend!(SF.Core,[Expr(:(=),SF.Param,Expr(:call,:broadcast,
        Expr(:->,mapped,Expr(:block,
            Expr(:call,:mod,mapped,Sdf.resid))),entry))])
    SF.Param=entry
    SF
end

struct Trans{T <: SDF} <: SDF
    Victim::T
    Vec::space
end

function to_code(Sdf::Trans)
    SF = to_code(Sdf.Victim)
    temp = gensym()
    prepend!(SF.Core,[Expr(:(=),SF.Param,Expr(:call,:(-),temp,Sdf.Vec))])
    SF.Param=temp
    SF
end

struct SUnion{T} <: SDF
    Victims::T
end

function to_code(Sdf::SUnion)
    entry = gensym()
    best = gensym()

    victs = [Expr(:(=),best,(Inf64,Shd_Id(0)))]
    for i in Sdf.Victims
        SF = to_code(i)
        prepend!(SF.Core,[Expr(:(=),SF.Param,entry)])
        append!(victs,[Expr(:(=),best,Expr(:call,:min,best,Expr(:block,SF.Core...)))])
    end
    append!(victs,[Expr(:block,best)])
    SingFunc(victs,entry)
end

struct SCut{T} <: SDF
    Victims::T
end

function to_code(Sdf::SCut)
    entry = gensym()
    best = gensym()

    victs = [Expr(:(=),best,(0.0,Shd_Id(0)))]
    for i in Sdf.Victims
        SF = to_code(i)
        prepend!(SF.Core,[Expr(:(=),SF.Param,entry)])
        append!(victs,[Expr(:(=),best,Expr(:call,:max,best,Expr(:block,SF.Core...)))])
    end
    append!(victs,[Expr(:block,best)])
    SingFunc(victs,entry)
end
