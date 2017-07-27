% ������ ��������� bdf
infile = 'Condor.bdf';
f06file = 'condor.f06';
outfile = '8\Condor_mod.bdf';
stif_in_file = 'temp\Stifnes_in.txt';
stif_out_file = 'temp\Stifnes_out.txt';
kof = 300; %���������� ��������� ��� ���������

res = bdf_input(infile);
num = res.num; % 1� ������� - ������ ��������� cbush, 2� � 3� - ������ �������� � ��� �����
c = res.c;  % ������ ��������� ���������� cbush
nmax = res.nmax;
nel = length(num(:,1)); % ���������� ��������� CBUSH
% ������������� ������������ ���� tamplate.bdf, ����� ������
%

% num2 = num; c2 = c;
% bdf_write ('1\Condor_mod.bdf', num2, c2, nmax);

c(c==0) = 1;
%dlmwrite(stif_in_file, c, '\t');

%  ��������� f06
res = f06_read(f06file, num(:,1));
% ������ ������ - ��������� ������� ���������� ��� ���������������
% ����������� ����, ��������� - �����������, ������ ������� ������������� �����������
% �����.

c = update('Freq_reckon.txt', 'Freq_test.txt', c, res, kof);

% ������ bdf ��� ������������ �������
num2 = num; c2 = c;
bdf_write (outfile, num2, c2, nmax);


clear all;