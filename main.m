%######################################################################## 
% 1. ���� ������������ ��������� ���������
% 1.1. �������� ���������������� ���� �� ������� ������� ./0CONF/0-EXAMPLE.conf
% 1.2. ��� ������� �������� � ��������� � ��������������, �������
% ������������� ���� (���������������� ���� ����� ������������, 
% �.�. ���� ���������� ��������� ���������� � ��������� � � �����, �� �������� ������ �������� ���������� �� �����)
%#######################################################
conf_file_name = 'trkv.conf';
conf_folder = '0CONF';
conf_file_path = [pwd '\' conf_folder '\' conf_file_name];
%#######################################################
conf = struct(...
    'in_file','Condor.bdf',... %��� ����� ������, ������� ����� ��������
    'f06_file', 'condor.f06',... %��� ����� � ������������ �������
    'out_file', 'Condor.bdf',... %��� ����� � ���������� �����������
    'freq_rek_file', 'Freq_reckon.txt',... %��� ����� � ���������� ���������
    'freq_test_file', 'Freq_test.txt',... %��� ����� � ��������� ���������
    'path', [pwd '\trkv'],... %���� � ����� � ������� ����� �������� ����������� ���������
    'kof', 1 ,... %���������� ��������� (������������ ��� ��������� �������� ����������). ����� ���� ������� �� ���� ��������� � ����� kof.temp
    'ch_up', 0.5,...  %������������ ��������� � % ��������� �� ����� ��������
    'ch_down', 0.5,...  %������������ ��������� � % ��������� �� ����� ��������
    'g_ch_max', 1.7,... %global changeable ������������ ��������� ��������� � % �� ��������������� �������� (�� ������ ��������)
    'g_ch_min', 0.5,... %global changeable ������������ ��������� ��������� � % �� ��������������� �������� (�� ������ ��������)
    'START', 1,... %�������� � �������� ����� 1
    'STEP', 50,... %��������� �������� �� 100
    'DEBUG', 5, ... %������� ����� �������
    'LOG', 4, ... %�������� ������� log-�����
    'freq_scale',[1,1,1],...%���������� ������
    'p1', 1, ... % �������� ���������� ����� ����� ������� � ��������
    'p2', 1, ...  % �������� �������� ��������� nastran � ��������
    'nastran', '"D:\Siemens\NX\NXNASTRAN\bin\nastran64Lw.exe"', ... %���� �� �������� 
    'is_it_start', 'tasklist | findstr /i nastran.exe', ... % ��� �������� � ������� ����� �������
    'nas_param', 'parallel=4 scratch=yes'... %��������� ��������
);
%diary([conf.path '\' datestr(now,'yy-mmmm-dd HH-MM-SS') '.log']);
conf = read_conf(conf, conf_file_path);
diary([conf.path '\' datestr(now,'yy-mmmm-dd HH-MM-SS') '.log']);
%########################################################################3
delete([pwd '\kof.temp']);
delete([pwd '\n.temp']);
conf.freq_scale
conf.freq_test_file = [conf_folder '\' conf.freq_test_file];
if ~conf.LOG
      diary off;
%     diary([conf.path '\' datestr(now,'yy-mmmm-dd HH-MM-SS') '.log']);
end
for i = conf.START:conf.STEP
    if conf.LOG
        diary on;
    end
    [i_in_file, i_f06_file, i_freq_rek_file, i_out_file, kof] = ...
    initialize(conf, i);
    % ������ ��������� bdf
    res = bdf_input(i_in_file, conf);
    num = res.num; % 1� ������� - ������ ��������� cbush, 2� � 3� - ������ �������� � ��� �����
    c = res.c;  % ������ ��������� ���������� cbush
    nmax = res.nmax;
    nel = length(num(:, 1)); % ���������� ��������� CBUSH
    % ������������� ������������ ���� tamplate.bdf, ����� ������
    %  ��������� f06
    res = f06_read(i_f06_file, num(:,1), i_freq_rek_file, conf, i_in_file);
    % ������ ������ - ��������� ������� ���������� ��� ���������������
    % ����������� ����, ��������� - �����������, ������ ������� ������������� �����������
    % �����.
    if i>1
        plot_freq(conf.freq_test_file, i_freq_rek_file, i, conf);
    end
    if i == conf.START
        c_start = c;
    end
    % ��������� ������ ����������
    c = update(i_freq_rek_file, conf.freq_test_file, c, res(2:end,1:end), c_start, conf);
    % ������ bdf ��� ������������ �������
    num2 = num; c2 = c;
    bdf_write(i_out_file, num2, c2, nmax, conf);
    % ������ nastran
    start_nastran(i_out_file, conf);
    if conf.LOG
        diary off
    end
end
clear all;

