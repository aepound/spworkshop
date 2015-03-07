function out = cube2matrix(A)
%  A = cube: dim1 x dim2 x lam_dim => B = matrix: lam_dim x (dim1 x dim2) 
%  
%  This restructures a cube into a matrix.
%
%  sum( [squeeze(A(1:2,1,:))]' - B(:,1:2) ) = [ 0 0 ]
%

%  This function takes a cube and stacks it next to each other with the 3rd
%  dimension becoming the first, and the other dimensions along the 2nd
%  dimension
%
szA = size(A);
out = permute(A,[3 1 2]);
out = out(:);
out = reshape(out,szA(3),[]);

end % function cube2matrix