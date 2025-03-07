function out = tensorNormalize(in)

temp1 = (vecnorm(in,2,3));
normC1 = cat(3,temp1,temp1,temp1 );
out = in./normC1;
end