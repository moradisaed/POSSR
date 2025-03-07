function [pointIntersect,lambda] = rayMatPlaneIntersection(rayStart,rayEnd,planeNormal,planePoint)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[p, q, ~] =size(rayStart);
d = -dot(planeNormal,planePoint);
distMat = repmat(d, [p ,q]);
norMat = repmat(reshape(planeNormal, [1, 1, 3]), [p, q, 1]);
lambda = (-distMat - dot(norMat, rayStart, 3))./( dot(norMat, rayEnd-rayStart, 3));

lambda(lambda < 0) = NaN;

lambda = cat(3, lambda,lambda,lambda);
pointIntersect = rayStart + lambda.*(rayEnd-rayStart);

end
%pointIntersect = rayStart + lambda*(rayEnd - rayStart);