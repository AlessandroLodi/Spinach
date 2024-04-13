% Hamiltonian symmetrization for a radical pair with four 
% equivalent nuclei under the S4 permutation group.
%
% i.kuprov@soton.ac.uk

function symmetry_4()

% Magnetic field
sys.magnet=0;

% Spin system
sys.isotopes ={'E','E','1H','1H','1H','1H'};

% Basis set
bas.formalism='zeeman-hilb';
bas.approximation='none';
bas.sym_spins={[3 4 5 6]};
bas.sym_group={'S4'};

% Interactions
inter.zeeman.scalar={2.002 2.002 0 0 0 0};
inter.coupling.scalar=num2cell(mt2hz([0      0   0.295 0.295 0.295 0.295
                                      0      0     0     0     0     0
                                      0.295  0     0     0     0     0
                                      0.295  0     0     0     0     0
                                      0.295  0     0     0     0     0
                                      0.295  0     0     0     0     0]));
% Spinach housekeeping
spin_system=create(sys,inter);
spin_system=basis(spin_system,bas);

% Assumptions
spin_system=assume(spin_system,'labframe');

% Hamiltonian superoperator
H=hamiltonian(spin_system);

% Symmetry factorization
S=horzcat(spin_system.bas.irrep.projector);

% Plotting
figure(); scale_figure([1.5 1]);
subplot(1,2,1); spy(abs(H)>1e3); 
ktitle('Original Hamiltonian');
subplot(1,2,2); spy(abs(S'*H*S)>1e3); 
ktitle('Symmetrised Hamiltonian');
xline(20); yline(20); xline(28); yline(28);

end
