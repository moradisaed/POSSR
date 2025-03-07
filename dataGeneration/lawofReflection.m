function r = lawofReflection(i,n)
i = tensorNormalize(i);
n = tensorNormalize(n);
temp = dot(i,n,3);
r = i - (2*temp).*n;
end