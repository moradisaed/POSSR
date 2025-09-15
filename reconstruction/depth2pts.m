function ptCloud = depth2pts(img,cam)

f_p = cam.F;
cx = cam.Res(1)/2;
cy = cam.Res(2)/2;

img=double(img);
[m,n]=size(img);
[u,v]=meshgrid(1:n,1:m);
pts=zeros(m,n,3);
pts(:,:,3)=img;
pts(:,:,1)=(1/f_p)*((v-cx).*img);
pts(:,:,2)=(1/f_p)*((u-cy).*img);

ptCloud=pointCloud(pts);
end