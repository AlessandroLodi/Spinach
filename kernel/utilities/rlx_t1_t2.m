% Extended T1/T2 relaxation model returning the relaxation super-
% operators separately for the longitudinal and the transverse 
% states. Syntax:
%
%       [R1Op,R2Op]=rlx_t1_t2(spin_system,euler_angles)
%
% Parameters:
%
%    euler_angles  - if this parameter is skipped, the isotropic
%                    part of the relaxation superoperator is re-
%                    turned; when this parameter is specified,
%                    those theories that support relaxation ani-
%                    sotropy start taking spin system orientati-
%                    on into account
%
% Outputs:
%
%    R1Op - relaxation superoperator containing
%           all longitudinal relaxation terms
%
%    R2Op - relaxation superoperator containing
%           all transverse relaxation terms
%
% Note: multi-spin orders relax at the sum of the rates of
%       their constituent single-spin orders.
%
% i.kuprov@soton.ac.uk
%
% <https://spindynamics.org/wiki/index.php?title=rlx_t1_t2.m>

function [R1Op,R2Op]=rlx_t1_t2(spin_system,euler_angles)

% Check consistency
grumble(spin_system);

% Compute ranks and projections
[L,M]=lin2lm(spin_system.bas.basis);

% Preallocate relaxation rates
r1_rates=zeros(size(spin_system.comp.isotopes));
r2_rates=zeros(size(spin_system.comp.isotopes));

% Fill in relaxation rates
for n=1:numel(spin_system.comp.isotopes)

    % Process the anisotropies
    if exist('euler_angles','var')

        % Compute orientation ort (this matches alphas=0 of two-angle grids)
        ort=[0 0 1]*euler2dcm(euler_angles(1),euler_angles(2),euler_angles(3));

        % Get the rates at the current orientation
        r1_rates(n)=ort*spin_system.rlx.r1_rates{n}*ort';
        r2_rates(n)=ort*spin_system.rlx.r2_rates{n}*ort';

    else

        % Get isotropic rates
        r1_rates(n)=spin_system.rlx.r1_rates{n};
        r2_rates(n)=spin_system.rlx.r2_rates{n};

    end

end

% Preallocate the diagonals
matrix_dim=size(spin_system.bas.basis,1);
r1_diagonal=zeros(matrix_dim,1);
r2_diagonal=zeros(matrix_dim,1);

% Inspect every state and assign its relaxation rate
parfor n=1:matrix_dim
    
    % Copy rate vectors to nodes
    local_r1_rates=r1_rates;
    local_r2_rates=r2_rates;
    
    % Spins in unit state do not contribute
    mask=(L(n,:)~=0);
    
    % Spins in longitudinal states contribute their R1
    r1_spins=(~logical(M(n,:)))&mask;
    r1_sum=sum(local_r1_rates(r1_spins));
    
    % Spins in transverse states contribute their R2
    r2_spins=(logical(M(n,:)))&mask;
    r2_sum=sum(local_r2_rates(r2_spins));
    
    % Total relaxation rate for the state
    r1_diagonal(n)=r1_sum;
    r2_diagonal(n)=r2_sum;
    
end

% Form relaxation superoperators
R1Op=-spdiags(r1_diagonal,0,matrix_dim,matrix_dim);
R2Op=-spdiags(r2_diagonal,0,matrix_dim,matrix_dim);

end

% Consistency enforcement
function grumble(spin_system)
if ~strcmp(spin_system.bas.formalism,'sphten-liouv')
    error('this function is only available in sphten-liouv formalism.');
end
end

% The state that separates its scholars from its warriors will
% have its thinking done by cowards and its fighting by fools.
%
% Sir William Francis Bacon

