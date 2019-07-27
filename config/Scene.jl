z = to_code(SUnion((Trans(Sphere(5*sqrt(2),4),vec3(0.0,-10.0,0.0)),
    Trans(Sphere(5*sqrt(2),5),vec3(0.0,5.0,8.66)),
    Trans(Sphere(5*sqrt(2),6),vec3(0.0,5.0,-8.66)),
    Plane(vec3(1.0,0.0,0.0),2),
    RepQ(Trans(Sphere(0.5,1),vec3(2.5,2.5,2.5)),5.0),
    Trans(Sphere(10.5,3),vec3(0.0,0.0,0.0)))))

scene = funcu(z,:space)
