function camzip3(filename)
% camzip3(filename) compresses a file using the arithmetic encoder
%
% Copyright Jossy 2016

f = fopen(filename,'r');
if (f == -1)
    error('Cannot open input file');
end
in = fread(f)';
fclose(f);

file_length = length(in);


out = arith_encode(in);
out = bits2bytes(out);

fprintf('Compression ratio: %g\n', 8*length(out)/length(in));

f = fopen(strcat(filename,'.cz3'),'w');
if (f == -1)
    error('Cannot open output file');
end
fwrite(f,out);
fclose(f);

%save(strcat(filename,'.cz3c'),'p','file_length');
