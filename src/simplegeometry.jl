struct Sphere <: SDF
    Radius::Float64
    ShaderID::Shd_Id
end

function to_code(Sdf::Sphere)
    temp = gensym()
    a = :((norm($temp)-$(Sdf.Radius)),$(Sdf.ShaderID))
    SingFunc([a],temp)
end

struct Ball <: SDF
    Radius::Float64
    ShaderID::Shd_Id

        Metric::Float64 ## Infinity allowed for Max norm
end

function to_code(Sdf::Ball)
    temp = gensym()
    a = :((norm($temp,$(Sdf.Metric))-$(Sdf.Radius)),$(Sdf.ShaderID))
    SingFunc([a],temp)
end

struct Plane <: SDF
    Normal::space
    ShaderID::Shd_Id
end

function to_code(Sdf::Plane)
    temp = gensym()
    a = Expr(:tuple,Expr(:call,:dot,Sdf.Normal,temp),Sdf.ShaderID)
    SingFunc([a],temp)
end
