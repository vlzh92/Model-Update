%######################################################################## 
% in_file = 'full_cub.dat';
% f06_file = 'full_cub.f06';
% out_file = 'full_cub.dat';
% % % % % % % % % % % % % % % % % 
in_file = 'sim.dat';
f06_file = 'sim.f06';
out_file = 'sim.dat';
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
path = [pwd '\5D-sprin'];
% path = [pwd '\1-attemp'];
kof = 0; %���������� ��������� ��� ���������
START = 1;
STEP = 10;
i = 10
%########################################################################
    [i_in_file, i_f06_file, i_freq_rek_file, i_out_file, kof] = ...
    initialize(path, in_file, f06_file, freq_rek_file, out_file, kof, i);
    % ������ ��������� bdf
    % ������ ������ - ��������� ������� ���������� ��� ���������������
    % ����������� ����, ��������� - �����������, ������ ������� ������������� �����������
    % �����.
    if i>1
        plot_freq(freq_test_file, i_freq_rek_file, i);
    end;