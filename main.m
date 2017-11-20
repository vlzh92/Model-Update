%######################################################################## 
conf = struct(...
    'in_file','tetra.dat',... %Имя файла модели, которая будет уточнена
    'f06_file', 'tetra.f06',... %Имя файла с результатами расчета
    'out_file', 'tetra.dat',... %Имя файла с изменёнными жесткостями
    'freq_rek_file', 'Freq_reckon.txt',... %Имя файла с расчетными частотами
    'freq_test_file', 'Freq_test.txt',... %Имя файла с тестовыми частотами
    'path', [pwd '\1-3D_task'],... %Путь к папке в которой будут хранится рпезультаты уточнения
    'kof', 0.1,... %масштабный множитель (исопльзуется дли изменения скорости сходимости). Может быть изменен по ходу уточнения в файле kof.temp
    'ch', 0,...  %максиамльное изменение в % жесткости на любой итерации
    'g_ch', 0,... %global changeable максиамльное изменение жесткости в % от первоначального значения (на первой итерации)
    'START', 1,... %Начинать с итерации номер 1
    'STEP', 100,... %Выполнять итерации до 100
    'DEBUG', 1, ... %Включен режим отладки
    'LOG', 1, ... %Включено ведение log-файла
    'p1', 1, ... % ожидание результата сразу после запуска в секундах
    'p2', 1, ...  % интервал запросов состояния nastran в секундах
    'nastran', '"D:\Siemens\NX\NXNASTRAN\bin\nastran64Lw.exe"', ... %Путь до решателя 
    'is_it_start', 'tasklist | findstr /i nastran.exe', ... % Имя решателя в консоли после запуска
    'nas_param', 'parallel=4 scratch=yes'... %Параметры решателя
);
% in_file = 'full_cub.dat';
% f06_file = 'full_cub.f06';
% out_file = 'full_cub.dat';
% % % % % % % % % % % % % % % % % 
% in_file = 'Condor.bdf';
% f06_file = 'condor.f06';
% out_file = 'Condor.bdf';
% in_file = 'tetra.dat';
% f06_file = 'tetra.f06';
% out_file = 'tetra.dat';
% % % % % % % % % % % % % % % % % 
% in_file = '1degre.dat';
% f06_file = '1degre.f06';
% out_file = '1degre.dat';
% % % % % % % % % % % % % % % % % 
% in_file = '2deg_s-2deg.dat3';
% f06_file = '2deg_s-2deg.f06';
% out_file = '2deg_s-2deg.dat';
% % % % % % % % % % % % % % % % % 
% freq_rek_file = 'Freq_reckon.txt';
% freq_test_file = 'Freq_test.txt';
% path = [pwd '\1-Condr'];
% path = [pwd '\1-3D_task'];
% path = [pwd '\1-attemp'];
% kof = 0.1; %Масштабный множитель при уточнении
% changeable = 0; %Максимально-допустимое изменение жесткости за одну итерацию в процентах
START = conf.START;
STEP = conf.STEP;
%########################################################################
delete([pwd '\kof.temp']);
delete([pwd '\n.temp']);
if conf.LOG
    diary([conf.path '\' datestr(now,'yy-mmmm-dd HH-MM-SS') '.log']);
end
for i = START:STEP
    if conf.LOG
        diary on;
    end
    [i_in_file, i_f06_file, i_freq_rek_file, i_out_file, kof] = ...
    initialize(conf, i);
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
        plot_freq(conf.freq_test_file, i_freq_rek_file, i);
    end
    
    % Изменение свойст материалов
    c = update(i_freq_rek_file, conf.freq_test_file, c, res(2:end,1:end), conf);
    % Запись bdf для последующего расчёта
    num2 = num; c2 = c;
    bdf_write(i_out_file, num2, c2, nmax);
    % Запуск nastran
    start_nastran(i_out_file, conf);
    if conf.LOG
        diary off
    end
end
clear all;

