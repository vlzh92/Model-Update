%######################################################################## 
in_file = 'Condor.bdf';
f06_file = 'condor.f06';
out_file = 'Condor.bdf';
freq_rek_file = 'Freq_reckon.txt';
kof = 100000; %Масштабный множитель при уточнении
STEP = 100;
%######################################################################## 
diary([pwd '\' datestr(now,'yy-mmmm-dd_HH-MM-SS') '.log']);
for i=1:STEP
    diary on;
    i_in_file = [pwd '\' num2str(i) '\' in_file];
    i_f06_file = [pwd '\' num2str(i) '\' f06_file];
    i_freq_rek_file = [pwd '\' num2str(i) '\' freq_rek_file];
    i_out_file = [pwd '\' num2str(i + 1) '\' out_file];
    mkdir(int2str(i+1));
    fprintf(1,'##################################################################\n');
    fprintf(1, '%s\n', datestr(now,'yy-mmmm-dd_HH-MM-SS'));
    fprintf(1, 'STEP = %d\n', i);
    fprintf(1, 'in_file = %s\n', i_in_file);
    fprintf(1, 'f06_file = %s\n', i_f06_file);
    fprintf(1, 'freq_rek_file = %s\n', i_freq_rek_file);
    fprintf(1, 'out_file = %s\n', i_out_file);
    fprintf(1, 'kof = %f\n', kof);
    fprintf(1,'##################################################################\n');
    diary off;diary on; 
    % Чтение заданного bdf
    res = bdf_input(i_in_file);
    num = res.num; % 1й столбец - номера элементов cbush, 2й и 3й - номера входящих в них узлов
    c = res.c;  % массив считанных жесткостей cbush
    nmax = res.nmax;
    nel = length(num(:,1)); % количество элементов CBUSH
    % Дополнительно генерируется файл tamplate.bdf, нужен дальше
    diary off;diary on;
    %  Считывани f06
    res = f06_read(i_f06_file, num(:,1), i_freq_rek_file);
    % Первая строка - суммарные энергии деформации для соответствующих
    % собственных форм, остальные - поэлементно, каждый столбец соответствует собственной
    % форме.
    diary off;diary on;
    % Изменение свойст материалов
    c = update(i_freq_rek_file, 'Freq_test.txt', c, res, kof);
    diary off;diary on;
    % Запись bdf для последующего расчёта
    num2 = num; c2 = c;
    bdf_write(i_out_file, num2, c2, nmax);
    diary off;diary on;
    % Запуск nastran
    start_nastran(i_out_file);
    diary off
end;
clear all;