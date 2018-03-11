function camzip4(filename,key_len)
% camzip4(filename,key_len) compresses a file using the noniid arithmetic encoder
%
% Copyright Jossy 2016

f = fopen(filename,'r');
if (f == -1)
    error('Cannot open input file');
end
in = fread(f)';
fclose(f);

file_length = length(in);

%define keySet (previous context) and conditional probability

keySet=zeros(file_length-key_len,key_len);

for k = key_len:length(in)
    key = in((1+k-key_len): k);    
    keySet(k-key_len+1,1:key_len) = key; 
end

keySet=unique(keySet,'rows');
   
p = zeros(length(keySet),256);

for k=key_len+1:length(in)
    key = in((k-key_len): k-1);   
    [dummy,ind] = ismember(key,keySet,'rows');
    p(ind,in(k)+1)=p(ind,in(k)+1)+1;             
    %in(k)+1 for alphabet ranges from 0 to 255 whereas index from 1 to 256
end

p=p/sum(sum(p));



out = noniid_arith_encode(in,p,key_len,keySet);
out = bits2bytes(out);

fprintf('Compression ratio: %g\n', 8*length(out)/length(in));

f = fopen(strcat(filename,'.cz4'),'w');
if (f == -1)
    error('Cannot open output file');
end
fwrite(f,out);
fclose(f);

save(strcat(filename,'.cz4c'),'p','file_length','key_len','keySet');
