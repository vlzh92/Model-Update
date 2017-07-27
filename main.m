% Чтение заданного bdf
infile = '7\Condor_mod.bdf';
outfile = '8\Condor_mod.bdf';
f06file = '7\condor_mod.f06';
stif_in_file = 'temp\Stifnes_in.txt';
stif_out_file = 'temp\Stifnes_out.txt';
kof = 300; % ??????????? ????????

res = bdf_input(infile);
num = res.num; % 1й столбец - номера элементов cbush, 2й и 3й - номера входящих в них узлов
c = res.c;  % массив считанных жесткостей cbush
nmax = res.nmax;
nel = length(num(:,1)); % количество элементов CBUSH
% Дополнительно генерируется файл tamplate.bdf, нужен дальше
%
% Запись bdf для последующего расчёта
% num2 = num; c2 = c;
% bdf_write ('1\Condor_mod.bdf', num2, c2, nmax);

c(c==0) = 1;
dlmwrite(stif_in_file, c, '\t');
%
% % Считывани?? f06
res = f06_read(f06file, num(:,1));
% 
% 
f = fopen('Freq_test.txt', 'r');
str = ' ';
count = 0;
while ~feof(f)
    str = fgets(f);
    count = count + 1;
end;
fseek(f,0,'bof');
freq_test = zeros(count,1);
freq_reckon = zeros(count,1);
for i = 1:count
    str = fgets(f);
    freq_test(i) = sscanf(str,'%f');
end;
fclose(f);

f = fopen('Freq_reckon.txt', 'r');
for i = 1:count
    str = fgets(f);
    freq_reckon(i) = sscanf(str,'%f');
end;
fclose(f);

freq_reckon(:)
freq_test(:)
% 
% 
% fprintf(1, 'length(res(:,1)) = %d\n', length(res(2:end,1)));
% fprintf(1, 'length(c) = %d\n', length(c));
rest = res';
% fprintf(1, 'length(resT(:,1)) = %d\n', length(rest(:,1)));
width = length(rest(:,1));
higth = length(res(2:end,1));
% fprintf(1,'width = %d\nhigth = %d\n', width, higth);
alpha = zeros(higth, width);
% size(alpha)
% size(res)
for i = 1:higth
    for j = 1:width
        alpha(i,j) = res(i + 1, j)/c(i);
    end
end
% 
% fprintf('size alpha\n');
alpha = alpha(1:end,1:count);
% size(alpha)
% 
dlmwrite('temp/Matrix_1.txt', alpha, '\t');
dlmwrite('temp/Matrix_2.txt', pinv(alpha), '\t');
% 
fprintf('c(1)\n');
size(c(1:end, 1))
fprintf('pinv(alpha)\n');
size(pinv(alpha'))
fprintf('pinv(alpha) * (freq_test - freq_reckon)\n');
size(pinv(alpha') * (freq_test - freq_reckon))
for i = 1:length(c(1,1:end))
    c(1:end,i) = c(1:end,i) + pinv(alpha') * (freq_reckon - freq_test) * kof;
    dlmwrite('temp/temp.txt', kof *(pinv(alpha') * (freq_reckon - freq_test))','-append');
end; 
% 
c(c<1) = 0;
dlmwrite(stif_out_file, c, '\t');
% % Çàïèñü bdf äëÿ ïîñëåäóþùåãî ðàñ÷¸òà
num2 = num; c2 = c;
bdf_write (outfile, num2, c2, nmax);
% strtok
% alpha(:,:)
% res(:,:); 
% Первая строка - суммарные энергии деформации для соответствующих
% собственных форм, остальные - поэлементно, каждый столбец соответствует собственной
% форме.

clear all;