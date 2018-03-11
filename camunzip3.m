function camunzip3(filename)
% camunzip3(filename) decompresses a file using the arithmetic decoder
%
% Copyright Jossy 2016

% if the user enters the filename with .cz3 extension cut it out
if (length(filename) > 4 & strcmp(filename((end-3):end),'.cz3'))
    filename = filename(1:(end-4));
end

f = fopen(strcat(filename,'.cz3'),'r');
if (f == -1)
    error('Cannot open compressed file');
end
in = fread(f)';
fclose(f);

load(strcat(filename,'.cz3c'),'-mat','p','file_length');

in = bytes2bits(in);
out = arith_decode(in,file_length);

f = fopen(strcat(filename,'.uz3'),'w');
if (f == -1)
    error('Cannot open output file');
end
fwrite(f,out);
fclose(f);

