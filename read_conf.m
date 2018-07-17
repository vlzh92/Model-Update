function conf = read_conf(conf, conf_name)
    f = fopen(conf_name, 'r');
    if ~f
        error(['Can not open file ' conf_name]);
    end
    
    i = 1;
    while ~feof(f)
        str = strtrim(fgets(f));
%         disp(str);
        t = strfind(str, ';');
        if ~isempty(t)
            str = str(1:t-1);
        end
        if isempty(str)
            continue;
        end
        t = strfind(str, '=');
        if isempty(t)
            fprintf(2,['Can not find value (no eq in str) in str = |' str '| in ' conf_name '\n']);
            continue;
        end
        par = str(1:t-1);
        value = strtrim(str(t+1:end));
        fprintf('%d) %s = %s\n', i, par, value);
        i = i + 1;
        
        if contains(par,'in_file')
            conf.in_file = value;
            continue;
        end        
        if contains(par,'f06_file')
            conf.f06_file = value;
            continue;
        end
        if contains(par,'out_file')
            conf.out_file = value;
            continue;
        end
        if contains(par,'freq_rek_file')
            conf.freq_rek_file = value;
            continue;
        end
        if contains(par,'freq_test_file')
            conf.freq_test_file = value;
            continue;
        end
        if contains(par,'path')
            conf.path = value;
            continue;
        end
        if contains(par,'freq_scale')
            conf.freq_scale = str2num(value);
            continue;
        end
        if contains(par,'split_spring')
            conf.split_spring = str2num(value);
            continue;
        end
        if contains(par,'kof')
            conf.kof = str2double(value);
            continue;
        end
        if contains(par,'ch_up')
            conf.ch_up = str2double(value);
            continue;
        end
        if contains(par,'ch_down')
            conf.ch_down = str2double(value);
            continue;
        end
        if contains(par,'g_ch_max')
            conf.g_ch_max = str2double(value);
            continue;
        end
        if contains(par,'g_ch_min')
            conf.g_ch_min = str2double(value);
            continue;
        end
        if contains(par,'START')
            conf.START = str2num(value);
            continue;
        end
        if contains(par,'STEP')
            conf.STEP = str2num(value);
            continue;
        end
        if contains(par,'DEBUG')
            conf.DEBUG = str2num(value);
            continue;
        end
        if contains(par,'p1')
            conf.p1 = str2num(value);
            continue;
        end
        if contains(par,'p2')
            conf.p2 = str2num(value);
            continue;
        end
        if contains(par,'nastran')
            conf.nastran = value;
            continue;
        end
        if contains(par,'is_it_start')
            conf.is_it_start = value;
            continue;
        end
        if contains(par,'nas_param')
            conf.nas_param = value;
            continue;
        end
    end
    
    fclose(f);
    print_struct(conf);
end

function print_struct(conf)
fprintf(1,'#####################################################\n');
fprintf(1, '1) Имя файла модели, которая будет уточнена\n');
fprintf(1, 'in_file = %s\n', conf.in_file );
fprintf(1, '2) Имя файла с результатами расчета\n');
fprintf(1, 'f06_file = %s\n', conf.f06_file );
fprintf(1, '3) Имя файла с изменёнными жесткостями\n');
fprintf(1, 'out_file = %s\n', conf.out_file );
fprintf(1, '4) Имя файла с расчетными частотами\n');
fprintf(1, 'freq_rek_file = %s\n', conf.freq_rek_file );
fprintf(1, '5) Имя файла с тестовыми частотами\n');
fprintf(1, 'freq_test_file = %s\n', conf.freq_test_file );
fprintf(1, '6) Путь к папке в которой будут хранится рпезультаты уточнения\n');
fprintf(1, 'path = %s\n', conf.path );
fprintf(1, '7) масштабный множитель (исопльзуется дли изменения скорости сходимости). Может быть изменен по ходу уточнения \n');
fprintf(1, 'kof = %f\n', conf.kof );
fprintf(1, '8) максиамльное/минимальное изменение в %% жесткости на любой итерации\n');
fprintf(1, 'ch_up = %f\n', conf.ch_up );
fprintf(1, 'ch_down = %f\n', conf.ch_down );
fprintf(1, '9) global changeable максиамльное/минимальное изменение жесткости в %% от первоначального значения (на первой итерации)\n');
fprintf(1, 'g_ch_max = %f\n', conf.g_ch_max);
fprintf(1, 'g_ch_min = %f\n', conf.g_ch_min);
fprintf(1, '10) Начинать с итерации номер 1\n');
fprintf(1, 'START = %d\n', conf.START);
fprintf(1, '11) Выполнять итерации до 100\n');
fprintf(1, 'STEP = %d\n', conf.STEP);
fprintf(1, '12) Включен режим отладки\n');
fprintf(1, 'DEBUG = %d\n', conf.DEBUG);
fprintf(1, '13) Включено ведение log-файла\n');
fprintf(1, 'LOG = %d\n', conf.LOG);
fprintf(1, '14)  ожидание результата сразу после запуска в секундах\n');
fprintf(1, 'p1 = %d\n', conf.p1);
fprintf(1, '15)  интервал запросов состояния nastran в секундах\n');
fprintf(1, 'p2 = %d\n', conf.p2);
fprintf(1, '16) Путь до решателя \n');
fprintf(1, 'nastran = %s\n', conf.nastran );
fprintf(1, '17)  Имя решателя в консоли после запуска\n');
fprintf(1, 'is_it_start = %s\n', conf.is_it_start );
fprintf(1, '18) Параметры решателя\n');
fprintf(1, 'nas_param = %s\n', conf.nas_param );
fprintf(1, '19) Коэффициент значимости частот\n');
fprintf(1, 'freq_scale = %d\n', conf.freq_scale );
fprintf(1,'#####################################################\n');
end

% function bres = contains(str1,str2)
% 
%     bres = size( strfind(str1,str2) );
% 
% end