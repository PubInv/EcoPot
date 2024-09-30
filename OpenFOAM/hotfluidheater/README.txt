- To solve the case, run the Allrun.pre bash script for all the pre-processing.
- Run chtMultiRegionFoam in the terminal afterwards to solve the case.

- The 0/ field files contain nonsense patchFields.
  All interesting work is done using the changeDictionaryDicts.

- The solver uses region-specific decomposition for the heater.
  This can be useful when the solid region is relatively small and a
  normal decomposition would result in very few cells per process.
