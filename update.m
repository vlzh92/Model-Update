function c = update(f_freq_r, f_freq_t, c, energy, kof, changeable)
    fprintf(1, '---------START--------\n');
    fprintf(1, 'update\n');
    
%     c_min = min(mean(c'));
%   —читывание собственных частот экспериментальных и расчетных
    f = fopen(f_freq_t, 'r');
    if f == -1
        error('Can not open file %s\n', f_freq_t);
    end
    str = ' ';
    count = 0;
    while ~feof(f)
        str = fgets(f);
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
    
    fprintf(1, 'є  reckon freq => test freq\n');
    for i = 1:length(freq_reckon)
        fprintf(1, '%d) %f Hz => %f Hz\n', i, freq_reckon(i), freq_test(i));
    end
    
%     c(c==0) = 0.0001;
    % fprintf(1, 'length(res(:,1)) = %d\n', length(energy(2:end,1)));
    % fprintf(1, 'length(c) = %d\n', length(c));
%     rest = energy';
    % fprintf(1, 'length(resT(:,1)) = %d\n', length(rest(:,1)));
    width = length(freq_reckon);
    higth = length(energy(:,1));
%     fprintf(1,'width = %d\nhigth = %d\n', width, higth);
    % size(alpha)
%     size(c)
%     energy
    dlmwrite([f_freq_r(1:end-4) '.Stiffnes_in.txt'] , c, '\t');
    for k=1:6
        alpha = zeros(higth,width);
        for i = 1:higth
            for j = 1:width
                if c(i, k) ~= 0
                    alpha(i,j) = energy(i,j) / freq_reckon(j) / c(i, k);
%                     fprintf('energy(i=%d,j=%d) = %f freq_reckon(j) = %f c(i, k) = %f alpha(i,j) = %3.5f\n', i, j, energy(i,j), freq_reckon(j), c(i, k), alpha(i,j));
                else
                    alpha(i,j) = 0;
                end
            end
        end
        format long
        dlmwrite([f_freq_r(1:end-4) '.alpha.txt'] , alpha, '-append');
%         alpha
%         pinv(alpha)
%    fprintf('Energy\n');
%     energy
%    fprintf('alpha\n');
%    alpha'
%    fprintf('pinv(alpha)\n');
%    pinv(alpha')
%    fprintf('delta_freq\n');
%    freq_test - freq_reckon
%    fprintf('kof \n');
%    kof
%    fprintf('res\n')
%    pinv(alpha') * (freq_test - freq_reckon) * kof
%         size(alpha)
        delta = pinv(alpha)' * (freq_test - freq_reckon) * kof;
        if changeable && max(delta) ~= 0            
            kof2 = max(c(1:end,k)) * changeable/ max(abs(delta)) / 100;
            fprintf('Calculate kof2 = %f\n', kof2);
            delta = delta * kof2;
        end
        c(1:end,k) = c(1:end,k) + delta;
        dlmwrite([f_freq_r(1:end-4) '.Delta.txt'], delta,'-append');
    end
    c(c<100000) = 100000;
    dlmwrite([f_freq_r(1:end-4) '.Stiffnes_out.txt'] , c, '\t');
    fprintf(1, 'update\n');
    fprintf(1, '----------END---------\n');
end

