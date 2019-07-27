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
