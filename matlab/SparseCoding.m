function [B, A, t] = SparseCoding(X, D, params, flag)
% [B, A, t] = SparseCoding(X, D, params, flag
% 
% Inputs:
%     X      - The input data to be represented by the dictionary.   
%     D      - The dictionary.
%     params - the options structure for use with SPAMS.
%     flag   - OPTIONAL logical specifying the method to loop over
%              the vectors being worked on. DEFAULT = 1.
% 
% Outputs:
%     B      - The coefficients, as solved using the support found
%              by LASSO.
%     A      - OPTIONAL The coefficients/support returned by LASS.O
%     t      - OPTIONAL The time it took to calculate.
%

% Copyright (c) 2012 Andrew Pound
% written for HSI group in the ECE dept at USU.
if nargin < 4
    % ok, no probs....
    % This is really for future developments...
    flag = 1;
end

szX = size(X);
%==============================================
%   Sparse coding part.
%==============================================
if isfield(params,'lassoMode')
    params.mode = params.lassoMode;
end
if isfield(params,'lassoLam')
    params.lambda = params.lassoLam;
end
try 
    A = mexLasso(X,D,params);
catch ME
    keyboard
end
szA = size(A);
tic
nnzA = nnz(A);
if ~isfield(params,'pos')
    params.pos = 0;
end
if flag == 1
    B = spalloc(szA(1),szA(2),nzmax(A));
    for iter=1:szX(2)
        active = logical(A(:,iter));
        if params.pos
            B(active,iter) = lsqnonneg(D(:,active),X(:,iter));
        else
            B(active,iter) = D(:,active)\X(:,iter);
        end
    end
elseif flag == 2
    Bi = zeros(1,nnzA);
    Bj = Bi;
    Bvals = Bi;
    for iter=1:szX(2)
        active = logical(A(:,iter));
        actinds = find(active);%logical(A(:,iter))
        valinds = (iter-1)*szA(1)+1:(iter-1)*szA(1)+length(actinds);
        if params.pos
            Bvals(valinds) = lsqnonneg(D(:,active),X(:,iter));
            Bi(valinds) = actinds;
            Bj(valinds) = ones(size(actinds))*iter;
        %    B(active,iter) = lsqnonneg(D(:,active),X(:,iter));
        else
            Bvals(valinds) = D(:,active)\X(:,iter);
            Bi(valinds) = actinds;
            Bj(valinds) = ones(size(actinds))*iter;
        %    B(active,iter) = D(:,active)\X(:,iter);
        end
    end
    B = sparse(Bi,Bj,Bvals,szA(1),szA(2));
else 
    B = [];
end
t = toc;


end % function SparseCoding()