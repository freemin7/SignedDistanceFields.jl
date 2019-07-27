using Images, ColorVectorSpace, Colors

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

const x, y = (600,600)

isocam = IsometricCamera(space(45.0,45.0,45.0),
                         space(-1.0,-1.0,-1.0),
                         45*normalize(space(0.0,1.0,-1.0)),
                         45*normalize(space(1.0,-1.0,-1.0)),x,y)

frame = Array{RayResults}(undef,x,y)
myPic = Array{RGB}(undef,x,y)
