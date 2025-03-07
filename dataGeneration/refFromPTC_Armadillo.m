clearvars
close all
clc

ptCloud = pcread("Armadillo.ply");
tempPos = ptCloud.Location;
zOffset = 1000;
xOffset = 0;
yOffset = -25;
tempPos(:,1) = tempPos(:,1)+xOffset;
tempPos(:,2) = tempPos(:,2)+yOffset;
tempPos(:,3) = tempPos(:,3)+zOffset;
ptCloud = pointCloud(tempPos);
viewPoint = [0,0,0]';
ptCloudOut = removeHiddenPoints( ptCloud , viewPoint' );
imRes = [500,500];
pPoint = imRes/2;
fLength = 3100;
K_init = [fLength, 0, pPoint(1);...
         0, fLength, pPoint(2); ...
            0, 0, 1];

surfPoints = ptCloudOut.Location;
projPoints = K_init*surfPoints';
projPoints(1,:) = projPoints(1,:)./projPoints(3,:);
projPoints(2,:) = projPoints(2,:)./projPoints(3,:);


x = round(projPoints(1, :));
y = round(projPoints(2, :));
validIndices = (x >= 1 & x <= imRes(1) & y >= 1 & y <= imRes(2));
x = x(validIndices);
y = y(validIndices);



z = surfPoints(validIndices, 3);  

depthMap = NaN(imRes);  
for i = 1:length(x)
    depthMap(y(i), x(i)) = z(i); 
end

figure;imagesc(depthMap);
colormap('jet');  
colorbar;  
title('Generated Depth Map');
axis equal;

filledDepthMap = fillmissing2(depthMap, 'movmedian',3);  
filledDepthMap = fillmissing2(filledDepthMap, 'movmedian',3);  
filledDepthMap = fillmissing2(filledDepthMap, 'movmedian',3);  

figure;imagesc(filledDepthMap);
colormap('jet');  
colorbar;  
title('Generated Depth Map');
axis equal;

cam.F = fLength;
cam.Res = imRes;

objPTC = depth2pts(filledDepthMap, cam);
figure; pcshow(objPTC)
normals = pcnormals(objPTC,35);


X = objPTC.Location(:,:,1);
Y = objPTC.Location(:,:,2);
Z = objPTC.Location(:,:,3);
u = normals(:,:,1);
v = normals(:,:,2);
w = normals(:,:,3);

for k = 1 : numel(x)
   p1 = viewPoint' - [x(k),y(k),z(k)];
   p2 = [u(k),v(k),w(k)];
   angle = atan2(norm(cross(p1,p2)),p1*p2');
   if angle > pi/2 || angle < -pi/2
       u(k) = -u(k);
       v(k) = -v(k);
       w(k) = -w(k);
   end
end

normals = cat(3, u,v,w);

x_vis = X(1:10:end,1:10:end);
y_vis = Y(1:10:end,1:10:end);
z_vis = Z(1:10:end,1:10:end);
u_vis = u(1:10:end,1:10:end);
v_vis = v(1:10:end,1:10:end);
w_vis = w(1:10:end,1:10:end);

figure; pcshow(objPTC)
hold on
quiver3(x_vis,y_vis,z_vis,u_vis,v_vis,w_vis);
hold off


[nn,mm]=meshgrid(1:imRes(2),1:imRes(1));
mm=mm-pPoint(1);
nn=nn-pPoint(2);
sensorSize = 0.003;
focalmm = fLength*sensorSize;
sensorLoc=cat(3,pixelSize*mm,pixelSize*nn,focalmm*ones(size(mm,1),size(mm,2)));
surfPoints = objPTC.Location;
r = lawofReflection(surfPoints - sensorLoc,normals);

planeNormal = [0,0,1];
planePoint = [0,0,0];
[patternPoints,~] = rayMatPlaneIntersection(surfPoints,surfPoints+r,planeNormal,planePoint);

