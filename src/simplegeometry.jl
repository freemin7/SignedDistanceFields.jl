struct Sphere <: SDF
    Radius::Float64
    ShaderID::Shd_Id
end

function to_code(Sdf::Sphere)
    temp = gensym()
    a = Expr(:tuple,Expr(:call,:(-),Expr(:call,:norm,temp),Sdf.Radius),Sdf.ShaderID)
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
