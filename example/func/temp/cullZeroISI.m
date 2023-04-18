function isi = cullZeroISI(obj)
st = obj.SpikeTimes;
isi = [NaN, diff(st)];
st(isi == 0) = [];
isi = [NaN, diff(st)];
obj.SpikeTimes = st;
