function opts = buildOptions(removeMean)
%--------------------------------------
% Build the options structure...with some defaults
if ~nargin
    removeMean = 0;
end
opts = struct([]);
opts(1).K = 200;                        % Dictionary size

opts.L = 50;                            % Max activated atoms (for
                                        % Lasso)

opts.iter = 10000;                      % Max iterations

opts.mode = 1;                          % 1: min 1-norm, 0: min
                                        % 2-norm (error)

opts.lambda = 0.0100000000000000000;    % Tuning parameter

opts.modeD = 0;                         % Atoms of unit norm or
                                        % less.

opts.posD = 1-removeMean;               % Positivity constraints...
opts.pos = 1-removeMean;                % | If the mean is removed = no 
opts.posAlpha = 1-removeMean;           % | positivity constraints...

opts.verbose = 0;                       % Turn off the comments

opts.numThreads = 4;                    % Number of compute
                                        % threads.

end % function buildOptions()