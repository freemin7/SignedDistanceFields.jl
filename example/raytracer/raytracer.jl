using LinearAlgebra, ImageView, Images, ColorVectorSpace, Colors, Dates, SignedDistanceFields

include("raymarching.jl")
include("camera.jl");
include("scene.jl")
include("shaders.jl")
@time include("render.jl")

imshow(myPic)

#begin stamp = Dates.format(Dates.DateTime(Dates.now()), "dd-u-yyyy-HH:MM:SS")
#save(pwd()*"/myPic-"*stamp*".png",map(clamp01nan,myPic)) end
