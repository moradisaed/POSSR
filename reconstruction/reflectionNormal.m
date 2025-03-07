function normalVec = reflectionNormal(surfacePoint, patternPoint, imagePoint)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
iVec = patternPoint - surfacePoint;
iVec = iVec/(norm(iVec));


rVec = imagePoint - surfacePoint;
rVec = rVec/(norm(rVec));

normalVec = iVec + rVec;
normalVec = normalVec/(norm(normalVec));

end