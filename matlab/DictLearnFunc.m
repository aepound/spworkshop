function [B, D, DLmodel] = DictLearnFunc(X, params, SCflag,normflag)
% X:        The pixels are in the columns
% params:   The parameter structure built for the SPAMS toolbox.
% SCflag:   If passed in, then sparse coding will happen too...
%           This will probably slow things down...
% normflag: If passed in, then the dataset will be spamsNormalized before
%           training the dictionary.

%==============================================
%   Dictionary learning part.
%==============================================
szX = size(X);
% Scale the data:
if nargin == 4 && normflag
    scalefactor = sqrt(norm(X,'fro')^2/szX(2));
    X = X/scalefactor;
end

[D, DLmodel] = mexTrainDL(X,params);

if nargin >= 3 && SCflag
%==============================================
%   Sparse coding part.
%==============================================

%{
    if isfield(params,'lassoMode')
        params.mode = params.lassoMode;
    end
    A = mexLasso(X,D,params);
    szA = size(A);
    B = spalloc(szA(1),szA(2),nzmax(A));
    for iter=1:szX(2)
        active = logical(A(:,iter));
        B(active,iter) = lsqnonneg(D(:,active),X(:,iter));
    end
%}
    [B A] = SparseCoding(X,D,params);
else 
    B = [];
end % nargin == 3
end % function DictLearnFunc()