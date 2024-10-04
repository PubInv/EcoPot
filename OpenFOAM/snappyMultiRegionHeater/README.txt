- To solve the case, run the Allrun_Modified bash script for all the pre-processing. You can also use the Allrun-parallel or Allrun-serial bash scripts to run the case in parallel mode.
- Go to controldict in the system directory and adjust the endTime parameter to a higher (for more simulation time) or lower (for a shorter simulation time).
- Run chtMultiRegionFoam in the terminal afterwards to solve the case if you used the Allrun_Modified script. However, if you used the other scripts, run chtMultiRegionFoam -parallel
- Use touch "name.foam" to create a file with filename "name"(any name of your choice) with the extension ".foam" for ParaView.
- To clear all pre-processing and created time files, run the Allclean bash script.
- Open the created file (in this case name.foam) in ParaView and start viewing. On the bottom left side, turn of "internal mesh" under "Mesh Regions" to get a finer view.

- The 0/ field files contain nonsense patchFields.
  All interesting work is done using the changeDictionaryDicts.

- The solver uses region-specific decomposition for the heater.
  This can be useful when the solid region is relatively small and a
  normal decomposition would result in very few cells per process.
