- To solve the case, run the Allrun.pre bash script for all the pre-processing.
- Go to controldict in the system directory and adjust the endTime parameter to a higher (for more simulation time) or lower (for a shorter simulation time).
- Run chtMultiRegionFoam in the terminal afterwards to solve the case.
- Use touch "name.foam" to create a file with filename "name"(any name of your choice) with the extension ".foam" for ParaView.
- Open the created file (in this case name.foam) in ParaView and start viewing. On the bottom left side, turn of "internal mesh" under "Mesh Regions" to get a finer view.

- The 0/ field files contain nonsense patchFields.
  All interesting work is done using the changeDictionaryDicts.

- The uses region-specific decomposition for the heater.
  This can be useful when the solid region is relatively small and a
  normal decomposition would result in very few cells per process.
