function camunzip4(filename)
% camunzip4(filename) decompresses a file using the noniid arithmetic decoder
%
% Copyright Jossy 2016

% if the user enters the filename with .cz3 extension cut it out
if (length(filename) > 4 & strcmp(filename((end-3):end),'.cz4'))
    filename = filename(1:(end-4));
end

f = fopen(strcat(filename,'.cz4'),'r');
if (f == -1)
    error('Cannot open compressed file');
end
in = fread(f)';
fclose(f);

load(strcat(filename,'.cz4c'),'-mat','p','file_length','key_len','keySet');

in = bytes2bits(in);
out = noniid_arith_decode(in,p,file_length,key_len,keySet);

f = fopen(strcat(filename,'.uz4'),'w');
if (f == -1)
    error('Cannot open output file');
end
fwrite(f,out);
fclose(f);

