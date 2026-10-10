# Residual Distribution Hydrodynamics Solver for Galaxy Formation Simulations

An implementation of the residual distriution (RD) partial differential equation (PDE) solver for the inviscid Eulerian fluid equations. 1D Roe hydro solver included for comparison with simple problems. We also include a standalone module for contructing periodic Delaunay meshes in both 2D and 3D, using the widely used CGAL library. A full description of the code can be found here (MNRAS paper): https://arxiv.org/pdf/2204.01757

In summary, `rdsolver` will evolve a compressible baryonic gas forward in time, within a static, periodic box, from some set of initial conditions (ICs). The intitial state requires the  density, velocity and internal energy distributions be defined across the box. At the time ICs are set up within the code, depending on the choice of case (outlined below). The domain is discretised into a static periodic Delaunay triangulation. The dual tesselation of this triangulation can be used to produce the piecewise uniform reconstruction of the fluid state at all positions, for the purposes of analyisis and visualisation.

## Prerequisits

OpenBLAS

OpenMP

C++ Compiler (tested most widely with clang)

CGAL (stand alone to generate meshes)


## Run Guide

1. Download repository using `git clone https://github.com/bpfm/rdsolver.git`
2. Configure with `cmake -S rd -B rd/build -DCMAKE_BUILD_TYPE=Release` (CMake 3.17 or newer). OpenBLAS and OpenMP are required; Homebrew dependency paths are detected on macOS. Use `CMAKE_PREFIX_PATH` for other custom installations and `CMAKE_CXX_COMPILER` to select a compiler.
3. Both solvers are enabled by default. Use `-DRD_BUILD_2D=OFF` or `-DRD_BUILD_3D=OFF` to disable one.
4. Compile with `cmake --build rd/build --parallel`.
5. The tracked templates are used automatically. To customize a case, copy `rd/constants.h.TEMPLATE` to `rd/constants.h`, or `rd/constants3D.h.TEMPLATE` to `rd/constants3D.h`, then edit the copy and reconfigure.
6. The local templates retain Sedov/Sedov3D, second-order N, and DRIFT. The 2D template also retains analytic gravity; disable it for a pure hydrodynamic Sedov test. The 3D template uses the upstream restriction `N_TBINS = 1`.
7. Set the mesh size and domain to match the selected case.
8. Generate mesh with appropriate dimensions
    - Move to triangulation/cgal/2d or triangulation/cgal/3d
    - Edit CMakeLists.txt with your CGAL location
    - Run `compile_cgal_2d.sh` or `compile_cgal_3d.sh` (whichever is appropriate to your chosen scenario)
    - Edit `cgal_periodic_2d.cpp` or `cgal_periodic_3d.cpp` to give it the correct edge length for the chosen problem, and the correct number of vertices
    - Run `run_cgal_2d.sh` or `run_cgal_3d.sh`
    - Copy output `.txt` file to `rd` directory, or whereever you plan to run
    - Move back to `rd`
9. Put the mesh file in `rd/` and create `rd/output/`.
10. Run `bash rd/run.sh` or `bash rd/run3D.sh`; these scripts build and run from `rd/`. Use `--build-only` to skip execution. Alternatively, run the executable from a directory containing the mesh and the configured output directory.
  
## Migration validation

Both solver targets compile on macOS with AppleClang, OpenBLAS, and OpenMP. Pure hydrodynamic smoke tests with whole-mesh stepping passed for 2D Sod on a periodic 32-by-32 grid to time 0.2, and 3D Gaussian advection on an 8-by-8-by-8 grid to time 0.05. All snapshot fields were finite, with positive density and pressure; relative mass and energy drift stayed below 2e-6.

Strong Sedov cases on these coarse regular grids still need numerical investigation: the pure hydrodynamic 2D case finished with approximately 0.29% mass drift and 9.23% energy drift, while the 3D case encountered NaN values. The retained 2D DRIFT plus analytic-gravity configuration also triggered density/pressure floors and approximately 0.66% mass drift. These cases have not passed numerical validation.

## Compile Time Options

