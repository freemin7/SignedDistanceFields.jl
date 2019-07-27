
include("../src/SignedDistanceFields.jl")
using LinearAlgebra, ImageView, Images, ColorVectorSpace, Colors, Dates, .SignedDistanceFields

struct RayResults
    Position::space
    Direction::space
    Grad::space
    Shader::Shd_Id
    Step::Float64
    Initial::space
    length::Float64
    renderlim::Float64
    Bias::RGB
end

import Base.zero
function Base.zero(R::Type{RayResults})
    RayResults(zero(space),zero(space),zero(space),zero(Shd_Id),
    zero(Float64),zero(space),zero(Float64),zero(Float64),zero(RGB))
end

function raymarch(Pos::space,Normal::space,SF,renderlim::Float64)
    Step=1.0;
    Start=Pos;
    Strecke=0.0;
    Shd = Shd_Id(0)
    while (Step > 0.001)
        temp = SF(Pos)
        Step = temp[1];
        Shd = temp[2]
        Pos+=Normal*Step;
        Strecke+=Step
        if Strecke > renderlim
            return RayResults(Pos,Normal,zero(space),Shd_Id(1),Step,Pos,Strecke,renderlim,zero(RGB))
        end
    end
    RayResults(Pos,Normal,
    normalize(space(SF(Pos+space(Step,0.0,0.0))[1]-Step,
    SF(Pos+space(0.0,Step,0.0))[1]-Step,
    SF(Pos+space(0.0,0.0,Step))[1]-Step)) ##Assumes 3D FIX
    ,Shd,Step,Pos,Strecke,renderlim,zero(RGB))
end


struct IsometricCamera
  Position::space
  Direction::space
  Sensorx::space
  Sensory::space
  Maxx::Float64
  Maxy::Float64
  function IsometricCamera(Position::space, Direction::space, Sensorx::space, Sensory::space, Maxx::Int64, Maxy::Int64)
    new(Position, normalize(Direction), Sensorx/Maxx, Sensory/Maxy, Maxx/2.0, Maxy/2.0)
  end
end

function los(Cam::IsometricCamera,X::Int64,Y::Int64)::Tuple{space,space}
  ((X-Cam.Maxx)*Cam.Sensorx+(Y-Cam.Maxy)*Cam.Sensory+Cam.Position,Cam.Direction)
end

x, y = (1080,1920)
#Höhe Breite
isocam = IsometricCamera(space(25.0,0.0,0.0),
                         space(-1.0,0,0),
                         x/600*35*normalize(space(0.0,1.0,0.0)),
                         y/600*35*normalize(space(0.0,0.0,1.0)),x,y)

frame = Array{RayResults}(undef,x,y)
myPic = Array{RGB}(undef,x,y);

z = to_code(SUnion((Trans(Sphere(5*sqrt(2),4),space(0.0,-10.0,0.0)),
    Trans(Sphere(5*sqrt(2),5),space(0.0,5.0,8.66)),
    Trans(Sphere(5*sqrt(2),6),space(0.0,5.0,-8.66)),
    Plane(space(1.0,0.0,0.0),2),
    RepQ(Trans(Sphere(0.5,1),space(2.5,2.5,2.5)),5.0),
    Trans(Sphere(10.5,3),space(0.0,0.0,0.0)))))

scene = funcu(z,:space)

ShaderArray = [
        (x⃗⃗::RayResults)->RGB(0.35,0.35,0.35),
        (x⃗::RayResults)->(RGB(0.8,0.8,0.8)*10*clamp01(1/norm(x⃗.Position))),
        (x⃗::RayResults)->(RGB(x⃗.Grad[1]/2+0.5,x⃗.Grad[2]/2+0.5,x⃗.Grad[3]/2+0.5)),
        (x⃗::RayResults)->RGB(0.22,0.545,0.133)*(abs(x⃗.Position[1]/(5*sqrt(2)))),
        (x⃗::RayResults)->RGB(0.584,0.345,0.689)*(abs(x⃗.Position[1]/(5*sqrt(2)))),
        (x⃗::RayResults)->RGB(0.796,0.235,0.2)*(abs(x⃗.Position[1]/(5*sqrt(2)))),
        (x⃗::RayResults)->RGB(0.35,0.35,0.55)]
## Max length of array is 2^16
## A sharder is (currenty) (subject to change due to unhandled reflections) a function that takes a RayResults struct and returns a RGB value


for i=1:x ## loop able to produce more than 1 gigapixel per hour per core on my laptop if fed correctly
    for j=1:y
        a = los(isocam,i,j)
        frame[i,j] = raymarch(a[1],a[2],scene,1000.0) ## upto 3x over head due to excessive copying
        ## Stencils on this ^ would be fun :)

        myPic[i,j] = ShaderArray[frame[i,j].Shader](frame[i,j]) ##TODO:reflections have no place in this model
        ## some improvement possible with the shader
    end
end

imshow(myPic)

stamp = Dates.format(Dates.DateTime(Dates.now()), "dd-u-yyyy-HH:MM:SS")
save(pwd()*"/results/myPic-"*stamp*".png",map(clamp01nan,myPic))
