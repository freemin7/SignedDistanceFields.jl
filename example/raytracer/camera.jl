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

struct PinholeCamera
  Position::space
  Direction::space
  Sensorx::space
  Sensory::space
  Maxx::Float64
  Maxy::Float64
  FocalLength::Float64
  function PinholeCamera(Position::space, Direction::space, Sensorx::space, Sensory::space, Maxx::Int64, Maxy::Int64, Fl::Float64)
    new(Position, normalize(Direction), Sensorx/Maxx, Sensory/Maxy, Maxx/2.0, Maxy/2.0,Fl)
  end
end # struct

function los(Cam::PinholeCamera,X::Int64,Y::Int64)::Tuple{space,space}
  light_passes_lens = (X-Cam.Maxx)*Cam.Sensorx+(Y-Cam.Maxy)*Cam.Sensory+Cam.Position
  (light_passes_lens,normalize(light_passes_lens-(Cam.Position-Cam.FocalLength*Cam.Direction)))
end


x, y = (1080,1920)
#Höhe Breite
#Heigth Width
isocam = IsometricCamera(space(25.0,0.0,0.0),
                         space(-1.0,0,0),
                         x/600*35*normalize(space(0.0,1.0,0.0)),
                         y/600*35*normalize(space(0.0,0.0,1.0)),x,y);

pincam = PinholeCamera(space(25.0,0.0,0.0),
                         space(-1.0,0,0),
                         x/600*35*normalize(space(0.0,1.0,0.0)),
                         y/600*35*normalize(space(0.0,0.0,1.0)),x,y,90.0);
#frame = Array{RayResults}(undef,x,y);
myPic = Array{RGB}(undef,x,y);
