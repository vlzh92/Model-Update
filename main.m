%######################################################################## 
% 1. Этап конфигурации алгоритма уточнения
% 1.1. Создайте конфигурационный файл по подобию примера ./0CONF/0-EXAMPLE.conf
% 1.2. Или внесите изменния в структуру с конфигурациями, которая
% распологается ниже (конфигурационный файл имеет преимущество, 
% т.е. если одинаковые параметры определены в структуре и в файле, то програма примет значения параметров из файла)
%#######################################################
conf_file_name = 'trkv.conf';
conf_folder = '0CONF';
conf_file_path = [pwd '\' conf_folder '\' conf_file_name];
%#######################################################
conf = struct(...
    'in_file','Condor.bdf',... %Имя файла модели, которая будет уточнена
    'f06_file', 'condor.f06',... %Имя файла с результатами расчета
    'out_file', 'Condor.bdf',... %Имя файла с изменёнными жесткостями
    'freq_rek_file', 'Freq_reckon.txt',... %Имя файла с расчетными частотами
    'freq_test_file', 'Freq_test.txt',... %Имя файла с тестовыми частотами
    'path', [pwd '\trkv'],... %Путь к папке в которой будут хранится рпезультаты уточнения
    'kof', 1 ,... %масштабный множитель (исопльзуется дли изменения скорости сходимости). Может быть изменен по ходу уточнения в файле kof.temp
    'ch_up', 0.5,...  %максиамльное изменение в % жесткости на любой итерации
    'ch_down', 0.5,...  %максиамльное изменение в % жесткости на любой итерации
    'g_ch_max', 1.7,... %global changeable максиамльное изменение жесткости в % от первоначального значения (на первой итерации)
    'g_ch_min', 0.5,... %global changeable максиамльное изменение жесткости в % от первоначального значения (на первой итерации)
    'START', 1,... %Начинать с итерации номер 1
    'STEP', 50,... %Выполнять итерации до 100
    'DEBUG', 5, ... %Включен режим отладки
    'LOG', 4, ... %Включено ведение log-файла
    'freq_scale',[1,1,1],...%Значимость частот
    'p1', 1, ... % ожидание результата сразу после запуска в секундах
    'p2', 1, ...  % интервал запросов состояния nastran в секундах
    'nastran', '"D:\Siemens\NX\NXNASTRAN\bin\nastran64Lw.exe"', ... %Путь до решателя 
    'is_it_start', 'tasklist | findstr /i nastran.exe', ... % Имя решателя в консоли после запуска
    'nas_param', 'parallel=4 scratch=yes'... %Параметры решателя
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
    % Чтение заданного bdf
    res = bdf_input(i_in_file, conf);
    num = res.num; % 1й столбец - номера элементов cbush, 2й и 3й - номера входящих в них узлов
    c = res.c;  % массив считанных жесткостей cbush
    nmax = res.nmax;
    nel = length(num(:, 1)); % количество элементов CBUSH
    % Дополнительно генерируется файл tamplate.bdf, нужен дальше
    %  Считывани f06
    res = f06_read(i_f06_file, num(:,1), i_freq_rek_file, conf, i_in_file);
    % Первая строка - суммарные энергии деформации для соответствующих
    % собственных форм, остальные - поэлементно, каждый столбец соответствует собственной
    % форме.
    if i>1
        plot_freq(conf.freq_test_file, i_freq_rek_file, i, conf);
    end
    if i == conf.START
        c_start = c;
    end
    % Изменение свойст материалов
    c = update(i_freq_rek_file, conf.freq_test_file, c, res(2:end,1:end), c_start, conf);
    % Запись bdf для последующего расчёта
    num2 = num; c2 = c;
    bdf_write(i_out_file, num2, c2, nmax, conf);
    % Запуск nastran
    start_nastran(i_out_file, conf);
    if conf.LOG
        diary off
    end
end
clear all;

