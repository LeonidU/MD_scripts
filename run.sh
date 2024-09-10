filename=$1
base="${filename%.*}"
rm topol.top
./gmx pdb2gmx -f $filename -o ${base}_processed.gro -water spce -ignh
./gmx editconf -f ${base}_processed.gro -o ${base}_newbox.gro -c -d 0.637 -bt cubic
./gmx solvate -cp ${base}_newbox.gro -cs spc216.gro -o ${base}_solv.gro -p topol.top
./gmx grompp -f ions.mdp -c ${base}_solv.gro -p topol.top -o ions.tpr
./gmx genion -s ions.tpr -o ${base}_solv_ions.gro -p topol.top -pname NA -nname CL -neutral
./gmx grompp -f minim.mdp -c ${base}_solv_ions.gro -p topol.top -o em.tpr -maxwarn 100
./gmx mdrun -v -deffnm em
./gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -o nvt.tpr -maxwarn 100
./gmx mdrun -deffnm nvt
./gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p topol.top -o npt.tpr -maxwarn 100
./gmx mdrun -deffnm npt
./gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o md_0_1.tpr -maxwarn 100
./gmx mdrun -deffnm md_0_1 -nb gpu -pme gpu -bonded gpu
./gmx trjconv -s md_0_1.tpr -f md_0_1.xtc -o md_0_1_noPBC.xtc -pbc mol -center
./gmx trjconv -s md_0_1.tpr -f md_0_1_noPBC.xtc -o output.pdb
