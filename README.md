# dautogrow
an automatic tool for constructing defects pattern in solid states

Usage: Put all *.ne in a directory and then Run:

                                   AutoGrowth x n M N

where x is the starting number of doping; n is the total number of atoms that will be substituted; 
M is the chemical symbol of atoms that will be substituted; N is the chemical symbol of defects
The format of the inital POSCAR (POSCAR.0) can be refered to our GenLS code, that is:

The stand VASP v5 format POSCAR.0 should be modified as following:

MergedCell
   1.00000000000000     
     3.43500000000     0.00000000000     0.00000000000
    -1.71750000000     2.97479726200     0.00000000000
     0.00000000000     0.00000000000    39.01558371223
  C   Sc  C   O 
  2   8   2   8
Selective
Direct
     0.00000000000     0.00000000000     0.58492479252  F F T M
     0.00000000000     0.00000000000     0.72581730093  F F T M
     0.66666666667     0.33333333333     0.23549154276  T T T Fe/X
     0.33333333333     0.66666666667     0.30047480737  T T T Fe/X
     0.66666666667     0.33333333333     0.38952732980  T T T Fe/X
     0.33333333333     0.66666666667     0.45409591211  T T T Fe/X
     0.66666666667     0.33333333333     0.60960416185  T T T Fe/X
     0.33333333333     0.66666666667     0.54460859447  T T T Fe/X
     0.66666666667     0.33333333333     0.76589757848  T T T Fe/X
     0.33333333333     0.66666666667     0.70133220351  T T T Fe/X
     0.00000000000     0.00000000000     0.26017091209  F F T M
     0.00000000000     0.00000000000     0.42961085652  F F T M
     0.00000000000     0.00000000000     0.21786166427  F F T M
     0.66666666667     0.33333333333     0.31689901377  T T T M
     0.33333333333     0.66666666667     0.37328673864  T T T M
     0.00000000000     0.00000000000     0.47180896597  F F T M
     0.00000000000     0.00000000000     0.62723404034  F F T M
     0.66666666667     0.33333333333     0.52819669085  T T T M
     0.00000000000     0.00000000000     0.68362176521  F F T M
     0.33333333333     0.66666666667     0.78213833573  T T T M

If Fe substitute Sc, the symbol 'Fe' should be placed on the positions of Sc, and others marked as 'M'.
If Sc vacances are need, the symbol 'X' should be placed on the positions of Sc, and others marked as 'M'.
