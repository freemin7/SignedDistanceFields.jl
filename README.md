# SignedDistanceFields.jl

SignedDistanceFields.jl provides primitive Signed Distance functions in 3 dimensions and ways to combine them. The resulting scene tree can be turned into a single Julia function which has all relevant information inlined and is in something approximating [static single assigment form](https://en.wikipedia.org/wiki/Static_single_assignment_form). This allows for faster execution then walking a tree with each call of the signed distance function of the total scene.
In the future running these functions on the GPU or implementing scene graph specific optimization are possible.

A simple raymarching engine with a scene and some simple shaders are provided in the example folder. 

![Written in Julia](https://raw.githubusercontent.com/freemin7/SignedDistanceFields.jl/master/example/raytracer/myPic-27-Jul-2019-14%3A15%3A35.png)


## Getting Started

Build a scene tree by combining primitives 
```
scene = SUnion((Trans(Sphere(5*sqrt(2),4),space(0.0,-10.0,0.0)),
    Trans(Sphere(5*sqrt(2),5),space(0.0,5.0,8.66)),
    Trans(Sphere(5*sqrt(2),6),space(0.0,5.0,-8.66)),
    Plane(space(1.0,0.0,0.0),2),
    RepQ(Trans(Sphere(0.5,1),space(2.5,2.5,2.5)),5.0),
    Trans(Sphere(10.5,3),space(0.0,0.0,0.0))))
```
Turn the scene in to a `SingFunc` struct which is an array of Julia Expresseion and an initial symbol.
```
SF = to_code(scene)
```
Decice whether you want to evaluate it for a certain value `exec(SF,value)` or if want to build a function `func(SF,:Type)`. Please note due to historic reasons `:Type` is restricted to the space type provided by the package (which is `SVector{3,Float64}` )

### Prerequisites

```
] add MacroTools, StaticArrays, LinearAlgebra, Images, ColorVectorSpace, Colors, Dates
```
Should get you all dependencies for the example.


## Running the tests

We have no tests yet.


## Deployment
`
?

## Built With

* [Julia](https://julialang.org/) - tested and developed on 1.0.4
* [stubGPUentry]() - GPU depedencies would go here, right now it runs on the CPU

## Contributing

Please read just open issues or make pull requests.

## Versioning

We use [SemVer](http://semver.org/) for versioning.

## Authors

* **Johann-Tobias Schäg** - *Initial work* - [Github: freemin7](https://github.com/freemin7)

See also the list of [contributors](https://github.com/freemin7/SignedDistanceFields.jl/graphs/contributors) who participated in this project.

## License

This project is licensed under the Zero-Clause BSD License - see the [LICENSE.md](LICENSE.md) file for details. If you hate this license open an issue.

## Acknowledgments

* Mason Protter for helping me with a few Julia snippets the night i wrote it
* The general #helpdesk Slack channel from the Julia Slack 
* Inigo Quilez [and his website with a few inspirational articles](https://iquilezles.org/index.html)
* Nicolau Leal Werneck for liking it which pushed me to spend the hours
