mutable struct SingFunc
    Core::Array{Expr,1}
    Param::Symbol
end

function exec(SingFun,V)
    SingFunc = deepcopy(SingFun)
    prepend!(SingFunc.Core,[Expr(:(=),SingFunc.Param,V)])
    println(Expr(:block,SingFunc.Core...))
    eval(Expr(:block,SingFunc.Core...))

end # function

function func(SingFunc,Type)
    eval(Expr(:function,
         Expr(:tuple,Expr(:(::),SingFunc.Param,Type)),
         Expr(:block,SingFunc.Core...)))
end
