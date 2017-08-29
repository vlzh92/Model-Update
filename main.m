%######################################################################## 
in_file = 'full_cub.dat';
f06_file = 'full_cub.f06';
out_file = 'full_cub.dat';
freq_rek_file = 'Freq_reckon.txt';
freq_test_file = 'Freq_test.txt';
% path = [pwd '\5-attemp'];
path = [pwd '\9-attemp'];
kof = 1; %���������� ��������� ��� ���������
START = 2;
STEP = 2000;
%########################################################################
delete('kof.temp');
diary([path '\' datestr(now,'yy-mmmm-dd_HH-MM-SS') '.log']);
for i=START:STEP
    diary on;
    [i_in_file, i_f06_file, i_freq_rek_file, i_out_file, kof] = ...
    initialize(path, in_file, f06_file, freq_rek_file, out_file, kof, i);
    % ������ ��������� bdf
    res = bdf_input(i_in_file);
    num = res.num; % 1� ������� - ������ ��������� cbush, 2� � 3� - ������ �������� � ��� �����
    c = res.c;  % ������ ��������� ���������� cbush
    nmax = res.nmax;
    nel = length(num(:,1)); % ���������� ��������� CBUSH
    % ������������� ������������ ���� tamplate.bdf, ����� ������
    %  ��������� f06
    res = f06_read(i_f06_file, num(:,1), i_freq_rek_file);
    % ������ ������ - ��������� ������� ���������� ��� ���������������
    % ����������� ����, ��������� - �����������, ������ ������� ������������� �����������
    % �����.
    if i>1
        plot_freq(freq_test_file, i_freq_rek_file, i);
    end;
    
    % ��������� ������ ����������
    c = update(i_freq_rek_file, 'Freq_test.txt', c, res(2:end,1:end), kof);
    % ������ bdf ��� ������������ �������
    num2 = num; c2 = c;
    bdf_write(i_out_file, num2, c2, nmax);
    % ������ nastran
    start_nastran(i_out_file);
    diary off
end
clear all;

