function out = estimateNormals(ptc, K)

normals = pcnormals (ptc,K);

x = ptc.Location(:,1);
y = ptc.Location(:,2);
z = ptc.Location(:,3);
u = normals(:,1);
v = normals(:,2);
w = normals(:,3);
sensorCenter = [0,-0.3,0.3]; 
for k = 1 : numel(x)
   p1 = sensorCenter - [x(k),y(k),z(k)];
   p2 = [u(k),v(k),w(k)];
   % Flip the normal vector if it is not pointing towards the sensor.
   angle = atan2(norm(cross(p1,p2)),p1*p2');
   if angle > pi/2 || angle < -pi/2
       u(k) = -u(k);
       v(k) = -v(k);
       w(k) = -w(k);
   end
end

out = cat(2, u, v, w);
end