function normalVec = geometricNormal(centerPoint, Point1, Point2)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
v1 = Point1 - centerPoint;
v2 = Point2 - centerPoint;

normalVec = cross(v1, v2);
normalVec = normalVec/(norm(normalVec));

end