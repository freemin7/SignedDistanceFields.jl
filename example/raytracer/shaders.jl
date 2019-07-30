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
