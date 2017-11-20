function [i_in_file, i_f06_file, ...
    i_freq_rek_file, i_out_file, kof] = ...
    initialize(conf, i)

path = conf.path;
in_file = conf.in_file;
f06_file = conf.f06_file;
freq_rek_file = conf.freq_rek_file;
out_file = conf.out_file;
kof = conf.kof;
%Тело функции инициализации
    i_in_file = [path '\' num2str(i) '\' in_file];
    i_f06_file = [path '\' num2str(i) '\' f06_file];
    i_freq_rek_file = [path '\' num2str(i) '\' freq_rek_file];
    i_out_file = [path '\' num2str(i + 1) '\' out_file];
    mkdir([path '\' int2str(i+1)]);
    kof = read_kof(kof);
    fprintf(2,'##################################################################\n');
    fprintf(2, '%s\n', datestr(now,'yy-mmmm-dd HH:MM:SS'));
    fprintf(2, 'STEP = %d\n', i);
    fprintf(2, 'in_file = %s\n', i_in_file);
    fprintf(2, 'f06_file = %s\n', i_f06_file);
    fprintf(2, 'freq_rek_file = %s\n', i_freq_rek_file);
    fprintf(2, 'out_file = %s\n', i_out_file);
    fprintf(2, 'kof = %f\n', kof);
    fprintf(2,'##################################################################\n');
end

