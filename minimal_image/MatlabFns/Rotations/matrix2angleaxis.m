% MATRIX2ANGLEAXIS - Homogeneous matrix to angle-axis description
%
% Usage: t = matrix2angleaxis(T)
%
% Argument:   T - 4x4 Homogeneous transformation matrix
% Returns:    t - 3-vector giving rotation axis with magnitude equal to the
%                 rotation angle in radians.
%
% See also: ANGLEAXIS2MATRIX, ANGLEAXIS2MATRIX2, ANGLEAXISROTATE, NEWANGLEAXIS, 
%           NORMALISEANGLEAXIS

% Copyright (c) 2008 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

%     2008  - Original version
% May 2013  - Code to trap small rotations added

function t = matrix2angleaxis(T)

    % This code follows the implementation suggested by Hartley and Zisserman
    R = T(1:3, 1:3);   % Extract rotation part of T
    
    % Trap case where rotation is very small.  (See angleaxis2matrix.m)
    Reye = R-eye(3);
    if norm(Reye) < 1e-8
        t = [T(3,2); T(1,3); T(2,1)];
        return
    end

    % Otherwise find rotation axis as the eigenvector having unit eigenvalue
    % Solve (R-I)v = 0;
    [v,d] = eig(Reye);
    
    % The following code assumes the eigenvalues returned are not necessarily
    % sorted by size. This may be overcautious on my part.
    d = diag(abs(d));      % Extract eigenvalues
    [s, ind] = sort(d);    % Find index of smallest one
    if d(ind(1)) > 0.001   % Hopefully it is close to 0
        warning('Rotation matrix is dubious');
    end
    
    axis = v(:,ind(1)); % Extract appropriate eigenvector
    
    if abs(norm(axis) - 1) > .0001     % Debug
        warning('non unit rotation axis');
    end
    
    % Now determine the rotation angle
    twocostheta = trace(R)-1;
    twosinthetav = [R(3,2)-R(2,3), R(1,3)-R(3,1), R(2,1)-R(1,2)]';
    twosintheta = axis'*twosinthetav;
    
    theta = atan2(twosintheta, twocostheta);
    
    t = theta*axis;
    