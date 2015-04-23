function [out fact] = spamsNormalize(A,flag)
% SPAMSNORMALIZE Normalize for use with the spams toolbox
% This function normalizes A to have columns with 2-norm of 1, on average.
%
% out = spamsNormalize(A), where A is a matrix of columns of
% interest.  
% 
% out = spamsNormalize(A,flag), DOES NOT do the normalization, ie. OUT=A.
%
% [out fact] = spamsNormalize(...), Also returns the factor that the matrix
% is scaled by. 
%

% copyright (c) 2012 Andrew Pound
% For the HSI group @ USU.

if nargin < 2
    fact = sqrt(norm(A,'fro')^2/size(A,2));
    out = A./fact;
else
    fact = 1;
    out = A;
end


end % function spamsNormalize()











