%######################################################################## 
% in_file = 'full_cub.dat';
% f06_file = 'full_cub.f06';
% out_file = 'full_cub.dat';
% % % % % % % % % % % % % % % % % 
% in_file = 'Condor.bdf';
% f06_file = 'condor.f06';
% out_file = 'Condor.bdf';
in_file = 'tetra.dat';
f06_file = 'tetra.f06';
out_file = 'tetra.dat';
% % % % % % % % % % % % % % % % % 
% in_file = '1degre.dat';
% f06_file = '1degre.f06';
% out_file = '1degre.dat';
% % % % % % % % % % % % % % % % % 
% in_file = '2deg_s-2deg.dat';
% f06_file = '2deg_s-2deg.f06';
% out_file = '2deg_s-2deg.dat';
% % % % % % % % % % % % % % % % % 
freq_rek_file = 'Freq_reckon.txt';
freq_test_file = 'Freq_test.txt';
% path = [pwd '\5-attemp'];
path = [pwd '\1-3D_task'];
% path = [pwd '\1-attemp'];
kof = 0.01; %Масштабный множитель при уточнении
changeable = 2; %Максимально-допустимое изменение жесткости за одну итерацию в процентах
START = 30;
STEP = 200;
%########################################################################
delete([pwd '\kof.temp']);
delete([pwd '\n.temp']);
diary([path '\' datestr(now,'yy-mmmm-dd HH-MM-SS') '.log']);
for i=START:STEP
    diary on;
    [i_in_file, i_f06_file, i_freq_rek_file, i_out_file, kof] = ...
    initialize(path, in_file, f06_file, freq_rek_file, out_file, kof, i);
    % Чтение заданного bdf
    res = bdf_input(i_in_file);
    num = res.num; % 1й столбец - номера элементов cbush, 2й и 3й - номера входящих в них узлов
    c = res.c;  % массив считанных жесткостей cbush
    nmax = res.nmax;
    nel = length(num(:,1)); % количество элементов CBUSH
    % Дополнительно генерируется файл tamplate.bdf, нужен дальше
    %  Считывани f06
    res = f06_read(i_f06_file, num(:,1), i_freq_rek_file);
    % Первая строка - суммарные энергии деформации для соответствующих
    % собственных форм, остальные - поэлементно, каждый столбец соответствует собственной
    % форме.
    if i>1
        plot_freq(freq_test_file, i_freq_rek_file, i);
    end;
    
    % Изменение свойст материалов
    c = update(i_freq_rek_file, 'Freq_test.txt', c, res(2:end,1:end), kof, changeable);
    % Запись bdf для последующего расчёта
    num2 = num; c2 = c;
    bdf_write(i_out_file, num2, c2, nmax);
    % Запуск nastran
    start_nastran(i_out_file);
    diary off
end
clear all;

