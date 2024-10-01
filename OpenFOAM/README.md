# Introduction

This is for OpenFOAM simulations. Our team is feeling its way in attempting
to do this.

# Rob's Problems

Rob is using a Mac. The other are using OpeanFOAM v. 2012 (which is NOT from that year, confusingly.) Rob is attempting to install this on Ubuntu.

Rob is currently attempting to use this method:

   [mulitpass](https://openfoam.org/download/macos/#:~:text=The%20packaged%20distributions%20of%20OpenFOAM,the%20OpenFOAM%20Issue%20Tracking%20system.)

This requires running:

> multipass shell openfoam

To use paraview, I use Microsoft Remote Desktop to connect to the Ubuntu instance.

A major problem with this approach is that my teammates, Morena and Cledden,
are using version 2012 (Not from that year!) which is the last version to run
on Microsoft windows. It is not clear if I will be able to do this.


I tried to follow these instructions:

    https://develop.openfoam.com/Development/openfoam/-/blob/master/doc/Build.md


By doing "source /etc/bash.rc" in othe rob-install-v2012, I seem to be installing the correct version.

I now don't know how to run paraview properly.

My OpenFoam Run directory is:

>    /home/ubuntu/OpenFOAM/ubuntu-v2012/run

When properly set up, I can run the remote desktop.

Running:

> xrdp &

is quite important.

## If you have a black screen on the remote desktop...

This happened to me---I had a completely black screen as a desktop, which did not allow a login or to start any programs. I solved this by using multipass to "stop" and "start" the Ubuntu thing.