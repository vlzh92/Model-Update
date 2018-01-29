%######################################################################## 
conf = struct(...
    'in_file','Condor.bdf',... %��� ����� ������, ������� ����� ��������
    'f06_file', 'condor.f06',... %��� ����� � ������������ �������
    'out_file', 'Condor.bdf',... %��� ����� � ���������� �����������
    'freq_rek_file', 'Freq_reckon.txt',... %��� ����� � ���������� ���������
    'freq_test_file', 'Freq_test.txt',... %��� ����� � ��������� ���������
    'path', [pwd '\2-3D_task'],... %���� � ����� � ������� ����� �������� ����������� ���������
    'kof', 0.75,... %���������� ��������� (������������ ��� ��������� �������� ����������). ����� ���� ������� �� ���� ��������� � ����� kof.temp
    'ch', 1,...  %������������ ��������� � % ��������� �� ����� ��������
    'g_ch', 10,... %global changeable ������������ ��������� ��������� � % �� ��������������� �������� (�� ������ ��������)
    'START', 1,... %�������� � �������� ����� 1
    'STEP', 100,... %��������� �������� �� 100
    'DEBUG', 1, ... %������� ����� �������
    'LOG', 1, ... %�������� ������� log-�����
    'p1', 1, ... % �������� ���������� ����� ����� ������� � ��������
    'p2', 1, ...  % �������� �������� ��������� nastran � ��������
    'nastran', '"D:\Siemens\NX\NXNASTRAN\bin\nastran64Lw.exe"', ... %���� �� �������� 
    'is_it_start', 'tasklist | findstr /i nastran.exe', ... % ��� �������� � ������� ����� �������
    'nas_param', 'parallel=4 scratch=yes'... %��������� ��������
);
conf = read_conf(conf, '3-spring.conf');
%########################################################################
delete([pwd '\kof.temp']);
delete([pwd '\n.temp']);
if conf.LOG
    diary([conf.path '\' datestr(now,'yy-mmmm-dd HH-MM-SS') '.log']);
end
for i = conf.START:conf.STEP
    if conf.LOG
        diary on;
    end
    [i_in_file, i_f06_file, i_freq_rek_file, i_out_file, kof] = ...
    initialize(conf, i);
    % ������ ��������� bdf
    res = bdf_input(i_in_file);
    num = res.num; % 1� ������� - ������ ��������� cbush, 2� � 3� - ������ �������� � ��� �����
    c = res.c;  % ������ ��������� ���������� cbush
    nmax = res.nmax;
    nel = length(num(:, 1)); % ���������� ��������� CBUSH
    % ������������� ������������ ���� tamplate.bdf, ����� ������
    %  ��������� f06
    res = f06_read(i_f06_file, num(:,1), i_freq_rek_file);
    % ������ ������ - ��������� ������� ���������� ��� ���������������
    % ����������� ����, ��������� - �����������, ������ ������� ������������� �����������
    % �����.
    if i>1
        plot_freq(conf.freq_test_file, i_freq_rek_file, i);
    end
    if i == conf.START
        c_start = c;
    end
    % ��������� ������ ����������
    c = update(i_freq_rek_file, conf.freq_test_file, c, res(2:end,1:end), conf, c_start);
    % ������ bdf ��� ������������ �������
    num2 = num; c2 = c;
    bdf_write(i_out_file, num2, c2, nmax);
    % ������ nastran
    start_nastran(i_out_file, conf);
    if conf.LOG
        diary off
    end
end
clear all;

