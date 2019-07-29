z = to_code(SUnion((Trans(Sphere(5*sqrt(2),4),space(0.0,-10.0,0.0)),
    Trans(Ball(5*sqrt(2),5,1),space(0.0,5.0,8.66)),
    Trans(Ball(5*sqrt(2),6,0.5),space(0.0,5.0,-8.66)),
    Plane(space(1.0,0.0,0.0),2),
    RepQ(Trans(Ball(0.5,1,3.5),space(2.5,2.5,2.5)),5.0),
    Trans(Ball(5,3,Inf64),space(0.0,0.0,0.0)))))

scene = func(z,:space)
