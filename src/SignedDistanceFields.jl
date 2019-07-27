module SignedDistanceFields
using LinearAlgebra, StaticArrays


export space, Shd_Id, SDF, Sphere, Plane, RepQ, Trans, SUnion, SCut, to_code, execu, funcu

const vec3 = SVector{3,Float64}

const space = vec3
const Shd_Id = UInt16

abstract type SDF end

struct Sphere <: SDF
    Radius::Float64
    ShaderID::Shd_Id
end

struct Plane <: SDF
    Normal::space
    ShaderID::Shd_Id
end # struct

struct RepQ{T <: SDF} <: SDF
    Victim::T
    resid::Float64
end

struct repb{T <: SDF} <: SDF
    Victim::T
    box::space
end

struct Trans{T <: SDF} <: SDF
    Victim::T
    Vec::space
end

struct SUnion{T} <: SDF
    Victims::T
end

struct SCut{T} <: SDF
    Victims::T
end

mutable struct SingFunc
    Core::Array{Expr,1}
    Param::Symbol
end

function to_code(Sdf::Sphere)
    temp = gensym()
    a = Expr(:tuple,Expr(:call,:(-),Expr(:call,:norm,temp),Sdf.Radius),Sdf.ShaderID)
    SingFunc([a],temp)
end

function to_code(Sdf::Plane)
    temp = gensym()
    a = Expr(:tuple,Expr(:call,:dot,Sdf.Normal,temp),Sdf.ShaderID)
    SingFunc([a],temp)
end

function to_code(Sdf::Trans)
    SF = to_code(Sdf.Victim)
    temp = gensym()
    prepend!(SF.Core,[Expr(:(=),SF.Param,Expr(:call,:(-),temp,Sdf.Vec))])
    SF.Param=temp
    SF
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

function execu(SingFun,V)
    SingFunc = deepcopy(SingFun)
    prepend!(SingFunc.Core,[Expr(:(=),SingFunc.Param,V)])
    println(Expr(:block,SingFunc.Core...))
    eval(Expr(:block,SingFunc.Core...))

end # function

function funcu(SingFunc,Type)
    eval(Expr(:function,
         Expr(:tuple,Expr(:(::),SingFunc.Param,Type)),
         Expr(:block,SingFunc.Core...)))
end

end  # module
