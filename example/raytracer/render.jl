for i=1:x ## loop able to produce more than 1 gigapixel per hour per core on my laptop if fed correctly
    for j=1:y
        a = los(pincam,i,j)
        #frame[i,j]
        temp = raymarch(a[1],a[2],scene,1000.0) ## upto 3x over head due to excessive copying
        ## Stencils on this ^ would be fun :)

        myPic[i,j] = ShaderArray[temp.Shader](temp) ##TODO:reflections have no place in this model
        ## some improvement possible with the shader
    end
end
