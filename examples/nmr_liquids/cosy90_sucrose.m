% COSY spectrum of sucrose (magnetic parameters computed with DFT).
%
% Calculation time: minutes
%
% i.kuprov@soton.ac.uk
% gareth.charnock@oerc.ox.ac.uk

function cosy90_sucrose()

% Spin system properties (vacuum DFT calculation)
options.min_j=2.0; options.no_xyz=1;
[sys,inter]=g2spinach(gparse('../standard_systems/sucrose.log'),...
                                     {{'H','1H'}},31.8,options);
% Magnet field
sys.magnet=5.9;

% Algorithmic options
sys.enable={'greedy'};
sys.tols.prox_cutoff=4.0;

% Basis set
bas.formalism='sphten-liouv';
bas.approximation='IK-2';
bas.connectivity='scalar_couplings';
bas.space_level=1;

% Spinach housekeeping
spin_system=create(sys,inter);
spin_system=basis(spin_system,bas);

% Sequence parameters
parameters.angle=pi/2;
parameters.offset=800;
parameters.sweep=1700;
parameters.npoints=[512 512];
parameters.zerofill=[2048 2048];
parameters.spins={'1H'};
parameters.axis_units='ppm';

% Simulation
fid=liquid(spin_system,@cosy,parameters,'nmr');

% Apodization
fid=apodization(fid,'cosbell-2d');

% Fourier transform
spectrum=fftshift(fft2(fid,parameters.zerofill(2),...
                           parameters.zerofill(1)));

% Plotting
figure(); scale_figure([1.5 2.0]);
plot_2d(spin_system,real(spectrum),parameters,...
        20,[0.02 0.2 0.02 0.2],2,256,6,'both');

end
