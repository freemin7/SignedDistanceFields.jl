module SignedDistanceFields

using LinearAlgebra
using StaticArrays

export space, Shd_Id, SDF, Sphere, Ball, Plane, RepQ, Trans, SUnion, SCut, to_code, exec, func, @func

const vec3 = SVector{3,Float64}
const space = vec3
const Shd_Id = UInt16

include("functionbuilder.jl")

abstract type SDF end

include("simplegeometry.jl")
include("higherordercombinators.jl")

end # module
