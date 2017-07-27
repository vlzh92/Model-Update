%######################################################################## 
in_file = 'Condor.bdf';
f06_file = 'condor.f06';
out_file = 'Condor_mod.bdf';
stif_in_file = 'temp\Stifnes_in.txt';
stif_out_file = 'temp\Stifnes_out.txt';
kof = 300; %Масштабный множитель при уточнении
%######################################################################## 

start_nastran([pwd '\' out_file]); 

% Чтение заданного bdf
res = bdf_input(in_file);
num = res.num; % 1й столбец - номера элементов cbush, 2й и 3й - номера входящих в них узлов
c = res.c;  % массив считанных жесткостей cbush
nmax = res.nmax;
nel = length(num(:,1)); % количество элементов CBUSH
% Дополнительно генерируется файл tamplate.bdf, нужен дальше

% num2 = num; c2 = c;
% bdf_write ('1\Condor_mod.bdf', num2, c2, nmax);

c(c==0) = 1;
%dlmwrite(stif_in_file, c, '\t');

%  Считывани f06
res = f06_read(f06_file, num(:,1));
% Первая строка - суммарные энергии деформации для соответствующих
% собственных форм, остальные - поэлементно, каждый столбец соответствует собственной
% форме.

c = update('Freq_reckon.txt', 'Freq_test.txt', c, res, kof);

% Запись bdf для последующего расчёта
num2 = num; c2 = c;
bdf_write (out_file, num2, c2, nmax);

start_nastran([pwd '\' out_file]); 

clear all;