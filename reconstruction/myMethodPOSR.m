clearvars
close all
clc
addpath(genpath('./.'))
load("threePlaneData4X.mat")
principalPoint = cam.Res/2;
cx = cam.Res(1)/2;
cy = cam.Res(2)/2;
f = cam.Focalmm;
focalPixel =cam.F; 

maskT = mask44;
surfPoints = maskT.*points;
plane1 = maskT.*patternPoints1;
plane2 = maskT.*patternPoints2;
plane3 = maskT.*patternPoints3;

[m,n,~] =size(points);
[NN , MM] = meshgrid(1:n,1:m);
sensorLoc = cat(3, (MM -(m/2))*cam.PixelSize , (NN -(n/2))*cam.PixelSize, cam.Focalmm*ones(m,n));
noise_std = 1;
noise_corr = normrnd(0,noise_std*cam.PixelSize,[size(sensorLoc,1),size(sensorLoc,2),2] );
noise_corr = cat(3,noise_corr, zeros(size(sensorLoc,1),size(sensorLoc,2)));
sensorLoc = sensorLoc + noise_corr;
figure;pcshow(surfPoints)
hold on 

pcshow(plane1)
pcshow(plane2)
pcshow(plane3)
pcshow([0,0,0])

H1 = isnan(surfPoints);
H2 = isnan(plane1);
H3 = isnan(plane2);
H4 = isnan(plane3);


H= or (or(H1(:,:,1),H2(:,:,1)),or(H3(:,:,1),H4(:,:,1)));

mask=cat(3,H,H,H);

surfPoints(mask)=NaN;
plane1(mask)=NaN;
plane2(mask)=NaN;
plane3(mask)=NaN;

figure;pcshow(surfPoints)
hold on 

pcshow(plane1)
pcshow(plane2)
pcshow(plane3)
pcshow([0,0,0])

plane1 = plane3;

%%   Optimization
[rowsInd , colsInd] = find(maskT(:,:,1)==1);

rowEnd = max(rowsInd);

colEnd = max(colsInd);
rng default % For reproducibility
A = [];
b = [];
Aeq = [];
beq = [];
lb = [-100, -100, -100];
ub = [5000, 5000, 5000];
r0 = min(rowsInd);
c0 = min(colsInd);
rowStart= r0;
colStart= c0;
alpha=1;
options = optimoptions('fmincon','Display','off');
depthTensor = [];

for fscale = 1:0.01:1

fscale

x0 = [surfPoints(r0,c0,3), surfPoints(r0,c0,3),surfPoints(r0,c0,3)];
initPoint = reshape(surfPoints(r0,c0,:),[3,1]);
depthOut = NaN(size(maskT,1), size(maskT,2));
depthOut (r0,c0) = fscale*surfPoints(r0,c0,3);
depthOut (r0,c0) = 10;

for rr = rowStart : rowStart
    for cc = colStart : colEnd-1
        
        rows = [rr, rr+alpha , rr+alpha];
        cols = [cc+alpha, cc , cc+alpha];

        pp1 = reshape(plane1(rr,cc,:),[3,1]);
        pp2 = reshape(plane1(rows(1),cols(1),:),[3,1]);
        pp3 = reshape(plane1(rows(2),cols(2),:),[3,1]);
        pp4 = reshape(plane1(rows(3),cols(3),:),[3,1]);
        pPoints =cat(2, pp1,pp2,pp3,pp4);

        ip1 = reshape(sensorLoc(rr,cc,:),[3,1]);
        ip2 = reshape(sensorLoc(rows(1),cols(1),:),[3,1]);
        ip3 = reshape(sensorLoc(rows(2),cols(2),:),[3,1]);
        ip4 = reshape(sensorLoc(rows(3),cols(3),:),[3,1]);
        iPoints =cat(2, ip1,ip2,ip3,ip4);

        fun=@(x)initialPatchCost_REV(x, pPoints, iPoints, initPoint, principalPoint, focalPixel, rows , cols);
        [x_sa,fval_sa] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,[],options);
        initPoint = [(rows(1)-cx)*(x_sa(1)/focalPixel) ,(cols(1)-cy)*(x_sa(1)/focalPixel) , x_sa(1)]';
        depthOut(rows(1), cols(1)) = x_sa(1); 
        depthOut(rows(2), cols(2)) = x_sa(2); 
        depthOut(rows(3), cols(3)) = x_sa(3); 
        x0 = [x_sa(1) ,x_sa(1) , x_sa(1)];
    end
end

temp1=surfPoints(rowStart,colStart:colEnd,3);
temp2=depthOut(rowStart,colStart:colEnd);
figure;imagesc(abs(temp1-temp2))


title("reconstruction error map")

figure;plot(surfPoints(rowStart,colStart:colEnd,3))
hold on
plot(depthOut(rowStart,colStart:colEnd))
legend('Ground truth','Our method')
xlabel('sample points')
ylabel('Depth value')


for cc = colStart : colEnd-1
    
    x0 = [depthOut(r0,cc), depthOut(r0,cc),depthOut(r0,cc)];
    initPoint = [(r0-cx)*(depthOut(r0,cc)/focalPixel) ,(cc-cy)*(depthOut(r0,cc)/focalPixel) , depthOut(r0,cc)]';

    for rr = rowStart : rowEnd -1
        rows = [rr, rr+alpha , rr+alpha];
        cols = [cc+alpha, cc , cc+alpha];
        pp1 = reshape(plane1(rr,cc,:),[3,1]);
        pp2 = reshape(plane1(rows(1),cols(1),:),[3,1]);
        pp3 = reshape(plane1(rows(2),cols(2),:),[3,1]);
        pp4 = reshape(plane1(rows(3),cols(3),:),[3,1]);
        pPoints =cat(2, pp1,pp2,pp3,pp4);

        ip1 = reshape(sensorLoc(rr,cc,:),[3,1]);
        ip2 = reshape(sensorLoc(rows(1),cols(1),:),[3,1]);
        ip3 = reshape(sensorLoc(rows(2),cols(2),:),[3,1]);
        ip4 = reshape(sensorLoc(rows(3),cols(3),:),[3,1]);
        iPoints =cat(2, ip1,ip2,ip3,ip4);
        fun=@(x)initialPatchCost_REV_VER(x, pPoints, iPoints, initPoint, principalPoint, focalPixel, rows , cols);
        [x_sa,fval_sa] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,[],options);
        initPoint = [(rows(2)-cx)*(x_sa(2)/focalPixel) ,(cols(2)-cy)*(x_sa(2)/focalPixel) , x_sa(2)]';
        depthOut(rows(1), cols(1)) = x_sa(1); 
        depthOut(rows(2), cols(2)) = x_sa(2); 
        depthOut(rows(3), cols(3)) = x_sa(3); 
        x0 = [x_sa(2) ,x_sa(2) , x_sa(2)];
    end
end
depthTensor=cat(3,depthTensor, depthOut );
end
pt2  =depth2pts(depthOut,cam);
figure;pcshow(pt2)
figure;pcshowpair(pt2,pointCloud(surfPoints))

pt3  =depth2pts(depthOut/fscale,cam);
figure;pcshow(pt3)
figure;pcshowpair(pt3,pointCloud(surfPoints))


save("tensorDepth11_10percent.mat", "depthTensor")
