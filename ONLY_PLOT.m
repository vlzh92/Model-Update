%######################################################################## 
% in_file = 'full_cub.dat';
% f06_file = 'full_cub.f06';
% out_file = 'full_cub.dat';
% % % % % % % % % % % % % % % % % 
in_file = 'Condor.bdf';
f06_file = 'condor.f06';
out_file = 'Condor.bdf';
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
path = [pwd '\1-attemp'];
% path = [pwd '\1-attemp'];
kof = 100; %Масштабный множитель при уточнении
START = 2500;
STEP = 20000;
%########################################################################
    [i_in_file, i_f06_file, i_freq_rek_file, i_out_file, kof] = ...
    initialize(path, in_file, f06_file, freq_rek_file, out_file, kof, i);
    % Чтение заданного bdf
    % Первая строка - суммарные энергии деформации для соответствующих
    % собственных форм, остальные - поэлементно, каждый столбец соответствует собственной
    % форме.
    if i>1
        plot_freq(freq_test_file, i_freq_rek_file, i);
    end;