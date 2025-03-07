function ThetaInDegrees = vecAngle(u,v)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

% 
CosTheta = max(min(dot(u,v)/(norm(u)*norm(v)),1),-1);
ThetaInDegrees = real(acosd(CosTheta));

% ThetaInDegrees = atan2(norm(cross(u,v)),dot(u,v));
end