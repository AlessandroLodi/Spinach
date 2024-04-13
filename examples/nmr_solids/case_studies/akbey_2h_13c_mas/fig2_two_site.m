% Two-site position exchange for a deuterium nucleus. The sites
% differ in the chemical shift and the orientation of the quad-
% rupolar tensor. Set to reproduce Figure 2 in:
%
%            https://doi.org/10.1016/j.jmr.2021.106974
%
% Calculation time: seconds.
%
% umitakbey@gmail.com
% i.kuprov@soton.ac.uk

function fig2_two_site()

% Magnet field
sys.magnet=9.4;

% Spin system
sys.isotopes={'2H','2H'};

% Quadrupolar interactions
[Q1,Q2]=weblab2nqi(0.16e6,0,1,0,acos(1/3),2*pi/3);
inter.coupling.matrix{1,1}=Q1;
inter.coupling.matrix{2,2}=Q2;

% Kinetics
inter.chem.parts={1,2};
inter.chem.rates=1e4*[-1  1;
                       1 -1];
inter.chem.concs=[1.0 1.0];

% Basis set
bas.formalism='sphten-liouv';
bas.approximation='none';

% Spinach housekeeping
spin_system=create(sys,inter);
spin_system=basis(spin_system,bas);

% Sequence parameters
parameters.spins={'2H'};
parameters.rho0=state(spin_system,'L+','2H','chem');
parameters.coil=state(spin_system,'L+','2H');
parameters.decouple={};
parameters.offset=0;
parameters.sweep=0.4e6;
parameters.npoints=1024;
parameters.zerofill=1024;
parameters.axis_units='kHz';
parameters.invert_axis=1;
parameters.grid='rep_2ang_800pts_sph';

% MAS parameters
parameters.rate=8500;
parameters.axis=[1 1 1];
parameters.max_rank=25;

% Acquisition
fid=singlerot(spin_system,@acquire,parameters,'nmr');

% Apodization
fid=apodization(fid,'exp-1d',3);

% Fourier transform
spectrum=fftshift(fft(fid,parameters.zerofill));

% Plotting
figure(); plot_1d(spin_system,real(spectrum),parameters);

end
