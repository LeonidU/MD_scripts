from simtk.openmm.app import *
from simtk.openmm import *
from simtk.unit import *
from sys import stdout
pdb = PDBFile('301D.pdb')
forcefield = app.ForceField('amber10.xml', 'amber10_obc.xml') #this is not used
modeller = Modeller(pdb.topology, pdb.positions)
modeller.addHydrogens(forcefield)
forcefield = app.ForceField('amber14/RNA.OL3.xml', 'amber14/tip3pfb.xml') #this is not used
modeller.addHydrogens(forcefield)
system = forcefield.createSystem(modeller.topology, nonbondedMethod=PME)
simulation = Simulation(modeller.topology, system, integrator)
integrator = LangevinIntegrator(300*kelvin, 1/picosecond, 0.002*picoseconds)
simulation = Simulation(modeller.topology, system, integrator)
simulation.context.setPositions(modeller.positions)
simulation.minimizeEnergy()
simulation.reporters.append(PDBReporter('output.pdb', 1000))
simulation.reporters.append(StateDataReporter(stdout, 1000, step=True, potentialEnergy=True, temperature=True))
simulation.step(100000)
