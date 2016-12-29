% copyright (2010) Evangelos Kalogerakis 

function logbins(numbins, D, LOGP)
s = numbins + 1;
for x=0:s-2
    startx = pow( (-log((s-x)/s) ), LOGP ) * (D / pow( log(s), LOGP) );
    endx = pow( (-log((s-x-1)/s) ), LOGP ) * (D / pow( log(s), LOGP) );
    disp([startx, endx])
end

function c = pow(a, b)
c = a ^ b;