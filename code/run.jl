using MacroTools, StaticArrays, LinearAlgebra
using Images, ColorVectorSpace, Colors
using Dates


const vec3 = SVector{3,Float64}
const vec4 = SVector{4,Float64}

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


include("../config/Rendering.jl")
include("../config/Camera.jl")
include("../config/Scene.jl")
include("../config/Picture.jl")


@time for i=1:x ## loop able to produce more than 1 gigapixel per hour per core on my laptop if fed correctly
    for j=1:y
        a = los(isocam,i,j)
        frame[i,j] = raymarch(a[1],a[2],scene,1000.0) ## upto 3x over head due to excessive copying
        ## Stencils on this ^ would be fun :)

        myPic[i,j] = ShaderArray[frame[i,j].Shader](frame[i,j]) ##TODO:reflections have no place in this model
        ## some improvement possible with the shader
    end
end
using ImageView
imshow(myPic)
stamp = Dates.format(Dates.DateTime(Dates.now()), "dd-u-yyyy-HH:MM:SS")
save(pwd()*"/results/myPic-"*stamp*".png",map(clamp01nan,myPic))
