clearvars
close all
clc
load("surface4.mat")
principalPoint = cam.Res/2;
cx = cam.Res(1)/2;
cy = cam.Res(2)/2;
f = cam.Focalmm;
focalPixel =cam.F; 





[m,n,~] =size(surfPoints);
[NN , MM] = meshgrid(1:n,1:m);
sensorLoc = cat(3, (MM -(m/2))*cam.PixelSize , (NN -(n/2))*cam.PixelSize, cam.Focalmm*ones(m,n));





H1 = isnan(surfPoints);
H2 = isnan(patternPlane);


H= or(H1(:,:,1),H2(:,:,1));

mask=cat(3,H,H,H);

surfPoints(mask)=NaN;
patternPlane(mask)=NaN;





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
rowStart = min(rowsInd);
colStart = min(colsInd);
depthTensor = [];

rowInit = ceil((rowStart+rowEnd)/2);
colInit = ceil((colStart+colEnd)/2);

alpha=1;
options = optimoptions('fmincon','Display','off');




x0 = [surfPoints(rowInit,colInit,3), surfPoints(rowInit,colInit,3),surfPoints(rowInit,colInit,3)];
xdata.knownPoint = x0;
initPoint = reshape(surfPoints(rowInit,colInit,:),[3,1]);
xdata.initPoint=initPoint;
xdata.principalPoint = principalPoint;
xdata. focalPixel= focalPixel;
depthOut = NaN(size(maskT,1), size(maskT,2));
depthOut (rowInit,colInit) = surfPoints(rowInit,colInit,3);


%% Sweaping right and buttom

for rr = rowInit : rowInit
    for cc = colInit : colEnd-1
        
        rows = [rr, rr+alpha , rr+alpha];
        cols = [cc+alpha, cc , cc+alpha];
        xdata.rows = rows;
        xdata.cols = cols;
        pp1 = reshape(patternPlane(rr,cc,:),[3,1]);
        pp2 = reshape(patternPlane(rows(1),cols(1),:),[3,1]);
        pp3 = reshape(patternPlane(rows(2),cols(2),:),[3,1]);
        pp4 = reshape(patternPlane(rows(3),cols(3),:),[3,1]);
        pPoints =cat(2, pp1,pp2,pp3,pp4);
        xdata.pPoints = pPoints;
        ip1 = reshape(sensorLoc(rr,cc,:),[3,1]);
        ip2 = reshape(sensorLoc(rows(1),cols(1),:),[3,1]);
        ip3 = reshape(sensorLoc(rows(2),cols(2),:),[3,1]);
        ip4 = reshape(sensorLoc(rows(3),cols(3),:),[3,1]);
        iPoints =cat(2, ip1,ip2,ip3,ip4);
        xdata.iPoints = iPoints;
        fun=@(x)rec_Right(x, xdata);
        [x_sa,fval_sa] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,[],options);
        initPoint = [(rows(1)-cx)*(x_sa(1)/focalPixel) ,(cols(1)-cy)*(x_sa(1)/focalPixel) , x_sa(1)]';
        xdata.initPoint = initPoint;
        depthOut(rows(1), cols(1)) = x_sa(1); 
        depthOut(rows(2), cols(2)) = x_sa(2); 
        depthOut(rows(3), cols(3)) = x_sa(3); 
        x0 = [x_sa(1) ,x_sa(1) , x_sa(1)];
    end
end








for cc = colInit : colEnd-1
    cc
    x0 = [depthOut(rowInit,cc), depthOut(rowInit,cc),depthOut(rowInit,cc)];
    initPoint = [(rowInit-cx)*(depthOut(rowInit,cc)/focalPixel) ,(cc-cy)*(depthOut(rowInit,cc)/focalPixel) , depthOut(rowInit,cc)]';
    xdata.initPoint=initPoint;

    for rr = rowInit : rowEnd -1
        rows = [rr, rr+alpha , rr+alpha];
        cols = [cc+alpha, cc , cc+alpha];
        xdata.rows = rows;
        xdata.cols = cols;
        pp1 = reshape(patternPlane(rr,cc,:),[3,1]);
        pp2 = reshape(patternPlane(rows(1),cols(1),:),[3,1]);
        pp3 = reshape(patternPlane(rows(2),cols(2),:),[3,1]);
        pp4 = reshape(patternPlane(rows(3),cols(3),:),[3,1]);
        pPoints =cat(2, pp1,pp2,pp3,pp4);
        xdata.pPoints = pPoints;
        ip1 = reshape(sensorLoc(rr,cc,:),[3,1]);
        ip2 = reshape(sensorLoc(rows(1),cols(1),:),[3,1]);
        ip3 = reshape(sensorLoc(rows(2),cols(2),:),[3,1]);
        ip4 = reshape(sensorLoc(rows(3),cols(3),:),[3,1]);
        iPoints =cat(2, ip1,ip2,ip3,ip4);
        xdata.iPoints = iPoints;
        fun=@(x)rec_Down(x, xdata);
        [x_sa,fval_sa] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,[],options);
        initPoint = [(rows(2)-cx)*(x_sa(2)/focalPixel) ,(cols(2)-cy)*(x_sa(2)/focalPixel) , x_sa(2)]';
        xdata.initPoint = initPoint;
        depthOut(rows(1), cols(1)) = x_sa(1); 
        depthOut(rows(2), cols(2)) = x_sa(2); 
        depthOut(rows(3), cols(3)) = x_sa(3); 
        x0 = [x_sa(2) ,x_sa(2) , x_sa(2)];
    end
end

%% Sweaping right and up










for cc = colInit : colEnd-1
    
    x0 = [depthOut(rowInit,cc), depthOut(rowInit,cc),depthOut(rowInit,cc)];
    initPoint = [(rowInit-cx)*(depthOut(rowInit,cc)/focalPixel) ,(cc-cy)*(depthOut(rowInit,cc)/focalPixel) , depthOut(rowInit,cc)]';
    xdata.initPoint=initPoint;

    for rr = rowInit :-1: rowStart
        rows = [rr, rr-alpha , rr-alpha];
        cols = [cc+alpha, cc+alpha , cc];
        xdata.rows = rows;
        xdata.cols = cols;
        pp1 = reshape(patternPlane(rr,cc,:),[3,1]);
        pp2 = reshape(patternPlane(rows(1),cols(1),:),[3,1]);
        pp3 = reshape(patternPlane(rows(2),cols(2),:),[3,1]);
        pp4 = reshape(patternPlane(rows(3),cols(3),:),[3,1]);
        pPoints =cat(2, pp1,pp2,pp3,pp4);
        xdata.pPoints = pPoints;
        ip1 = reshape(sensorLoc(rr,cc,:),[3,1]);
        ip2 = reshape(sensorLoc(rows(1),cols(1),:),[3,1]);
        ip3 = reshape(sensorLoc(rows(2),cols(2),:),[3,1]);
        ip4 = reshape(sensorLoc(rows(3),cols(3),:),[3,1]);
        iPoints =cat(2, ip1,ip2,ip3,ip4);
        xdata.iPoints = iPoints;
        fun=@(x)rec_Up(x, xdata);
        [x_sa,fval_sa] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,[],options);
        initPoint = [(rows(3)-cx)*(x_sa(3)/focalPixel) ,(cols(3)-cy)*(x_sa(3)/focalPixel) , x_sa(3)]';
        xdata.initPoint = initPoint;
        depthOut(rows(1), cols(1)) = x_sa(1); 
        depthOut(rows(2), cols(2)) = x_sa(2); 
        depthOut(rows(3), cols(3)) = x_sa(3); 
        x0 = [x_sa(3) ,x_sa(3) , x_sa(3)];
    end
end



%% Sweaping left and up
for rr = rowInit : rowInit
    for cc = colInit :-1: colStart
        
        rows = [rr, rr+alpha , rr+alpha];
        cols = [cc-alpha, cc , cc-alpha];
        xdata.rows = rows;
        xdata.cols = cols;
        pp1 = reshape(patternPlane(rr,cc,:),[3,1]);
        pp2 = reshape(patternPlane(rows(1),cols(1),:),[3,1]);
        pp3 = reshape(patternPlane(rows(2),cols(2),:),[3,1]);
        pp4 = reshape(patternPlane(rows(3),cols(3),:),[3,1]);
        pPoints =cat(2, pp1,pp2,pp3,pp4);
        xdata.pPoints = pPoints;
        ip1 = reshape(sensorLoc(rr,cc,:),[3,1]);
        ip2 = reshape(sensorLoc(rows(1),cols(1),:),[3,1]);
        ip3 = reshape(sensorLoc(rows(2),cols(2),:),[3,1]);
        ip4 = reshape(sensorLoc(rows(3),cols(3),:),[3,1]);
        iPoints =cat(2, ip1,ip2,ip3,ip4);
        xdata.iPoints = iPoints;
        fun=@(x)rec_Left(x, xdata);
        [x_sa,fval_sa] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,[],options);
        initPoint = [(rows(1)-cx)*(x_sa(1)/focalPixel) ,(cols(1)-cy)*(x_sa(1)/focalPixel) , x_sa(1)]';
        xdata.initPoint = initPoint;
        depthOut(rows(1), cols(1)) = x_sa(1); 
        depthOut(rows(2), cols(2)) = x_sa(2); 
        depthOut(rows(3), cols(3)) = x_sa(3); 
        x0 = [x_sa(1) ,x_sa(1) , x_sa(1)];
    end
end








for cc = colInit :-1: colStart
    
    x0 = [depthOut(rowInit,cc), depthOut(rowInit,cc),depthOut(rowInit,cc)];
    initPoint = [(rowInit-cx)*(depthOut(rowInit,cc)/focalPixel) ,(cc-cy)*(depthOut(rowInit,cc)/focalPixel) , depthOut(rowInit,cc)]';
    xdata.initPoint=initPoint;

    for rr = rowInit :-1: rowStart
        rows = [rr, rr-alpha , rr-alpha];
        cols = [cc-alpha, cc , cc-alpha];
        xdata.rows = rows;
        xdata.cols = cols;
        pp1 = reshape(patternPlane(rr,cc,:),[3,1]);
        pp2 = reshape(patternPlane(rows(1),cols(1),:),[3,1]);
        pp3 = reshape(patternPlane(rows(2),cols(2),:),[3,1]);
        pp4 = reshape(patternPlane(rows(3),cols(3),:),[3,1]);
        pPoints =cat(2, pp1,pp2,pp3,pp4);
        xdata.pPoints = pPoints;
        ip1 = reshape(sensorLoc(rr,cc,:),[3,1]);
        ip2 = reshape(sensorLoc(rows(1),cols(1),:),[3,1]);
        ip3 = reshape(sensorLoc(rows(2),cols(2),:),[3,1]);
        ip4 = reshape(sensorLoc(rows(3),cols(3),:),[3,1]);
        iPoints =cat(2, ip1,ip2,ip3,ip4);
        xdata.iPoints = iPoints;
        fun=@(x)rec_Upleft(x, xdata);
        [x_sa,fval_sa] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,[],options);
        initPoint = [(rows(2)-cx)*(x_sa(2)/focalPixel) ,(cols(2)-cy)*(x_sa(2)/focalPixel) , x_sa(2)]';
        xdata.initPoint = initPoint;
        depthOut(rows(1), cols(1)) = x_sa(1); 
        depthOut(rows(2), cols(2)) = x_sa(2); 
        depthOut(rows(3), cols(3)) = x_sa(3); 
        x0 = [x_sa(2) ,x_sa(2) , x_sa(2)];
    end
end
%% Sweaping left and down



for cc = colInit :-1: colStart
    
    x0 = [depthOut(rowInit,cc), depthOut(rowInit,cc),depthOut(rowInit,cc)];
    initPoint = [(rowInit-cx)*(depthOut(rowInit,cc)/focalPixel) ,(cc-cy)*(depthOut(rowInit,cc)/focalPixel) , depthOut(rowInit,cc)]';
    xdata.initPoint=initPoint;

    for rr = rowInit : rowEnd
        rows = [rr, rr+alpha , rr+alpha];
        cols = [cc-alpha, cc , cc-alpha];
        xdata.rows = rows;
        xdata.cols = cols;
        pp1 = reshape(patternPlane(rr,cc,:),[3,1]);
        pp2 = reshape(patternPlane(rows(1),cols(1),:),[3,1]);
        pp3 = reshape(patternPlane(rows(2),cols(2),:),[3,1]);
        pp4 = reshape(patternPlane(rows(3),cols(3),:),[3,1]);
        pPoints =cat(2, pp1,pp2,pp3,pp4);
        xdata.pPoints = pPoints;
        ip1 = reshape(sensorLoc(rr,cc,:),[3,1]);
        ip2 = reshape(sensorLoc(rows(1),cols(1),:),[3,1]);
        ip3 = reshape(sensorLoc(rows(2),cols(2),:),[3,1]);
        ip4 = reshape(sensorLoc(rows(3),cols(3),:),[3,1]);
        iPoints =cat(2, ip1,ip2,ip3,ip4);
        xdata.iPoints = iPoints;
        fun=@(x)rec_Downleft(x, xdata);
        [x_sa,fval_sa] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,[],options);
        initPoint = [(rows(2)-cx)*(x_sa(2)/focalPixel) ,(cols(2)-cy)*(x_sa(2)/focalPixel) , x_sa(2)]';
        xdata.initPoint = initPoint;
        depthOut(rows(1), cols(1)) = x_sa(1); 
        depthOut(rows(2), cols(2)) = x_sa(2); 
        depthOut(rows(3), cols(3)) = x_sa(3); 
        x0 = [x_sa(2) ,x_sa(2) , x_sa(2)];
    end
end

%% Visualization
pt2  =depth2pts(depthOut,cam);
figure;pcshow(pt2)
figure;pcshowpair(pt2,pointCloud(surfPoints))

 figure; pcshow(pt2,"BackgroundColor",[1 1 1])
       campos([10500, 4330, 3200]);

temp = surfPoints(:,:,1);
surfX_GT = temp(:);
temp = surfPoints(:,:,2);
surfY_GT = temp(:);
temp = surfPoints(:,:,3);
surfZ_GT = temp(:);


