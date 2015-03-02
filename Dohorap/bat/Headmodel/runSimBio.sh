bin="/scr/kuba1/sw/simbio/bin/anne/ipm_linux_opt_Venant_MEG"
subject="dh${1}a"

headmodel="${HEADDIR}${subject}/HeadModel-iso.v"
sources="${HEADDIR}${subject}/distributed_dipoles.dip"
sensors="${HEADDIR}${subject}/neuromag.grd"
outfile="${HEADDIR}${subject}/ForwardModel.asa"
outfilelog="${HEADDIR}${subject}/ForwardModel.log"

params="${BATDIR}Headmodel/headVenant.par"
pebbles="${BATDIR}Headmodel/pebbles.inp"

ln -s -f ${pebbles} ./pebbles.inp
${bin} -i sourcesimulation -h ${headmodel} -s ${sensors} -p ${params} -dip ${sources} -sens MEG -fwd FEM -o ${outfile} > ${outfilelog} 2>&1

