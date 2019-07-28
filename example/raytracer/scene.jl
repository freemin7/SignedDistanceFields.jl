z = to_code(SUnion((Trans(Sphere(5*sqrt(2),4),space(0.0,-10.0,0.0)),
    Trans(Sphere(5*sqrt(2),5),space(0.0,5.0,8.66)),
    Trans(Sphere(5*sqrt(2),6),space(0.0,5.0,-8.66)),
    Plane(space(1.0,0.0,0.0),2),
    RepQ(Trans(Sphere(0.5,1),space(2.5,2.5,2.5)),5.0),
    Trans(Sphere(10.5,3),space(0.0,0.0,0.0)))))

scene = func(z,:space)
