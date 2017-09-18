# CarND-Controls-MPC

## Model 
A kinetic model is used to describe the state of the car. The state vector is described by the x, y position, orientation, velocity, crosstrack error, and orientation error and given by the equations:


```C++

fg[2 + x_start + i] = x1 - (x0 + v0 * CppAD::cos(psi0) * dt);
fg[2 + y_start + i] = y1 - (y0 + v0 * CppAD::sin(psi0) * dt);
fg[2 + psi_start + i] = psi1 - (psi0 + v0 * delta0 / Lf * dt);
fg[2 + v_start + i] = v1 - (v0 + a0 * dt);
fg[2 + cte_start + i] = cte1 - ((f0 - y0) + (v0 * CppAD::sin(epsi0) * dt));
fg[2 + epsi_start + i] = epsi1 - ((psi0 - psides0) + v0 * delta0 / Lf * dt);

```

### Tuning the Model specifics

The objective function consist of the following :

1. State Cost : crosstrack error (cte), heading error and speed error. The three costs were weighted to keep the car at the center of the track. The heading cost has the highest weight to account for the curvy road. The cte error has a weigth of 100, whereas the speed error a weight of 50. The cost term is used to prevent the car from stopping if perfectly centered.  
2. Actuation cost

3. Rate of change in actuation. To prevent osccilations in the sterring or suddently aceleration, the cost dependent on changes in actuation was added. Fo a smooth path the steering angle was weighted with 1700 .  

The following code implementing the above costs is in MPC.cpp:

```C++
fg[0] = 0;

// Reference State Cost
for (int t = 0; t < N; t++) {
    fg[0] += 100*CppAD::pow(vars[cte_start + t], 2);
    fg[0] += 1500*CppAD::pow(vars[epsi_start + t], 2);
    fg[0] += 50*CppAD::pow(vars[v_start + t] - ref_v, 2);
}
        
// Minimize change-rate.
for (int t = 0; t < N - 1; t++) {
    fg[0] += 1500*CppAD::pow(vars[delta_start + t], 2);
    fg[0] += CppAD::pow(vars[a_start + t], 2);
}
        
// Minimize the value gap between sequential actuations.
for (int t = 0; t < N - 2; t++) {
   fg[0] += 500*CppAD::pow(vars[delta_start + t + 1] - vars[delta_start + t], 2);
   fg[0] += CppAD::pow(vars[a_start + t + 1] - vars[a_start + t], 2);
}

```

## Receding Horizon

The MPC is used to predicts the state of the system based on the following "N" steps. For setting the horizon I tried out different combination and settled for 0.75 seconds (N = 15 and dt = 0.05s). 

Within a smaller horizon the car behaved erractily at curves .

## Polynomial fitting and Preprocessing

The path the car needs to follow is parametrized by fitting an order 3 polynomial to the way poins provided by the simulator in the global coordinate system.
To calculate the cross track and heading errors the waypoints are transformed in car's local coordinate system, with the x-axis in the direction of car's heading and y-axis to the left of it. 
The following equations  were used to convert the way points to car's coordinates.

```C++
//Translation
double x = ptsx[i] - px;
double y = ptsy[i] - py;
//Rotation
ptsx_car[i] =  x * cos(-psi) - y * sin(-psi);
ptsy_car[i] = x * sin(-psi) + y * cos(-psi);

```

## Latency

In the real world there is a latency between commands and the actual actuation. The controller should compansate for
for these delays. 

The latency is inserter in the kinetic model and used to predict the state of the car as follows:
```C++

// predict state in 100ms
double latency = 0.1;
x = x + v*cos(psi)*latency;
y = y + v*sin(psi)*latency;
psi = psi - v*delta/Lf*latency;
v = v + acceleration*latency;


```

## Results

The car was able to go around the track with a speed close to 40mph. 
## Dependencies

* cmake >= 3.5
 * All OSes: [click here for installation instructions](https://cmake.org/install/)
* make >= 4.1(mac, linux), 3.81(Windows)
  * Linux: make is installed by default on most Linux distros
  * Mac: [install Xcode command line tools to get make](https://developer.apple.com/xcode/features/)
  * Windows: [Click here for installation instructions](http://gnuwin32.sourceforge.net/packages/make.htm)
* gcc/g++ >= 5.4
  * Linux: gcc / g++ is installed by default on most Linux distros
  * Mac: same deal as make - [install Xcode command line tools]((https://developer.apple.com/xcode/features/)
  * Windows: recommend using [MinGW](http://www.mingw.org/)
* [uWebSockets](https://github.com/uWebSockets/uWebSockets)
  * Run either `install-mac.sh` or `install-ubuntu.sh`.
  * If you install from source, checkout to commit `e94b6e1`, i.e.
    ```
    git clone https://github.com/uWebSockets/uWebSockets 
    cd uWebSockets
    git checkout e94b6e1
    ```
    Some function signatures have changed in v0.14.x. See [this PR](https://github.com/udacity/CarND-MPC-Project/pull/3) for more details.
* Fortran Compiler
  * Mac: `brew install gcc` (might not be required)
  * Linux: `sudo apt-get install gfortran`. Additionall you have also have to install gcc and g++, `sudo apt-get install gcc g++`. Look in [this Dockerfile](https://github.com/udacity/CarND-MPC-Quizzes/blob/master/Dockerfile) for more info.
* [Ipopt](https://projects.coin-or.org/Ipopt)
  * If challenges to installation are encountered (install script fails).  Please review this thread for tips on installing Ipopt.
  * Mac: `brew install ipopt`
       +  Some Mac users have experienced the following error:
       ```
       Listening to port 4567
       Connected!!!
       mpc(4561,0x7ffff1eed3c0) malloc: *** error for object 0x7f911e007600: incorrect checksum for freed object
       - object was probably modified after being freed.
       *** set a breakpoint in malloc_error_break to debug
       ```
       This error has been resolved by updrading ipopt with
       ```brew upgrade ipopt --with-openblas```
       per this [forum post](https://discussions.udacity.com/t/incorrect-checksum-for-freed-object/313433/19).
  * Linux
    * You will need a version of Ipopt 3.12.1 or higher. The version available through `apt-get` is 3.11.x. If you can get that version to work great but if not there's a script `install_ipopt.sh` that will install Ipopt. You just need to download the source from the Ipopt [releases page](https://www.coin-or.org/download/source/Ipopt/).
    * Then call `install_ipopt.sh` with the source directory as the first argument, ex: `sudo bash install_ipopt.sh Ipopt-3.12.1`. 
  * Windows: TODO. If you can use the Linux subsystem and follow the Linux instructions.
* [CppAD](https://www.coin-or.org/CppAD/)
  * Mac: `brew install cppad`
  * Linux `sudo apt-get install cppad` or equivalent.
  * Windows: TODO. If you can use the Linux subsystem and follow the Linux instructions.
* [Eigen](http://eigen.tuxfamily.org/index.php?title=Main_Page). This is already part of the repo so you shouldn't have to worry about it.
* Simulator. You can download these from the [releases tab](https://github.com/udacity/self-driving-car-sim/releases).
* Not a dependency but read the [DATA.md](./DATA.md) for a description of the data sent back from the simulator.


## Basic Build Instructions


1. Clone this repo.
2. Make a build directory: `mkdir build && cd build`
3. Compile: `cmake .. && make`
4. Run it: `./mpc`.

