#!/bin/bash

set -o errexit

fname=$1

cat>>${fname}.py<<!
# -------------------------------------------------------------
# Calculator
# -------------------------------------------------------------
numerical_accuracy_parameters = NumericalAccuracyParameters(
    k_point_sampling=(3, 3, 1),
    density_mesh_cutoff=100.0*Hartree,
    )

#iteration_control_parameters = IterationControlParameters(
#    tolerance=1e-04,
#    )

calculator = LCAOCalculator(
#   basis_set=basis_set,
    numerical_accuracy_parameters=numerical_accuracy_parameters,
#   iteration_control_parameters=iteration_control_parameters,
    )

bulk_configuration.setCalculator(calculator)
bulk_configuration.update()

# -------------------------------------------------------------
# Total energy
# -------------------------------------------------------------
total_energy = TotalEnergy(bulk_configuration)
nlsave('${fname}-NM.nc', total_energy)
nlprint(total_energy)
!
