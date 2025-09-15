function Theta = vecAngle(u,v)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

% 
CosTheta = max(min(dot(u,v)/(norm(u)*norm(v)),1),-1);
Theta = real(acosd(CosTheta));


end
