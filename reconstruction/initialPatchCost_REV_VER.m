function out = initialPatchCost_REV_VER(x, pPoints, iPoints, initPoint, principalPoint, focalPixel, rows , cols)
%UNTITLED3 Summary of this function goes here
%   pPoints: 4 points on the pattern plane (a 3*4 matrix)
%   iPoints: 4 points on the image plane (a 3*4 matrix)
%   initPoint: initial point on the surface (assumed to be known) (a 3*1 vector)
%              corresponds to the first points on the pattern and image
%              planes

cx = principalPoint(1);
cy = principalPoint(2);
f = focalPixel;

pP1 = pPoints(:,1);
pP2 = pPoints(:,2);
pP3 = pPoints(:,3);
pP4 = pPoints(:,4);

iP1 = iPoints(:,1);
iP2 = iPoints(:,2);
iP3 = iPoints(:,3);
iP4 = iPoints(:,4);

sP1 = initPoint;
sP2 = [(rows(1)-cx)*(x(1)/f) ,(cols(1)-cy)*(x(1)/f) , x(1)]';
sP3 = [(rows(2)-cx)*(x(2)/f) ,(cols(2)-cy)*(x(2)/f) , x(2)]';
sP4 = [(rows(3)-cx)*(x(3)/f) ,(cols(3)-cy)*(x(3)/f) , x(3)]';

reflNormal1 = reflectionNormal(sP1, pP1, iP1);
reflNormal2 = reflectionNormal(sP2, pP2, iP2);
reflNormal3 = reflectionNormal(sP3, pP3, iP3);
reflNormal4 = reflectionNormal(sP4, pP4, iP4);

% geoNormasl1 = geometricNormal(sP1, sP3, sP2);
% geoNormasl2 = geometricNormal(sP2, sP1, sP4);
% geoNormasl3 = geometricNormal(sP3, sP4, sP1);
% geoNormasl4 = geometricNormal(sP4, sP2, sP3);

geoNormasl1 = geometricNormal(sP1, sP2, sP3);
geoNormasl2 = geometricNormal(sP2, sP4, sP1);
geoNormasl3 = geometricNormal(sP3, sP1, sP4);
geoNormasl4 = geometricNormal(sP4, sP3, sP2);

% geoNormaslT = geoNormasl1+geoNormasl2+geoNormasl3+geoNormasl4;
% reflNormalT = reflNormal1+reflNormal2+reflNormal3+reflNormal4;
% sim1 = cosineSIM(reflNormal1, geoNormasl1);
% sim2 = cosineSIM(reflNormal2, geoNormasl2);
% sim3 = cosineSIM(reflNormal3, geoNormasl3);
% sim4 = cosineSIM(reflNormal4, geoNormasl4);
% simT = cosineSIM(reflNormalT, geoNormaslT);

sim1 = vecAngle(reflNormal1, geoNormasl1)^2;
sim2 = vecAngle(reflNormal2, geoNormasl2)^2;
sim3 = vecAngle(reflNormal3, geoNormasl3)^2;
sim4 = vecAngle(reflNormal4, geoNormasl4)^2;

% alpha=0.001;
% geoSim1 = alpha*(norm(sP1 - sP2)^2);
% geoSim2 = alpha*(norm(sP1 - sP3)^2);
% geoSim3 = alpha*(norm(sP1 - sP4)^2);

 %out = sim1+sim2+sim3+sim4+geoSim1+geoSim2+geoSim3;
 out = sim1+sim2+sim3+sim4;


end