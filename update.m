function c = update(f_freq_r, f_freq_t, c, energy, c_start, conf)
    fprintf(1, '---------START--------\n');
    fprintf(1, 'update\n');
    
    if check_stiffnes(c, conf) == 1
        fprintf(2, 'Spring elem mast have stifnes in one directions!\n');
        fprintf(2, 'In common case spring has 6 stiffnes (kx, ky, ... ). This way not work!\n');
        error('Can NOT UPDATE model becouse properties of BUSH elements has more then one parametr.');
    end
    
    ct = c;
    ct(ct<0) = 0;
    stiffnes = sum(ct');
    index = sign(ct);
    
    ct = c_start;
    ct(ct<0) = 0;
    start_stiffnes = sum(ct');
    
    kof = conf.kof
%     c_min = min(mean(c'));
%   Считывание собственных частот экспериментальных и расчетных
    f = fopen(f_freq_t, 'r');
    if f == -1
        error('Can not open file %s\n', f_freq_t);
    end
%     str = ' ';
    count = 0;
    while ~feof(f)
        fgets(f);
        count = count + 1;
    end
    fseek(f,0,'bof');
    freq_test = zeros(count,1);
    freq_reckon = zeros(count,1);
    for i = 1:count
        str = fgets(f);
        freq_test(i) = sscanf(str,'%f');
    end
    fclose(f);

    f = fopen(f_freq_r, 'r');
    for i = 1:count
        str = fgets(f);
%         fprintf(1, 'str = %s', str);
        freq_reckon(i) = sscanf(str,'%f');
    end
    fclose(f);
    
    fprintf(1, '№  reckon freq => test freq\n');
    for i = 1:length(freq_reckon)
        fprintf(1, '%d) %f Hz => %f Hz\n', i, freq_reckon(i), freq_test(i));
    end
   
    n_dof = 6;
    height = length(stiffnes);
    width = length(freq_reckon);
    if conf.DEBUG > 0
        dlmwrite([f_freq_r(1:end-4) '.Stiffnes_in.txt'] , c, '\t');
        dlmwrite([f_freq_r(1:end-4) '.Stiffnes_in_vector.txt'] , stiffnes, '\t');
    end
    
    count_max = 0;
    count_min = 0;
    ch_up_max = 0;
    ch_down_max = 0;
 
    alpha = zeros(height,width);
    for i = 1:height
        for j = 1:width
            if stiffnes(i) > 0
                alpha(i,j) = energy(i,j) / freq_reckon(j) / stiffnes(i);
%                   fprintf('energy(i=%d,j=%d) = %f freq_reckon(j) = %f c(i, k) = %f alpha(i,j) = %3.5f\n', i, j, energy(i,j), freq_reckon(j), c(i, k), alpha(i,j));
            else
                alpha(i,j) = 0;
            end
        end
    end
    format long

    delta_freq = freq_test - freq_reckon;
 
%     alpha = alpha';
    for j = 1:width
        alpha(:,j) = alpha(:,j) * conf.freq_scale(j);
    end
    if conf.DEBUG > 2
        dlmwrite([f_freq_r(1:end-4) '-alpha.txt'] , alpha, '-append', 'delimiter',' ','roffset',1);
    end    
%     Масштабный множитель - учитывает значимость частот
%     alpha
%     pinv(alpha)'
    delta = pinv(alpha)' * delta_freq;
    if kof > -10
        delta = delta * kof;
    end

%       Проверка шага изменения жёсткости в большую сторону
    if conf.ch_up > 0
        for m = 1:height
            if delta(m) >= stiffnes(m)* conf.ch_up
                delta(m) = stiffnes(m) * conf.ch_up;
                ch_up_max = ch_up_max + 1;
            end
        end
    end
%       Проверка шага изменения жёсткости в меньшую сторону
    if conf.ch_down > 0
        for m = 1:height
            if delta(m) <= stiffnes(m)* conf.ch_down
                delta(m) = stiffnes(m) * conf.ch_down;
                ch_down_max = ch_down_max + 1;
            end
        end
    end


    for m = 1:height
       fprintf(1, 'A: stiffnes(%d) = %f delta = %f\n', m, stiffnes(m), delta(m));
       stiffnes(m) = stiffnes(m) + delta(m);
       fprintf(1, 'B: stiffnes(%d) = %f\n', m, stiffnes(m));
%           Если жестоксть превышает жесткость на первой итерации в
%           conf.g_ch_max раз, то вносится ограничение
        if conf.g_ch_max > 1
            if stiffnes(m) > start_stiffnes(m)* conf.g_ch_max
                stiffnes(m) = start_stiffnes(m)* conf.g_ch_max;
                fprintf(1, '   MAX: stiffnes(%d) = %f\n', m, stiffnes(m));
                count_max = count_max + 1;
            end
        end
%           Если жестоксть меньше чем жесткость на первой итерации в
%           conf.g_ch_min раз, то вносится ограничение
        if and(conf.g_ch_min > 0, conf.g_ch_min < 1)
            if stiffnes(m) < start_stiffnes(m) * conf.g_ch_min
                 stiffnes(m) = start_stiffnes(m)* conf.g_ch_min;
                 fprintf(1, '   MIN: stiffnes(%d) = %f\n', m, stiffnes(m));
                 count_min = count_min + 1;
            end
        end
        fprintf(1, '\n');
    end
    if conf.DEBUG > 1
        dlmwrite([f_freq_r(1:end-4) '-delta.txt'], delta,'-append', 'delimiter',' ','roffset',1);
    end

    fprintf(1, '\nMAX/MIN value reached for %d/%d elements\n', count_max, count_min);
    fprintf(1, 'Max delta to UP/DOWN reached %d/%d elements\n', ch_up_max, ch_down_max);

    c = mt(index, stiffnes);
        
    if conf.DEBUG > 0
        dlmwrite([f_freq_r(1:end-4) '.Stiffnes_out.txt'] , c, '\t');
        dlmwrite([f_freq_r(1:end-4) '.Stiffnes_out_vector.txt'] , stiffnes, '\t');
    end
       
    fprintf(1, 'update\n');
    fprintf(1, '----------END---------\n');
end

function [bool] = check_stiffnes(c, conf)
    len = size(c,1);
    if conf.DEBUG > 4
        fprintf(1,'len = %d\n',len);
    end

    for i=1:len
        n = 0;
        for j = 1:6
            if c(i,j) > 0
                n = n + 1;
            end
            if n >= 2
                bool = 1;
                return 
            end
            if conf.DEBUG > 4
                fprintf(1, 'c(%d, %d) = %f n = %d\n', i, j, c(i,j), n);
            end        
        end
    end
    bool = 0;
    return;
end

function m = mt(M, v)
    len = size(M,1);
    m = zeros(len, size(M,2));
    for i=1:len
%         M(i,:)
        m(i,:) = M(i,:) * v(i);
    end
end