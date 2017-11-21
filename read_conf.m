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
        if contains(par,'kof')
            conf.kof = str2double(value);
            continue;
        end
        if contains(par,'ch')
            conf.ch = str2double(value);
            continue;
        end
        if contains(par,'g_ch')
            conf.g_ch = str2double(value);
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
end