Information
===========

This is the release of the RGB-D holistic model described in the paper
http://www.cs.utoronto.edu/~fidler/papers/lin_et_al_iccv13.pdf.

Project webpage: http://www.cs.utoronto.edu/~fidler/projects/scenes3D.html
Code git: https://bitbucket.org/lindahua/indoor3d

For questions concerning the code please contact Dahua Lin at
<dhlin AT ttic DOT edu> and Sanja Fidler <fidler  AT cs DOT toronto DOTedu>.

The code was developed when Dahua Lin and Sanja Fidler were at TTI Chicago.

How to Cite
===========
If you use this code or data in your research, please cite:

  @inProceedings{LinICCV13,
    author       = "D. Lin and S. Fidler and R. Urtasun",
    title        = "Holistic Scene Understanding for 3D Object Detection with RGBD Cameras",
    booktitle    = "ICCV",
    year         = {2013}
  }



* If you use the CRF please also cite:

@inproceedings{hazan10,
    author = {T. Hazan and R. Urtasun},
    title = {A Primal-Dual Message-Passing Algorithm for Approximated Large Scale Structured Prediction},
    booktitle = NIPS,
    year = {2010}
}

@inproceedings{Schwing11,
 author = {A. Schwing and T. Hazan and M. Pollefeys and R. Urtasun},
 title = {Distributed Message Passing for Large Scale Graphical Models},
 booktitle = CVPR,
 year = {2011}
}


System Requirements
===================
 * Linux or OS X
 * MATLAB

The software was tested on Linux using MATLAB versions R2012b. There may be compatibility issues with older
versions of MATLAB.


Compilation
===========

All necessary code has already been compiled under Linux and is included in the package. If you want
to recompile the CRF code, then download it here: http://www.alexander-schwing.de/dcbp_1.1.zip. The
zip includes an example of how to encode the model. A few more instructions can also be found here:
http://ttic.uchicago.edu/~yaojian/CVPR12_readme.pdf. Note that for CRF inference that code is not
very fast (the default number of iterations is 10K and the gap is set to eps). For efficiency we also
compiled a version (called libCRFmatlabRgap) where we modified the code to have 100 iterations and a 
smaller gap. Since our project, the author of the CRF code (Alex Schwing) also released a new version
where both learning and inference are much more efficient, however the data format is a little different.
So if you decide to use it you'll need to modify our code to accomodate for the new format.

Before running the code, don't forget to include all paths. The easiest to do this is to go to the root
code folder of our project and do: addpath(genpath(pwd)) in Matlab.


Running the code
================

First download the data from our project website. You'll then need to place a config file called data.cfg
into the codes folder. This file should contain all necessary paths to the data:

datadir = /MYPATH/scenes3d/data
outputdir = /MYPATH/scenes3d/results
split_file = /MYPATH/scenes3d/data/split.mat

* To run the experiment with GT cuboids run the function: 
in3d_gt    (it's in the codes/exp subfolder)

* To run the experiment with our cuboid candidates run the function:
in3d_ns(k)    (it's in the codes/exp subfolder
Here k is the number of cuboid candidates per image. We support k = 8, 15 and 30.

The results will be stored in the outputdir you set up above as well as they will be printed out in Matlab.

Note that we do not include the code to compute the potentials and cuboids as it was obtained via other
available code (please check the paper for references). Some helping functions to put data in our format:

* if you have regions, then you'll need to compute the cuboids. To do this you can use: p3d_fitcubes.m

* to prepare the statistics and geometry features and GT, run: 
function in3d_prepare_all(objty), 
where objty='gt' or 'nn08', 'nn15', 'nn30' (depending which experiment you are running)
