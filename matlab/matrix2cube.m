function out = matrix2cube(M, sizeM)
% M: data, sizeM: size to be reshaped back to.
%

out = permute(M,[2,3,1]);
out = reshape(out,sizeM);










